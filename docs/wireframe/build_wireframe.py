"""AppScout 와이어프레임 HTML 생성기

사용법 (저장소 루트에서):
  python3 docs/wireframe/build_wireframe.py docs/wireframe/index.html
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --no-pdf-header-footer --virtual-time-budget=5000 \
    --print-to-pdf=docs/wireframe/AppScout_Wireframe.pdf "file://$PWD/docs/wireframe/index.html"

폰트: Pretendard가 시스템에 설치돼 있어야 PDF에 반영된다 (Projects/Shared/DesignSystem/Resources/Fonts).

레드라인: 폰 안 요소에 rl("h:44;ml:20") 처럼 붙이면 redline.js가 인쇄 직전에 실제 위치를 재서 분홍 치수선을 그린다.
숫자는 실제 구현 값(pt). 문법은 redline.js 맨 위 주석 참고. Chrome 명령에 --virtual-time-budget=5000 을 붙여 스크립트가 끝난 뒤 인쇄되게 한다.
"""
import sys
from pathlib import Path

OUT = Path(sys.argv[1])
TOTAL = 16
DATE = "2026-11-10"

STATUS = '<div class="status"><span>9:41</span><span class="island"></span><span>▮▮▮ ◔</span></div>'
HOME = '<div class="home"></div>'


def tabbar(active):
    items = [("search", "⌕", "검색"), ("fav", "♡", "즐겨찾기"), ("profile", "◯", "프로필")]
    spans = "".join(f'<span class="{"on" if k == active else ""}"><i>{i}</i>{t}</span>' for k, i, t in items)
    return f'<div class="tabbar">{spans}</div>{HOME}'


CALLOUT_RE = __import__("re").compile(r'<span class="n callout" style="top:(\d+)px;left:(\d+)px">(\w+)</span>')


def phone(label, inner, cls="", note=""):
    # 번호 원은 폰 안쪽 내용을 가리지 않도록 폰 테두리(왼쪽/오른쪽) 위로 옮긴다.
    width = 190 if "sm" in cls else 210
    marks = []
    for top, left, num in CALLOUT_RE.findall(inner):
        x = -7 if int(left) < width / 2 else width - 7
        marks.append(f'<span class="n callout" style="top:{top}px;left:{x}px">{num}</span>')
    inner = CALLOUT_RE.sub("", inner)
    return f'''<div class="phone-wrap" style="position:relative"><div class="phone {cls}">{inner}</div>{"".join(marks)}
<div class="phone-label">{label}</div>{f'<div class="s" style="max-width:210px;text-align:center">{note}</div>' if note else ""}</div>'''


def n(num, top, left):
    return f'<span class="n callout" style="top:{top}px;left:{left}px">{num}</span>'


def page(no, title, sub, body, tag=""):
    return f'''<section class="page">
<div class="page-head"><span class="no">p.{no}</span><h1>{title}</h1><span class="sub">{sub}</span><span class="tag">{tag}</span></div>
<div class="body">{body}</div>
<div class="page-foot"><span>AppScout 와이어프레임 v1.0 · {DATE}</span><span>{no} / {TOTAL}</span></div>
</section>'''


def app_row(name="앱 이름", sub="장르 · 개발사", stars="★★★★☆", score="4.5 · 1.2만", trailing="", row_rl="", icon_rl=""):
    return f'''<div class="row"{rl(row_rl) if row_rl else ""}><div class="icon"{rl(icon_rl) if icon_rl else ""}></div><div class="lines"><div class="t">{name}</div><div class="s">{sub}</div>
<div class="stars">{stars}<em>{score}</em></div></div>{trailing}</div>'''


def spec_table(rows, head=("#", "컴포넌트", "설명 · 제약")):
    th = "".join(f"<th>{h}</th>" for h in head)
    trs = "".join("<tr>" + "".join(f"<td>{c}</td>" for c in r) + "</tr>" for r in rows)
    return f"<table><tr>{th}</tr>{trs}</table>"


def ul(items):
    return "<ul>" + "".join(f"<li>{i}</li>" for i in items) + "</ul>"


def rl(spec):
    """레드라인 치수 속성. 문법은 redline.js 맨 위 주석 참고. 숫자는 실제 구현 값(pt)."""
    return f' data-rl="{spec}"'


def nn(x):
    return f'<span class="n">{x}</span>'


pages = []

# ---------------------------------------------------------------- p.1 표지
pages.append(f'''<section class="page" style="justify-content:space-between">
<div>
  <div style="display:flex;align-items:center;gap:14px;margin-top:18mm">
    <div style="width:64px;height:64px;border-radius:15px;background:linear-gradient(135deg,#4F46E5,#0F766E);display:flex;align-items:center;justify-content:center;color:#fff;font-size:34px;font-weight:800">⌕</div>
    <div><div style="font-size:34px;font-weight:800;letter-spacing:-1px">AppScout</div>
    <div style="font-size:14px;color:#4B5563">TCA 복습 프로젝트 · 화면 와이어프레임</div></div>
  </div>
  <div style="margin-top:10mm;display:flex;gap:30px;font-size:11px">
    <div><b>버전</b><br>v1.0 ({DATE})</div>
    <div><b>대상</b><br>iOS 17.0+ (iOS 26 Liquid Glass 대응)</div>
    <div><b>범위</b><br>검색 · 최근 검색어 · 결과 · 상세 · 즐겨찾기 · 프로필 편집 · 설정</div>
    <div><b>관련 문서</b><br>docs/feature-guide.md · docs/design-system.md · docs/backend.md</div>
  </div>
</div>
<div class="cols" style="margin-bottom:10mm">
  <div>
    <h2 style="font-size:13px;margin-bottom:6px">목차</h2>
    <table style="width:100%;font-size:10.5px;border-collapse:collapse">
      {"".join(f'<tr><td style="padding:2px 0;width:40px;color:#4F46E5;font-weight:800">p.{p}</td><td>{t}</td></tr>' for p, t in [
        (2, "화면 흐름도"), (3, "탭 구조 · 공통 규칙"), (4, "검색 — 초기 / 최근 검색어"),
        (5, "검색 — 입력 · 로딩 · 결과"), (6, "검색 — 결과 없음 · 에러"), (7, "결과 셀 · 무한 스크롤"),
        (8, "상세 — 로딩 · 상단 정보")])}
    </table>
  </div>
  <div>
    <h2 style="font-size:13px;margin-bottom:6px;visibility:hidden">목차</h2>
    <table style="width:100%;font-size:10.5px;border-collapse:collapse">
      {"".join(f'<tr><td style="padding:2px 0;width:40px;color:#4F46E5;font-weight:800">p.{p}</td><td>{t}</td></tr>' for p, t in [
        (9, "상세 — 스크린샷 · 정보 · 즐겨찾기"), (10, "즐겨찾기"), (11, "프로필"),
        (12, "이름 · 이메일 편집"), (13, "프로필 이미지 변경"), (14, "설정"),
        (15, "공통 컴포넌트 · 상태"), (16, "디자인 토큰 요약")])}
    </table>
  </div>
  <div class="note" style="flex:1.1">
    <b>읽는 법</b><br>
    · 화면 위 <span class="n">1</span> 번호는 오른쪽 명세표의 같은 번호와 대응합니다.<br>
    · <code>monospace</code> 글자는 TCA Action·State 이름 제안입니다. (구현 시 바꿔도 됨)<br>
    · 색·글꼴은 실제 디자인 토큰이 아니라 배치를 위한 회색조 표현입니다. 실제 값은 p.16 / design-system.md.<br>
    · 모든 문구(알럿·빈 상태)는 그대로 써도 되는 최종 문구입니다.<br>
    · 화면 위 <b style="color:#E5007E">분홍 선·숫자</b>는 실제 구현 치수(pt)입니다. 자세한 읽는 법은 p.3.
  </div>
</div>
<div class="page-foot"><span>AppScout 와이어프레임 v1.0 · {DATE}</span><span>1 / {TOTAL}</span></div>
</section>''')

