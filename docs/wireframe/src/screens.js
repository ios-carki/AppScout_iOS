// ============================================================
// screens.js — 화면 S1 ~ S14 · 99 체크리스트 · 렌더
// ============================================================
function screenPage(id, title, sub, frame, label, right) {
  return page(id, title, sub, `<div class="pbody">
    <div class="col" style="width:413px;flex-shrink:0"><div class="flabel">${label}</div>${frame}</div>
    <div class="col" style="flex:1">${LEGEND}${right}</div></div>`);
}
function statePage(id, title, sub, left, right, leftW = 800) {
  return page(id, title, sub, `<div class="pbody">
    <div class="col" style="width:${leftW}px;flex-shrink:0">${left}</div>
    <div class="col" style="flex:1">${right}</div></div>`);
}
const STATE_COLS = [['#', 26], ['레이어', 104], ['레이아웃', 80], ['크기 W × H', 90], ['padding', 52], ['간격', 60], ['배경', 84], ['모서리', 72], ['텍스트', 96], ['상태 · 제약', 0]];
const sspec = (key, rows) => specTable(key, rows, { cols: STATE_COLS });
const two = (a, b) => `<div style="display:flex;gap:16px"><div style="flex:1;min-width:0">${a}</div><div style="flex:1;min-width:0">${b}</div></div>`;
const NAVROW = (n) => ({ n, layer: '내비게이션 바', sub: '시스템 → 05', layout: '—', size: 'Fill × 52', pad: '—', gap: '—', bg: '투명 / 유리', border: '—', text: '시스템', act: '—' });
const TABROW = (n, which) => ({ n, layer: '탭 바', sub: '시스템 → 05', layout: '—', size: '345 × 62', pad: '—', gap: '좌우 24 · 아래 21', bg: '유리', border: 'radius 31', text: '—', act: `${which} 탭 선택 · 목록은 탭 바 뒤로 스크롤됨 (Safe Area 자동)` });

