#!/usr/bin/env python3
"""독일어 음성 개선 시험(2026-11-07, docs/AUDIO_QA_DE.md ②③⑤): r1_survival_s1 을 MOSS 개선판·VoxCPM2 판으로 만들고 r2_love_b1 11번을 다시 만든다. D1 은 건드리지 않는다.
  TTS_OUT=de_v2 <venv>/bin/python tools/tts/trial.py <작업폴더>      venv = mlx-whisper 가 있는 파이썬. PC 는 한 번에 한 세션 — uk 의 "지금 시작" 뒤에 돌린다.
순서: 참고 음성(잡음 바닥 -60dB 넘으면 내려받아 잡음을 줄여 되돌림) → 문장 → 받아쓰기 검사·재생성 → 묶어서 R2 → 리뷰 페이지."""
import glob, json, os, shutil, subprocess, sys, time
import ttslib as L
import qa
PC = 'Administrator@100.127.143.37'; HERE = os.path.dirname(os.path.abspath(__file__))
EP, FIX, FIXTURN = 'r1_survival_s1', 'r2_love_b1', '11_0_c.wav'
work = sys.argv[1]; job = f'{work}/job_v2'; wav = f'{work}/wav_v2'; refd = f'{work}/ref_v2'
for d in (job, f'{wav}/retake', refd):
    os.makedirs(d, exist_ok=True)
log = lambda *a: print(time.strftime('%H:%M:%S'), *a, flush=True)


def sh(*a, check=True, **k):
    return subprocess.run(a, check=check, capture_output=True, text=True, **k)


def state():
    return sh('ssh', PC, "(Get-ScheduledTask -TaskName 'TTS job 2060').State", check=False).stdout


def pc_run():
    while 'Ready' not in state():
        time.sleep(30)
    for n in ('vox_jobs.json', 'moss_jobs.json'):
        if os.path.exists(f'{job}/{n}'):
            sh('scp', '-q', f'{job}/{n}', f'{PC}:D:/tts_test/job/')
        else:
            sh('ssh', PC, f'Remove-Item D:\\tts_test\\job\\{n} -ErrorAction SilentlyContinue')
    sh('ssh', PC, "Start-ScheduledTask -TaskName 'TTS job 2060'")
    time.sleep(20)
    while 'Ready' not in state():
        time.sleep(30)


def fetch(path, dst):
    os.makedirs(dst, exist_ok=True)
    sh('scp', '-q', '-r', f'{PC}:D:/tts_test/job/out/{L.OUT}/{path}', dst + '/', check=False)


def clear():
    for n in ('vox_jobs.json', 'moss_jobs.json'):
        if os.path.exists(f'{job}/{n}'):
            os.remove(f'{job}/{n}')


# 1. 참고 음성
clear()
sh(sys.executable, f'{HERE}/make_plan.py', EP)
log(sh(sys.executable, f'{HERE}/make_jobs.py', job, '--refs', EP, FIX).stdout.strip())
pc_run()
sh('scp', '-q', f'{PC}:D:/tts_test/job/out/{L.REF}/*.wav', refd + '/', check=False)
for f in sorted(glob.glob(f'{refd}/*.wav')):
    n = qa.floor(f)
    if n > -60:
        o = f + '.dn.wav'
        sh('ffmpeg', '-y', '-v', 'error', '-i', f, '-af', 'afftdn=nf=-40,highpass=f=60', o)
        os.replace(o, f)
        sh('scp', '-q', f, f'{PC}:D:/tts_test/job/out/{L.REF}/')
        log('잡음 줄임', os.path.basename(f), round(n, 1), '→', round(qa.floor(f), 1))
log('참고 음성 끝')

# 2. 문장 — MOSS 개선판 + VoxCPM2 판 + 11번
clear()
eps = [EP, EP + L.VOX]
log(sh(sys.executable, f'{HERE}/make_jobs.py', job, *eps).stdout.strip())
moss = json.load(open(f'{job}/moss_jobs.json', encoding='utf-8'))
fix = next(x for x in L.seg_files(FIX) if x[0] == FIXTURN)
moss.append(L.job(FIX, *fix))
json.dump(moss, open(f'{job}/moss_jobs.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
pc_run(); log('생성 끝')
for e in eps + [FIX]:
    fetch(e, wav)

# 3. 검사·재생성
for rnd in range(3):
    jobs = []
    for e in eps:
        q = f'{job}/qa_{e}.json'
        try:
            r = subprocess.run([sys.executable, f'{HERE}/qa.py', wav, e, '--jobs', q], capture_output=True, text=True, timeout=600)
            log(e, r.stdout.strip() or r.stderr.strip()[-300:])
        except subprocess.TimeoutExpired:
            log('TIMEOUT', e); continue
        if os.path.exists(q):
            jobs += json.load(open(q, encoding='utf-8')); os.remove(q)
    s, _ = qa.score(f'{wav}/{FIX}/{FIXTURN}', fix[3])
    log('11번', round(s, 2))
    if s < qa.PASS:
        jobs.append({**L.job(FIX, *fix, out=f'{L.OUT}/retake/{FIX}/11_0_c.t{rnd + 1}.wav'), 'seed': 42 + 97 * (rnd + 1)})
    if not jobs:
        break
    clear()
    for n, x in (('moss_jobs.json', [j for j in jobs if 'language' in j]), ('vox_jobs.json', [j for j in jobs if 'language' not in j])):
        if x:
            json.dump(x, open(f'{job}/{n}', 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
    pc_run()
    for e in eps + [FIX]:
        fetch(f'retake/{e}', f'{wav}/retake')
    for c in glob.glob(f'{wav}/retake/{FIX}/11_0_c.t*.wav'):
        if qa.score(c, fix[3])[0] > s:
            shutil.copy(c, f'{wav}/{FIX}/{FIXTURN}')
        os.remove(c)
log('PC 끝')

# 4. 올리기(R2 만) — 11번은 기존 r2 조각에 넣어 다시 묶는다
shutil.copy(f'{wav}/{FIX}/{FIXTURN}', f'{work}/wav/{FIX}/{FIXTURN}')
for w, e in ((wav, EP), (wav, EP + L.VOX), (f'{work}/wav', FIX)):
    r = sh(sys.executable, f'{HERE}/pack.py', w, e, '--upload', '--no-db', check=False)
    log(r.stdout.strip() or (r.stderr or '')[-300:])
log('끝')