# ---------------------------------------------------------------- p.2 흐름도
flow = '''<div class="flow" style="position:relative">
<svg width="100%" height="100%" style="position:absolute;inset:0" viewBox="0 0 1030 600" preserveAspectRatio="xMinYMin meet">
  <defs>
    <marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#111827"/></marker>
    <marker id="b" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#0F766E"/></marker>
  </defs>
  <g stroke="#111827" stroke-width="1.6" fill="none" marker-end="url(#a)">
    <path d="M190,80 L290,80"/>
    <path d="M470,80 L570,80"/>
    <path d="M190,250 L570,250" />
    <path d="M190,420 L290,420"/>
    <path d="M190,420 L250,420 L250,505 L290,505"/>
    <path d="M190,420 L250,420 L250,335 L290,335"/>
    <path d="M470,335 L570,335"/>
  </g>
  <g stroke="#0F766E" stroke-width="1.6" stroke-dasharray="6 4" fill="none" marker-end="url(#b)">
    <path d="M190,420 L230,420 L230,585 L290,585"/>
  </g>
  <g stroke="#4F46E5" stroke-width="1.4" stroke-dasharray="2 4" fill="none">
    <path d="M100,110 L100,215"/><path d="M100,280 L100,385"/>
  </g>
</svg>
<div class="box tab" style="left:10px;top:50px;width:180px"><b>① 검색 탭</b><small>p.4–7 · SearchFeature</small></div>
<div class="box" style="left:290px;top:50px;width:180px"><b>검색 결과 (같은 화면)</b><small>입력 → 디바운스 → 결과 · p.5–7</small></div>
<div class="box" style="left:570px;top:50px;width:200px"><b>앱 상세</b><small>push · AppDetailFeature · p.8–9</small></div>
<div class="box tab" style="left:10px;top:220px;width:180px"><b>② 즐겨찾기 탭</b><small>p.10 · FavoritesFeature</small></div>
<div class="box" style="left:570px;top:220px;width:200px"><b>앱 상세 (같은 리듀서 재사용)</b><small>push · 하트 해제 시 목록에서 즉시 사라짐</small></div>
<div class="box tab" style="left:10px;top:390px;width:180px"><b>③ 프로필 탭</b><small>p.11 · ProfileFeature</small></div>
<div class="box" style="left:290px;top:305px;width:180px"><b>설정</b><small>push (우상단 ⚙) · p.14</small></div>
<div class="box" style="left:570px;top:305px;width:200px"><b>확인 다이얼로그</b><small>최근 검색어 전체 삭제 · p.14</small></div>
<div class="box" style="left:290px;top:390px;width:180px"><b>이름 편집</b><small>push · p.12</small></div>
<div class="box" style="left:290px;top:475px;width:180px"><b>이메일 편집</b><small>push · p.12</small></div>
<div class="box" style="left:290px;top:555px;width:180px;border-color:#0F766E"><b>사진 선택 (PhotosPicker)</b><small>시스템 sheet · p.13</small></div>
<div style="position:absolute;right:0;top:40px;width:220px" class="spec">
  <h2>내비게이션 규칙</h2>
  <ul>
    <li>탭마다 독립된 <code>NavigationStack(path:)</code></li>
    <li>push 대상은 <code>@Reducer enum Path</code>로 선언</li>
    <li>편집 화면은 <code>@Dependency(\\.dismiss)</code>로 스스로 닫고, 결과는 <code>delegate</code> 액션으로 부모에게 전달</li>
    <li>탭 전환 시 각 탭의 스택은 유지</li>
    <li>시트 안에 NavigationStack을 둘 경우 루트에 <b>navigationTitle 필수</b> (iOS 26 바 점프 방지)</li>
  </ul>
  <h2 style="margin-top:6px">상태 보존</h2>
  <ul>
    <li>검색어·결과는 탭 전환 후에도 유지</li>
    <li>최근 검색어·즐겨찾기는 로컬 DB(SQLiteData) → 앱 재실행 후에도 유지</li>
    <li>프로필은 서버 저장 → 탭 진입 시 다시 조회</li>
  </ul>
</div>
</div>'''
pages.append(page(2, "화면 흐름도", "탭 3개와 push / sheet 관계", flow + '''''',
                  tag='<span class="legend"><span>━▶ push</span><span style="color:#0F766E">┅▶ sheet</span><span style="color:#4F46E5">··· 탭 전환</span></span>'))

# ---------------------------------------------------------------- p.3 탭 구조
p3_phone = phone("탭 구조 (검색 탭 선택)", f'''{STATUS}
<div class="nav"{rl("h:52")}><div class="large">검색</div><div class="right" style="top:14px"><span class="glass"{rl("t:44×44")}>⚙</span></div></div>
<div class="content"><div class="searchbar"{rl("ml:20;mr:20")}>⌕ 앱 이름이나 키워드를 검색해 보세요</div>
<div class="l w80"></div><div class="l w60"></div><div class="l w70"></div></div>
<div{rl("t:시스템 탭 바 · 직접 그리지 않음")} style="height:0"></div>{tabbar("search")}
{n(1, 30, 10)}{n(2, 410, 20)}{n(3, 66, 180)}''')
p3_spec = f'''<div class="spec">
<div class="note"><b>레드라인 읽는 법</b> · <span class="rl-legend"><i>44</i> 분홍 선 = 간격·크기 (pt)</span> &nbsp; <span class="rl-legend"><s>r 14</s> 테두리 배지 = 크기·모양·토큰 메모</span><br>
그림은 축소본이라 픽셀과 숫자가 다릅니다. <b>숫자(pt)를 기준으로</b> 구현하세요. 시스템이 그리는 요소(탭 바, 내비게이션 바, 알럿, 시트)는 치수를 적지 않았습니다.</div>
<h2>구성</h2>
{spec_table([
  (nn(1), "내비게이션 타이틀", "탭 루트는 <code>.navigationTitle</code> + <code>.toolbarTitleDisplayMode(.inlineLarge)</code> (왼쪽 큰 제목, 스크롤 시 축소). 텍스트를 툴바 아이템으로 넣지 않는다 (iOS 26에서 유리 버블에 갇힘)."),
  (nn(2), "탭 바", "검색 ⌕ / 즐겨찾기 ♡ / 프로필 ◯. 선택 색 <code>brandPrimary</code>. iOS 26에서는 시스템이 떠 있는 유리 탭 바로 그림 (직접 꾸미지 않음)."),
  (nn(3), "툴바 버튼", "아이콘 버튼은 시스템 기본 색을 따른다. <code>.foregroundStyle(.black)</code> 같은 고정 색 금지 (다크 모드에서 안 보임). 유리 버블을 숨기려면 <code>sharedBackgroundVisibility(.hidden)</code> (iOS 26+)."),
])}
<div class="cols">
<div><h2>레이아웃 공통</h2>{ul([
  "화면 좌우 여백 20pt (<code>DSSpacing.screenHorizontal</code>)",
  "최소 터치 영역 44×44pt",
  "리스트 셀 세로 여백 8pt, 셀 사이 구분선 0.5pt",
  "콘텐츠는 Safe Area 안. 배경색만 <code>ignoresSafeArea</code>",
  "세로 고정 (가로 회전 미지원)",
])}</div>
<div><h2>접근성 · 테마</h2>{ul([
  "모든 글자는 Dynamic Type 대응 (<code>.typography()</code>가 <code>relativeTo</code> 지정)",
  "라이트 / 다크 / 시스템 테마 (p.14 설정)",
  "색만으로 상태 구분 금지 (하트는 채움/빈 모양 + 라벨)",
  "아이콘 버튼은 <code>accessibilityLabel</code> 필수",
])}</div>
</div>
<h2>상태 표현 원칙 (모든 화면 공통, 자세한 모양은 p.15)</h2>
{spec_table([
  ("첫 로딩", "화면 가운데 <code>LoadingView</code>. 이미 데이터가 있으면 덮어쓰지 않고 유지"),
  ("추가 로딩", "목록 하단 작은 스피너 (페이지네이션)"),
  ("빈 상태", "<code>EmptyStateView</code> (아이콘 + 제목 + 설명 + 선택 버튼)"),
  ("에러 (화면)", "<code>ErrorStateView</code> + 다시 시도. 데이터가 없을 때만"),
  ("에러 (작업)", "알럿. 저장·삭제·토글처럼 사용자가 시킨 작업이 실패했을 때"),
], head=("상황", "표현"))}
</div>'''
pages.append(page(3, "탭 구조 · 공통 규칙", "RootFeature · 모든 화면에 적용", f'<div class="phones">{p3_phone}</div>{p3_spec}'))