// ============================================================
// S1 검색 — 최근 검색어
// ============================================================
pages.push(screenPage('S1', '화면 — 검색 · 최근 검색어', 'SearchFeature · 탭 루트 · 검색어가 비어 있을 때 · 최근 검색어는 로컬 DB(SQLiteData) 관찰',
  device(scr.S1({
    nav: { root: { n: 1, b: 'l', dim: 'h' } },
    top: { n: 2, pad: true, b: 'l', nobox: true, gap: 'b' },
    search: { root: { n: 3, b: 'tr', dim: 'h' } },
    header: { root: { n: 5, b: 'l', dim: 'h' }, action: { n: 6, b: 'tr' } },
    section: { n: 4, b: 'bl', nobox: true },
    row: { root: { n: 7, b: 'l', dim: 'h' }, icon: { n: 8, b: 'tl', gap: 'r' }, text: { n: 9, b: 'bc', nobox: true }, del: { n: 10, b: 'tr', dim: 'w' } },
    tab: { root: { n: 11, b: 'l' } },
  }), { key: 'S1' }), 'S1 최근 검색어 <small>검색어 없음 · 최근 검색어 5개</small>',
  specTable('S1', [
    NAVROW(1),
    { n: 2, layer: '상단 VStack', layout: 'VStack', size: 'Fill × Hug', pad: 'H20 T8', gap: 'B12', bg: '—', border: '—', text: '—', act: '스크롤 밖에 고정 (목록만 스크롤)' },
    { n: 3, d: 1, layer: 'SearchBar', sub: '→ C1', layout: 'HStack', size: '353 × 44', pad: 'L12 R12', gap: '—', bg: '{surface}', border: 'radius 10', text: '`.callout`', act: '`$store.query` · 리턴 키 `.search` · 최대 100자' },
    { n: 4, layer: '최근 검색어 섹션', sub: '`ScrollView`', layout: 'VStack(spacing: 0)', size: '353 × Hug', pad: 'H20', gap: 'T12', bg: '—', border: '—', text: '—', act: '최대 10개라 `List` · `LazyVStack` 불필요 · 구분선 · 스와이프 없음 · 0개면 섹션 전체 숨김 → S3 빈 상태' },
    { n: 5, d: 1, layer: '섹션 헤더', layout: 'HStack · 양 끝', size: 'Fill × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '"최근 검색어" `.headline` · {textPrimary}', act: '—' },
    { n: 6, d: 2, layer: 'Button 전체 삭제', layout: '—', size: 'Hug × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`.callout` · {brandPrimary}', act: '<b>확인 없이</b> 즉시 전체 삭제 (설정의 전체 삭제는 확인 있음)' },
    { n: 7, d: 1, layer: '최근 검색어 행 ×5', layout: 'HStack', size: 'Fill × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '탭 → 입력창에 채우고 <b>즉시 검색</b> (디바운스 없음) + 검색 시각 갱신' },
    { n: 8, d: 2, layer: 'Image 시계', layout: '—', size: '18', pad: '—', gap: 'R12', bg: '—', border: '—', text: '{textSecondary}', act: '`clock.arrow.circlepath`' },
    { n: 9, d: 2, layer: 'Text 키워드', layout: '—', size: 'Fill × 24', pad: '—', gap: '—', bg: '—', border: '—', text: '`.body` · {textPrimary}', act: '`.lineLimit(1)` · 남은 폭 전부 (`maxWidth: .infinity, alignment: .leading`) · 저장된 표기 그대로' },
    { n: 10, d: 2, layer: 'Button 개별 삭제', layout: 'center', size: '44 × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`xmark` 15 · {textTertiary}', act: '`accessibilityLabel("카카오 삭제")` · 목록은 DB 관찰로 자동 갱신' },
    TABROW(11, '검색'),
  ]) + two(`<div class="note"><b>제약</b><br>
    · 최대 <b>10개</b>, 최신순 (<code>RecentKeywordUseCase.maxCount</code>)<br>
    · 대소문자 · 앞뒤 공백이 달라도 같은 검색어 ("Kakao " = "kakao") → 맨 위로, 표기는 마지막 입력값<br>
    · 저장 시점: <b>리턴 키</b> 또는 최근 검색어 탭. 디바운스 자동 검색은 저장하지 않음<br>
    · 공백뿐인 검색어는 저장 · 검색하지 않음</div>`,
    `<div class="tca"><b>TCA 제안</b><br>
    · <code>.task</code> → <code>onAppear</code> → <code>recentKeywordUseCase.observe()</code> 구독 → <code>recentKeywordsUpdated([RecentKeyword])</code><br>
    · <code>recentKeywordTapped(RecentKeyword)</code> · <code>recentKeywordDeleteTapped(id:)</code> · <code>clearRecentKeywordsTapped</code><br>
    · 구독은 <code>.cancellable(id: CancelID.recentKeywords)</code><br>
    · View: <code>.task { await store.send(.onAppear).finish() }</code></div>`)));

// ============================================================
// S2 검색 — 결과
// ============================================================
pages.push(screenPage('S2', '화면 — 검색 · 결과', 'SearchFeature · 300ms 디바운스 또는 리턴 키 → `searchAppsUseCase.execute(term:page:)` · 20개씩 페이지네이션',
  device(scr.S2({
    nav: { root: { n: 1, b: 'l' } },
    top: { n: 2, pad: true, b: 'l', nobox: true, gap: 'b' },
    search: { root: { n: 3, b: 'tr' }, clear: { n: 4, b: 'tr', dim: 'w' } },
    count: { n: 5, b: 'l', gap: 'b' },
    row: { root: { n: 6, b: 'l', dim: 'h', pad: true }, icon: { n: 7, b: 'tl', gap: 'r' }, price: { n: 8, b: 'tr' } },
    cell: { sep: { n: 9, b: 'br' } },
    tab: { root: { n: 10, b: 'l' } },
  }), { key: 'S2' }), 'S2 결과 <small>"카카오" · 11개</small>',
  specTable('S2', [
    NAVROW(1),
    { n: 2, layer: '상단 VStack', layout: 'VStack', size: 'Fill × Hug', pad: 'H20 T8', gap: 'B16', bg: '—', border: '—', text: '—', act: '—' },
    { n: 3, d: 1, layer: 'SearchBar · 입력됨', sub: '→ C1', layout: 'HStack', size: '353 × 44', pad: 'L12', gap: '—', bg: '{surface}', border: 'radius 10', text: '`.callout`', act: '글자가 바뀔 때마다 300ms 뒤 검색 · 대기 중엔 이전 화면 유지' },
    { n: 4, d: 2, layer: 'Button 지우기', layout: 'center', size: '44 × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '검색어 · 결과 · 에러 비우고 S1로 · 진행 중 요청 취소' },
    { n: 5, layer: 'Text 결과 개수', layout: '—', size: 'Hug × 18', pad: '—', gap: 'B8', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '"검색 결과 N개" (서버 `total`)' },
    { n: 6, layer: 'AppRowView ×N', sub: '→ C3 · `List(.plain)`의 행', layout: 'HStack(spacing: 12)', size: '353 × 84', pad: 'V8', gap: '—', bg: '—', border: '—', text: '—', act: '컨테이너는 `List` + `.listStyle(.plain)` (구분선 92 맞춤이 기본 동작) · 탭 → 상세 push (`Path.detail`) · 끝에서 5번째 행이 나타나면 다음 페이지' },
    { n: 7, d: 1, layer: 'AppIconView', layout: '→ C2', size: '60 × 60', pad: '—', gap: 'R12', bg: '—', border: 'r 13.4', text: '—', act: '—' },
    { n: 8, d: 1, layer: '가격', layout: '—', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '`formattedPrice`' },
    { n: 9, layer: '구분선', layout: '—', size: '왼쪽 92 ~ 끝 × 0.5', pad: '—', gap: '—', bg: '{border}', border: '—', text: '—', act: 'List 기본' },
    TABROW(10, '검색'),
  ]) + two(`<div class="note"><b>제약</b><br>
    · 디바운스 <b>300ms</b> (<code>continuousClock</code> 주입 → 테스트에서 <code>TestClock</code>)<br>
    · 새 검색이 시작되면 이전 요청 <b>취소</b> (<code>cancelInFlight: true</code>)<br>
    · 리턴 키: 디바운스 없이 즉시 + 최근 검색어 저장<br>
    · 페이지 크기 <b>20</b> · 이미 다음 페이지 요청 중이면 무시 · id 중복 제거<br>
    · <code>offset + items.count >= total</code> → <code>nextPage = nil</code></div>`,
    `<div class="tca"><b>TCA 제안</b><br>
    · <code>queryChanged(String)</code> 또는 <code>BindableAction</code> · <code>searchSubmitted</code> · <code>clearButtonTapped</code><br>
    · <code>searchResponse(Result&lt;Page&lt;AppSummary&gt;, any Error&gt;)</code><br>
    · <code>rowAppeared(id:)</code> · <code>nextPageResponse(…)</code> · <code>loadMoreRetryTapped</code> · <code>cellTapped(AppSummary)</code><br>
    · State: <code>results: IdentifiedArrayOf&lt;AppSummary&gt;</code>, <code>total</code>, <code>nextPage: PageRequest?</code>, <code>loadState</code></div>`)));

// ============================================================
// S3 검색 — 상태 모음
// ============================================================
pages.push(statePage('S3', '화면 — 검색 · 상태 모음', '입력 대기 · 첫 로딩 · 결과 없음 · 에러 · 목록 하단 — 치수는 S1 · S2 · C5와 같음',
  gallery([
    ['A. 입력 중', scr.S3typing(), '300ms 대기 — 이전 화면 유지'],
    ['B. 첫 로딩', scr.S3loading(), '결과가 없을 때만'],
    ['C. 결과 없음', scr.S3empty()],
    ['D. 에러', scr.S3error(), '결과가 하나도 없을 때'],
    ['E. 처음 (최근 검색어 0개)', scr.S1e()],
  ], 0.42),
  `<h2>상태 규칙</h2>
  ${simpleTable([['상태', 90], ['표시', 0]], [
    ['A 입력 중', '디바운스 대기 중에는 아무것도 바꾸지 않음 (이전 최근 검색어 또는 이전 결과 그대로)'],
    ['B 첫 로딩', '가운데 `LoadingView("검색 중…")` — <b>이전 결과가 있으면</b> 결과를 유지한 채 다시 불러옴'],
    ['C 결과 없음', '`EmptyStateView` · 제목 "‘검색어’ 검색 결과가 없어요" · 설명 "철자를 확인하거나 다른 키워드로 검색해 보세요."'],
    ['D 에러', '`ErrorStateView` + 다시 시도 (같은 검색어 · 같은 페이지) · 검색어를 바꾸면 에러 지우고 새로 검색'],
    ['E 처음', '제목 "어떤 앱을 찾고 있나요?" · 설명 "앱 이름, 개발사, 장르로 검색할 수 있어요."'],
    ['다음 페이지 실패', '화면 전체 에러가 아니라 목록 하단 "더 불러오지 못했어요. 다시 시도" (C5)'],
  ])}
  <h2>에러 문구 (DomainError.message)</h2>
  ${simpleTable([['케이스', 130], ['문구', 0]], [
    ['`.network`', '네트워크 연결을 확인해 주세요.'],
    ['`.server(message)`', '서버 메시지 또는 "서버에 문제가 생겼어요. 잠시 후 다시 시도해 주세요."'],
    ['`.validation`', '서버 검증 메시지 (예: 요청 값이 올바르지 않아요.)'],
    ['`.notFound`', '요청한 정보를 찾을 수 없어요.'],
    ['`.unknown`', '알 수 없는 문제가 발생했어요.'],
    ['`CancellationError`', '표시하지 않음 (새 검색이 이전 요청을 취소한 것)'],
  ])}
  <div class="tca"><b>TCA 제안</b> · <code>loadState: enum { idle, loading, loaded, empty, failed(String) }</code>처럼 한 값으로 표현하면 "로딩 중인데 에러" 같은 모순 상태가 생기지 않습니다. 다시 시도는 <code>retryButtonTapped</code>.</div>
  <div class="note"><b>테스트 포인트</b> · <code>TestClock</code>으로 299ms에는 요청이 없고 300ms에 한 번만 · 빠르게 두 번 입력하면 마지막 검색어만 · 빈 결과 → <code>.empty</code> · 실패 → <code>.failed</code></div>`, 820));

// ============================================================
// S4 상세 — 상단
// ============================================================
pages.push(screenPage('S4', '화면 — 상세 · 상단', 'AppDetailFeature · 결과/즐겨찾기 셀 탭 → push · `State(app: AppSummary)`로 시작',
  device(scr.S4({
    nav: { root: { n: 1, b: 'l' } }, back: { n: 2, b: 'tl' }, fav: { n: 3, b: 'tr' },
    root: { n: 4, pad: true, nobox: true, b: 'bl' },
    header: { n: 5, b: 'l', gap: 'b' }, icon: { n: 6, b: 'tl', gap: 'r', dim: 'h' }, name: { n: 7, b: 'tr' }, seller: { n: 8, b: 'ir' }, rating: { n: 9, b: 'tr' },
    tags: { n: 10, b: 'l', gap: 'b' }, metrics: { n: 11, b: 'l', dim: 'h', gap: 'b' }, store: { n: 12, b: 'l', dim: 'h', gap: 'b' },
    shotsTitle: { n: 13, b: 'l', gap: 'b' }, shot: { n: 14, b: 'tr', dim: 'w', gap: 'r' },
  }), { key: 'S4' }), 'S4 상세 상단 <small>로딩 완료</small>',
  specTable('S4', [
    { ...NAVROW(1), act: '`.inline` · 제목은 처음엔 비움, 스크롤해서 이름이 가려지면 표시' },
    { n: 2, d: 1, layer: '뒤로 (유리 원)', layout: '—', size: '44 × 44', pad: '—', gap: '왼쪽 16', bg: '유리', border: '원형', text: '시스템', act: '시스템 back 버튼' },
    { n: 3, d: 1, layer: '즐겨찾기 버튼', layout: '—', size: '44 × 44', pad: '—', gap: '오른쪽 16', bg: '유리', border: '원형', text: '`heart` / `heart.fill` · {brandPrimary}', act: '로딩 중에도 누를 수 있음 · `accessibilityLabel("즐겨찾기 추가/해제")`' },
    { n: 4, layer: 'ScrollView 콘텐츠', layout: 'VStack(alignment: .leading)', size: 'Fill × Hug', pad: 'H20 T8', gap: '—', bg: '{background}', border: '—', text: '—', act: '—' },
    { n: 5, d: 1, layer: '헤더 HStack', layout: 'HStack(alignment: .top, spacing: 12)', size: '353 × 100', pad: '—', gap: 'B16', bg: '—', border: '—', text: '—', act: '목록에서 받은 <b>AppSummary로 즉시</b> 그림' },
    { n: 6, d: 2, layer: 'AppIconView', layout: '→ C2', size: '100 × 100', pad: '—', gap: 'R12', bg: '—', border: 'r 22.4', text: '—', act: '—' },
    { n: 7, d: 2, layer: 'Text 이름', layout: '—', size: 'Fill × Hug (최대 2줄)', pad: '—', gap: 'B4', bg: '—', border: '—', text: '`.title1` · {textPrimary}', act: '`.lineLimit(2)`' },
    { n: 8, d: 2, layer: 'Text 개발사', layout: '—', size: 'Fill × 22', pad: '—', gap: 'B8', bg: '—', border: '—', text: '`.callout` · {textSecondary}', act: '`.lineLimit(1)`' },
    { n: 9, d: 2, layer: 'RatingView', layout: '→ C2', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '—' },
    { n: 10, d: 1, layer: '장르 태그 HStack', layout: 'HStack(spacing: 6)', size: 'Hug × 18', pad: '—', gap: 'B16', bg: '—', border: '—', text: '→ C2 TagView', act: '최대 3개, 한 줄' },
    { n: 11, d: 1, layer: '요약 지표', layout: 'HStack · 4칸 균등', size: '353 × 70', pad: 'V12', gap: 'B16', bg: '—', border: '위아래 0.5 · 칸 사이 0.5 {border}', text: '값 `.headline` · 라벨 `.caption` {textSecondary}', act: '평점(별 11) · 평가 수 · 연령 등급 · 가격' },
    { n: 12, d: 1, layer: 'App Store에서 보기', layout: '→ C4 primary', size: '353 × 52', pad: '—', gap: 'B24', bg: '{brandPrimary}', border: 'radius 10', text: '`.headline` · {onBrand}', act: '`@Dependency(\\.openURL)` · URL 없으면 버튼 숨김' },
    { n: 13, d: 1, layer: 'Text "미리 보기"', layout: '—', size: 'Hug × 28', pad: '—', gap: 'B12', bg: '—', border: '—', text: '`.title2` · {textPrimary}', act: '스크린샷 0개면 섹션 숨김' },
    { n: 14, d: 1, layer: '스크린샷', sub: 'ScrollView(.horizontal)', layout: 'HStack(spacing: 12)', size: '185 × 400 (비율 유지)', pad: '—', gap: 'R12', bg: '{surface} (로딩 전)', border: 'radius 14 · 0.5 {border}', text: '—', act: '오른쪽은 화면 끝까지 (`.contentMargins(.horizontal, 20)`) · 탭 → 전체 화면 (선택 과제)' },
  ]) + `<div class="tca"><b>TCA 제안</b> · <code>onAppear</code>에서 <code>.merge(상세 요청, 즐겨찾기 구독)</code> · <code>favoriteButtonTapped</code> · <code>appStoreButtonTapped</code> · <code>retryButtonTapped</code> · State: <code>app: AppSummary</code>, <code>detail: AppDetail?</code>, <code>loadState</code>, <code>isFavorite: Bool</code></div>`));

// ============================================================
// S5 상세 — 본문
// ============================================================
pages.push(screenPage('S5', '화면 — 상세 · 본문 (스크롤 아래)', 'AppDetailFeature · 설명 · 새로운 기능 · 정보',
  device(scr.S5({
    nav: { root: { n: 1, b: 'l' } },
    root: { n: 2, pad: true, nobox: true, b: 'bl' },
    descTitle: { n: 3, b: 'l', gap: 'b' }, desc: { n: 4, b: 'tr', dim: 'h' }, more: { n: 5, b: 'tr', dim: 'h' },
    newTitle: { n: 6, b: 'l' }, version: { n: 7, b: 'tr' }, notes: { n: 8, b: 'tr' },
    infoTitle: { n: 9, b: 'l', gap: 'b' }, infoRow: { n: 10, b: 'l', dim: 'h' },
  }), { key: 'S5' }), 'S5 상세 본문 <small>스크롤해서 제목이 바에 나타남</small>',
  specTable('S5', [
    { ...NAVROW(1), act: '스크롤로 이름이 가려지면 제목 "카카오톡 KakaoTalk" 표시' },
    { n: 2, layer: '콘텐츠 VStack', layout: 'VStack(alignment: .leading)', size: 'Fill × Hug', pad: 'H20', gap: '섹션 사이 24', bg: '—', border: '—', text: '—', act: '—' },
    { n: 3, d: 1, layer: 'Text "설명"', layout: '—', size: 'Hug × 28', pad: '—', gap: 'B8', bg: '—', border: '—', text: '`.title2` · {textPrimary}', act: '—' },
    { n: 4, d: 1, layer: 'Text 설명', layout: '—', size: 'Fill × 72 (3줄)', pad: '—', gap: '—', bg: '—', border: '—', text: '`.body` · {textPrimary}', act: '`.lineLimit(descriptionExpanded ? nil : 3)`' },
    { n: 5, d: 1, layer: 'Button 더 보기', layout: '오른쪽 정렬', size: 'Hug × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`.callout` · {brandPrimary}', act: '3줄을 넘을 때만 · 누르면 펼침 (다시 접기 없음)' },
    { n: 6, d: 1, layer: '"새로운 기능" 헤더', layout: 'HStack · firstTextBaseline', size: 'Fill × 28', pad: '—', gap: 'T16 (더 보기 44 포함 → 24)', bg: '—', border: '—', text: '`.title2` · {textPrimary} / 버전 `.caption` · {textSecondary}', act: '릴리스 노트가 없으면 섹션 숨김' },
    { n: 7, d: 2, layer: 'Text 버전 · 날짜', layout: '—', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '"버전 26.9.2 · 2026.11.03" (`yyyy.MM.dd`)' },
    { n: 8, d: 1, layer: 'Text 릴리스 노트', layout: '—', size: 'Fill × 72 (3줄)', pad: '—', gap: 'T8', bg: '—', border: '—', text: '`.body` · {textPrimary}', act: '`.lineLimit(3)`' },
    { n: 9, d: 1, layer: 'Text "정보"', layout: '—', size: 'Hug × 28', pad: '—', gap: 'T24 B8', bg: '—', border: '—', text: '`.title2` · {textPrimary}', act: '—' },
    { n: 10, d: 1, layer: '정보 행 ×5', layout: 'HStack · 양 끝', size: '353 × 44', pad: '—', gap: '—', bg: '—', border: '아래 0.5 {border}', text: '라벨 `.callout` {textSecondary} · 값 `.callout` {textPrimary}', act: '개발사 · 크기(MB 소수 1자리, `ByteCountFormatStyle`) · 연령 등급 · 호환성("iOS 17.0 이상") · 장르. 값이 없으면 "-"' },
  ]) + `<div class="note"><b>날짜 · 용량 포맷은 View에서</b> — <code>Date.FormatStyle</code>, <code>ByteCountFormatStyle</code>. State에는 원본 값(Date, Int)을 둡니다.</div>`));

// ============================================================
// S6 상세 — 상태 모음
// ============================================================
pages.push(statePage('S6', '화면 — 상세 · 상태 모음', '스켈레톤 · 즐겨찾기 토스트 · 에러 · 404',
  gallery([
    ['A. 진입 직후', scr.S6skel(), '요약은 즉시 · 나머지 스켈레톤'],
    ['B. 즐겨찾기 추가 직후', scr.S6fav(), '♥ + 토스트 (선택)'],
    ['C. 상세 실패', scr.S6error()],
    ['D. 404', scr.S6notfound(), '다시 시도 없음'],
  ], 0.55), `<h2>상태 규칙</h2>
  ${simpleTable([['상태', 110], ['표시', 0]], [
    ['A 로딩', '헤더(아이콘 · 이름 · 개발사 · 별점)는 AppSummary로 바로. 나머지는 {surface} 스켈레톤 (radius 6) — <b>전체 화면 스피너 금지</b> (덜 깜빡임)'],
    ['B 즐겨찾기', '하트는 <b>DB 저장 성공 후</b> 스트림 값으로만 바뀜 (낙관적 업데이트 금지) · 토스트 "즐겨찾기에 추가했어요" / "즐겨찾기에서 뺐어요" (C7, 선택 과제)'],
    ['C 실패', '헤더는 유지, 아래에 `ErrorStateView` + 다시 시도'],
    ['D 404', '"요청한 정보를 찾을 수 없어요." · 다시 시도 버튼 없음'],
    ['토글 실패', '알럿 "기기에 저장하지 못했어요" + `DomainError.message`'],
  ])}
  <h2>스켈레톤 치수 (로딩 완료 화면과 같은 자리)</h2>
  ${simpleTable([['블록', 120], ['크기', 0]], [
    ['태그', '150 × 18'], ['요약 지표', '353 × 70'], ['버튼', '353 × 52'], ['"미리 보기"', '120 × 28'], ['스크린샷', '185 × 400 ×2, 간격 12'],
  ])}
  <div class="tca"><b>왜 스트림인가?</b> 같은 앱이 즐겨찾기 탭에도 떠 있을 수 있습니다. 하트 상태를 화면마다 따로 들고 있으면 어긋나므로, DB를 단일 진실 원천으로 두고 <code>favoriteUseCase.observeIsFavorite(appID:)</code>를 구독합니다.</div>
  <div class="note"><b>테스트 포인트</b> · 하트 탭 → <code>toggle</code> 호출 · 스트림이 <code>true</code>를 내보내면 <code>isFavorite</code> 변경 · 실패 시 알럿 State · 404 → 다시 시도 없는 상태 · App Store 버튼 → <code>openURL</code> 호출</div>`, 1000));

// ============================================================
// S7 즐겨찾기 — 목록
// ============================================================
pages.push(screenPage('S7', '화면 — 즐겨찾기 · 목록', 'FavoritesFeature · 탭 루트 · 로컬 DB 관찰 스트림으로만 갱신',
  device(scr.S7({
    nav: { root: { n: 1, b: 'l' } },
    root: { n: 2, pad: true, nobox: true, b: 'bl' },
    count: { n: 3, b: 'l', gap: 'b' },
    row: { root: { n: 4, b: 'l', dim: 'h', pad: true }, icon: { n: 5, b: 'tl', gap: 'r' }, info: { n: 6, b: 'tr', nobox: true } },
    tab: { root: { n: 7, b: 'l' } },
  }), { key: 'S7' }), 'S7 즐겨찾기 <small>3개</small>',
  specTable('S7', [
    NAVROW(1),
    { n: 2, layer: '콘텐츠', sub: '`List` + `.listStyle(.plain)`', layout: '— (List가 행 배치)', size: 'Fill × Hug', pad: 'H20 T8', gap: '—', bg: '{background}', border: '—', text: '—', act: '스와이프 삭제(`.swipeActions`)는 <b>List에서만</b> 동작 → ScrollView 불가' },
    { n: 3, d: 1, layer: 'Text 개수 · 정렬', layout: '—', size: 'Hug × 18', pad: '—', gap: 'B8', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '"N개 · 최근 추가순" · 정렬은 `addedAt` 내림차순 고정' },
    { n: 4, d: 1, layer: 'AppRowView ×N', sub: '→ C3', layout: 'HStack(spacing: 12)', size: '353 × 84', pad: 'V8', gap: '—', bg: '—', border: '—', text: '—', act: '평가 수 · 가격 없음 (저장된 스냅샷) · 탭 → 상세 push' },
    { n: 5, d: 2, layer: 'AppIconView', layout: '→ C2', size: '60', pad: '—', gap: 'R12', bg: '—', border: '—', text: '—', act: '—' },
    { n: 6, d: 2, layer: '텍스트', layout: '→ C3', size: 'Fill × 68', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '—' },
    TABROW(7, '즐겨찾기'),
  ]) + two(`<div class="note"><b>제약</b><br>
    · 목록은 DB 관찰 스트림으로만 갱신 (삭제 후 배열에서 직접 빼지 않음)<br>
    · 오프라인에서도 보여야 함 → 목록 값은 로컬 스냅샷, 최신 정보는 상세에서 서버로<br>
    · 상세에서 ♥ 해제 후 돌아오면 그 셀은 이미 사라져 있어야 함</div>`,
    `<div class="tca"><b>TCA 제안</b><br>
    · State: <code>favorites: IdentifiedArrayOf&lt;FavoriteApp&gt;</code>, <code>path</code><br>
    · <code>favoritesUpdated</code> · <code>deleteSwiped(id:)</code> · <code>cellTapped(FavoriteApp)</code> · <code>searchButtonTapped</code><br>
    · 상세로 갈 때 <code>FavoriteApp → AppSummary</code> 변환 (평가 수 0, 가격 "-")</div>`)));

// ============================================================
// S8 즐겨찾기 — 상태 모음
// ============================================================
pages.push(statePage('S8', '화면 — 즐겨찾기 · 빈 상태 · 스와이프 삭제', 'FavoritesFeature',
  `<div style="display:flex;gap:24px">
    <div><div class="flabel">A. 비어 있음</div>${device(scr.S8empty({ empty: { root: { n: 1, b: 'l', pad: true }, title: { n: 2, b: 'tr' }, action: { n: 3, b: 'tr', dim: 'wh' } } }), { key: 'S8', scale: 0.7 })}</div>
    <div><div class="flabel">B. 스와이프 삭제</div>${device(scr.S8swipe({ delete: { n: 4, b: 'tr', dim: 'w' } }), { key: 'S8', scale: 0.7 })}</div>
  </div>`,
  `${LEGEND}
  ${sspec('S8', [
    { n: 1, layer: 'EmptyStateView', sub: '→ C5', layout: 'VStack(spacing: 12)', size: 'Fill × Hug', pad: '24', gap: '남은 영역 가운데', bg: '—', border: '—', text: '—', act: '`heart` 44 · 설명 "앱 상세에서 ♡를 눌러 모아 보세요."' },
    { n: 2, d: 1, layer: '제목', layout: '—', size: 'Hug × 24', pad: '—', gap: '—', bg: '—', border: '—', text: '`.headline` · {textPrimary}', act: '"아직 즐겨찾기한 앱이 없어요"' },
    { n: 3, d: 1, layer: '앱 검색하러 가기', layout: '→ C4 secondary', size: '200 × 52', pad: '—', gap: 'T8', bg: '—', border: '테두리 1 {border}', text: '`.headline`', act: '`delegate(.searchTabRequested)` → RootFeature가 `selectedTab = .search`' },
    { n: 4, layer: '삭제 액션', sub: '시스템 `.swipeActions`', layout: '—', size: '88 × 84', pad: '—', gap: '—', bg: '{error} (`.tint(.dsError)`)', border: '—', text: '`trash` + "삭제"', act: '확인 없이 삭제 · 끝까지 밀면 즉시 · 실패 시 알럿 "기기에 저장하지 못했어요. 저장 공간을 확인해 주세요."' },
  ])}
  <div class="tca"><b>탭 전환은 자식이 못 합니다.</b> FavoritesFeature는 탭을 모르므로 <code>delegate</code>로 알리고, RootFeature에 delegate 처리용 <code>Reduce</code>를 추가합니다 (지금은 BindingReducer + Scope만 있음).</div>
  <div class="note"><b>테스트 포인트</b> · 스트림 값 → 목록 반영 (<code>AsyncThrowingStream.makeStream</code>) · 스와이프 → <code>remove(appID:)</code> 호출 · 빈 상태 버튼 → delegate → RootFeature 탭 변경 (RootFeature 테스트)</div>`, 640));

// ============================================================
// S9 프로필
// ============================================================
pages.push(screenPage('S9', '화면 — 프로필', 'ProfileFeature · 탭 루트 · 진입할 때마다(`.task`) 서버에서 다시 조회 · 인증 없이 id=1 사용자',
  device(scr.S9({
    nav: { root: { n: 1, b: 'l' } }, gear: { n: 2, b: 'tr', dim: 'w' },
    head: { n: 3, b: 'l', nobox: true, gap: 'b' },
    avatar: { root: { n: 4, b: 'tl', dim: 'wh', gap: 'b' }, badge: { n: 5, b: 'tr', dim: 'w' } },
    name: { n: 6, b: 'tr', gap: 'b' }, email: { n: 7, b: 'tr' },
    groupTitle: { n: 8, b: 'l', gap: 'b' }, group: { n: 9, b: 'bl', pad: true },
    row: { root: { n: 10, b: 'tr', dim: 'h' } },
    tab: { root: { n: 11, b: 'l' } },
  }), { key: 'S9' }), 'S9 프로필',
  specTable('S9', [
    NAVROW(1),
    { n: 2, d: 1, layer: '설정 버튼', layout: '—', size: '44 × 44', pad: '—', gap: '오른쪽 16', bg: '유리', border: '원형', text: '`gearshape` 20 · {textPrimary}', act: '→ 설정 push (`Path.settings`) · `accessibilityLabel("설정")`' },
    { n: 3, layer: '프로필 헤더', layout: 'VStack · center', size: 'Fill × Hug', pad: '—', gap: 'T16 · B24', bg: '—', border: '—', text: '—', act: '—' },
    { n: 4, d: 1, layer: '프로필 이미지', layout: 'ZStack', size: '88 × 88', pad: '—', gap: 'B12', bg: '없으면 {brandPrimary} 12% + 이니셜', border: '원형', text: '이니셜 34 Bold · {brandPrimary}', act: 'Kingfisher · 탭 → PhotosPicker (S10)' },
    { n: 5, d: 2, layer: '편집 배지', layout: 'center', size: '28 × 28', pad: '—', gap: '오른쪽 아래 −2', bg: '{brandPrimary}', border: '원형 · 테두리 2 {background}', text: '`pencil` 13 · {onBrand}', act: '업로드 중 40% · 비활성' },
    { n: 6, d: 1, layer: 'Text 이름', layout: '—', size: 'Hug × 28', pad: '—', gap: 'B2', bg: '—', border: '—', text: '`.title2` · {textPrimary}', act: '—' },
    { n: 7, d: 1, layer: 'Text 이메일', layout: '—', size: 'Hug × 22', pad: '—', gap: '—', bg: '—', border: '—', text: '`.callout` · {textSecondary}', act: '—' },
    { n: 8, layer: '섹션 제목', layout: '—', size: 'Hug × 18', pad: '—', gap: '왼쪽 36 · B8', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '`Section("계정 정보")`' },
    { n: 9, layer: '그룹', sub: '→ C6', layout: 'VStack', size: '353 × 89', pad: 'H16', gap: '좌우 20', bg: '{surface}', border: 'radius 14', text: '—', act: '`.insetGrouped`' },
    { n: 10, d: 1, layer: 'DSListRow 이름 · 이메일', layout: '→ C6', size: 'Fill × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '제목 `.body` · {textPrimary}<br>값 `.callout` · {textSecondary}<br>꺾쇠 14 · {textTertiary}', act: '탭 → 편집 push (S11) · 값이 길면 말줄임' },
    TABROW(11, '프로필'),
  ]) + two(`<div class="note"><b>규칙</b><br>
    · 프로필이 아직 없을 때만 가운데 로딩/에러 (S10). 이미 있으면 기존 값을 유지한 채 조용히 갱신<br>
    · 편집 화면에서 저장 성공 → <code>delegate(.profileUpdated(Profile))</code>로 받은 값으로 즉시 갱신 (재조회 안 함)</div>`,
    `<div class="tca"><b>TCA 제안</b><br>
    · State: <code>profile: Profile?</code>, <code>loadState</code>, <code>path</code>, <code>isUploadingAvatar</code>, <code>@Presents alert</code><br>
    · <code>@Reducer enum Path { case editName(EditNameFeature), editEmail(EditEmailFeature), settings(SettingsFeature) }</code><br>
    · 부모는 <code>.path(.element(_, .editName(.delegate(.profileUpdated(let p)))))</code>만 처리</div>`)));

// ============================================================
// S10 프로필 — 상태 모음
// ============================================================
pages.push(statePage('S10', '화면 — 프로필 · 상태 모음', '첫 로딩 실패 · 사진 업로드 중 · 업로드 실패 — PhotosPicker → 압축 → 업로드',
  gallery([
    ['A. 첫 로딩 실패', scr.S10error(), '프로필이 없을 때만'],
    ['B. 사진 업로드 중', scr.S10uploading()],
    ['C. 업로드 실패', scr.S10fail()],
  ], 0.6), `<h2>상태 규칙</h2>
  ${simpleTable([['상태', 100], ['표시', 0]], [
    ['A 실패', '`ErrorStateView` + 다시 시도 — 이미 프로필이 있으면 표시하지 않고 기존 값 유지'],
    ['B 업로드 중', '이미지 위 스크림 + 흰 스피너 24 · 이메일 자리에 "사진을 올리는 중…" · 편집 배지 40%, 중복 선택 막기'],
    ['C 실패', '알럿 "사진을 바꾸지 못했어요" + `DomainError.message` · 기존 이미지 유지'],
  ])}
  <h2>처리 흐름</h2>
  ${simpleTable([['단계', 90], ['내용', 0]], [
    ['1 View', '이미지 · ✎ 탭 → `PhotosPicker` (이미지만 1장, 권한 요청 없음) · `.onChange`에서 `loadTransferable(type: Data.self)` → `store.send(.photoPicked(data))`'],
    ['2 Domain', '원본 20MB 초과면 요청 없이 `validation(.imageTooLarge)`'],
    ['3 Data', '`ImageCompressor`가 긴 변 1024px JPEG(0.8)로 축소'],
    ['4 Server', '`PUT /v1/users/me/avatar` multipart · JPEG/PNG만(415) · 5MB 이하(413)'],
    ['5 응답', '새 `avatar_url`에 `?v=수정시각` → Kingfisher 캐시 자동 갱신'],
  ])}
  <div class="tca"><b>TCA 제안</b> · <code>photoPicked(Data)</code> · <code>avatarUploadResponse(Result&lt;Profile, any Error&gt;)</code> · <code>PhotosPickerItem</code>은 Equatable/Sendable 문제로 State에 넣지 말고 View의 <code>@State</code>로.</div>`, 820));

// ============================================================
// S11 이름 편집
// ============================================================
pages.push(screenPage('S11', '화면 — 이름 · 이메일 편집', 'EditNameFeature / EditEmailFeature · 프로필에서 push · 저장 성공 → delegate + dismiss',
  device(scr.S11({
    nav: { root: { n: 1, b: 'l', dim: 'h' } }, back: { n: 2, b: 'tl' }, save: { n: 3, b: 'tr', pad: true },
    root: { n: 4, pad: true, nobox: true, b: 'bl' },
    field: { root: { n: 5, b: 'l', dim: 'wh', gap: 'b' }, text: { n: 6, b: 'tc' }, clear: { n: 7, b: 'tr' } },
    helper: { root: { n: 8, b: 'bl' }, right: { n: 9, b: 'tr' } },
  }), { key: 'S11' }), 'S11 이름 편집 <small>값이 바뀌어 저장 활성</small>',
  specTable('S11', [
    { ...NAVROW(1), act: '제목 "이름" / "이메일" · `.inline`' },
    { n: 2, d: 1, layer: '뒤로', layout: '—', size: '44 × 44', pad: '—', gap: '—', bg: '유리', border: '원형', text: '시스템', act: '저장 중에도 허용 (요청은 취소)' },
    { n: 3, d: 1, layer: '저장 버튼', sub: '`.topBarTrailing`', layout: '—', size: 'Hug × 44', pad: 'H16', gap: '오른쪽 16', bg: '유리', border: '캡슐', text: '시스템 17 Semibold · {brandPrimary} / 비활성 {textTertiary}', act: '<b>값이 바뀌었고 형식이 맞을 때만</b> 활성 · 저장 중엔 스피너' },
    { n: 4, layer: '콘텐츠', layout: 'VStack(alignment: .leading)', size: 'Fill × Hug', pad: 'H20 T16', gap: '—', bg: '{background}', border: '—', text: '—', act: '—' },
    { n: 5, d: 1, layer: '편집 필드', sub: '→ C6', layout: 'HStack', size: '353 × 44', pad: 'L12', gap: 'B8', bg: '{surface}', border: 'radius 10', text: '—', act: '진입 시 현재 값 + <b>자동 포커스</b> (`@FocusState`) · 리턴 키 = 저장' },
    { n: 6, d: 2, layer: 'TextField', layout: '—', size: 'Fill × 24', pad: '—', gap: '—', bg: '—', border: '—', text: '`.body` · {textPrimary}', act: '이메일은 `.keyboardType(.emailAddress)` · 자동 대문자 끔' },
    { n: 7, d: 2, layer: '지우기', layout: '—', size: '44 × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`xmark.circle.fill` 18 · {textTertiary}', act: '—' },
    { n: 8, d: 1, layer: '도움말', layout: 'HStack · 양 끝', size: 'Fill × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '이름 "2~20자" · 이메일은 도움말 없음' },
    { n: 9, d: 2, layer: '글자 수', layout: '—', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '"N/20" — 앞뒤 공백 제외 기준 · 이름만' },
  ]) + two(simpleTable([['항목', 60], ['규칙 (클라이언트 = 서버)', 0]], [
    ['이름', '앞뒤 공백 제거 후 2~20자 → 실패 422 `invalid_name`'],
    ['이메일', '필수 · 100자 이하 · 이름@도메인.최상위(2자+) → 422 `invalid_email`'],
    ['서버 422', '`validation(.server(message))` → 알럿이 아니라 <b>인라인 오류</b>'],
  ]), `<div class="tca"><b>TCA 제안</b><br>
    · <code>saveButtonTapped</code> → <code>profileUseCase.updateName</code><br>
    · 성공: <code>.send(.delegate(.profileUpdated(profile)))</code> 후 <code>await dismiss()</code><br>
    · <code>@Presents var alert</code> + <code>.ifLet(\\.$alert, action: \\.alert)</code><br>
    · 같은 모양이면 <code>EditFieldFeature</code> 하나 + 종류 enum도 가능</div>`)));

// ============================================================
// S12 편집 — 상태 모음
// ============================================================
pages.push(statePage('S12', '화면 — 편집 · 상태 모음', '형식 오류 · 저장 중 · 저장 실패',
  `<div style="display:flex;gap:18px">
    <div><div class="flabel" style="font-size:13px">A. 이메일 형식 오류</div>${device(scr.S12email({ field: { root: { n: 1, b: 'l' } }, helper: { n: 2, b: 'bl', gap: 'b' } }), { key: 'S12', scale: 0.48 })}</div>
    ${thumb('B. 저장 중', scr.S12saving(), 0.48, '입력 비활성')}
    ${thumb('C. 저장 실패', scr.S12fail(), 0.48, '입력값 유지')}
  </div>`, `${LEGEND}
  ${sspec('S12', [
    { n: 1, layer: '편집 필드 · 오류', layout: '→ C6', size: '353 × 44', pad: 'L12', gap: 'B8', bg: '{surface}', border: 'radius 10 · 1.5 {error}', text: '—', act: '입력이 0.5초 멈추거나 저장을 시도하면 표시' },
    { n: 2, layer: '인라인 오류', layout: 'HStack(spacing: 4)', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '`exclamationmark.circle` 14 + `.caption` · {error}', act: '문구 = `ValidationError.message`' },
  ])}
  <h2>상태 규칙</h2>
  ${simpleTable([['상태', 90], ['표시', 0]], [
    ['A 오류', '테두리 {error} 1.5 + 아래 오류 문구 · 저장 버튼 비활성'],
    ['B 저장 중', '저장 버튼 자리에 스피너 · 입력 비활성(60%) · ✕ 숨김 · 뒤로 가기 허용'],
    ['C 실패', '알럿 "저장하지 못했어요" + `DomainError.message` · 버튼 "확인" · 입력값 유지'],
  ])}
  <h2>검증 오류 문구 (ValidationError.message)</h2>
  ${simpleTable([['케이스', 130], ['문구', 0]], [
    ['이름 짧음/김', '이름은 2~20자로 입력해 주세요.'],
    ['이메일 비어 있음', '이메일을 입력해 주세요.'],
    ['이메일 형식', '이메일 형식이 올바르지 않아요.'],
    ['이메일 김', '이메일은 100자 이하로 입력해 주세요.'],
  ])}
  <div class="note"><b>테스트 포인트</b> · 형식 오류 → 저장 비활성 · 저장 성공 → delegate + <code>dismiss</code> 호출 (<code>$0.dismiss = DismissEffect { … }</code>) · 서버 422 → 인라인 오류 · 네트워크 오류 → 알럿</div>`, 660));

// ============================================================
// S13 설정
// ============================================================
pages.push(screenPage('S13', '화면 — 설정', 'SettingsFeature · 프로필 툴바 ⚙ → push · 테마는 `@Shared(.appStorage)`',
  device(scr.S13({
    nav: { root: { n: 1, b: 'l' } },
    title1: { n: 2, b: 'l', gap: 'b' }, group1: { n: 3, b: 'bl', pad: true }, seg: { n: 4, b: 'tr', dim: 'h' },
    title2: { n: 5, b: 'l' }, clear: { root: { n: 6, b: 'l', dim: 'h' } },
    version: { root: { n: 7, b: 'l' } }, server: { root: { n: 8, b: 'l' } }, license: { root: { n: 9, b: 'l' }, chev: { n: 10, b: 'tr' } },
  }), { key: 'S13' }), 'S13 설정',
  specTable('S13', [
    { ...NAVROW(1), act: '제목 "설정" · `.inline`' },
    { n: 2, layer: '섹션 제목 "화면"', layout: '—', size: 'Hug × 18', pad: '—', gap: '왼쪽 36 · T16 · B8', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '섹션: 화면 / 데이터 / 정보 (사이 24)' },
    { n: 3, layer: '그룹', sub: '→ C6', layout: 'VStack', size: '353 × 56', pad: 'H16 V12', gap: '좌우 20', bg: '{surface}', border: 'radius 14', text: '—', act: '—' },
    { n: 4, d: 1, layer: 'Picker 화면 모드', sub: '`.pickerStyle(.segmented)`', layout: '시스템', size: 'Fill × 32', pad: '—', gap: '—', bg: '시스템', border: '시스템', text: '시스템 13 · {textPrimary}', act: '시스템 / 라이트 / 다크 · <b>즉시 적용 · 재실행 후 유지</b>' },
    { n: 5, layer: '섹션 제목 "데이터"', layout: '—', size: 'Hug × 18', pad: '—', gap: 'T24 · B8', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '—' },
    { n: 6, d: 1, layer: '최근 검색어 전체 삭제', sub: 'DSListRow', layout: '→ C6', size: 'Fill × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`.body` · {error}', act: '탭 → 확인 다이얼로그 (S14) · 최근 검색어 0개면 비활성' },
    { n: 7, d: 1, layer: '앱 버전', layout: '→ C6', size: 'Fill × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '제목 `.body` · {textPrimary}<br>값 `.callout` · {textSecondary}', act: '`CFBundleShortVersionString (CFBundleVersion)`' },
    { n: 8, d: 1, layer: '서버 주소', layout: '→ C6', size: 'Fill × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '제목 `.body` · {textPrimary}<br>값 `.callout` · {textSecondary}', act: '<b>Debug 빌드에서만</b> · Info.plist `APIBaseURL`의 host:port' },
    { n: 9, d: 1, layer: '오픈소스 라이선스', layout: '→ C6', size: 'Fill × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`.body` · {textPrimary} · 꺾쇠 {textTertiary}', act: '→ 라이선스 목록 push (S14)' },
    { n: 10, d: 2, layer: '꺾쇠', layout: '—', size: '13', pad: '—', gap: '—', bg: '—', border: '—', text: '{textTertiary}', act: 'push되는 행만' },
  ]) + two(code(`
public enum AppTheme: String, CaseIterable, Sendable {
    case system, light, dark
}
extension SharedKey where Self == AppStorageKey<AppTheme>.Default {
    static var appTheme: Self {
        Self[.appStorage("appTheme"), default: .system]
    }
}
// SettingsFeature.State · RootFeature.State
@Shared(.appTheme) var theme
// RootView
.preferredColorScheme(store.theme.colorScheme)`, 'font-size:11px'),
    `<div class="tca"><b>TCA 제안</b><br>
    · <code>themeChanged(AppTheme)</code> 또는 <code>BindableAction</code><br>
    · <code>clearRecentKeywordsTapped</code> → <code>@Presents var confirmationDialog</code><br>
    · <code>.confirmationDialog(.presented(.clearConfirmed))</code> → <code>recentKeywordUseCase.deleteAll()</code><br>
    · 삭제 성공 후 안내 없음 (검색 탭은 DB 관찰로 자동 반영)</div>`)));

// ============================================================
// S14 설정 — 상태 모음
// ============================================================
pages.push(statePage('S14', '화면 — 설정 · 확인 다이얼로그 · 라이선스', 'SettingsFeature',
  `<div style="display:flex;gap:24px">
    <div><div class="flabel">A. 전체 삭제 확인</div>${device(scr.S14confirm({ card: { n: 1, b: 'tl', dim: 'w' } }), { key: 'S14', scale: 0.7 })}</div>
    ${thumb('B. 오픈소스 라이선스', scr.S14license(), 0.7, 'push · 텍스트만')}
  </div>`, `${LEGEND}
  ${sspec('S14', [
    { n: 1, layer: '확인 다이얼로그', sub: '시스템 `confirmationDialog`', layout: '시스템', size: '시스템', pad: '—', gap: '—', bg: '시스템', border: '시스템', text: '메시지 시스템 13 · "전체 삭제" {error} · "취소"', act: '"최근 검색어를 모두 삭제할까요? 삭제한 검색어는 되돌릴 수 없어요." · 버튼 `.destructive` / `.cancel`' },
  ])}
  <h2>라이선스 목록</h2>
  ${simpleTable([['라이브러리', 0], ['라이선스', 120]], [
    ['Pretendard', 'SIL OFL 1.1'], ['swift-composable-architecture', 'MIT'], ['Alamofire', 'MIT'], ['Kingfisher', 'MIT'], ['sqlite-data', 'MIT'], ['GRDB.swift', 'MIT'],
  ])}
  <div class="note"><b>테스트 포인트</b> · 테마 변경 → <code>@Shared</code> 값 변경 (<code>$0.$theme.withLock { … }</code>) · 전체 삭제 탭 → 다이얼로그 → 확인 → <code>deleteAll</code> 호출 · 취소 → 호출 없음</div>`, 640));

// ============================================================
// 99 구현 체크리스트
// ============================================================
pages.push(page('99', '구현 체크리스트 · 구현 순서', 'feature-guide.md와 같은 순서 — 1~2단계(검색 · 상세)만 해도 TCA 핵심은 대부분 다룸',
  `<div class="pbody">
  <div class="col" style="width:700px;flex-shrink:0">
    <h2>구현 순서</h2>
    ${simpleTable([['', 26], ['기능', 120], ['쪽', 90], ['핵심 연습', 0]], [
      ['1', '검색', 'S1 – S3 · C1 C3 C5', '디바운스 · 요청 취소 · 페이지네이션 · DB 구독 · `@Reducer enum Path`'],
      ['2', '상세', 'S4 – S6 · C2 C4', 'Effect 병합 · 즐겨찾기 스트림 · `openURL`'],
      ['3', '즐겨찾기', 'S7 – S8', '상세 재사용 · 스와이프 삭제 · delegate로 탭 전환'],
      ['4', '프로필', 'S9 – S12 · C6 C7', '편집 리듀서 분리 · delegate · dismiss · 알럿 · PhotosPicker'],
      ['5', '설정', 'S13 – S14', '`@Shared(.appStorage)` · 확인 다이얼로그'],
    ])}
    <h2>공통 체크</h2>
    ${simpleTable([['', 26], ['항목', 0]], [
      ['☐', '색은 `.dsX` 토큰만 · 글자는 `.typography()`만 · 간격은 `DSSpacing`만 (숫자 직접 X)'],
      ['☐', '화면 좌우 여백 20 · 모든 버튼 · 행 터치 영역 44 이상'],
      ['☐', 'Action은 사용자가 한 일로 이름 짓기 (`searchSubmitted`, `cellTapped`, `saveButtonTapped`)'],
      ['☐', '응답은 `xxxResponse(Result<T, any Error>)` · `CancellationError`는 에러로 표시하지 않기'],
      ['☐', '장기 실행 Effect는 `.cancellable(id:)` · View는 `.task { await store.send(.onAppear).finish() }`'],
      ['☐', '아이콘 버튼에 `accessibilityLabel` · 색만으로 상태 구분하지 않기 (하트는 채움/빈 모양)'],
      ['☐', '라이트 · 다크 모드에서 모두 확인 (01쪽 다크 값)'],
      ['☐', '모든 리듀서에 TestStore 테스트'],
    ])}
  </div>
  <div class="col" style="flex:1">
    <h2>파일 위치</h2>
    ${code(`
Projects/Feature/
  SearchFeature/      SearchFeature · SearchView            S1–S3
  AppDetailFeature/   AppDetailFeature · AppDetailView      S4–S6
  FavoritesFeature/   FavoritesFeature · FavoritesView      S7–S8
  ProfileFeature/     ProfileFeature · EditName/EmailFeature S9–S12
  SettingsFeature/    SettingsFeature · SettingsView        S13–S14
  RootFeature/        RootFeature · RootView (TabView)      05
Projects/Shared/DesignSystem/Sources/
  Foundation/         DSColor · DSTypography · DSLayout     01–02
  Components/         SearchBar                             C1
                      AppIconView · RatingView · TagView    C2
                      AppRowView (ListComponents)           C3
                      DSButtonStyle                         C4
                      StateViews                            C5
                      DSListRow (ListComponents)            C6`, 'font-size:11px')}
    <h2>이 문서 다시 만들기</h2>
    ${code(`
# 소스: docs/wireframe/src (lib.js · mock.js · pages.js · components.js · screens.js)
sh docs/wireframe/src/render.sh   # → docs/wireframe/AppScout_Wireframe.pdf`, 'font-size:11px')}
    <div class="note">치수를 바꾸려면 <code>mock.js</code>의 스타일 값을 고치면 됩니다. 레드라인과 "측정" 값은 렌더할 때 다시 잽니다.</div>
  </div></div>`));

// ============================================================
// 렌더
// ============================================================
document.getElementById('doc').innerHTML = pages.join('').replace('%%TOC%%', simpleTable([['ID', 50], ['내용', 0], ['쪽', 40]], TOC));
document.fonts.ready.then(() => {
  document.querySelectorAll('.rlroot').forEach(drawRedlines);
  fillMeasures();
  document.body.dataset.ready = '1';
});
