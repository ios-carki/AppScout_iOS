// ============================================================
// pages.js — 표지 · 토큰 · 공통 UI · 컴포넌트 페이지
// (화면 페이지는 screens.js)
// ============================================================
const pages = [];

const vcell = (label, inner, { dark, w } = {}) => `<div class="vcell"><div class="vl">${label}</div><div class="stage${dark ? ' dark' : ''}"${w ? ` style="width:${w}px"` : ''}>${inner}</div></div>`;
const propsTable = (rows) => simpleTable([['파라미터', 150], ['타입', 150], ['기본값', 90], ['설명', 0]], rows);
const compPage = (id, title, sub, left, right, leftW = 560) => page(id, title, sub, `<div class="pbody">
  <div class="col" style="width:${leftW}px;flex-shrink:0">${left}</div>
  <div class="col" style="flex:1">${right}</div></div>`);
const CSPEC = (key, rows) => specTable(key, rows, { cols: [
  ['#', 30], ['레이어', 118], ['레이아웃', 88], ['크기 W × H', 100], ['padding', 58], ['간격', 62],
  ['배경', 96], ['모서리', 70], ['텍스트', 108], ['상태 · 제약', 0]] });

// ============================================================
// 00 표지
// ============================================================
pages.push(page('00', 'AppScout — 와이어프레임 & 디자인 스펙',
  'TCA 복습 프로젝트 · iOS 17+ (iOS 26 Liquid Glass 기준으로 그림) · SwiftUI + TCA 1.26 · DesignSystem 모듈 토큰 사용',
  `<div class="pbody">
  <div class="col" style="width:520px;flex-shrink:0">
    <div style="display:flex;gap:16px;align-items:center;background:#4F46E5;border-radius:16px;padding:24px;color:#fff">
      <div style="width:84px;height:84px;border-radius:19px;background:#fff;display:flex;align-items:center;justify-content:center">
        <span class="ic" style="font-size:46px;line-height:46px;color:#4F46E5">&#${GLYPH.search};</span></div>
      <div><div style="font-family:'pretendard-bold';font-size:34px;line-height:42px">AppScout</div>
      <div style="font-size:15px;opacity:.9">앱을 찾고, 모아 보고, 내 정보를 관리하는 앱</div></div>
    </div>
    <h2>이 문서 보는 법</h2>
    ${simpleTable([['쪽', 70], ['내용', 0]], [
      ['01 – 03', '디자인 토큰 (컬러 · 타이포 · 간격 · 아이콘) — 코드에서는 DesignSystem 모듈의 이름 그대로 사용'],
      ['04 – 06', '내비게이션 구조 · 화면 개요 · 공통 UI (상태 바 · 내비게이션 바 · 탭 바)'],
      ['C1 – C7', '컴포넌트별 시트 — Variant × 상태, 파라미터, 해부도, 레이어 스펙'],
      ['S1 – S14', '화면별 시트 — 실제 크기 목업 + 레드라인 + 레이어 스펙 + 규칙 + TCA 제안'],
      ['99', '구현 체크리스트 — 검증 규칙, 에러 문구, 구현 순서'],
    ])}
    <h2>레드라인 읽는 법</h2>
    ${LEGEND}
    <div class="note">목업은 구현할 값(pt)을 그대로 넣어 그렸고, 그린 뒤 실제 위치를 재서 선과 숫자를 붙였습니다. 표의 <span style="color:#C2185B;font-family:Menlo">측정 W × H</span>는 그림에서 잰 값입니다.
    텍스트 높이는 <b>줄 높이(lineHeight)</b> 기준입니다. SwiftUI에서는 <code>.typography()</code>가 같은 높이를 맞춥니다.</div>
    <div class="note"><b>레이어 스펙 표 읽는 법</b><br>
    · <b>레이어</b> 열 작은 글씨 = 그 레이어를 만드는 <b>SwiftUI 타입</b> (<code>List</code>, <code>ScrollView</code>) 또는 재사용할 컴포넌트 (→ C3)<br>
    · <b>레이아웃</b> 열 = 그 컨테이너 <b>안</b>에서 자식을 놓는 방식. 예: <code>ScrollView</code> + <code>VStack(spacing: 0)</code> = ScrollView 안에 VStack<br>
    · <code>List</code>는 행을 스스로 배치하므로 레이아웃 열이 '—'입니다.</div>
    <div class="note"><b>그림과 실제 앱의 차이</b><br>
    · 아이콘은 SF Symbols 대신 비슷한 모양으로 그렸습니다. 실제 심볼 이름은 표와 02쪽에 있습니다.<br>
    · 앱 아이콘 · 스크린샷은 색 블록입니다. 실제로는 서버 <code>icon_url</code> · <code>screenshot_urls</code> 이미지.<br>
    · 상태 바 · 내비게이션 바 · 탭 바 · 알럿은 <b>시스템이 그리는 부분</b>입니다. 크기는 참고용이며 직접 그리지 않습니다.</div>
  </div>
  <div class="col" style="flex:1">
    <h2>목차</h2>
    %%TOC%%
  </div></div>`, '표지 · 목차'));

