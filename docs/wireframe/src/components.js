// ============================================================
// components.js — 화면 정의 · 04 화면 개요 · 05 공통 UI · C1~C7 컴포넌트
// ============================================================

// ---------- 화면 빌더 (개요 · 상세 · 상태 페이지가 같은 함수를 씀) ----------
const back = (m) => GlassIcon('chevron-back', { m });
const scr = {
  S1: (m) => Screen({ nav: NavLarge('검색', { m: M(m, 'nav') }), body: RecentBody(m), tab: 'search', m }),
  S1e: (m) => Screen({ nav: NavLarge('검색'), body: SearchTop('', m) + CenterFill(EmptyState({ title: '어떤 앱을 찾고 있나요?', message: '앱 이름, 개발사, 장르로 검색할 수 있어요.', m: M(m, 'empty') })), tab: 'search', m }),
  S2: (m) => Screen({ nav: NavLarge('검색', { m: M(m, 'nav') }), body: ResultsBody(m), tab: 'search', m }),
  S3typing: () => Screen({ nav: NavLarge('검색'), body: SearchTop('카카') + V({ ...PAD, marginTop: 12 }, SectionHeader('최근 검색어', '전체 삭제') + KEYWORDS.slice(0, 3).map((w) => KeywordRow(w)).join('')), tab: 'search' }),
  S3loading: () => Screen({ nav: NavLarge('검색'), body: SearchTop('카카오') + CenterFill(Loading('검색 중…')), tab: 'search' }),
  S3empty: () => Screen({ nav: NavLarge('검색'), body: SearchTop('zzzzqq') + CenterFill(EmptyState({ title: '‘zzzzqq’ 검색 결과가 없어요', message: '철자를 확인하거나 다른 키워드로 검색해 보세요.' })), tab: 'search' }),
  S3error: () => Screen({ nav: NavLarge('검색'), body: SearchTop('카카오') + CenterFill(ErrorState('네트워크 연결을 확인해 주세요.')), tab: 'search' }),
  S4: (m) => Screen({ nav: NavInline('', { left: back(M(m, 'back')), right: GlassIcon('heart-outline', { m: M(m, 'fav') }), m: M(m, 'nav') }), body: DetailTop(APPS[0], { m }), tab: 'search', m }),
  S5: (m) => Screen({ nav: NavInline('카카오톡 KakaoTalk', { left: back(), right: GlassIcon('heart-outline'), m: M(m, 'nav') }), body: DetailBody(m), tab: 'search', m }),
  S6skel: () => Screen({ nav: NavInline('', { left: back(), right: GlassIcon('heart-outline') }), body: DetailTop(APPS[0], { loaded: false }), tab: 'search' }),
  S6fav: () => Screen({ nav: NavInline('', { left: back(), right: GlassIcon('heart', { color: C.brandPrimary }) }), body: DetailTop(APPS[0]), tab: 'search', overlay: Toast('즐겨찾기에 추가했어요') }),
  S6error: () => Screen({ nav: NavInline('', { left: back(), right: GlassIcon('heart-outline') }), body: DetailTop(APPS[0], { loaded: false, error: '네트워크 연결을 확인해 주세요.' }), tab: 'search' }),
  S6notfound: () => Screen({ nav: NavInline('', { left: back(), right: GlassIcon('heart-outline') }), body: DetailTop(APPS[0], { loaded: false, error: '요청한 정보를 찾을 수 없어요.', retry: false }), tab: 'search' }),
  S7: (m) => Screen({ nav: NavLarge('즐겨찾기', { m: M(m, 'nav') }), body: FavoritesBody({ m }), tab: 'fav', m }),
  S8empty: (m) => Screen({ nav: NavLarge('즐겨찾기'), body: CenterFill(EmptyState({ icon: 'heart-outline', title: '아직 즐겨찾기한 앱이 없어요', message: '앱 상세에서 ♡를 눌러 모아 보세요.', action: '앱 검색하러 가기', m: M(m, 'empty') })), tab: 'fav', m }),
  S8swipe: (m) => Screen({ nav: NavLarge('즐겨찾기'), body: FavoritesBody({ swipe: true, m }), tab: 'fav', m }),
  S9: (m) => Screen({ nav: NavLarge('프로필', { right: GlassIcon('settings-outline', { m: M(m, 'gear') }), m: M(m, 'nav') }), body: ProfileBody({ m }), tab: 'profile', m }),
  S10error: () => Screen({ nav: NavLarge('프로필', { right: GlassIcon('settings-outline') }), body: CenterFill(ErrorState('네트워크 연결을 확인해 주세요.')), tab: 'profile' }),
  S10uploading: () => Screen({ nav: NavLarge('프로필', { right: GlassIcon('settings-outline') }), body: ProfileBody({ uploading: true }), tab: 'profile' }),
  S10fail: () => Screen({ nav: NavLarge('프로필', { right: GlassIcon('settings-outline') }), body: ProfileBody(), tab: 'profile', overlay: Alert('사진을 바꾸지 못했어요', '이미지는 5MB 이하만 올릴 수 있어요.') }),
  S11: (m) => Screen({ nav: NavInline('이름', { left: back(M(m, 'back')), right: GlassText('저장', { m: M(m, 'save') }), m: M(m, 'nav') }), body: EditBody('크리스', { counter: '3/20', m }), tab: 'profile', m }),
  S12email: (m) => Screen({ nav: NavInline('이메일', { left: back(), right: GlassText('저장', { disabled: true }) }), body: EditBody('chris@', { error: '이메일 형식이 올바르지 않아요.', m }), tab: 'profile', m }),
  S12saving: () => Screen({ nav: NavInline('이름', { left: back(), right: GlassText('저장', { loading: true }) }), body: EditBody('크리스', { counter: '3/20', disabled: true }), tab: 'profile' }),
  S12fail: () => Screen({ nav: NavInline('이름', { left: back(), right: GlassText('저장') }), body: EditBody('크리스', { counter: '3/20' }), tab: 'profile', overlay: Alert('저장하지 못했어요', '네트워크 연결을 확인해 주세요.') }),
  S13: (m) => Screen({ nav: NavInline('설정', { left: back(), m: M(m, 'nav') }), body: SettingsBody(m), tab: 'profile', m }),
  S14confirm: (m) => Screen({ nav: NavInline('설정', { left: back() }), body: SettingsBody(), tab: 'profile', overlay: ConfirmDialog(m), m }),
  S14license: () => Screen({ nav: NavInline('오픈소스 라이선스', { left: back() }), body: LicensesBody(), tab: 'profile' }),
};