# ---------------------------------------------------------------- p.4 검색 초기
p4a = phone("A. 최근 검색어 있음", f'''{STATUS}
<div class="nav"><div class="large">검색</div></div>
<div class="content"><div class="searchbar"{rl("gt:8;h:44;ml:20")}>⌕ 앱 이름이나 키워드를 검색해 보세요</div>
<div class="section"{rl("gt:12;h:44")}>최근 검색어 <a>전체 삭제</a></div>
{"".join(f'<div class="row"{rl("h:44") if i == 0 else ""}><span class="muted"{rl("gl:12") if i == 0 else ""}>↺</span><span>{w}</span><span class="end"{rl("t:✕ 44×44") if i == 1 else ""}>✕</span></div>' for i, w in enumerate(["카카오", "토스", "notion", "가계부", "날씨"]))}
</div>{tabbar("search")}
{n(1, 56, 4)}{n(2, 92, 4)}{n(3, 92, 160)}{n(4, 120, 4)}{n(5, 120, 186)}''')
p4b = phone("B. 최근 검색어 없음", f'''{STATUS}
<div class="nav"><div class="large">검색</div></div>
<div class="content"><div class="searchbar">⌕ 앱 이름이나 키워드를 검색해 보세요</div>
<div class="center" style="top:40px"><div class="big-ic"{rl("t:44pt · textTertiary")}>⌕</div><div class="t"{rl("gt:20")}>어떤 앱을 찾고 있나요?</div><div class="s">앱 이름, 개발사, 장르로 검색할 수 있어요.</div></div>
</div>{tabbar("search")}{n(6, 200, 30)}''')
p4_spec = f'''<div class="spec">
<h2>컴포넌트</h2>
{spec_table([
  (nn(1), "SearchBar", "플레이스홀더 “앱 이름이나 키워드를 검색해 보세요”. 키보드 리턴 키 <code>.search</code>. 최대 100자 (서버 제한과 동일)."),
  (nn(2), "섹션 헤더", "“최근 검색어”. 목록이 비면 헤더 자체를 숨김."),
  (nn(3), "전체 삭제", "탭 즉시 전체 삭제 (확인 없이). 설정 화면의 전체 삭제는 확인 다이얼로그 있음 (p.14)."),
  (nn(4), "최근 검색어 행", "탭 → 검색어를 입력창에 채우고 <b>즉시 검색</b> (디바운스 없이) + 검색 시각 갱신."),
  (nn(5), "개별 삭제 ✕", "44pt 터치 영역. 삭제 후 목록은 DB 관찰로 자동 갱신."),
  (nn(6), "빈 상태", "최근 검색어가 0개이고 검색어가 비어 있을 때."),
])}
<div class="cols">
<div><h2>제약사항</h2>{ul([
  "최대 <b>10개</b>, 최신순",
  "대소문자·앞뒤 공백이 달라도 같은 검색어 (“Kakao ” = “kakao”) → 맨 위로 이동, 표기는 마지막 입력값",
  "검색어 저장 시점: <b>제출(리턴 키)</b> 또는 최근 검색어 탭. 디바운스 자동 검색은 저장하지 않음",
  "공백뿐인 검색어는 저장·검색하지 않음",
])}</div>
<div><h2>TCA 제안</h2>{ul([
  "<code>onAppear</code>(.task)에서 <code>recentKeywordUseCase.observe()</code> 구독 → <code>recentKeywordsUpdated([RecentKeyword])</code>",
  "<code>recentKeywordTapped(RecentKeyword)</code>",
  "<code>recentKeywordDeleteTapped(id:)</code>",
  "<code>clearRecentKeywordsTapped</code>",
  "구독 Effect는 <code>.cancellable(id: CancelID.recentKeywords)</code>",
])}</div>
</div>
<div class="note"><b>테스트 포인트</b> · 구독 중 DB가 바뀌면 State가 갱신되는지 (<code>TestStore</code> + 가짜 스트림), 최근 검색어 탭 시 저장과 검색이 함께 일어나는지.</div>
</div>'''
pages.append(page(4, "검색 — 초기 / 최근 검색어", "검색어가 비어 있을 때", f'<div class="phones">{p4a}{p4b}</div>{p4_spec}', tag="SearchFeature"))

# ---------------------------------------------------------------- p.5 입력·로딩·결과
p5a = phone("A. 입력 중 (300ms 대기)", f'''{STATUS}
<div class="nav"><div class="large">검색</div></div>
<div class="content"><div class="searchbar filled">⌕ 카카<span class="x"{rl("t:44×44")}>✕</span></div>
<div class="section">최근 검색어 <a>전체 삭제</a></div>
{"".join(f'<div class="row"><span class="muted">↺</span>{w}<span class="end">✕</span></div>' for w in ["카카오", "토스"])}
</div>{tabbar("search")}{n(1, 56, 4)}{n(2, 56, 186)}''', cls="sm")
p5b = phone("B. 첫 로딩", f'''{STATUS}
<div class="nav"><div class="large">검색</div></div>
<div class="content"><div class="searchbar filled">⌕ 카카오<span class="x">✕</span></div>
<div class="center" style="top:40px"><div class="spinner"></div><div class="s">검색 중…</div></div>
</div>{tabbar("search")}{n(3, 190, 40)}''', cls="sm")
p5c = phone("C. 결과", f'''{STATUS}
<div class="nav"><div class="large">검색</div></div>
<div class="content"><div class="searchbar filled">⌕ 카카오<span class="x">✕</span></div>
<div class="s"{rl("gt:16")} style="margin:-2px 0 2px"><b>검색 결과 11개</b></div>
{app_row("카카오톡 KakaoTalk", "소셜 네트워킹 · Kakao Corp.", "★★★½☆", "3.6 · 94.2만", row_rl="h:84", icon_rl="sz:60")}
{app_row("카카오 T", "여행 · Kakao Mobility", "★★★★★", "4.7 · 46.4만")}
{app_row("카카오맵", "내비게이션 · Kakao Corp.", "★★★★☆", "4.5 · 12.1만")}
{app_row("카카오뱅크", "금융 · KakaoBank", "★★★★★", "4.8 · 30.0만")}
</div>{tabbar("search")}{n(4, 82, 4)}{n(5, 100, 4)}''', cls="sm")
p5_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "입력 → 자동 검색", "글자가 바뀔 때마다 300ms 디바운스 후 검색. 대기 중에는 이전 화면(최근 검색어 또는 이전 결과)을 그대로 보여 줌."),
  (nn(2), "✕ 지우기", "검색어·결과·에러를 모두 비우고 최근 검색어 화면(p.4)으로. 진행 중인 요청 취소."),
  (nn(3), "첫 로딩", "결과가 없을 때만 가운데 스피너 “검색 중…”. 이전 결과가 있으면 결과를 유지한 채 다시 불러옴."),
  (nn(4), "결과 개수", "서버 <code>total</code> 사용. “검색 결과 N개”."),
  (nn(5), "결과 셀", "셀 구성·페이지네이션은 p.7. 탭 → 상세 push (p.8)."),
])}
<div class="cols">
<div><h2>제약사항</h2>{ul([
  "디바운스 <b>300ms</b> (<code>continuousClock</code> 주입 → 테스트에서 <code>TestClock</code>)",
  "새 검색이 시작되면 이전 요청 <b>취소</b> (<code>cancelInFlight: true</code>) → 늦게 온 이전 응답이 결과를 덮지 않음",
  "리턴 키 제출: 디바운스 무시하고 즉시 검색 + 최근 검색어 저장",
  "검색어가 공백뿐이면 요청하지 않고 p.4 상태",
  "페이지 크기 <b>20</b>",
])}</div>
<div><h2>TCA 제안</h2>{ul([
  "<code>BindableAction</code> + <code>$store.query</code> 또는 <code>queryChanged(String)</code>",
  "<code>searchSubmitted</code>",
  "<code>searchResponse(Result&lt;Page&lt;AppSummary&gt;, any Error&gt;)</code>",
  "<code>clearButtonTapped</code>",
  "State: <code>query</code>, <code>results: IdentifiedArrayOf&lt;AppSummary&gt;</code>, <code>total</code>, <code>nextPage: PageRequest?</code>, <code>isLoading</code>",
])}</div>
</div>
<div class="note"><b>테스트 포인트</b> · <code>TestClock</code>으로 299ms에는 요청이 없고 300ms에 한 번만 요청되는지, 빠르게 두 번 입력하면 마지막 검색어만 요청되는지.</div>
</div>'''
pages.append(page(5, "검색 — 입력 · 로딩 · 결과", "디바운스와 요청 취소", f'<div class="phones">{p5a}{p5b}{p5c}</div>{p5_spec}', tag="SearchFeature"))

# ---------------------------------------------------------------- p.6 빈 결과·에러
p6a = phone("A. 결과 없음", f'''{STATUS}
<div class="nav"><div class="large">검색</div></div>
<div class="content"><div class="searchbar filled">⌕ zzzzqq<span class="x">✕</span></div>
<div class="center" style="top:40px"><div class="big-ic">⌕</div><div class="t"{rl("gt:20")}>‘zzzzqq’ 검색 결과가 없어요</div><div class="s">철자를 확인하거나 다른 키워드로 검색해 보세요.</div></div>
</div>{tabbar("search")}{n(1, 200, 24)}''')
p6b = phone("B. 에러 (결과 없음 상태)", f'''{STATUS}
<div class="nav"><div class="large">검색</div></div>
<div class="content"><div class="searchbar filled">⌕ 카카오<span class="x">✕</span></div>
<div class="center" style="top:40px"><div class="big-ic">⚠︎</div><div class="t">문제가 발생했어요</div><div class="s">네트워크 연결을 확인해 주세요.</div><div class="btn ghost"{rl("t:최대 200 × 52")} style="width:90px;margin-top:6px">다시 시도</div></div>
</div>{tabbar("search")}{n(2, 200, 24)}{n(3, 262, 50)}''')
p6_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "결과 없음", "제목 “‘{{검색어}}’ 검색 결과가 없어요”, 설명 “철자를 확인하거나 다른 키워드로 검색해 보세요.” 검색어가 길면 제목 2줄까지 후 말줄임."),
  (nn(2), "에러 화면", "결과가 하나도 없을 때의 실패만 화면으로 표시. 메시지는 <code>DomainError.message</code> 그대로."),
  (nn(3), "다시 시도", "같은 검색어·같은 페이지로 재요청. 누르면 B → 로딩(p.5-B)."),
])}
<h2>에러별 문구 (DomainError.message)</h2>
{spec_table([
  ("<code>.network</code>", "네트워크 연결을 확인해 주세요.", "오프라인·타임아웃"),
  ("<code>.server(message)</code>", "서버 메시지 또는 “서버에 문제가 생겼어요. 잠시 후 다시 시도해 주세요.”", "5xx"),
  ("<code>.validation</code>", "서버 검증 메시지 (예: 요청 값이 올바르지 않아요.)", "4xx 입력 오류"),
  ("<code>.unknown</code>", "알 수 없는 문제가 발생했어요.", "디코딩 실패 등"),
  ("<code>CancellationError</code>", "<b>표시하지 않음</b>", "새 검색으로 이전 요청이 취소됨"),
], head=("케이스", "문구", "발생"))}
<div class="cols">
<div><h2>규칙</h2>{ul([
  "결과가 이미 있는 상태에서 다음 페이지 실패 → 화면 전체 에러가 아니라 목록 하단 재시도 (p.7)",
  "에러 상태에서 검색어를 바꾸면 에러를 지우고 새로 검색",
  "취소(<code>CancellationError</code>)는 에러로 취급하지 않음",
])}</div>
<div><h2>TCA 제안</h2>{ul([
  "State: <code>loadState: enum {{ idle, loading, loaded, empty, failed(String) }}</code> 처럼 한 값으로 표현하면 모순 상태(로딩 중인데 에러)가 생기지 않음",
  "<code>retryButtonTapped</code>",
])}</div>
</div>
</div>'''
pages.append(page(6, "검색 — 결과 없음 · 에러", "검색 실패와 빈 결과", f'<div class="phones">{p6a}{p6b}</div>{p6_spec}', tag="SearchFeature"))