// ============================================================
// 01 컬러
// ============================================================
const COLOR_USE = {
  brandPrimary: '주요 액션 · 선택 상태 · 링크 · 탭 틴트', brandSecondary: '보조 강조 · 장르 태그', onBrand: 'brandPrimary 위 글자 · 아이콘',
  background: '화면 배경', surface: '검색창 · 카드 · 리스트 그룹 · 스켈레톤', surfaceElevated: '시트 · 알럿 · 팝오버',
  textPrimary: '본문 · 제목', textSecondary: '보조 설명 · 메타 정보', textTertiary: '플레이스홀더 · 비활성 · 꺾쇠 (본문 X)',
  border: '구분선 · 테두리', success: '성공', warning: '주의', error: '에러 · 삭제 · 검증 실패', rating: '별점',
};
const swCard = (k) => `<div style="display:flex;gap:10px;align-items:flex-start;padding:8px;border:1px solid #E5E7EB;border-radius:8px;background:#fff">
  <div style="display:flex;flex-shrink:0;border-radius:6px;overflow:hidden;border:1px solid rgba(0,0,0,.1)">
    <div style="width:40px;height:40px;background:${C[k]}"></div><div style="width:40px;height:40px;background:${DARK[k]}"></div></div>
  <div style="min-width:0"><div style="font-family:'pretendard-semibold'">${k} <span class="muted" style="font-family:Menlo;font-size:10.5px">${C[k]} / ${DARK[k]}</span></div>
  <div style="font-size:11.5px;color:#4B5563">${COLOR_USE[k]}</div>
  <div style="font-size:10.5px;font-family:Menlo;color:#4F46E5">.ds${k[0].toUpperCase() + k.slice(1)}</div></div></div>`;
pages.push(page('01', '디자인 토큰 — 컬러', 'Colors.xcassets · 라이트 / 다크 쌍 14개 · 코드에서는 `DSColor.x` 또는 `.dsX` — 고정 색(.black, Color(hex:)) 금지',
  `<div class="pbody">
  <div class="col" style="width:900px;flex-shrink:0">
    <h2>토큰 (왼쪽 칸 라이트 · 오른쪽 칸 다크)</h2>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">${Object.keys(C).map(swCard).join('')}</div>
    <h2>시스템 재질 (토큰 아님 — 그림 표현용)</h2>
    ${simpleTable([['이름', 140], ['그림 값', 220], ['실제', 0]], [
      ['유리 (glass)', '`rgba(255,255,255,0.86)` + 테두리 0.5 + 그림자', '툴바 버튼 · 탭 바 · 내비게이션 바 — iOS 26 Liquid Glass. 직접 그리지 않음'],
      ['스크림 (scrim)', '`rgba(17,24,39,0.36)`', '알럿 · 다이얼로그 뒤 — 시스템'],
      ['브랜드 틴트', '`brandPrimary` 12%', '선택된 탭 배경(시스템) · 프로필 기본 이미지 배경 `DSColor.brandPrimary.opacity(0.12)`'],
      ['틸 틴트', '`brandSecondary` 12%', 'TagView 배경'],
    ])}
  </div>
  <div class="col" style="flex:1">
    <h2>대비 (WCAG, 라이트 기준)</h2>
    ${simpleTable([['조합', 0], ['대비', 60], ['판정', 70]], [
      ['{textPrimary} / {background}', '17.7', 'AAA'],
      ['{textSecondary} / {background}', '7.6', 'AAA'],
      ['{brandPrimary} / {background}', '6.3', 'AA'],
      ['{onBrand} / {brandPrimary}', '6.3', 'AA'],
      ['{error} / {surface}', '5.9', 'AA'],
      ['{textTertiary} / {background}', '3.2', '본문 불가'],
    ])}
    <div class="note"><b>textTertiary</b>는 4.5:1에 못 미치므로 플레이스홀더 · 비활성 · 장식(꺾쇠, ✕ 아이콘)에만 씁니다. 목록 하단 "모든 결과를 확인했어요"처럼 의미 있는 문구는 textSecondary 이상.</div>
    <h2>사용 규칙</h2>
    ${simpleTable([['상황', 120], ['토큰', 0]], [
      ['화면 배경', '{background}'],
      ['입력창 · 그룹 · 스켈레톤', '{surface}'],
      ['주 버튼 / 글자', '{brandPrimary} / {onBrand}'],
      ['삭제 · 에러', '{error} (배경은 10%)'],
      ['별점', '{rating}'],
      ['장르 태그', '{brandSecondary} (배경 12%)'],
    ])}
    ${code(`
Text("제목").foregroundStyle(.dsTextPrimary)
RoundedRectangle(cornerRadius: DSRadius.s)
    .fill(.dsSurface)
Image(systemName: "star.fill")
    .foregroundStyle(.dsRating)`, 'font-size:11px')}
  </div></div>`));

