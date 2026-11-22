# -*- coding: utf-8 -*-
"""Grok 그림 요청 한 건(PC 크롬 9258, 「빠른」): 새 챗 또는 기존 챗 → 첨부 → 요청문 → 새 그림(assets.grok.com, 가로 300px 이상)이 올 때까지(최대 3분) → 첫 그림 저장.
  GROK_CDP_PORT=9258 python3 tools/grok_image_pc.py <요청문.md> <저장.jpg> [첨부 ...] [--chat <챗 주소>]
첨부는 grok_text.py 처럼 PC D:\\grok_att\\de\\ 로 보낸 뒤 붙인다. 한도 문구면 종료 코드 3, 그림 없으면 2. 마지막 줄 `CHAT <주소>`. 끝나면 탭을 닫는다."""
import base64, json, os, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grok_cdp as G
from grok_text import new_tab, close_tab, PC_ATT

IMGS = "[...document.querySelectorAll('img')].filter(i=>i.src.includes('assets.grok.com')&&i.src.includes('/generated/')&&i.naturalWidth>=300).map(i=>i.src)"


def main():
    a = sys.argv[1:]
    chat = ''
    if '--chat' in a:
        i = a.index('--chat'); chat = a[i + 1]; del a[i:i + 2]
    text, out, atts = open(a[0], encoding='utf-8').read().strip(), a[1], a[2:]
    remote = []
    if atts:
        subprocess.run(['ssh', 'pc', 'cmd /c if not exist D:\\grok_att\\de mkdir D:\\grok_att\\de'], check=False, capture_output=True)
        for p in atts:
            subprocess.run(['scp', '-q', p, 'pc:' + PC_ATT], check=True)
            remote.append((PC_ATT + os.path.basename(p)).replace('/', '\\'))
    t = new_tab(chat if chat else 'https://grok.com/')
    try:
        c = G.CDP(t)
        c.call('Page.bringToFront')
        for _ in range(40):
            if c.ev("!!(%s)" % G.FIND):
                break
            time.sleep(1)
        time.sleep(4)
        if remote:
            doc = c.call('DOM.getDocument', depth=-1, pierce=True)
            node = c.call('DOM.querySelector', nodeId=doc['root']['nodeId'], selector='input[type=file]')
            if not node.get('nodeId'):
                raise SystemExit('파일 입력 없음')
            c.call('DOM.setFileInputFiles', nodeId=node['nodeId'], files=remote)
            time.sleep(4 + 2 * len(remote))
        before = set(c.ev(IMGS) or [])  # 첨부 미리보기도 assets 그림이라 첨부 뒤에 센다
        model = c.ev("[...document.querySelectorAll('button')].map(b=>b.getAttribute('aria-label')||'').find(x=>/^모델/.test(x))||''")
        if '빠른' not in model:
            raise SystemExit('Grok 모델이 빠른 모드가 아님: ' + model)
        lim0 = c.ev("(document.body.innerText.match(/한도에 도달|limit reached/g)||[]).length")
        c.ev("(()=>{const e=%s;e.focus();return 1})()" % G.FIND)
        c.call('Input.insertText', text=text)
        time.sleep(1)
        for typ in ('keyDown', 'keyUp'):
            c.call('Input.dispatchKeyEvent', type=typ, key='Enter', code='Enter', windowsVirtualKeyCode=13, nativeVirtualKeyCode=13)
        time.sleep(3)
        left = c.ev("(()=>{const e=%s;return e?(e.value||e.innerText||'').trim().length:-1})()" % G.FIND)
        if left and left > 0:
            c.ev("(()=>{const b=[...document.querySelectorAll('button')].find(x=>/제출|보내기|Submit|Send/.test(x.getAttribute('aria-label')||''));if(b){b.click();return 1}return 0})()")
        url, t0, seen = None, time.time(), 0
        while time.time() - t0 < 180:  # 사용자 지시: Grok 은 3분까지만
            time.sleep(10)
            if (c.ev("(document.body.innerText.match(/한도에 도달|limit reached/g)||[]).length") or 0) > lim0:
                print('LIMIT'); sys.exit(3)
            new = [s for s in (c.ev(IMGS) or []) if s not in before]
            busy = c.ev("!![...document.querySelectorAll('button')].find(e=>(e.getAttribute('aria-label')||'')==='응답 중지')")
            if new and not busy:
                seen += 1
                if seen >= 2:
                    url = new[0]; break
        href = c.ev('location.href')
        if not url:
            c.ev("(()=>{const b=[...document.querySelectorAll('button')].find(e=>/중지|stop/i.test(e.getAttribute('aria-label')||''));if(b)b.click()})()")
            print('그림 없음'); print('CHAT', href); sys.exit(2)
        d = c.ev("fetch(%s,{credentials:'include'}).then(r=>r.blob()).then(b=>new Promise(ok=>{const f=new FileReader();f.onload=()=>ok(f.result);f.readAsDataURL(b)}))" % json.dumps(url))
        os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
        open(out, 'wb').write(base64.b64decode(d.split(',', 1)[1]))
        print('저장', out); print('CHAT', href)
    finally:
        close_tab(t)


if __name__ == '__main__':
    main()