// 상태 갤러리: 작은 기기 여러 대 (레드라인 없음)
const thumb = (label, html, scale = 0.6, sub = '') =>
  `<div><div class="flabel" style="font-size:13px">${label}${sub ? `<small>${sub}</small>` : ''}</div>${device(html, { scale, draw: false })}</div>`;
const gallery = (items, scale = 0.6) => `<div style="display:flex;gap:18px;flex-wrap:wrap">${items.map(([l, h, s]) => thumb(l, h, scale, s)).join('')}</div>`;

// ============================================================
// 04 화면 개요
// ============================================================
pages.push(page('04', '화면 개요', 'Figma 캔버스처럼 모든 화면을 한 번에 — 각 화면의 치수 · 스펙은 S1 ~ S14',
  `<div style="display:flex;flex-direction:column;gap:18px">
    ${gallery([
      ['S1 검색', scr.S1(), '최근 검색어'], ['S2 검색', scr.S2(), '결과'], ['S3', scr.S3loading(), '로딩'], ['S3', scr.S3error(), '에러'],
      ['S4 상세', scr.S4(), '상단'], ['S5 상세', scr.S5(), '본문'], ['S6', scr.S6fav(), '즐겨찾기 토스트'], ['S7 즐겨찾기', scr.S7(), '목록'],
    ], 0.4)}
    ${gallery([
      ['S8', scr.S8empty(), '빈 상태'], ['S8', scr.S8swipe(), '스와이프'], ['S9 프로필', scr.S9()], ['S10', scr.S10uploading(), '업로드 중'],
      ['S11 이름 편집', scr.S11()], ['S12', scr.S12email(), '입력 오류'], ['S13 설정', scr.S13()], ['S14', scr.S14confirm(), '삭제 확인'],
    ], 0.4)}
  </div>`));