# ---------------------------------------------------------------- p.7 셀·무한 스크롤
cell_big = f'''<div class="phone-wrap"><div data-rl-host style="width:330px;border:1.5px dashed var(--line);border-radius:10px;padding:12px 14px;position:relative">
<div{rl("h:84 (위아래 8)")} style="display:flex;gap:12px;align-items:center">
 <div class="icon"{rl("sz:60×60;gl:12;t:r 13.4")} style="width:60px;height:60px;border-radius:13px"></div>
 <div style="flex:1"><div style="font-size:14px;font-weight:700">카카오톡 KakaoTalk</div>
 <div{rl("gt:4")} style="font-size:11px;color:#4B5563">소셜 네트워킹 · Kakao Corp.</div>
 <div class="stars"{rl("gt:4")} style="font-size:11px">★★★½☆<em>3.6 · 94.2만</em></div></div>
 <div{rl("t:caption")} style="font-size:11px;color:#8A919E">무료</div>
</div>
<span class="n callout" style="top:-7px;left:14px">1</span><span class="n callout" style="top:-7px;left:84px">2</span>
<span class="n callout" style="top:24px;left:323px">5</span><span class="n callout" style="top:34px;left:-7px">3</span><span class="n callout" style="top:54px;left:-7px">4</span>
</div><div class="phone-label">셀 구성 (확대)</div>
<div style="height:10px"></div>
<div class="phone sm" style="height:300px">{STATUS}
<div class="content" style="padding-top:4px">
{app_row("…", "…")}{app_row("…", "…")}
<div class="row"{rl("h:52")} style="justify-content:center;border:0"><div class="spinner" style="width:14px;height:14px"></div><span class="s">불러오는 중</span></div>
<div class="row"{rl("h:52")} style="justify-content:center;border:0;flex-direction:column;gap:3px"><span class="s">더 불러오지 못했어요.</span><span class="btn ghost" style="height:22px;width:70px;font-size:8.5px">다시 시도</span></div>
<div class="row"{rl("h:52")} style="justify-content:center;border:0"><span class="s">모든 결과를 확인했어요</span></div>
</div>
{n(6, 124, 30)}{n(7, 150, 30)}{n(8, 194, 30)}</div><div class="phone-label">목록 하단 3가지 상태</div></div>'''
p7_spec = f'''<div class="spec">
<h2>셀 (DesignSystem <code>AppRowView</code>)</h2>
{spec_table([
  (nn(1), "앱 아이콘", "60×60, 모서리 = 한 변 × 0.2237 (iOS 아이콘 모양), 0.5pt 테두리. Kingfisher 다운샘플링 + 캐시. 로딩 전 회색 플레이스홀더."),
  (nn(2), "앱 이름", "<code>headline</code> 17pt SemiBold, 1줄 말줄임."),
  (nn(3), "장르 · 개발사", "<code>caption</code> 13pt, <code>textSecondary</code>, 1줄 말줄임."),
  (nn(4), "별점", "<code>RatingView</code>: 별 5개(반 개 단위) + 평점 소수 1자리 + 평가 수 축약(1.2천 / 3.4만 / 1.2억). 평가 0개면 “0.0”."),
  (nn(5), "가격", "서버 <code>formatted_price</code> (무료 / ₩4,400). 셀 전체가 탭 영역."),
])}
<h2>무한 스크롤 (페이지네이션)</h2>
{spec_table([
  ("트리거", "끝에서 <b>5번째 셀</b>이 나타날 때 <code>nextPage</code>가 있으면 다음 페이지 요청 (<code>onAppear</code> of row)"),
  ("중복 방지", "이미 다음 페이지 요청 중이면 무시. 응답이 오면 <code>offset</code> 기준으로 이어 붙이고 id 중복은 제거"),
  ("끝", "<code>offset + items.count >= total</code> → <code>nextPage = nil</code>. 하단에 ⑧ 표시"),
  ("실패", "결과는 유지하고 하단에 ⑦ 재시도. 재시도는 실패한 페이지를 그대로 다시 요청"),
  ("검색어 변경", "목록·페이지 상태 초기화. 진행 중인 다음 페이지 요청도 취소"),
], head=("항목", "규칙"))}
<div class="note"><b>TCA 제안</b> · <code>rowAppeared(id:)</code>, <code>nextPageResponse(Result&lt;Page&lt;AppSummary&gt;, any Error&gt;)</code>, <code>loadMoreRetryTapped</code>. 다음 페이지 Effect는 검색 Effect와 다른 <code>CancelID</code>를 쓰되, 검색어가 바뀌면 둘 다 취소.</div>
</div>'''
pages.append(page(7, "결과 셀 · 무한 스크롤", "AppRowView와 페이지 크기 20", f'<div class="phones" style="gap:20px">{cell_big}</div>{p7_spec}', tag="SearchFeature"))

