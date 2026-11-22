#!/usr/bin/env python3
"""장면 컷 요청문(편마다 1컷 — 반전 턴 순간)을 만든다. 심사 준비 기준 「회화 그림 10장」(사용자 2026-11-18, ja 전달).
  python3 tools/scene_prompts_de.py <편id> ...   → data/review/art/scene_<편>.md
첨부 1 = data/review/art/chars_de_v1.jpg(인물 시트), 첨부 2 = ref_tone_clay.jpg(톤)."""
import glob, json, sys
CAST = {'{name}': '시트 5번 남자 학습자(갈색 곱슬머리, 구리색 후드티, 베이지 바지, 갈색 백팩)',
        'Mia': '시트 1번 Mia(구릿빛 웨이브 단발·주근깨, 검은 크롭 데님 재킷·머스터드 티)',
        'Lena': '시트 2번 Lena(금발 낮은 묶음, 동그란 금테 안경, 올리브 트렌치코트)',
        'Felix': '시트 3번 Felix(짙은 갈색 옆가르마·짧은 턱수염, 네이비 체크 셔츠·체크 앞치마)',
        'Jonas': '시트 4번 Jonas(부스스한 애쉬블론드, 회색 후드·초록 바람막이, 가장 큼)'}
for id_ in sys.argv[1:]:
    e = json.load(open(glob.glob(f'assets/data/dialogues/R*/*/{id_}.json')[0], encoding='utf-8'))
    n = int(e['twist']); ts = e['turns']
    pair = [t for t in ts if t['num'] in (n - 1, n)]
    who = lambda k: CAST.get(e['speakers'][k], f"{e['speakers'][k]}(시트에 없는 조연 — 역할에 맞는 차림의 독일 사람, 같은 점토 톤, 실존 인물 닮지 않게)")
    lines = ' / '.join(f"{e['speakers'][t['speaker']].replace('{name}', '학습자')}: {t['ko']}" for t in pair)
    cast = ', '.join(f'{k} = {who(k)}' for k in e['speakers'])
    p = (f"[SC-DE-{id_}] **이미지 1장을 생성해 주세요**(글 설명 없이 그림만). 독일어 학습 앱 회화의 장면 컷입니다.\n"
         f"첨부 1 = 우리 앱 인물 기준 그림(이 인물들의 얼굴·머리·옷을 그대로), 첨부 2 = 그림 톤 참고.\n"
         f"톤: 부드러운 펠트·점토 인형, 파스텔·크림 톤, 둥근 얼굴, 따뜻한 조명, 독일(베를린)의 실제 장소 느낌. 3:2 가로. "
         f"**그림 안에 글자·말풍선·간판 글씨·로고 없음**. 실존 인물·브랜드 금지. 수위 12+.\n"
         f"장면: {e['scene']}\n등장: {cast}\n"
         f"그릴 순간(대사는 그리지 말고 표정·동작·장소만): {lines}\n지금 바로 이미지 1장을 생성하세요.")
    open(f'data/review/art/scene_{id_}.md', 'w', encoding='utf-8').write(p)
    print(id_, len(p))