// ============================================================
// 05 공통 UI
// ============================================================
pages.push(page('05', '공통 UI — 상태 바 · 내비게이션 바 · 탭 바', '시스템이 그리는 부분 (iOS 26 Liquid Glass). 크기는 시스템 기본값이고, 우리가 정하는 건 제목 · 버튼 · 틴트뿐',
  `<div class="pbody">
  <div class="col" style="width:413px;flex-shrink:0"><div class="flabel">탭 루트 (S1)</div>
  ${device(scr.S1({
    status: { n: 1, b: 'ir' },
    nav: { root: { n: 2, b: 'l', dim: 'h', pad: true }, title: { n: 3, b: 'tr' } },
    tab: { root: { n: 6, b: 'l', dim: 'wh', pad: true }, active: { n: 7, b: 'tr' } },
  }), { key: 'G1' })}</div>
  <div class="col" style="flex:1">
    ${LEGEND}
    ${specTable('G1', [
      { n: 1, layer: '상태 바', sub: '시스템', layout: '—', size: 'Fill × 59', pad: '—', gap: '—', bg: '투명 (화면 배경)', border: '—', text: '시스템', act: '다크 모드에서 자동으로 흰 글자' },
      { n: 2, layer: '내비게이션 바 · 탭 루트', sub: '시스템', layout: 'HStack', size: 'Fill × 52', pad: 'L20 R16', gap: '—', bg: '투명 → 스크롤 시 유리', border: '—', text: '—', act: '`.navigationTitle("검색")` + `.toolbarTitleDisplayMode(.inlineLarge)`' },
      { n: 3, d: 1, layer: '큰 제목', layout: '—', size: 'Hug × 41', pad: '—', gap: '—', bg: '—', border: '—', text: '시스템 34 Bold · {textPrimary}', act: '왼쪽 정렬 · 스크롤하면 작아짐' },
      { n: 4, d: 1, layer: '툴바 버튼 (유리 원)', sub: 'S9 · S4 참고', layout: 'center', size: '44 × 44', pad: '—', gap: '오른쪽 16', bg: '유리 (시스템)', border: '원형', text: '아이콘 20 · {textPrimary}', act: '`ToolbarItem(placement: .topBarTrailing)` · `accessibilityLabel` 필수', nomeas: true },
      { n: 5, d: 1, layer: '텍스트 툴바 버튼 (유리 캡슐)', sub: 'S11 저장', layout: 'center', size: 'Hug × 44', pad: 'H16', gap: '—', bg: '유리 (시스템)', border: '캡슐', text: '시스템 17 Semibold · {brandPrimary}', act: '비활성이면 {textTertiary}', nomeas: true },
      { n: 6, layer: '탭 바', sub: '시스템 · 떠 있는 유리', layout: 'HStack', size: '345 × 62', pad: '4', gap: '좌우 24 · 아래 21', bg: '유리 (시스템)', border: 'radius 31', text: '—', act: '`TabView` + `.tint(.dsBrandPrimary)` — 직접 꾸미지 않음' },
      { n: 7, d: 1, layer: '선택된 탭', layout: 'VStack · center', size: '1/3 × 54', pad: '—', gap: '아이콘-라벨 2', bg: '선택 틴트 (시스템)', border: 'radius 27', text: '시스템 10 Semibold · {brandPrimary}', act: '아이콘 24 · 비선택은 {textPrimary}' },
    ])}
    <div style="display:flex;gap:16px">
      <div style="flex:1">
        <h2>push 화면 내비게이션 바 (S4 · S11 · S13)</h2>
        ${stage(NavInline('카카오톡 KakaoTalk', { left: GlassIcon('chevron-back', { m: { n: 4, b: 'tl', dim: 'wh' } }), right: GlassText('저장', { m: { n: 5, b: 'tr', pad: true } }), m: { root: { n: 8, b: 'l', dim: 'h' } } }),
          { key: 'G2', w: 520, pad: 16, cw: 393, bg: '#F3F4F6' })}
        <div class="muted" style="font-size:11.5px">⑧ 높이 52 · 제목은 시스템 17 Semibold 가운데 · <code>.navigationBarTitleDisplayMode(.inline)</code> · 뒤로 버튼은 시스템 기본</div>
      </div>
      <div style="flex:1">${code(`
// RootView
TabView(selection: $store.selectedTab) {
    Tab("검색", systemImage: "magnifyingglass", value: .search) {
        SearchView(store: store.scope(state: \\.search, action: \\.search))
    }
    Tab("즐겨찾기", systemImage: "heart", value: .favorites) { … }
    Tab("프로필", systemImage: "person.crop.circle", value: .profile) { … }
}
.tint(.dsBrandPrimary)

// 툴바 아이콘 버튼 — 고정 색 금지
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button { store.send(.settingsButtonTapped) } label: {
            Image(systemName: "gearshape")
        }
        .accessibilityLabel("설정")
    }
}`, 'font-size:11px')}</div>
    </div>
  </div></div>`));