# ---------------------------------------------------------------- p.8 상세 로딩·상단
p8a = phone("A. 진입 직후 (상세 로딩 중)", f'''{STATUS}
<div class="nav inline"><span class="left">‹</span><span class="title"></span><span class="right"><span class="glass"{rl("t:44×44")}>♡</span></span></div>
<div class="content">
<div style="display:flex;gap:10px;margin-top:4px"><div class="icon lg"{rl("sz:100×100")}></div><div><div class="t" style="font-size:12px">카카오톡 KakaoTalk</div><div class="s">Kakao Corp.</div><div class="stars">★★★½☆<em>3.6 · 94.2만</em></div></div></div>
<div class="skeleton"{rl("t:스켈레톤 · surface")} style="height:28px;margin:10px 0"></div>
<div class="skeleton" style="height:120px;margin-bottom:8px"></div>
<div class="skeleton" style="height:8px;width:80%;margin:4px 0"></div><div class="skeleton" style="height:8px;width:60%"></div>
</div>{HOME}{n(1, 64, 4)}{n(2, 128, 4)}{n(3, 26, 186)}''')
p8b = phone("B. 로딩 완료 (상단)", f'''{STATUS}
<div class="nav inline"><span class="left">‹</span><span class="title">카카오톡 KakaoTalk</span><span class="right"><span class="glass" style="color:#4F46E5">♥</span></span></div>
<div class="content">
<div{rl("gt:8")} style="display:flex;gap:10px;margin-top:4px"><div class="icon lg"{rl("sz:100×100;gl:12")}></div><div style="flex:1"><div class="t" style="font-size:12px">카카오톡 KakaoTalk</div><div class="s">Kakao Corp.</div>
<div{rl("gt:8")} style="margin-top:3px"><span class="chip">소셜 네트워킹</span> <span class="chip">생산성</span></div></div></div>
<div{rl("gt:16;h:70")} style="display:flex;justify-content:space-around;text-align:center;margin:10px 0;font-size:8px;color:#4B5563">
<div><b style="font-size:10px;color:#111">3.6</b><br>★★★½☆</div><div><b style="font-size:10px;color:#111">94.2만</b><br>평가</div><div><b style="font-size:10px;color:#111">4+</b><br>연령</div><div><b style="font-size:10px;color:#111">무료</b><br>가격</div></div>
<div class="btn"{rl("gt:16;sz:높이 52;ml:20;mr:20")}>App Store에서 보기</div>
<div class="section"{rl("gt:24")} style="margin-top:10px">미리 보기</div><div class="shots"{rl("gt:12")}><div class="shot"></div><div class="shot"></div><div class="shot"></div></div>
</div>{HOME}{n(4, 94, 4)}{n(5, 128, 4)}{n(6, 186, 4)}''')
p8_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "요약 정보 (즉시)", "목록에서 받은 <code>AppSummary</code>로 아이콘·이름·개발사·별점을 <b>바로</b> 그림. 상세 응답을 기다리지 않음."),
  (nn(2), "스켈레톤", "나머지 영역은 상세 응답 전까지 회색 블록. 전체 화면 스피너를 쓰지 않음 (화면이 덜 깜빡임)."),
  (nn(3), "즐겨찾기 ♡/♥", "툴바 오른쪽. 로딩 중에도 누를 수 있음 (요약 정보로 저장). 상태는 DB 관찰 스트림으로 갱신 → 다른 화면에서 바꿔도 반영. <code>accessibilityLabel</code> “즐겨찾기 추가/해제”."),
  (nn(4), "장르 태그", "<code>TagView</code>, 최대 3개, 한 줄."),
  (nn(5), "요약 지표", "평점 / 평가 수 / 연령 등급 / 가격. 4칸 균등."),
  (nn(6), "App Store에서 보기", "<code>DSButtonStyle(.primary)</code>. <code>@Dependency(\\.openURL)</code>로 <code>appStoreURL</code> 열기. URL이 없으면 버튼 숨김."),
])}
<div class="cols">
<div><h2>규칙</h2>{ul([
  "내비게이션 타이틀은 inline, 스크롤해서 상단 이름이 가려지면 표시 (처음엔 비움)",
  "상세 요청 실패 시: 요약 정보는 유지하고 스켈레톤 자리에 <code>ErrorStateView</code> (다시 시도)",
  "404 → “요청한 정보를 찾을 수 없어요.” 다시 시도 버튼 없이 표시",
])}</div>
<div><h2>TCA 제안</h2>{ul([
  "<code>State(app: AppSummary)</code>로 시작",
  "<code>detail: LoadState&lt;AppDetail&gt;</code>, <code>isFavorite: Bool</code>",
  "onAppear에서 <code>.merge(상세 요청, 즐겨찾기 구독)</code>",
  "<code>favoriteButtonTapped</code>, <code>appStoreButtonTapped</code>, <code>retryButtonTapped</code>",
])}</div>
</div>
</div>'''
pages.append(page(8, "상세 — 로딩 · 상단 정보", "결과/즐겨찾기 → push", f'<div class="phones">{p8a}{p8b}</div>{p8_spec}', tag="AppDetailFeature"))

# ---------------------------------------------------------------- p.9 상세 본문
p9a = phone("A. 본문 (스크롤 아래)", f'''{STATUS}
<div class="nav inline"><span class="left">‹</span><span class="title">카카오톡 KakaoTalk</span><span class="right"><span class="glass">♡</span></span></div>
<div class="content">
<div class="shots"><div class="shot"{rl("hl:400;gl:12;t:r 14")}></div><div class="shot"></div><div class="shot"></div></div>
<div class="section"{rl("gt:24")}>설명</div><div class="l w90"{rl("t:body · 최대 3줄")}></div><div class="l w80"></div><div class="l w70"></div><div class="s"{rl("t:44 터치")} style="color:#4F46E5;text-align:right">더 보기</div>
<div class="section"{rl("gt:24")}>새로운 기능 <a>버전 25.9.0 · 2026.11.03</a></div><div class="l w80"></div><div class="l w50"></div>
<div class="section">정보</div>
<div class="kv"{rl("h:44")}><span>개발사</span><span>Kakao Corp.</span></div><div class="kv"><span>크기</span><span>393.2MB</span></div>
<div class="kv"><span>연령 등급</span><span>4+</span></div><div class="kv"><span>호환성</span><span>iOS 16.0 이상</span></div>
</div>{HOME}{n(1, 54, 4)}{n(2, 184, 4)}{n(3, 200, 186)}{n(4, 236, 4)}{n(5, 290, 4)}''')
p9b = phone("B. 즐겨찾기 추가 직후", f'''{STATUS}
<div class="nav inline"><span class="left">‹</span><span class="title">카카오톡 KakaoTalk</span><span class="right"><span class="glass" style="color:#4F46E5">♥</span></span></div>
<div class="content"><div style="display:flex;gap:10px;margin-top:4px"><div class="icon lg"></div><div><div class="t" style="font-size:12px">카카오톡 KakaoTalk</div><div class="s">Kakao Corp.</div></div></div>
<div class="l w80" style="margin-top:12px"></div><div class="l w60"></div></div>
<div class="toast"{rl("h:44;t:탭 바 위 12 · 2초")}>♥ 즐겨찾기에 추가했어요</div>{HOME}{n(6, 26, 186)}{n(7, 352, 8)}''', cls="sm")
p9_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "스크린샷", "가로 스크롤, 높이 <b>400pt</b>(실기기), 비율은 이미지 원본 유지, 모서리 14pt. 탭 → (선택 과제) 전체 화면 보기. 스크린샷이 0개면 섹션 숨김."),
  (nn(2), "설명", "<code>body</code>, 기본 <b>3줄</b> 말줄임. 3줄을 넘을 때만 “더 보기” 표시."),
  (nn(3), "더 보기", "누르면 전체 펼침 (<code>descriptionExpanded</code>). 다시 접기는 없음."),
  (nn(4), "새로운 기능", "릴리스 노트가 없으면 섹션 숨김. 날짜는 <code>yyyy.MM.dd</code>."),
  (nn(5), "정보", "개발사 / 크기(MB, 소수 1자리) / 연령 등급 / 호환성(“iOS {{최소 버전}} 이상”) / 장르. 값이 없으면 “-”."),
  (nn(6), "♥ 토글", "탭 즉시 아이콘 변경(낙관적 업데이트 금지: DB 저장 성공 후 스트림 값으로 바뀜). 실패 시 알럿 “기기에 저장하지 못했어요…”."),
  (nn(7), "토스트 (선택 과제)", "“즐겨찾기에 추가했어요” / “즐겨찾기에서 뺐어요”. 하단 탭 바 위, 2초 후 사라짐. 구현하지 않아도 됨."),
])}
<div class="note"><b>왜 스트림으로 상태를 받나?</b> 같은 앱이 즐겨찾기 탭에도 떠 있을 수 있다. 하트 상태를 각 화면이 따로 들고 있으면 어긋난다. DB를 단일 진실 원천으로 두고 <code>favoriteUseCase.observeIsFavorite(appID:)</code>를 구독한다.</div>
<div class="note"><b>테스트 포인트</b> · 하트를 누르면 <code>toggle</code>이 호출되고, 스트림이 <code>true</code>를 내보내면 <code>isFavorite</code>가 바뀌는지. 실패 시 알럿 State가 채워지는지.</div>
</div>'''
pages.append(page(9, "상세 — 스크린샷 · 정보 · 즐겨찾기", "AppDetail 본문", f'<div class="phones">{p9a}{p9b}</div>{p9_spec}', tag="AppDetailFeature"))