// ============================================================
// 02 타이포 · 간격 · 모서리 · 크기 · 아이콘
// ============================================================
const FONT_USE = { display: '큰 제목', title1: '상세 앱 이름', title2: '섹션 제목 (설명 · 정보) · 프로필 이름', headline: '셀 제목 · 버튼 · 섹션 헤더',
  body: '본문 · 최근 검색어 · 행 제목 · 입력값', callout: '보조 본문 · 검색 입력 · 행 값', caption: '메타 · 결과 개수 · 도움말', caption2: '태그 · 배지' };
const WEIGHT = { 'pretendard': 'Regular', 'pretendard-medium': 'Medium', 'pretendard-semibold': 'SemiBold', 'pretendard-bold': 'Bold' };
const SYM = [
  ['검색 탭 · 검색창', 'search', '`magnifyingglass`'], ['즐겨찾기 탭 / 하트', 'heart', '`heart` · `heart.fill`'],
  ['프로필 탭', 'person-circle', '`person.crop.circle` · `.fill`'], ['설정', 'settings-outline', '`gearshape`'],
  ['최근 검색어', 'time-outline', '`clock.arrow.circlepath`'], ['지우기', 'close-circle', '`xmark.circle.fill`'],
  ['개별 삭제', 'close', '`xmark`'], ['별점', 'star', '`star.fill` · `star.leadinghalf.filled` · `star`'],
  ['사진 변경', 'pencil', '`pencil`'], ['에러', 'warning-outline', '`exclamationmark.triangle`'],
  ['검증 오류', 'alert-circle-outline', '`exclamationmark.circle`'], ['꺾쇠 / 뒤로', 'chevron-forward', '`chevron.right` · `chevron.left`'],
  ['스와이프 삭제', 'trash', '`trash`'],
];
pages.push(page('02', '디자인 토큰 — 타이포 · 간격 · 모서리 · 크기 · 아이콘', 'Pretendard v1.3.9 (SIL OFL 1.1) · `Text("…").typography(.headline)` · Dynamic Type은 relativeTo 기준',
  `<div class="pbody">
  <div class="col" style="width:760px;flex-shrink:0">
    <h2>DSTypography</h2>
    ${simpleTable([['토큰', 90], ['예시', 0], ['크기 / 줄', 76], ['굵기', 70], ['자간', 46], ['용도', 170]],
      Object.entries(F).map(([k, f]) => [`\`.${k}\``,
        `<span style="font-family:'${f.fontFamily}';font-size:${f.fontSize}px;line-height:${f.lineHeight}px;letter-spacing:${f.letterSpacing || 0}px;background:rgba(229,0,126,.06);box-shadow:inset 0 0 0 1px rgba(229,0,126,.25);display:inline-block">카카오톡 KakaoTalk</span>`,
        `${f.fontSize} / ${f.lineHeight}`, WEIGHT[f.fontFamily], String(f.letterSpacing || 0), FONT_USE[k]]))}
    <div class="muted" style="font-size:11.5px">분홍 박스 = 줄 높이. 레드라인의 텍스트 높이는 이 박스 기준입니다.</div>
    <h2>시스템 글꼴로 두는 곳 (DS 토큰 아님)</h2>
    ${simpleTable([['위치', 200], ['스타일', 0]], [
      ['탭 루트 큰 제목', '`.navigationTitle` + `.toolbarTitleDisplayMode(.inlineLarge)` — 34 Bold'],
      ['push 화면 제목', '`.navigationBarTitleDisplayMode(.inline)` — 17 Semibold'],
      ['탭 바 라벨 · 알럿 · 다이얼로그', '시스템 기본 (Dynamic Type · Liquid Glass 동작 유지)'],
    ])}
  </div>
  <div class="col" style="flex:1">
    <div style="display:flex;gap:20px">
      <div style="flex:1">
        <h2>DSSpacing</h2>
        ${simpleTable([['토큰', 60], ['pt', 36], ['주 사용처', 0]], [
          ['`.xxs`', '4', '셀 줄 사이 · 별-점수'], ['`.xs`', '8', '아이콘-텍스트 · 셀 위아래 · 도움말 위'],
          ['`.s`', '12', '셀 아이콘-본문 · 섹션 헤더 위'], ['`.m`', '16', '그룹 안 좌우 · 블록 사이'],
          ['`.l`', '20', '<b>화면 좌우 여백</b>'], ['`.xl`', '24', '섹션 사이 · 빈 상태 안쪽'], ['`.xxl`', '32', '큰 섹션 사이'],
        ])}
      </div>
      <div style="flex:1">
        <h2>DSRadius · DSSize</h2>
        ${simpleTable([['토큰', 96], ['pt', 40], ['사용처', 0]], [
          ['`DSRadius.xs`', '6', '스켈레톤'], ['`DSRadius.s`', '10', '검색창 · 입력 · 버튼'], ['`DSRadius.m`', '14', '그룹 · 스크린샷'],
          ['`DSRadius.l`', '20', '시트'], ['`.appIcon(size:)`', '× 0.2237', '앱 아이콘'],
          ['`DSSize.minTouch`', '44', '모든 버튼 · 행'], ['`DSSize.searchBar`', '44', '검색창 · 입력'], ['`DSSize.button`', '52', 'DSButtonStyle'],
          ['`DSSize.iconList`', '60', '목록 아이콘'], ['`DSSize.iconDetail`', '100', '상세 아이콘'], ['`DSSize.avatar`', '88', '프로필 이미지'],
        ])}
      </div>
    </div>
    <h2>아이콘 — SF Symbols 대응표 (그림의 아이콘은 비슷한 모양의 대체)</h2>
    ${simpleTable([['위치', 130], ['그림', 44], ['SF Symbol', 0]], SYM.map(([w, g, s]) =>
      [w, `<span class="ic" style="font-size:18px;line-height:18px;display:inline-block;color:#111827">&#${GLYPH[g]};</span>`, s]))}
  </div></div>`));

// ============================================================
// 03 내비게이션 구조
// ============================================================
const navBox = (title, sub, bg, bd, extra = '') => `<div style="border:1.5px solid ${bd};background:${bg};border-radius:10px;padding:10px 12px;${extra}">
  <div style="font-family:'pretendard-bold';font-size:13px">${title}</div><div style="font-size:11.5px;color:#4B5563">${sub}</div></div>`;
pages.push(page('03', '내비게이션 구조 · 화면 이동', 'RootFeature(TabView) 아래 탭마다 독립된 NavigationStack(path:) — push 대상은 `@Reducer enum Path`',
  `<div class="pbody">
  <div class="col" style="width:780px;flex-shrink:0">
    <h2>구조</h2>
    <div style="display:flex;flex-direction:column;gap:12px">
      ${navBox('RootFeature — TabView', '`selectedTab: Tab` (search · favorites · profile) · 탭 전환해도 각 탭의 스택 유지', '#EEF0FF', '#4F46E5')}
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:12px">
        <div style="display:flex;flex-direction:column;gap:8px">
          ${navBox('① 검색 탭 · SearchFeature', 'S1 · S2 · S3 — NavigationStack(path:)', '#fff', '#111827')}
          ${navBox('→ push 상세 · AppDetailFeature', 'S4 · S5 · S6 — `Path.detail`', '#F9FAFB', '#8A919E')}
        </div>
        <div style="display:flex;flex-direction:column;gap:8px">
          ${navBox('② 즐겨찾기 탭 · FavoritesFeature', 'S7 · S8', '#fff', '#111827')}
          ${navBox('→ push 상세 · AppDetailFeature', '같은 리듀서 재사용 — `Path.detail`', '#F9FAFB', '#8A919E')}
          ${navBox('빈 상태 버튼 → 검색 탭으로', '`delegate(.searchTabRequested)` → Root가 `selectedTab = .search`', '#FFF8E6', '#F0D9A0')}
        </div>
        <div style="display:flex;flex-direction:column;gap:8px">
          ${navBox('③ 프로필 탭 · ProfileFeature', 'S9 · S10', '#fff', '#111827')}
          ${navBox('→ push 이름 · 이메일 편집', 'S11 · S12 — `Path.editName` / `.editEmail`', '#F9FAFB', '#8A919E')}
          ${navBox('→ push 설정 · SettingsFeature', 'S13 · S14 — `Path.settings`', '#F9FAFB', '#8A919E')}
          ${navBox('사진 선택 — PhotosPicker', '시스템 시트 (권한 요청 없음)', '#F9FAFB', '#8A919E')}
        </div>
      </div>
    </div>
    ${code(`
// SearchFeature
@Reducer
public enum Path {
    case detail(AppDetailFeature)
}

// SearchView
NavigationStack(path: $store.scope(state: \\.path, action: \\.path)) {
    content
        .navigationTitle("검색")
        .toolbarTitleDisplayMode(.inlineLarge)
} destination: { store in
    switch store.case {
    case let .detail(store): AppDetailView(store: store)
    }
}`, 'font-size:11px')}
  </div>
  <div class="col" style="flex:1">
    <h2>화면 목록</h2>
    ${simpleTable([['ID', 40], ['화면', 150], ['Feature', 130], ['진입', 0]], [
      ['S1', '검색 — 최근 검색어', 'SearchFeature', '탭 루트 · 검색어가 빈 상태'],
      ['S2', '검색 — 결과', 'SearchFeature', '입력 후 300ms 또는 리턴 키'],
      ['S3', '검색 — 상태 모음', 'SearchFeature', '로딩 · 결과 없음 · 에러 · 페이지네이션'],
      ['S4', '상세 — 상단', 'AppDetailFeature', '결과 · 즐겨찾기 셀 탭 → push'],
      ['S5', '상세 — 본문', 'AppDetailFeature', '스크롤'],
      ['S6', '상세 — 상태 모음', 'AppDetailFeature', '스켈레톤 · 즐겨찾기 토스트 · 에러'],
      ['S7', '즐겨찾기 — 목록', 'FavoritesFeature', '탭 루트'],
      ['S8', '즐겨찾기 — 상태 모음', 'FavoritesFeature', '빈 상태 · 스와이프 삭제'],
      ['S9', '프로필', 'ProfileFeature', '탭 루트 · 진입마다 조회'],
      ['S10', '프로필 — 상태 모음', 'ProfileFeature', '첫 로딩 실패 · 업로드 중 · 업로드 실패'],
      ['S11', '이름 편집', 'EditNameFeature', '이름 행 탭 → push'],
      ['S12', '편집 — 상태 모음', 'EditName/EmailFeature', '형식 오류 · 저장 중 · 저장 실패'],
      ['S13', '설정', 'SettingsFeature', '툴바 ⚙ → push'],
      ['S14', '설정 — 상태 모음', 'SettingsFeature', '전체 삭제 확인 · 오픈소스 라이선스'],
    ])}
    <div class="note"><b>iOS 26 주의</b><br>· 탭 루트 제목은 텍스트를 툴바 아이템으로 넣지 말고 <code>.navigationTitle</code> + <code>.inlineLarge</code> (유리 버블에 갇힘)<br>
    · 시트 안에 NavigationStack을 둘 땐 루트에 비어 있지 않은 <code>navigationTitle</code> 필수 (바가 내려오는 현상)<br>
    · 아이콘 버튼 색을 <code>.black</code>으로 고정하지 않기 (다크 모드)</div>
    <div class="tca"><b>delegate 규칙</b> · 자식은 부모를 모릅니다. 부모에게 알릴 일은 <code>case delegate(Delegate)</code>로 보내고, 부모는 자식의 delegate만 처리합니다. 편집 화면은 <code>@Dependency(\\.dismiss)</code>로 스스로 닫습니다.</div>
  </div></div>`));