// ============================================================
// C1 SearchBar
// ============================================================
pages.push(compPage('C1', '컴포넌트 — SearchBar', 'DesignSystem/Components/SearchBar.swift · 텍스트 상태는 바깥(TCA State)이 소유하고, 컴포넌트는 바인딩과 콜백만 받음',
  `<h2>Variant × 상태</h2>
  <div class="canvas"><div class="vgrid" style="grid-template-columns:1fr">
    ${vcell('비어 있음 · 플레이스홀더 (✕ 없음)', SearchBar(''))}
    ${vcell('입력됨 · ✕ 표시', SearchBar('카카오'))}
    ${vcell('긴 검색어 · 한 줄 말줄임', SearchBar('카카오톡 카카오맵 카카오페이 카카오뱅크 카카오T'))}
  </div></div>
  <h2>해부도 (실제 크기 × 1.4)</h2>
  ${stage(SearchBar('카카오', { m: { root: { n: 1, pad: true, dim: 'wh', b: 'l' }, icon: { n: 2, gap: 'r', b: 'tl' }, text: { n: 3, b: 'tc' }, clear: { n: 4, b: 'tr', dim: 'w' } } }),
    { key: 'C1', w: 560, cw: 353, pad: 24 })}
  <div class="note">✕ 버튼은 아이콘(18)보다 큰 <b>44 × 44 터치 영역</b>입니다. 그래서 입력됨 상태는 오른쪽 padding이 0이고, 버튼 자체가 여백 역할을 합니다.</div>`,
  `<h2>파라미터</h2>
  ${propsTable([
    ['`text`', '`Binding<String>`', '—', '`$store.query` — State가 소유'],
    ['`placeholder`', 'String', '"앱 이름이나 키워드를 검색해 보세요"', '최대 100자 (서버 제한과 같음)'],
    ['`onSubmit`', '`() -> Void`', '`{}`', '리턴 키(.search) → `store.send(.searchSubmitted)`'],
    ['`onClear`', '`(() -> Void)?`', 'nil', '✕ → `store.send(.clearButtonTapped)` · nil이면 text만 비움'],
  ])}
  <h2>레이어 스펙</h2>
  ${CSPEC('C1', [
    { n: 1, layer: 'HStack', layout: 'HStack(spacing: 8)', size: 'Fill × 44', pad: 'L12 · R0/12', gap: '—', bg: '{surface}', border: 'radius 10 (`DSRadius.s`)', text: '—', act: '`DSSize.searchBar` 높이 고정' },
    { n: 2, d: 1, layer: 'Image 돋보기', layout: '—', size: '17', pad: '—', gap: 'R8', bg: '—', border: '—', text: '{textSecondary}', act: '`magnifyingglass` · `accessibilityHidden`' },
    { n: 3, d: 1, layer: 'TextField', layout: '—', size: 'Fill × 22', pad: '—', gap: '—', bg: '—', border: '—', text: '`.callout` · {textPrimary} / 플레이스홀더 {textTertiary}', act: '`.submitLabel(.search)` · 자동 대문자 · 자동 수정 끔' },
    { n: 4, d: 1, layer: 'Button 지우기', layout: 'center', size: '44 × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`xmark.circle.fill` 18 · {textTertiary}', act: 'text가 비어 있으면 숨김 · `accessibilityLabel("검색어 지우기")`' },
  ])}
  ${code(`
SearchBar(
    text: $store.query.sending(\\.queryChanged),
    onSubmit: { store.send(.searchSubmitted) },
    onClear: { store.send(.clearButtonTapped) }
)
.padding(.horizontal, DSSpacing.screenHorizontal)   // 20
.padding(.top, DSSpacing.xs)                         // 8`, 'font-size:11px')}`));

// ============================================================
// C2 AppIconView · RatingView · TagView
// ============================================================
pages.push(compPage('C2', '컴포넌트 — AppIconView · RatingView · TagView', 'AppIconView.swift · RatingView.swift · ListComponents.swift (TagView)',
  `<h2>Variant</h2>
  <div class="canvas"><div class="vgrid" style="grid-template-columns:1fr 1fr">
    ${vcell('AppIconView · 목록 60', H({ alignItems: 'center', gap: 12 }, AppIcon(APPS[0], 60) + AppIcon(APPS[1], 60) + AppIcon(APPS[3], 60)))}
    ${vcell('AppIconView · 상세 100', AppIcon(APPS[0], 100))}
    ${vcell('RatingView · 평가 수 있음', Rating(4.6, '12.3만'))}
    ${vcell('RatingView · 평가 수 없음 (즐겨찾기)', Rating(3.2, null))}
    ${vcell('RatingView · 반 개 단위 (3.6 → ★★★½☆)', Rating(3.6, '94.2만'))}
    ${vcell('RatingView · 평가 0개', Rating(0, null))}
    ${vcell('TagView · 장르 (최대 3개, 한 줄)', H({ gap: 6 }, Tag('소셜 네트워킹') + Tag('생산성') + Tag('금융')))}
  </div></div>
  <h2>해부도 (× 2)</h2>
  ${stage(H({ alignItems: 'center' },
      AppIcon(APPS[0], 60, { n: 1, b: 'tl', dim: 'wh', gap: 'r' }) +
      V({ marginLeft: 16, gap: 10 }, Rating(4.6, '12.3만', { m: { root: { n: 2, b: 'tr', dim: 'h' }, stars: { n: 3, b: 'bl', gap: 'r' }, score: { n: 4, b: 'tc', gap: 'r' }, count: { n: 5, b: 'tr' } } }) +
        Tag('소셜 네트워킹', { n: 6, b: 'tr', pad: true }))),
    { key: 'C2', w: 560, pad: 20, cw: 260 })}`,
  `<h2>파라미터</h2>
  ${propsTable([
    ['AppIconView `url`', 'URL?', '—', '서버 `icon_url` · nil이면 회색 플레이스홀더'],
    ['AppIconView `size`', 'CGFloat', '`DSSize.iconList` (60)', '상세는 `DSSize.iconDetail` (100)'],
    ['RatingView `rating`', 'Double', '—', '0.0 ~ 5.0 (범위 밖은 자름)'],
    ['RatingView `count`', 'Int?', 'nil', 'nil이면 "· 평가 수" 숨김 · 1.2천 / 3.4만 / 1.2억'],
    ['RatingView `starSize`', 'CGFloat', '12', '상세 요약 지표는 11'],
    ['TagView `text`', 'String', '—', '장르 이름'],
  ])}
  <h2>레이어 스펙</h2>
  ${CSPEC('C2', [
    { n: 1, layer: 'AppIconView', sub: 'KFImage', layout: '—', size: 'size × size', pad: '—', gap: '—', bg: '로딩 전 {surface}', border: 'radius = size × 0.2237 (continuous) · 테두리 0.5 {border}', text: '—', act: 'Kingfisher 캐시 + 다운샘플링(표시 크기만큼) · 0.2초 페이드' },
    { n: 2, layer: 'RatingView', layout: 'HStack(spacing: 4)', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '`accessibilityLabel("별점 3.6점, 평가 941736개")` 하나로 묶음' },
    { n: 3, d: 1, layer: '별 5개', layout: 'HStack(spacing: 1)', size: '64 × 12', pad: '—', gap: 'R4', bg: '—', border: '—', text: '{rating} · semibold', act: '≥ 0.75 `star.fill` · ≥ 0.25 `star.leadinghalf.filled` · 나머지 `star`' },
    { n: 4, d: 1, layer: '점수', layout: '—', size: 'Hug × 18', pad: '—', gap: 'R4', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '소수 1자리 (`.fractionLength(1)`)' },
    { n: 5, d: 1, layer: '평가 수', layout: '—', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '`RatingView.compactCount(_:)`' },
    { n: 6, layer: 'TagView', layout: '—', size: 'Hug × 18', pad: 'H8 V2', gap: '태그 사이 6', bg: '{brandSecondary} 12%', border: 'Capsule', text: '`.caption2` · {brandSecondary}', act: '상세 장르 최대 3개' },
  ])}`));

// ============================================================
// C3 AppRowView
// ============================================================
pages.push(compPage('C3', '컴포넌트 — AppRowView (검색 결과 · 즐겨찾기 셀)', 'DesignSystem/Components/ListComponents.swift · 셀 전체가 탭 영역 (contentShape)',
  `<h2>Variant × 상태</h2>
  <div class="canvas"><div class="vgrid" style="grid-template-columns:1fr">
    ${vcell('검색 결과 · 평가 수 + 가격', AppRow(APPS[0]))}
    ${vcell('긴 이름 · 긴 개발사 → 한 줄 말줄임', AppRow(APPS[5]))}
    ${vcell('즐겨찾기 · 평가 수 · 가격 없음 (로컬 스냅샷)', AppRow(FAVS[1], { trailing: false, count: false }))}
    ${vcell('눌림 (List 기본 하이라이트)', AppRow(APPS[1], { pressed: true }))}
  </div></div>
  <h2>해부도 (× 1.45)</h2>
  ${stage(ListCell(AppRow(APPS[0], { m: { root: { n: 1, pad: true, b: 'l', dim: 'h' }, icon: { n: 2, b: 'tl', gap: 'r' }, info: { n: 3, b: 'tr', nobox: true },
      title: { n: 4, b: 'tr', gap: 'b' }, sub: { n: 5, b: 'ir', gap: 'b' }, rating: { root: { n: 6, b: 'tr' } }, price: { n: 7, b: 'tr' } } }), { m: { sep: { n: 8, b: 'br', dim: 'w' } } }),
    { key: 'C3', w: 560, pad: 20, cw: 353 })}`,
  `<h2>파라미터</h2>
  ${propsTable([
    ['`iconURL`', 'URL?', '—', '`AppSummary.iconURL`'],
    ['`title`', 'String', '—', '앱 이름 (한 줄)'],
    ['`subtitle`', 'String', '—', '`"\\(primaryGenre) · \\(sellerName)"`'],
    ['`rating` · `ratingCount`', 'Double · Int?', '— · nil', '즐겨찾기는 ratingCount nil'],
    ['`trailing`', '`@ViewBuilder`', '`EmptyView()`', '검색 결과: `Text(formattedPrice)` · 즐겨찾기: 없음'],
  ])}
  <h2>레이어 스펙</h2>
  ${CSPEC('C3', [
    { n: 1, layer: 'HStack', layout: 'HStack(spacing: 12) · center', size: 'Fill × 84', pad: 'V8', gap: '—', bg: '—', border: '—', text: '—', act: '`.contentShape(Rectangle())` → 빈 곳도 탭됨' },
    { n: 2, d: 1, layer: 'AppIconView', layout: '→ C2', size: '60 × 60', pad: '—', gap: 'R12', bg: '—', border: 'r 13.4', text: '—', act: '—' },
    { n: 3, d: 1, layer: 'VStack 텍스트', layout: 'VStack(alignment: .leading, spacing: 4)', size: 'Fill × 68', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '24 + 4 + 18 + 4 + 18' },
    { n: 4, d: 2, layer: 'Text 이름', layout: '—', size: 'Fill × 24', pad: '—', gap: 'B4', bg: '—', border: '—', text: '`.headline` · {textPrimary}', act: '`.lineLimit(1)`' },
    { n: 5, d: 2, layer: 'Text 장르 · 개발사', layout: '—', size: 'Fill × 18', pad: '—', gap: 'B4', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '`.lineLimit(1)`' },
    { n: 6, d: 2, layer: 'RatingView', layout: '→ C2', size: 'Hug × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '—' },
    { n: 7, d: 1, layer: 'trailing (가격)', layout: '—', size: 'Hug × 18', pad: '—', gap: 'Spacer(min 8)', bg: '—', border: '—', text: '`.caption` · {textSecondary}', act: '서버 `formatted_price` ("무료" / "₩4,400")' },
    { n: 8, layer: '구분선 (List)', layout: '—', size: '텍스트 시작 ~ 화면 끝 × 0.5', pad: '—', gap: '왼쪽 92 (20+60+12)', bg: '{border}', border: '—', text: '—', act: 'List 기본 · `.listRowSeparatorTint(.dsBorder)` · 행 여백 `.listRowInsets(H20)`' },
  ])}`));

// ============================================================
// C4 DSButtonStyle
// ============================================================
const btnRow = (kind, label) => ['기본', '눌림', '로딩', '비활성'].map((s, i) =>
  vcell(`${kind} · ${s}`, DSButton(label, { kind, pressed: i === 1, loading: i === 2, disabled: i === 3 }))).join('');
pages.push(compPage('C4', '컴포넌트 — DSButtonStyle', 'DesignSystem/Components/DSButton.swift · `Button("저장") { … }.buttonStyle(.ds(.primary, isLoading:))`',
  `<h2>Variant × 상태</h2>
  <div class="canvas"><div class="vgrid" style="grid-template-columns:repeat(4,1fr)">
    ${btnRow('primary', '저장')}${btnRow('secondary', '다시 시도')}${btnRow('destructive', '삭제')}
  </div></div>
  <h2>해부도 (× 1.4)</h2>
  ${stage(DSButton('App Store에서 보기', { m: { root: { n: 1, b: 'l', dim: 'wh' }, text: { n: 2, b: 'tr' } } }), { key: 'C4', w: 560, cw: 353 })}
  <div class="note">한 화면에 <b>primary는 하나</b>만. 보조 액션(다시 시도, 앱 검색하러 가기)은 secondary, 지우기·초기화는 destructive.</div>`,
  `<h2>파라미터</h2>
  ${propsTable([
    ['`kind`', '`DSButtonKind`', '—', '`.primary` · `.secondary` · `.destructive`'],
    ['`isLoading`', 'Bool', 'false', 'true면 글자 숨기고 스피너 · 터치 막음 (`allowsHitTesting(false)`)'],
    ['(환경) `isEnabled`', 'Bool', 'true', '`.disabled(!store.canSave)` → 불투명도 40%'],
  ])}
  <h2>레이어 스펙</h2>
  ${CSPEC('C4', [
    { n: 1, layer: '버튼 배경', layout: 'ZStack', size: 'Fill × 52 (min)', pad: '—', gap: '—', bg: 'primary {brandPrimary}<br>secondary 투명<br>destructive {error} 10%', border: 'radius 10 · secondary는 테두리 1 {border}', text: '—', act: '`.frame(maxWidth: .infinity, minHeight: DSSize.button)`' },
    { n: 2, d: 1, layer: 'label', layout: '—', size: 'Hug × 24', pad: '—', gap: '—', bg: '—', border: '—', text: '`.headline` · primary {onBrand} / secondary {textPrimary} / destructive {error}', act: '로딩 중 opacity 0 + `ProgressView().tint(같은 색)`' },
  ])}
  ${simpleTable([['상태', 90], ['표현', 0]], [
    ['눌림', '`opacity 0.8` + `scaleEffect(0.98)` · 0.15초 easeOut'],
    ['비활성', '`opacity 0.4` (색은 그대로)'],
    ['로딩', '글자 자리에 스피너 · 크기 변하지 않음'],
  ])}
  ${code(`
Button("저장") { store.send(.saveButtonTapped) }
    .buttonStyle(.ds(.primary, isLoading: store.isSaving))
    .disabled(!store.canSave)`, 'font-size:11px')}`));

// ============================================================
// C5 상태 뷰
// ============================================================
pages.push(compPage('C5', '컴포넌트 — EmptyStateView · ErrorStateView · LoadingView · 목록 하단', 'DesignSystem/Components/StateViews.swift · 목록 하단(페이지네이션)은 SearchFeature 안에서 조립',
  `<h2>Variant</h2>
  <div class="canvas"><div class="vgrid" style="grid-template-columns:1fr 1fr">
    ${vcell('EmptyStateView · 버튼 없음', EmptyState({ title: '검색 결과가 없어요', message: '다른 키워드로 검색해 보세요.' }))}
    ${vcell('EmptyStateView · 버튼 있음', EmptyState({ icon: 'heart-outline', title: '아직 즐겨찾기한 앱이 없어요', message: '앱 상세에서 ♡를 눌러 모아 보세요.', action: '앱 검색하러 가기' }))}
    ${vcell('ErrorStateView · 다시 시도', ErrorState('네트워크 연결을 확인해 주세요.'))}
    ${vcell('ErrorStateView · 404 (다시 시도 없음)', ErrorState('요청한 정보를 찾을 수 없어요.', { retry: false }))}
    ${vcell('LoadingView', V({ height: 140, justifyContent: 'center' }, Loading('검색 중…')))}
    ${vcell('목록 하단 3가지 (각 52)', ListFooter('loading') + ListFooter('failed') + ListFooter('end'))}
  </div></div>`,
  `<h2>해부도 (× 1.3)</h2>
  ${stage(EmptyState({ icon: 'heart-outline', title: '아직 즐겨찾기한 앱이 없어요', message: '앱 상세에서 ♡를 눌러 모아 보세요.', action: '앱 검색하러 가기',
      m: { root: { n: 1, pad: true, b: 'l' }, icon: { n: 2, b: 'tr', gap: 'b' }, title: { n: 3, b: 'tr', gap: 'b' }, msg: { n: 4, b: 'tr', gap: 'b' }, action: { n: 5, b: 'tr', dim: 'wh' } } }),
    { key: 'C5', w: 520, cw: 353 })}
  ${CSPEC('C5', [
    { n: 1, layer: 'VStack', layout: 'VStack(spacing: 12) · center', size: 'Fill × Fill', pad: '24', gap: '—', bg: '—', border: '—', text: '—', act: '`.frame(maxWidth: .infinity, maxHeight: .infinity)` → 남은 영역 가운데' },
    { n: 2, d: 1, layer: 'Image', layout: '—', size: '44', pad: 'B8', gap: '12 + 8 = 20', bg: '—', border: '—', text: '`.light` · {textTertiary}', act: '`accessibilityHidden`' },
    { n: 3, d: 1, layer: 'Text 제목', layout: '—', size: 'Hug × 24', pad: '—', gap: '12', bg: '—', border: '—', text: '`.headline` · {textPrimary}', act: '가운데 정렬' },
    { n: 4, d: 1, layer: 'Text 설명', layout: '—', size: 'Hug × 22', pad: '—', gap: '12 + 8', bg: '—', border: '—', text: '`.callout` · {textSecondary}', act: '여러 줄 가능' },
    { n: 5, d: 1, layer: 'Button', layout: '→ C4 secondary', size: '최대 200 × 52', pad: '—', gap: 'T8', bg: '—', border: '—', text: '—', act: '`actionTitle`과 `action`이 둘 다 있을 때만' },
  ])}
  ${simpleTable([['상황', 110], ['어떤 뷰', 0]], [
    ['첫 로딩', '화면 가운데 `LoadingView` — 이미 데이터가 있으면 덮지 않고 유지'],
    ['추가 로딩', '목록 하단 "불러오는 중" (스피너 16)'],
    ['빈 상태', '`EmptyStateView`'],
    ['에러 (화면)', '`ErrorStateView` + 다시 시도 — 데이터가 하나도 없을 때만'],
    ['에러 (작업)', '알럿 (C7) — 저장 · 삭제 · 토글처럼 사용자가 시킨 일이 실패했을 때'],
  ])}`, 640));

// ============================================================
// C6 DSListRow · 그룹 · 편집 필드
// ============================================================
pages.push(compPage('C6', '컴포넌트 — DSListRow · 그룹 · 편집 필드', 'ListComponents.swift (DSListRow) · 편집 필드는 ProfileFeature 안에서 조립 (EditNameView · EditEmailView 공용)',
  `<h2>Variant</h2>
  <div class="canvas"><div class="vgrid" style="grid-template-columns:1fr">
    ${vcell('그룹 (List .insetGrouped) · 값 + 꺾쇠', V({ marginHorizontal: -20 }, Group(ListRow('이름', 'Chris') + RowSep() + ListRow('이메일', 'chris@example.com'))))}
    ${vcell('값만 (꺾쇠 없음) · 위험 행', V({ marginHorizontal: -20 }, Group(ListRow('앱 버전', '1.0.0 (1)', { chevron: false }) + RowSep() + ListRow('최근 검색어 전체 삭제', null, { chevron: false, color: C.error }))))}
    ${vcell('편집 필드 · 기본 (글자 수)', EditField('크리스') + Helper('2~20자', '3/20'))}
    ${vcell('편집 필드 · 오류', EditField('chris@', { error: true }) + Helper('이메일 형식이 올바르지 않아요.', null, { error: true }))}
    ${vcell('편집 필드 · 저장 중 (입력 비활성)', EditField('크리스', { disabled: true }) + Helper('2~20자', '3/20'))}
  </div></div>`,
  `<h2>해부도 — 그룹 행 (× 1.3)</h2>
  ${stage(Group(ListRow('이메일', 'chris@example.com', { m: { root: { n: 2, b: 'l', dim: 'h' }, title: { n: 3, b: 'tl' }, value: { n: 4, b: 'tr', gap: 'r' }, chev: { n: 5, b: 'tr' } } }), { m: { n: 1, pad: true, b: 'tl' } }),
    { key: 'C6', w: 520, cw: 393, pad: 12 })}
  <h2>해부도 — 편집 필드 (× 1.3)</h2>
  ${stage(EditField('크리스', { m: { root: { n: 6, pad: true, b: 'l', dim: 'wh', gap: 'b' }, text: { n: 7, b: 'tc' }, clear: { n: 8, b: 'tr' } } }) + Helper('2~20자', '3/20', { m: { root: { n: 9, b: 'bl' } } }),
    { key: 'C6', w: 520, cw: 353 })}
  ${CSPEC('C6', [
    { n: 1, layer: '그룹 (List 섹션)', sub: '`.listStyle(.insetGrouped)`', layout: 'VStack', size: '353 × Hug', pad: 'H16', gap: '화면 좌우 20', bg: '{surface}', border: 'radius 14', text: '—', act: '`.scrollContentBackground(.hidden)` + 배경 {background} · 행 사이 0.5 {border}' },
    { n: 2, d: 1, layer: 'DSListRow', layout: 'HStack(spacing: 12)', size: 'Fill × 44 (min)', pad: '—', gap: '—', bg: '—', border: '—', text: '—', act: '`DSSize.minTouch` · 행 전체 탭' },
    { n: 3, d: 2, layer: '제목', layout: '—', size: 'Hug × 24', pad: '—', gap: '—', bg: '—', border: '—', text: '`.body` · {textPrimary} (위험 행 {error})', act: '—' },
    { n: 4, d: 2, layer: '값', layout: '—', size: 'Hug × 22', pad: '—', gap: 'Spacer(min 8) · R12', bg: '—', border: '—', text: '`.callout` · {textSecondary}', act: '`.lineLimit(1)` 말줄임' },
    { n: 5, d: 2, layer: '꺾쇠', layout: '—', size: '13 semibold', pad: '—', gap: '—', bg: '—', border: '—', text: '{textTertiary}', act: 'push되는 행만 (`showsChevron`)' },
    { n: 6, layer: '편집 필드 HStack', layout: 'HStack', size: 'Fill × 44', pad: 'L12', gap: 'B8', bg: '{surface}', border: 'radius 10 · 오류 시 1.5 {error}', text: '—', act: '진입 시 자동 포커스 (`@FocusState`) · 리턴 키 = 저장' },
    { n: 7, d: 1, layer: 'TextField', layout: '—', size: 'Fill × 24', pad: '—', gap: '—', bg: '—', border: '—', text: '`.body` · {textPrimary}', act: '저장 중 `.disabled(true)`' },
    { n: 8, d: 1, layer: 'Button 지우기', layout: 'center', size: '44 × 44', pad: '—', gap: '—', bg: '—', border: '—', text: '`xmark.circle.fill` 18 · {textTertiary}', act: '저장 중 숨김' },
    { n: 9, layer: '도움말 HStack', layout: 'HStack · 양 끝', size: 'Fill × 18', pad: '—', gap: '—', bg: '—', border: '—', text: '`.caption` · {textSecondary} / 오류 {error}', act: '이름: "2~20자" + "N/20" · 이메일: 글자 수 없음 · 오류는 `exclamationmark.circle` 14 + 문구' },
  ])}`));

// ============================================================
// C7 알럿 · 확인 다이얼로그 · 토스트
// ============================================================
const box = (inner, h) => V({ position: 'relative', height: h, borderRadius: 12, overflow: 'hidden', backgroundColor: C.background, borderWidth: 1, borderColor: C.border }, inner);
pages.push(compPage('C7', '컴포넌트 — 알럿 · 확인 다이얼로그 · 토스트', '알럿·다이얼로그는 시스템이 그림 (TCA `AlertState` · `ConfirmationDialogState`) · 토스트는 선택 과제',
  `<h2>Variant</h2>
  <div class="canvas"><div class="vgrid" style="grid-template-columns:1fr 1fr">
    ${vcell('알럿 · 작업 실패', box(Alert('저장하지 못했어요', '네트워크 연결을 확인해 주세요.'), 300))}
    ${vcell('확인 다이얼로그 · 위험 작업', box(ConfirmDialog(), 300))}
    ${vcell('토스트 · 즐겨찾기 추가', box(Toast('즐겨찾기에 추가했어요'), 160))}
    ${vcell('토스트 · 즐겨찾기 해제', box(Toast('즐겨찾기에서 뺐어요'), 160))}
  </div></div>
  <h2>토스트 해부도 (× 1.4)</h2>
  ${stage(V({ position: 'relative', height: 160 }, Toast('즐겨찾기에 추가했어요', { n: 1, b: 'l', dim: 'h', pad: true })), { key: 'C7', w: 560, cw: 353 })}`,
  `<h2>알럿 규칙</h2>
  ${simpleTable([['항목', 90], ['규칙', 0]], [
    ['제목', '무엇이 실패했는지: "저장하지 못했어요" · "사진을 바꾸지 못했어요" · "삭제하지 못했어요" · "기기에 저장하지 못했어요"'],
    ['메시지', '`DomainError.message` 그대로 (사용자용 문장으로 이미 작성됨)'],
    ['버튼', '"확인" 하나. 재시도 버튼은 넣지 않음 (화면의 버튼으로 다시 시도)'],
    ['공통화', '`AlertState.error(title:message:)` 같은 extension을 Feature 공용 위치에 두고 재사용'],
    ['닫기', '`.ifLet(\\.$alert, action: \\.alert)`가 처리 → `case .dismiss: state.alert = nil` 불필요'],
  ])}
  <h2>확인 다이얼로그 (설정 → 최근 검색어 전체 삭제)</h2>
  ${simpleTable([['항목', 90], ['값', 0]], [
    ['메시지', '"최근 검색어를 모두 삭제할까요? 삭제한 검색어는 되돌릴 수 없어요."'],
    ['버튼', '"전체 삭제" (`.destructive`) · "취소" (`.cancel`)'],
    ['상태', '`@Presents var confirmationDialog: ConfirmationDialogState<Action.Dialog>?`'],
  ])}
  <h2>토스트 (선택 과제 — DesignSystem에 없음)</h2>
  ${CSPEC('C7', [
    { n: 1, layer: '토스트 캡슐', layout: 'HStack(spacing: 8) · center', size: 'Hug × 44', pad: 'H18', gap: '탭 바 위 12 (아래에서 95)', bg: '{textPrimary} (반전)', border: 'Capsule', text: '`.callout` · {background} · `heart.fill` 16', act: '2초 뒤 사라짐 · `State.toast: String?` + `clock.sleep(for: .seconds(2))` → nil' },
  ])}
  ${code(`
extension AlertState where Action == SomeFeature.Action.Alert {
    static func error(title: String, message: String) -> Self {
        AlertState {
            TextState(title)
        } actions: {
            ButtonState(role: .cancel) { TextState("확인") }
        } message: {
            TextState(message)
        }
    }
}`, 'font-size:11px')}`));