# ---------------------------------------------------------------- p.10 즐겨찾기
p10a = phone("A. 비어 있음", f'''{STATUS}
<div class="nav"><div class="large">즐겨찾기</div></div>
<div class="content"><div class="center"><div class="big-ic">♡</div><div class="t">아직 즐겨찾기한 앱이 없어요</div><div class="s">앱 상세에서 ♡를 눌러 모아 보세요.</div><div class="btn ghost"{rl("t:최대 200 × 52")} style="width:100px;margin-top:6px">앱 검색하러 가기</div></div></div>
{tabbar("fav")}{n(1, 180, 24)}{n(2, 258, 46)}''', cls="sm")
p10b = phone("B. 목록", f'''{STATUS}
<div class="nav"><div class="large">즐겨찾기</div></div>
<div class="content"><div class="s"{rl("gt:8")} style="margin-bottom:2px"><b>3개</b> · 최근 추가순</div>
{app_row("토스", "금융 · Viva Republica", "★★★★★", "4.8", row_rl="h:84", icon_rl="sz:60")}
{app_row("Notion", "생산성 · Notion Labs", "★★★★½", "4.5")}
{app_row("카카오톡 KakaoTalk", "소셜 네트워킹 · Kakao", "★★★½☆", "3.6")}
</div>{tabbar("fav")}{n(3, 64, 4)}{n(4, 84, 4)}''', cls="sm")
p10c = phone("C. 스와이프 삭제", f'''{STATUS}
<div class="nav"><div class="large">즐겨찾기</div></div>
<div class="content"><div class="s" style="margin-bottom:2px"><b>3개</b> · 최근 추가순</div>
<div class="swipe"><div style="margin-left:-30px;flex:1">{app_row("토스", "금융 · Viva Republica", "★★★★★", "4.8")}</div><div class="del"{rl("t:시스템 swipeActions · .tint(.dsError)")}>삭제</div></div>
{app_row("Notion", "생산성 · Notion Labs", "★★★★½", "4.5")}
</div>{tabbar("fav")}{n(5, 90, 168)}''', cls="sm")
p10_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "빈 상태", "제목 “아직 즐겨찾기한 앱이 없어요”, 설명 “앱 상세에서 ♡를 눌러 모아 보세요.”"),
  (nn(2), "검색하러 가기", "검색 탭으로 전환. 자식은 탭을 모르므로 <code>delegate(.searchTabRequested)</code> → RootFeature가 <code>selectedTab = .search</code>."),
  (nn(3), "개수 · 정렬", "“N개 · 최근 추가순”. 정렬은 <code>addedAt</code> 내림차순 고정."),
  (nn(4), "셀", "검색 결과와 같은 <code>AppRowView</code> (평가 수는 생략, 저장된 스냅샷 값 사용). 탭 → 상세 push."),
  (nn(5), "스와이프 삭제", "<code>.swipeActions</code> 빨간 “삭제”, 전체 스와이프로 즉시 삭제. 확인 없음."),
])}
<div class="cols">
<div><h2>규칙</h2>{ul([
  "목록은 <b>DB 관찰 스트림</b>으로만 갱신 (삭제 후 직접 배열에서 빼지 않음)",
  "오프라인에서도 보여야 함 → 목록용 값은 로컬 스냅샷. 최신 정보는 상세에서 서버로",
  "상세에서 ♥ 해제 후 뒤로 오면 해당 셀이 이미 사라져 있어야 함",
  "삭제 실패 시 알럿 “기기에 저장하지 못했어요. 저장 공간을 확인해 주세요.”",
])}</div>
<div><h2>TCA 제안</h2>{ul([
  "State: <code>favorites: IdentifiedArrayOf&lt;FavoriteApp&gt;</code>, <code>path: StackState&lt;Path.State&gt;</code>",
  "<code>@Reducer enum Path {{ case detail(AppDetailFeature) }}</code>",
  "<code>favoritesUpdated</code>, <code>deleteSwiped(id:)</code>, <code>cellTapped(FavoriteApp)</code>",
  "상세 State를 만들 때 <code>FavoriteApp</code> → <code>AppSummary</code> 변환 필요 (평가 수 0)",
])}</div>
</div>
</div>'''
pages.append(page(10, "즐겨찾기", "로컬 DB 관찰 · 스와이프 삭제", f'<div class="phones">{p10a}{p10b}{p10c}</div>{p10_spec}', tag="FavoritesFeature"))

# ---------------------------------------------------------------- p.11 프로필
p11a = phone("A. 프로필", f'''{STATUS}
<div class="nav"><div class="large">프로필</div><div class="right" style="top:14px"><span class="glass"{rl("t:44×44")}>⚙</span></div></div>
<div class="content">
<div style="display:flex;flex-direction:column;align-items:center;gap:4px;margin:6px 0 12px"><div class="avatar"{rl("sz:88;t:원형")}><span class="badge-cam"{rl("tl:28")}>✎</span></div>
<div class="t"{rl("gt:12")} style="font-size:12px">Chris</div><div class="s">chris@example.com</div></div>
<div class="group-title"{rl("gt:24")}>계정 정보</div>
<div class="group"{rl("ml:20;tl:r 14")}><div class="row"{rl("h:44")}>이름<span class="end">Chris ›</span></div><div class="row">이메일<span class="end">chris@example.com ›</span></div></div>
</div>{tabbar("profile")}{n(1, 66, 50)}{n(2, 30, 186)}{n(3, 178, 4)}{n(4, 204, 4)}''')
p11b = phone("B. 첫 로딩 / 실패", f'''{STATUS}
<div class="nav"><div class="large">프로필</div><div class="right" style="top:14px"><span class="glass">⚙</span></div></div>
<div class="content"><div class="center"><div class="big-ic">⚠︎</div><div class="t">문제가 발생했어요</div><div class="s">네트워크 연결을 확인해 주세요.</div><div class="btn ghost" style="width:90px;margin-top:6px">다시 시도</div></div></div>
{tabbar("profile")}{n(5, 200, 24)}''', cls="sm")
p11_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "프로필 이미지", "지름 88pt 원형, Kingfisher. 없으면 회색 기본 이미지 + 이니셜. 이미지나 ✎ 배지를 탭하면 사진 선택 (p.13)."),
  (nn(2), "설정 ⚙", "SettingsFeature push (p.14). 아이콘 색은 시스템 기본."),
  (nn(3), "이름 행", "<code>DSListRow</code>. 탭 → 이름 편집 push (p.12). 값이 길면 말줄임."),
  (nn(4), "이메일 행", "탭 → 이메일 편집 push (p.12)."),
  (nn(5), "로딩 · 실패", "프로필이 아직 없을 때만 가운데 로딩/에러. 이미 있으면 기존 값을 유지한 채 조용히 갱신."),
])}
<div class="cols">
<div><h2>규칙</h2>{ul([
  "탭에 들어올 때마다(<code>.task</code>) 서버에서 다시 조회",
  "편집 화면에서 저장 성공 → <code>delegate(.profileUpdated(Profile))</code>로 받은 값으로 즉시 갱신 (재조회하지 않음)",
  "서버는 인증 없이 id=1 사용자 고정 (docs/backend.md)",
])}</div>
<div><h2>TCA 제안</h2>{ul([
  "State: <code>profile: Profile?</code>, <code>loadState</code>, <code>path</code>, <code>isUploadingAvatar</code>, <code>@Presents alert</code>",
  "<code>@Reducer enum Path {{ case editName(EditNameFeature), editEmail(EditEmailFeature), settings(SettingsFeature) }}</code>",
  "<code>nameRowTapped</code>, <code>emailRowTapped</code>, <code>settingsButtonTapped</code>",
  "부모는 <code>.path(.element(_, .editName(.delegate(.profileUpdated(let p)))))</code>만 처리",
])}</div>
</div>
<div class="note"><b>강의 코드와 다른 점</b> · 강의에서는 View가 SwiftData에 직접 저장하고, 부모가 자식의 <code>onEditSuccess</code>를 엿봤다. 여기서는 저장은 리듀서 Effect(UseCase)가, 결과 전달은 <code>delegate</code>가 맡는다.</div>
</div>'''
pages.append(page(11, "프로필", "서버 프로필 조회 · 편집 진입점", f'<div class="phones">{p11a}{p11b}</div>{p11_spec}', tag="ProfileFeature"))

