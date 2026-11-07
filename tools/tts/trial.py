#!/usr/bin/env python3
"""독일어 음성 개선 시험(2026-11-07, docs/AUDIO_QA_DE.md ②③⑤): r1_survival_s1 을 MOSS 개선판·VoxCPM2 판으로 만들고 r2_love_b1 11번을 다시 만든다. D1 은 건드리지 않는다.
  TTS_OUT=de_v2 <venv>/bin/python tools/tts/trial.py <작업폴더>      venv = mlx-whisper 가 있는 파이썬. PC 는 한 번에 한 세션 — uk 의 "지금 시작" 뒤에 돌린다.
순서: 참고 음성(잡음 -60dB·음색 상관 0.90 미달은 seed 를 바꿔 세 번까지) → 문장 → 받아쓰기 검사·재생성 → 묶어서 R2 → 리뷰 페이지."""
import glob, json, os, shutil, subprocess, sys, time
import numpy as np
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
            sh('ssh', PC, f'Remove-Item D:\\tts_test\\job\\{n} -ErrorAction SilentlyContinue', check=False)
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


def timbre(f):
    o = subprocess.run(['ffmpeg', '-v', 'error', '-i', f, '-ac', '1', '-ar', '16000', '-f', 'f32le', '-'], capture_output=True).stdout
    x = np.frombuffer(o, np.float32); n = 512
    fr = np.lib.stride_tricks.sliding_window_view(x, n)[::160] * np.hanning(n)
    e = np.sqrt((fr ** 2).mean(1)); fr = fr[e > e.max() * .1]
    S = np.abs(np.fft.rfft(fr, axis=1)) ** 2
    B = np.log(np.stack([S[:, b].mean(1) for b in np.array_split(np.arange(S.shape[1]), 24)], 1) + 1e-9)
    return B.mean(0) - B.mean()


def ref_bad(f):
    """참고 음성 기준(§5): 무음 구간 잡음 ≤ -60dB, 같은 목소리 기본 음성과 음색 상관 ≥ 0.90."""
    why = []
    n = qa.floor(f)
    if n is not None and n > -60:
        why.append(f'잡음 {n:.1f}')
    name = os.path.basename(f)[:-4].split('.')[0]; base = f"{refd}/{name.rsplit('_', 1)[0]}_base.wav"
    if not name.endswith('_base'):
        c = float(np.corrcoef(timbre(f), timbre(base))[0, 1])
        if c < .90:
            why.append(f'음색 {c:.2f}')
    return why


vox = {os.path.basename(j['out']): j for j in json.load(open(f'{job}/vox_jobs.json', encoding='utf-8'))}
for rnd in range(1, 4):
    bad = {os.path.basename(f): ref_bad(f) for f in sorted(glob.glob(f'{refd}/*.wav'))}
    bad = {k: v for k, v in bad.items() if v}
    log('참고 음성 미달', rnd, bad)
    if not bad:
        break
    clear()
    json.dump([{**vox[k], 'out': f"{vox[k]['out'][:-4]}.t{rnd}.wav", 'seed': 42 + 97 * rnd} for k in bad], open(f'{job}/vox_jobs.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
    pc_run()
    for k in bad:
        c = f'{refd}/{k[:-4]}.t{rnd}.wav'
        sh('scp', '-q', f"{PC}:D:/tts_test/job/out/{L.REF}/{k[:-4]}.t{rnd}.wav", c, check=False)
        if os.path.exists(c):
            if len(ref_bad(c)) < len(bad[k]) or not ref_bad(c):
                os.replace(c, f'{refd}/{k}')
                sh('scp', '-q', f'{refd}/{k}', f'{PC}:D:/tts_test/job/out/{L.REF}/{k}')
            elif os.path.exists(c):
                os.remove(c)
left = {os.path.basename(f): ref_bad(f) for f in sorted(glob.glob(f'{refd}/*.wav')) if ref_bad(f)}
log('참고 음성 끝, 남은 미달', left)

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