# ---------------------------------------------------------------- p.12 이름·이메일 편집
p12a = phone("A. 이름 편집", f'''{STATUS}
<div class="nav inline"><span class="left"{rl("t:시스템 뒤로")}>‹ 프로필</span><span class="title">이름</span><span class="right"><span class="glass pill"{rl("h:44")} style="color:#4F46E5">저장</span></span></div>
<div class="content" style="padding-top:10px"><div class="field"{rl("gt:16;sz:높이 44;ml:20;mr:20")}>Chris<span{rl("t:✕ 44×44")} style="margin-left:auto;color:#8A919E">✕</span></div>
<div class="helper"{rl("gt:8")}><span>2~20자</span><span>5/20</span></div></div>{HOME}
{n(1, 62, 4)}{n(2, 86, 4)}{n(3, 26, 168)}''', cls="sm")
p12b = phone("B. 입력 오류", f'''{STATUS}
<div class="nav inline"><span class="left">‹ 프로필</span><span class="title">이메일</span><span class="right"><span class="glass pill"{rl("t:비활성 40%")} style="opacity:.4">저장</span></span></div>
<div class="content" style="padding-top:10px"><div class="field error"{rl("t:테두리 1.5 · error")}>chris@<span style="margin-left:auto;color:#8A919E">✕</span></div>
<div class="helper error"{rl("gt:8")}><span>이메일 형식이 올바르지 않아요.</span></div></div>{HOME}
{n(4, 82, 4)}''', cls="sm")
p12c = phone("C. 저장 중 → 실패", f'''{STATUS}
<div class="nav inline"><span class="left">‹ 프로필</span><span class="title">이름</span><span class="right"><span class="glass pill"><span class="spinner" style="width:10px;height:10px;border-width:2px"></span></span></span></div>
<div class="content" style="padding-top:10px"><div class="field">철수</div></div>
<div class="dim"></div><div class="alert"{rl("t:시스템 알럿")}><div class="at">저장하지 못했어요</div><div class="am">네트워크 연결을 확인해 주세요.</div><div class="ab"><span>확인</span></div></div>{HOME}
{n(5, 26, 168)}{n(6, 150, 10)}''', cls="sm")
p12_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "입력 필드", "진입 시 현재 값으로 채우고 <b>자동 포커스</b>(<code>@FocusState</code>). ✕로 비우기. 리턴 키 = 저장."),
  (nn(2), "도움말 · 글자 수", "이름: “2~20자” + “N/20” (앞뒤 공백 제외 기준). 이메일: 글자 수 표시 없음."),
  (nn(3), "저장 버튼", "툴바 오른쪽 (<code>topBarTrailing</code>). <b>값이 바뀌었고 형식이 맞을 때만</b> 활성."),
  (nn(4), "인라인 오류", "입력이 멈추고 0.5초 뒤 또는 저장 시도 시 표시. 문구는 <code>ValidationError.message</code>."),
  (nn(5), "저장 중", "저장 버튼 자리에 스피너, 입력 비활성, 뒤로 가기 허용 (요청은 취소)."),
  (nn(6), "실패 알럿", "제목 “저장하지 못했어요”, 메시지 = <code>DomainError.message</code>, 버튼 “확인”. 입력값 유지."),
])}
<div class="cols">
<div><h2>검증 규칙 (클라이언트 = 서버)</h2>{spec_table([
  ("이름", "앞뒤 공백 제거 후 2~20자"),
  ("이메일", "필수, 100자 이하, <code>이름@도메인.최상위(2자+)</code>"),
  ("서버 422", "<code>validation(.server(message))</code> → 인라인 오류로 표시"),
], head=("항목", "규칙"))}</div>
<div><h2>TCA 제안</h2>{ul([
  "리듀서 분리: <code>EditNameFeature</code>, <code>EditEmailFeature</code> (같은 모양이면 <code>EditFieldFeature</code> 하나 + 종류 enum도 가능)",
  "<code>saveButtonTapped</code> → <code>profileUseCase.updateName</code>",
  "성공: <code>.send(.delegate(.profileUpdated(profile)))</code> 후 <code>await dismiss()</code>",
  "<code>@Presents var alert: AlertState&lt;Action.Alert&gt;?</code> + <code>.ifLet(\\.$alert, action: \\.alert)</code>",
])}</div>
</div>
</div>'''
pages.append(page(12, "이름 · 이메일 편집", "검증 · 저장 · delegate · dismiss", f'<div class="phones">{p12a}{p12b}{p12c}</div>{p12_spec}', tag="ProfileFeature"))

# ---------------------------------------------------------------- p.13 이미지 변경
p13a = phone("A. 사진 선택", f'''{STATUS}
<div class="nav"><div class="large">프로필</div></div>
<div class="content"><div style="display:flex;flex-direction:column;align-items:center;gap:4px;margin:6px 0"><div class="avatar"><span class="badge-cam">✎</span></div></div></div>
<div class="dim"></div>
<div class="sheet"{rl("t:시스템 PhotosPicker")} style="height:300px"><div class="grabber"></div><div class="section" style="justify-content:center">사진 (시스템 PhotosPicker)</div>
<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:3px">{"".join('<div class="skeleton" style="height:40px"></div>' for _ in range(16))}</div></div>{n(1, 66, 50)}{n(2, 190, 6)}''', cls="sm")
p13b = phone("B. 업로드 중", f'''{STATUS}
<div class="nav"><div class="large">프로필</div></div>
<div class="content"><div style="display:flex;flex-direction:column;align-items:center;gap:4px;margin:6px 0 12px">
<div class="avatar"{rl("sz:88")} style="display:flex;align-items:center;justify-content:center"><div class="spinner"></div></div>
<div class="t" style="font-size:12px">Chris</div><div class="s"{rl("t:callout · textSecondary")}>사진을 올리는 중…</div></div></div>
{tabbar("profile")}{n(3, 66, 50)}''', cls="sm")
p13c = phone("C. 실패", f'''{STATUS}
<div class="nav"><div class="large">프로필</div></div>
<div class="content"><div style="display:flex;flex-direction:column;align-items:center;margin:6px 0"><div class="avatar"></div></div></div>
<div class="dim"></div><div class="alert"><div class="at">사진을 바꾸지 못했어요</div><div class="am">이미지는 5MB 이하만 올릴 수 있어요.</div><div class="ab"><span>확인</span></div></div>{n(4, 150, 10)}''', cls="sm")
p13_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "진입", "프로필 이미지 또는 ✎ 배지 탭 → <code>PhotosPicker</code> (이미지만, 1장). <b>사진 권한 요청 불필요</b> (PhotosPicker는 별도 프로세스)."),
  (nn(2), "선택 완료", "<code>PhotosPickerItem.loadTransferable(type: Data.self)</code>로 원본 데이터를 받아 리듀서에 전달. 취소하면 아무 일도 없음."),
  (nn(3), "업로드 중", "이미지 위 스피너 + “사진을 올리는 중…”. 중복 선택 막기 (업로드 중에는 배지 비활성)."),
  (nn(4), "실패 알럿", "제목 “사진을 바꾸지 못했어요”, 메시지 = <code>DomainError.message</code>. 기존 이미지 유지."),
])}
<h2>처리 흐름과 제약</h2>
{spec_table([
  ("1. Feature", "원본 Data를 <code>profileUseCase.updateAvatar(imageData:)</code>에 전달"),
  ("2. Domain", "원본 <b>20MB 초과</b>면 요청 없이 <code>validation(.imageTooLarge)</code>"),
  ("3. Data", "<code>ImageCompressor</code>가 긴 변 <b>1024px JPEG(품질 0.8)</b>로 축소. 이미지가 아니면 실패"),
  ("4. Server", "<code>PUT /v1/users/me/avatar</code> multipart <code>file</code>. JPEG/PNG만(415), 5MB 이하(413)"),
  ("5. 응답", "새 <code>avatar_url</code>에 <code>?v=수정시각</code>이 붙어 Kingfisher 캐시가 자동으로 갱신됨"),
], head=("단계", "내용"))}
<div class="note"><b>강의 코드와 다른 점</b> · 강의는 Photos 권한을 직접 요청하고 60×60 썸네일을 그대로 저장해서 화질이 깨졌다. 여기서는 PhotosPicker + 목적에 맞는 크기(1024px)로 압축한다. View는 <code>PhotosPickerItem</code>만 다루고, 이미지 처리는 Data 계층에 있다.</div>
<div class="note"><b>TCA 제안</b> · <code>photoPicked(Data)</code>, <code>avatarUploadResponse(Result&lt;Profile, any Error&gt;)</code>. <code>PhotosPickerItem</code>은 Equatable/Sendable 문제로 State에 넣지 말고, View의 <code>.onChange</code>에서 Data로 바꿔서 보낸다.</div>
</div>'''
pages.append(page(13, "프로필 이미지 변경", "PhotosPicker → 압축 → 업로드", f'<div class="phones">{p13a}{p13b}{p13c}</div>{p13_spec}', tag="ProfileFeature"))

# ---------------------------------------------------------------- p.14 설정
p14a = phone("A. 설정", f'''{STATUS}
<div class="nav inline"><span class="left">‹ 프로필</span><span class="title">설정</span></div>
<div class="content" style="padding-top:6px">
<div class="group-title"{rl("gt:16")}>화면</div><div class="group"{rl("ml:20;tl:r 14")} style="padding:8px 9px"><div class="seg"{rl("t:Picker(.segmented)")}><span>시스템</span><span class="on">라이트</span><span>다크</span></div></div>
<div class="group-title"{rl("gt:24")}>데이터</div><div class="group"><div class="row"{rl("h:44")} style="color:#B91C1C">최근 검색어 전체 삭제</div></div>
<div class="group-title">정보</div><div class="group"><div class="row">앱 버전<span class="end">1.0.0 (1)</span></div><div class="row">서버 주소<span class="end">localhost:8000</span></div><div class="row">오픈소스 라이선스<span class="end">›</span></div></div>
</div>{HOME}{n(1, 82, 4)}{n(2, 140, 4)}{n(3, 196, 4)}{n(4, 222, 4)}{n(5, 248, 4)}''')
p14b = phone("B. 전체 삭제 확인", f'''{STATUS}
<div class="nav inline"><span class="left">‹ 프로필</span><span class="title">설정</span></div>
<div class="content"></div><div class="dim"></div>
<div class="sheet"><div class="s" style="text-align:center;margin-bottom:6px">최근 검색어를 모두 삭제할까요?<br>삭제한 검색어는 되돌릴 수 없어요.</div>
<div class="btn danger"{rl("t:시스템 confirmationDialog")} style="margin-bottom:5px">전체 삭제</div><div class="btn ghost">취소</div></div>{n(6, 330, 8)}''', cls="sm")
p14_spec = f'''<div class="spec">
{spec_table([
  (nn(1), "화면 모드", "Segmented Picker: 시스템 / 라이트 / 다크. 즉시 적용, 앱 재실행 후에도 유지."),
  (nn(2), "최근 검색어 전체 삭제", "빨간 글자 행. 탭 → 확인 다이얼로그(B). 최근 검색어가 0개면 비활성."),
  (nn(3), "앱 버전", "<code>CFBundleShortVersionString (CFBundleVersion)</code>."),
  (nn(4), "서버 주소", "<b>Debug 빌드에서만</b> 표시. Info.plist <code>APIBaseURL</code>의 host:port."),
  (nn(5), "오픈소스 라이선스", "push로 목록 표시: Pretendard(OFL-1.1), TCA, Alamofire, Kingfisher, SQLiteData (MIT). 텍스트만."),
  (nn(6), "확인 다이얼로그", "<code>confirmationDialog</code>. 메시지 “최근 검색어를 모두 삭제할까요? 삭제한 검색어는 되돌릴 수 없어요.” 버튼 “전체 삭제”(destructive) / “취소”."),
])}
<div class="cols">
<div><h2>테마 저장 방식</h2>{ul([
  "<code>@Shared(.appStorage(\"appTheme\")) var theme: AppTheme = .system</code>",
  "<code>enum AppTheme: String {{ case system, light, dark }}</code>",
  "RootView에서도 같은 키를 읽어 <code>.preferredColorScheme</code> 적용 → 설정에서 바꾸면 앱 전체 즉시 반영",
  "<code>@Shared</code>라서 테스트에서 값 변경을 검증할 수 있음",
])}</div>
<div><h2>TCA 제안</h2>{ul([
  "<code>themeChanged(AppTheme)</code> 또는 <code>BindableAction</code>",
  "<code>clearRecentKeywordsTapped</code> → <code>@Presents var confirmationDialog</code>",
  "<code>confirmationDialog(.presented(.clearConfirmed))</code> → <code>recentKeywordUseCase.deleteAll()</code>",
  "삭제 성공 후 별도 안내 없음 (검색 탭은 DB 관찰로 자동 반영)",
])}</div>
</div>
</div>'''
pages.append(page(14, "설정", "@Shared 테마 · 확인 다이얼로그", f'<div class="phones">{p14a}{p14b}</div>{p14_spec}', tag="SettingsFeature"))

# ---------------------------------------------------------------- p.15 공통 컴포넌트
p15 = f'''<div class="phones" style="flex-wrap:wrap;width:470px;gap:10px">
{phone("알럿 (작업 실패)", f'{STATUS}<div class="content"></div><div class="dim"></div><div class="alert"><div class="at">저장하지 못했어요</div><div class="am">네트워크 연결을 확인해 주세요.</div><div class="ab"><span>확인</span></div></div>', cls="sm")}
{phone("로딩 · 빈 상태 · 에러", f'''{STATUS}<div class="content">
<div style="height:110px;position:relative;border-bottom:1px dashed #D1D5DB"><div class="center"><div class="spinner"></div><div class="s">불러오는 중…</div></div></div>
<div style="height:120px;position:relative;border-bottom:1px dashed #D1D5DB"><div class="center"><div class="big-ic">♡</div><div class="t">제목</div><div class="s">설명</div></div></div>
<div style="height:130px;position:relative"><div class="center"><div class="big-ic">⚠︎</div><div class="t">문제가 발생했어요</div><div class="s">메시지</div><div class="btn ghost" style="width:80px;height:22px;margin-top:4px">다시 시도</div></div></div>
</div>''', cls="sm")}
</div>
<div class="spec">
<h2>알럿 규칙 (<code>AlertState</code>)</h2>
{spec_table([
  ("제목", "무엇이 실패했는지: “저장하지 못했어요”, “사진을 바꾸지 못했어요”, “삭제하지 못했어요”"),
  ("메시지", "<code>DomainError.message</code> 그대로 (사용자용 문장으로 이미 작성됨)"),
  ("버튼", "“확인” 하나. 재시도 버튼은 넣지 않음 (화면의 버튼으로 다시 시도)"),
  ("공통화", "<code>AlertState.error(title:message:)</code> 같은 extension을 Feature 공용 위치에 두고 재사용 (강의 코드처럼 화면마다 복붙 금지)"),
  ("닫기", "<code>.ifLet(\\.$alert, action: \\.alert)</code>가 자동 처리 → <code>case .dismiss: state.alert = nil</code> 작성 불필요"),
], head=("항목", "규칙"))}
<h2>DesignSystem 컴포넌트 대응표</h2>
{spec_table([
  ("<code>SearchBar</code>", "검색창 (p.4–6)", "<code>text</code> 바인딩, <code>onSubmit</code>, <code>onClear</code>"),
  ("<code>AppRowView</code>", "결과·즐겨찾기 셀 (p.7, 10)", "아이콘, 이름, 부제, 별점, trailing"),
  ("<code>AppIconView</code>", "앱 아이콘 (p.7–10)", "Kingfisher 캐시·다운샘플링"),
  ("<code>RatingView</code>", "별점 (p.7–9)", "반 개 단위, 평가 수 축약"),
  ("<code>TagView</code>", "장르 태그 (p.8)", ""),
  ("<code>DSListRow</code>", "프로필·설정 행 (p.11, 14)", "제목, 값, 아이콘, 꺾쇠"),
  ("<code>.buttonStyle(.ds(...))</code>", "버튼 (p.8, 12, 14)", "primary / secondary / destructive, <code>isLoading</code>"),
  ("<code>LoadingView</code> · <code>EmptyStateView</code> · <code>ErrorStateView</code>", "상태 화면 (전체)", "왼쪽 그림"),
], head=("컴포넌트", "사용 위치", "비고"))}
<div class="note"><b>토스트</b>는 DesignSystem에 없다 (p.9 선택 과제). 만든다면 Feature 공용 모듈 또는 DesignSystem에 <code>ToastView</code> + <code>@Presents</code> 대신 State의 <code>toast: String?</code>과 <code>clock.sleep</code>으로 2초 후 nil.</div>
</div>'''
pages.append(page(15, "공통 컴포넌트 · 상태", "알럿 · 로딩 · 빈 상태 · 에러", p15))

# ---------------------------------------------------------------- p.16 디자인 토큰
colors = [
    ("brandPrimary", "#4F46E5", "#818CF8"), ("brandSecondary", "#0F766E", "#2DD4BF"), ("onBrand", "#FFFFFF", "#0B0D12"),
    ("background", "#FFFFFF", "#0B0D12"), ("surface", "#F4F5F9", "#161922"), ("surfaceElevated", "#FFFFFF", "#1F2330"),
    ("textPrimary", "#111827", "#F3F4F6"), ("textSecondary", "#4B5563", "#A1A7B3"), ("textTertiary", "#8A919E", "#6B7280"),
    ("border", "#E5E7EB", "#2A2F3C"), ("success", "#15803D", "#4ADE80"), ("warning", "#B45309", "#FBBF24"),
    ("error", "#B91C1C", "#F87171"), ("rating", "#F59E0B", "#FBBF24"),
]
color_rows = "".join(
    f'<tr><td><code>{name}</code></td><td><span class="swatch"><i style="background:{l}"></i>{l}</span></td>'
    f'<td><span class="swatch"><i style="background:{d}"></i>{d}</span></td></tr>' for name, l, d in colors)
types = [("display", 28, 36, 700, "Bold"), ("title1", 22, 30, 700, "Bold"), ("title2", 20, 28, 600, "SemiBold"),
         ("headline", 17, 24, 600, "SemiBold"), ("body", 16, 24, 400, "Regular"), ("callout", 15, 22, 500, "Medium"),
         ("caption", 13, 18, 400, "Regular"), ("caption2", 11, 14, 500, "Medium")]
type_rows = "".join(
    f'<div class="type-row"><span class="meta"><code>.{t}</code> {s}/{lh} · {wn}</span>'
    f'<span style="font-size:{s * 0.8:.1f}px;font-weight:{w};line-height:1.2">앱을 찾는 가장 빠른 방법</span></div>' for t, s, lh, w, wn in types)
p16 = f'''<div class="spec" style="flex:1.05">
<h2>컬러 (라이트 / 다크)</h2>
<table><tr><th>토큰</th><th>라이트</th><th>다크</th></tr>{color_rows}</table>
<div class="note">본문 텍스트는 배경 대비 <b>WCAG AA 4.5:1 이상</b>을 확인함. <code>textTertiary</code>는 플레이스홀더·비활성 전용(대비 3:1대)이라 본문에 쓰지 않음.</div>
</div>
<div class="spec" style="flex:1">
<h2>타이포그래피 (Pretendard, 크기/줄 높이 pt)</h2>
{type_rows}
<div class="s" style="margin-top:2px">※ 미리 보기는 0.8배 축소. 실제 앱은 Dynamic Type에 따라 커짐.</div>
<h2 style="margin-top:6px">간격 · 모서리 · 크기</h2>
{spec_table([
  ("간격", "4 · 8 · 12 · 16 · 20 · 24 · 32 (xxs~xxl). 화면 좌우 20"),
  ("모서리", "태그 6 · 입력창/버튼 10 · 카드 14 · 시트 20 · 앱 아이콘 = 변 × 0.2237"),
  ("크기", "터치 44 · 검색창 44 · 버튼 52 · 셀 아이콘 60 · 상세 아이콘 100 · 프로필 88"),
], head=("항목", "값"))}
<div class="note">코드: <code>DSColor.brandPrimary</code> 또는 <code>.foregroundStyle(.dsBrandPrimary)</code>, <code>Text("…").typography(.body)</code>, <code>DSSpacing.m</code>. 자세한 내용은 docs/design-system.md.</div>
</div>'''
pages.append(page(16, "디자인 토큰 요약", "Shared/DesignSystem 모듈", p16))

html = f'''<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<title>AppScout 와이어프레임</title>
<link rel="stylesheet" href="wireframe.css">
</head><body>
{"".join(pages)}
</body></html>'''
html = html.replace("</body></html>", '<script src="redline.js"></script>\n</body></html>')
html = html.replace("{{", "{").replace("}}", "}")
OUT.write_text(html, encoding="utf-8")
print(f"{len(pages)} pages → {OUT}")
