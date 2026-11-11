// ============================================================
// mock.js — 화면·컴포넌트 목업
// 스타일 값 = SwiftUI 구현 값 (pt). m = { 파트이름: meta } 로 레드라인 번호를 붙임
// ============================================================

const TINT = {
  indigo: ['#E0E7FF', '#3730A3'], teal: ['#CCFBF1', '#115E59'], amber: ['#FEF3C7', '#92400E'],
  rose: ['#FFE4E6', '#9F1239'], sky: ['#E0F2FE', '#075985'], violet: ['#EDE9FE', '#5B21B6'],
};
// 시드 데이터 (Server/seed/apps.json) 그대로
const APPS = [
  { name: '카카오톡 KakaoTalk', seller: 'Kakao Corp.', genre: '소셜 네트워킹', rating: 3.6, count: '94.2만', price: '무료', initial: 'K', tint: 'indigo', genres: ['소셜 네트워킹', '생산성'] },
  { name: '카카오 T - 택시, 세차, 주차, 바이크, 항공, 퀵', seller: 'Kakao Mobility Corp.', genre: '여행', rating: 4.7, count: '46.4만', price: '무료', initial: 'T', tint: 'teal' },
  { name: '카카오맵 - 대한민국 No.1 지도앱', seller: 'Kakao Corp.', genre: '내비게이션', rating: 4.7, count: '18.8만', price: '무료', initial: 'M', tint: 'sky' },
  { name: '멜론(Melon)', seller: 'Kakao M Corp.', genre: '음악', rating: 2.4, count: '3.1만', price: '무료', initial: 'M', tint: 'rose' },
  { name: '카카오페이', seller: 'Kakao Pay Co., Ltd.', genre: '금융', rating: 4.6, count: '3.0만', price: '무료', initial: 'P', tint: 'amber' },
  { name: '카카오웹툰 – KAKAO WEBTOON', seller: 'Kakao Entertainment Corp.', genre: '엔터테인먼트', rating: 4.1, count: '2.8만', price: '무료', initial: 'W', tint: 'violet' },
  { name: '카카오뱅크', seller: 'KakaoBank Corp.', genre: '금융', rating: 3.2, count: '1.5만', price: '무료', initial: 'B', tint: 'teal' },
];
const FAVS = [
  { name: '토스', seller: 'Viva Republica', genre: '금융', rating: 4.2, initial: 'T', tint: 'sky' },
  { name: 'Notion: 메모, 작업, AI', seller: 'Notion Labs, Incorporated', genre: '생산성', rating: 4.8, initial: 'N', tint: 'violet' },
  { name: '카카오톡 KakaoTalk', seller: 'Kakao Corp.', genre: '소셜 네트워킹', rating: 3.6, initial: 'K', tint: 'indigo' },
];
const KEYWORDS = ['카카오', '토스', 'notion', '가계부', '날씨'];
const M = (m, k) => (m ? m[k] : undefined);

// ---------- 시스템 영역 ----------
function StatusBar(m) {
  const fg = '#000000';
  return H({ height: 59, alignItems: 'center', justifyContent: 'space-between' },
    Tx({ ...SF.status, color: fg, width: 132, textAlign: 'center', paddingTop: 4 }, '9:41') +
    V({ position: 'absolute', left: 133, top: 11, width: 126, height: 37, borderRadius: 19, backgroundColor: '#000' }) +
    H({ width: 132, justifyContent: 'center', alignItems: 'center', paddingTop: 4 },
      Ic('cellular', 15, fg, { marginRight: 5 }) + Ic('wifi', 15, fg, { marginRight: 5 }) + Ic('battery-full', 24, fg)),
    m);
}
const HomeIndicator = () =>
  V({ position: 'absolute', left: 129, bottom: 8, width: 135, height: 5, borderRadius: 3, backgroundColor: '#000', zIndex: 3 });

const GLASS = { backgroundColor: SYS.glass, borderWidth: 0.5, borderColor: SYS.glassStroke, boxShadow: '0 6px 18px rgba(17,24,39,.12)' };

// 유리 원형 버튼 (툴바 아이템 · 시스템이 그림)
function GlassIcon(icon, { color = C.textPrimary, m, size = 20 } = {}) {
  return V({ width: 44, height: 44, borderRadius: 22, ...GLASS, alignItems: 'center', justifyContent: 'center' },
    Ic(icon, size, color), m);
}
// 유리 캡슐 버튼 (텍스트 툴바 아이템)
function GlassText(label, { color = C.brandPrimary, disabled, loading, m } = {}) {
  return V({ height: 44, minWidth: 64, paddingHorizontal: 16, borderRadius: 22, ...GLASS, alignItems: 'center', justifyContent: 'center' },
    loading ? Spinner(18, C.textSecondary) : Tx({ ...SF.headline, color: disabled ? C.textTertiary : color }, label), m);
}

// 탭 루트: 큰 제목 (inlineLarge)
function NavLarge(title, { right, m } = {}) {
  return H({ height: 52, alignItems: 'center', justifyContent: 'space-between', paddingLeft: 20, paddingRight: 16 },
    Tx({ ...SF.largeTitle, color: C.textPrimary }, title, M(m, 'title')) + (right || ''), M(m, 'root'));
}
// push 화면: 가운데 제목 (inline)
function NavInline(title, { left, right, m } = {}) {
  return H({ height: 52, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 16 },
    (left ? V({ position: 'absolute', left: 16, top: 4 }, left) : '') +
    Tx({ ...SF.headline, color: C.textPrimary, maxWidth: 220 }, title, M(m, 'title'), 1) +
    (right ? V({ position: 'absolute', right: 16, top: 4 }, right) : ''), M(m, 'root'));
}

// iOS 26 떠 있는 유리 탭 바 (시스템이 그림)
function TabBar(active, m) {
  const item = (key, icon, label) => {
    const on = key === active;
    return V({ flex: 1, alignItems: 'center', justifyContent: 'center', borderRadius: 27, backgroundColor: on ? SYS.brandTint : 'transparent' },
      Ic(icon, 24, on ? C.brandPrimary : C.textPrimary) +
      Tx({ ...SF.tab, color: on ? C.brandPrimary : C.textPrimary, marginTop: 2 }, label),
      M(m, on ? 'active' : undefined));
  };
  return H({ position: 'absolute', left: 24, right: 24, bottom: 21, height: 62, borderRadius: 31, padding: 4, ...GLASS, zIndex: 2 },
    item('search', 'search', '검색') + item('fav', on('fav', active) ? 'heart' : 'heart-outline', '즐겨찾기') + item('profile', on('profile', active) ? 'person-circle' : 'person-circle-outline', '프로필'),
    M(m, 'root'));
}
const on = (k, active) => k === active;

// 화면 조립: 상태 바 + 내비 + 본문 + (탭 바) + 홈 인디케이터
function Screen({ nav, body, tab, overlay = '', m }) {
  return StatusBar(M(m, 'status')) + (nav || '') +
    V({ flex: 1, overflow: 'hidden' }, body, M(m, 'body')) +
    (tab ? TabBar(tab, M(m, 'tab')) : '') + overlay + HomeIndicator();
}

// ---------- DS: SearchBar ----------
function SearchBar(text, { m, focused } = {}) {
  const has = !!text;
  return H({ height: 44, alignItems: 'center', backgroundColor: C.surface, borderRadius: 10, paddingLeft: 12, paddingRight: has ? 0 : 12,
      borderWidth: focused ? 1.5 : 0, borderColor: C.brandPrimary },
    Ic('search', 17, C.textSecondary, { marginRight: 8 }, M(m, 'icon')) +
    Tx({ ...F.callout, color: has ? C.textPrimary : C.textTertiary, flex: 1 }, has ? text : '앱 이름이나 키워드를 검색해 보세요', M(m, 'text'), 1) +
    (has ? V({ width: 44, height: 44, alignItems: 'center', justifyContent: 'center' }, Ic('close-circle', 18, C.textTertiary), M(m, 'clear')) : ''),
    M(m, 'root'));
}

// ---------- 섹션 헤더 · 최근 검색어 행 (SearchFeature) ----------
function SectionHeader(title, action, m) {
  return H({ height: 44, alignItems: 'center', justifyContent: 'space-between' },
    Tx({ ...F.headline, color: C.textPrimary }, title, M(m, 'title')) +
    (action ? V({ height: 44, justifyContent: 'center' }, Tx({ ...F.callout, color: C.brandPrimary }, action), M(m, 'action')) : ''),
    M(m, 'root'));
}
function KeywordRow(word, m) {
  return H({ height: 44, alignItems: 'center' },
    Ic('time-outline', 18, C.textSecondary, { marginRight: 12 }, M(m, 'icon')) +
    Tx({ ...F.body, color: C.textPrimary, flex: 1 }, word, M(m, 'text'), 1) +
    V({ width: 44, height: 44, alignItems: 'center', justifyContent: 'center' }, Ic('close', 15, C.textTertiary), M(m, 'del')),
    M(m, 'root'));
}

// ---------- DS: AppIconView · RatingView · TagView ----------
function AppIcon(app, size, m) {
  const t = TINT[app.tint];
  return V({ width: size, height: size, borderRadius: +(size * 0.2237).toFixed(1), backgroundColor: t[0], borderWidth: 0.5, borderColor: C.border, alignItems: 'center', justifyContent: 'center' },
    Tx({ fontFamily: 'pretendard-bold', fontSize: Math.round(size * 0.4), lineHeight: Math.round(size * 0.4), color: t[1] }, app.initial), m);
}
function Stars(rating, size = 12, m) {
  let s = '';
  for (let i = 0; i < 5; i++) {
    const v = rating - i;
    s += Ic(v >= 0.75 ? 'star' : v >= 0.25 ? 'star-half' : 'star-outline', size, C.rating);
  }
  return H({ alignItems: 'center', gap: 1 }, s, m);
}
function Rating(rating, count, { size = 12, m } = {}) {
  return H({ alignItems: 'center', height: 18 },
    Stars(rating, size, M(m, 'stars')) +
    Tx({ ...F.caption, color: C.textSecondary, marginLeft: 4 }, rating.toFixed(1), M(m, 'score')) +
    (count ? Tx({ ...F.caption, color: C.textSecondary, marginLeft: 4 }, '· ' + count, M(m, 'count')) : ''),
    M(m, 'root'));
}
function Tag(text, m) {
  return V({ paddingHorizontal: 8, paddingVertical: 2, borderRadius: 999, backgroundColor: SYS.tealTint, alignSelf: 'flex-start' },
    Tx({ ...F.caption2, color: C.brandSecondary }, text), m);
}

// ---------- DS: AppRowView ----------
function AppRow(app, { trailing = true, count = true, m, pressed } = {}) {
  return H({ paddingVertical: 8, alignItems: 'center', opacity: pressed ? 0.6 : 1 },
    AppIcon(app, 60, M(m, 'icon')) +
    V({ flex: 1, marginLeft: 12 },
      Tx({ ...F.headline, color: C.textPrimary }, app.name, M(m, 'title'), 1) +
      Tx({ ...F.caption, color: C.textSecondary, marginTop: 4 }, `${app.genre} · ${app.seller}`, M(m, 'sub'), 1) +
      V({ marginTop: 4 }, Rating(app.rating, count ? app.count : null, { m: M(m, 'rating') })),
      M(m, 'info')) +
    (trailing && app.price ? Tx({ ...F.caption, color: C.textSecondary, marginLeft: 8 }, app.price, M(m, 'price')) : ''),
    M(m, 'root'));
}
// List 한 줄 = AppRow + 구분선(텍스트 시작점 92부터)
function ListCell(inner, { last, m } = {}) {
  return V({}, inner + (last ? '' : V({ position: 'absolute', left: 72, right: -20, bottom: 0, height: 0.5, backgroundColor: C.border }, '', M(m, 'sep'))), M(m, 'cell'));
}

// ---------- DS: DSButtonStyle ----------
function DSButton(label, { kind = 'primary', loading, disabled, pressed, m, style } = {}) {
  const fg = kind === 'primary' ? C.onBrand : kind === 'secondary' ? C.textPrimary : C.error;
  const bg = kind === 'primary' ? C.brandPrimary : kind === 'secondary' ? 'transparent' : SYS.errorTint;
  return V({ height: 52, borderRadius: 10, alignItems: 'center', justifyContent: 'center', backgroundColor: bg,
      borderWidth: kind === 'secondary' ? 1 : 0, borderColor: C.border,
      opacity: disabled ? 0.4 : pressed ? 0.8 : 1, transform: pressed ? 'scale(0.98)' : undefined, ...style },
    loading ? Spinner(20, fg) : Tx({ ...F.headline, color: fg }, label, M(m, 'text')), M(m, 'root'));
}

// ---------- DS: 상태 뷰 ----------
function EmptyState({ icon = 'search-outline', title, message, action, m } = {}) {
  return V({ alignItems: 'center', padding: 24 },
    Ic(icon, 44, C.textTertiary, { marginBottom: 20 }, M(m, 'icon')) +
    Tx({ ...F.headline, color: C.textPrimary, textAlign: 'center' }, title, M(m, 'title')) +
    (message ? Tx({ ...F.callout, color: C.textSecondary, textAlign: 'center', marginTop: 12 }, message, M(m, 'msg')) : '') +
    (action ? V({ marginTop: 20, width: 200 }, DSButton(action, { kind: 'secondary' }), M(m, 'action')) : ''),
    M(m, 'root'));
}
const ErrorState = (message, { retry = true, m } = {}) =>
  EmptyState({ icon: 'warning-outline', title: '문제가 발생했어요', message, action: retry ? '다시 시도' : null, m });
function Loading(message, m) {
  return V({ alignItems: 'center' }, Spinner(28, C.brandPrimary) +
    (message ? Tx({ ...F.callout, color: C.textSecondary, marginTop: 12 }, message) : ''), m);
}
function ListFooter(kind, m) {
  const inner = kind === 'loading'
    ? Spinner(16, C.textSecondary, { marginRight: 8 }) + Tx({ ...F.caption, color: C.textSecondary }, '불러오는 중')
    : kind === 'failed'
      ? Tx({ ...F.caption, color: C.textSecondary }, '더 불러오지 못했어요.') +
        V({ height: 44, justifyContent: 'center', paddingHorizontal: 8 }, Tx({ ...F.callout, color: C.brandPrimary }, '다시 시도'))
      : Tx({ ...F.caption, color: C.textTertiary }, '모든 결과를 확인했어요');
  return H({ height: 52, alignItems: 'center', justifyContent: 'center' }, inner, m);
}
const Skel = (w, h, st = {}, m) => V({ width: w, height: h, borderRadius: 6, backgroundColor: C.surface, ...st }, '', m);

// ---------- DS: DSListRow · 그룹 ----------
function ListRow(title, value, { chevron = true, color = C.textPrimary, m } = {}) {
  return H({ height: 44, alignItems: 'center' },
    Tx({ ...F.body, color }, title, M(m, 'title')) + V({ flex: 1, minWidth: 8 }) +
    (value ? Tx({ ...F.callout, color: C.textSecondary, marginLeft: 8 }, value, M(m, 'value'), 1) : '') +
    (chevron ? Ic('chevron-forward', 14, C.textTertiary, { marginLeft: 12 }, M(m, 'chev')) : ''),
    M(m, 'root'));
}
const RowSep = () => V({ height: 0.5, backgroundColor: C.border });
function Group(inner, { m, padding } = {}) {
  return V({ marginHorizontal: 20, backgroundColor: C.surface, borderRadius: 14, paddingHorizontal: 16, ...(padding ? { padding } : {}) }, inner, m);
}
const GroupTitle = (text, { first, m } = {}) =>
  Tx({ ...F.caption, color: C.textSecondary, marginTop: first ? 16 : 24, marginBottom: 8, marginLeft: 36 }, text, m);

// ---------- 편집 필드 (ProfileFeature) ----------
function EditField(text, { error, disabled, m } = {}) {
  return H({ height: 44, alignItems: 'center', backgroundColor: C.surface, borderRadius: 10, paddingLeft: 12,
      borderWidth: error ? 1.5 : 0, borderColor: C.error, opacity: disabled ? 0.6 : 1 },
    Tx({ ...F.body, color: C.textPrimary, flex: 1 }, text, M(m, 'text'), 1) +
    (disabled ? V({ width: 12 }) : V({ width: 44, height: 44, alignItems: 'center', justifyContent: 'center' }, Ic('close-circle', 18, C.textTertiary), M(m, 'clear'))),
    M(m, 'root'));
}
function Helper(left, right, { error, m } = {}) {
  if (error) {
    return H({ marginTop: 8, alignItems: 'center' },
      Ic('alert-circle-outline', 14, C.error, { marginRight: 4 }) + Tx({ ...F.caption, color: C.error }, left), m);
  }
  return H({ marginTop: 8, justifyContent: 'space-between' },
    Tx({ ...F.caption, color: C.textSecondary }, left, M(m, 'left')) + (right ? Tx({ ...F.caption, color: C.textSecondary }, right, M(m, 'right')) : ''), M(m, 'root'));
}

// ---------- 프로필 이미지 ----------
function Avatar({ uploading, m } = {}) {
  return V({ width: 88, height: 88, borderRadius: 44, backgroundColor: SYS.brandTint, alignItems: 'center', justifyContent: 'center' },
    Tx({ fontFamily: 'pretendard-bold', fontSize: 34, lineHeight: 34, color: C.brandPrimary }, 'C') +
    (uploading ? V({ position: 'absolute', left: 0, top: 0, width: 88, height: 88, borderRadius: 44, backgroundColor: SYS.scrim, alignItems: 'center', justifyContent: 'center' }, Spinner(24, '#FFFFFF')) : '') +
    V({ position: 'absolute', right: -2, bottom: -2, width: 28, height: 28, borderRadius: 14, backgroundColor: C.brandPrimary, borderWidth: 2, borderColor: C.background,
        alignItems: 'center', justifyContent: 'center', opacity: uploading ? 0.4 : 1 }, Ic('pencil', 13, C.onBrand), M(m, 'badge')),
    M(m, 'root'));
}

// ---------- 시스템 알럿 · 다이얼로그 · 토스트 ----------
function Alert(title, message, m) {
  return V({ position: 'absolute', left: 0, top: 0, right: 0, bottom: 0, backgroundColor: SYS.scrim, zIndex: 4, alignItems: 'center', justifyContent: 'center' },
    V({ width: 270, backgroundColor: C.surfaceElevated, borderRadius: 26, padding: 20, boxShadow: '0 12px 36px rgba(0,0,0,.25)' },
      Tx({ ...SF.headline, textAlign: 'center', color: C.textPrimary }, title) +
      Tx({ ...SF.footnote, textAlign: 'center', color: C.textSecondary, marginTop: 6 }, message) +
      V({ height: 44, marginTop: 16, borderRadius: 22, backgroundColor: C.surface, alignItems: 'center', justifyContent: 'center' },
        Tx({ ...SF.headline, color: C.brandPrimary }, '확인')),
      M(m, 'card')), M(m, 'root'));
}
function ConfirmDialog(m) {
  return V({ position: 'absolute', left: 0, top: 0, right: 0, bottom: 0, backgroundColor: SYS.scrim, zIndex: 4, justifyContent: 'flex-end', paddingHorizontal: 8, paddingBottom: 34 },
    V({ backgroundColor: C.surfaceElevated, borderRadius: 26, overflow: 'hidden', boxShadow: '0 12px 36px rgba(0,0,0,.25)' },
      V({ paddingVertical: 14, paddingHorizontal: 16 },
        Tx({ ...SF.footnote, textAlign: 'center', color: C.textSecondary }, '최근 검색어를 모두 삭제할까요?\n삭제한 검색어는 되돌릴 수 없어요.')) +
      RowSep() +
      V({ height: 56, alignItems: 'center', justifyContent: 'center' }, Tx({ ...SF.body, color: C.error }, '전체 삭제')) +
      RowSep() +
      V({ height: 56, alignItems: 'center', justifyContent: 'center' }, Tx({ ...SF.headline, color: C.brandPrimary }, '취소')),
      M(m, 'card')), M(m, 'root'));
}
function Toast(text, m) {
  return H({ position: 'absolute', left: 0, right: 0, bottom: 95, justifyContent: 'center', zIndex: 3 },
    H({ height: 44, paddingHorizontal: 18, borderRadius: 22, backgroundColor: C.textPrimary, alignItems: 'center' },
      Ic('heart', 16, C.background, { marginRight: 8 }) + Tx({ ...F.callout, color: C.background }, text), m));
}

// ============================================================
// 화면 본문
// ============================================================
const PAD = { paddingHorizontal: 20 };

function SearchTop(text, m) {
  return V({ ...PAD, paddingTop: 8 }, SearchBar(text, { m: M(m, 'search') }), M(m, 'top'));
}
function RecentBody(m) {
  return SearchTop('', m) +
    V({ ...PAD, marginTop: 12 },
      SectionHeader('최근 검색어', '전체 삭제', M(m, 'header')) +
      KEYWORDS.map((w, i) => KeywordRow(w, i === 0 ? M(m, 'row') : i === 1 ? M(m, 'row2') : undefined)).join(''),
      M(m, 'section'));
}
function ResultsBody(m) {
  return SearchTop('카카오', m) +
    V({ ...PAD, marginTop: 16 },
      Tx({ ...F.caption, color: C.textSecondary }, '검색 결과 11개', M(m, 'count')) +
      V({ marginTop: 8 }, APPS.map((a, i) => ListCell(AppRow(a, { m: i === 0 ? M(m, 'row') : undefined }), { m: i === 0 ? M(m, 'cell') : undefined })).join(''), M(m, 'list')),
      M(m, 'results'));
}
const CenterFill = (inner, m) => V({ flex: 1, alignItems: 'center', justifyContent: 'center', paddingBottom: 83 }, inner, m);

function DetailTop(app, { loaded = true, error, retry = true, m } = {}) {
  const metric = (value, sub, first) => V({ flex: 1, alignItems: 'center', borderLeftWidth: first ? 0 : 0.5, borderColor: C.border },
    Tx({ ...F.headline, color: C.textPrimary }, value) + Tx({ ...F.caption, color: C.textSecondary, marginTop: 2 }, sub));
  return V({ ...PAD, paddingTop: 8 },
    H({ alignItems: 'flex-start' },
      AppIcon(app, 100, M(m, 'icon')) +
      V({ flex: 1, marginLeft: 12 },
        Tx({ ...F.title1, color: C.textPrimary, lines: 2 }, app.name, M(m, 'name')) +
        Tx({ ...F.callout, color: C.textSecondary, marginTop: 4 }, app.seller, M(m, 'seller'), 1) +
        V({ marginTop: 8 }, Rating(app.rating, app.count), M(m, 'rating')),
        M(m, 'info')),
      M(m, 'header')) +
    (loaded
      ? H({ marginTop: 16, gap: 6 }, app.genres.map((g, i) => Tag(g, i === 0 ? M(m, 'tag') : undefined)).join(''), M(m, 'tags')) +
        H({ marginTop: 16, paddingVertical: 12, borderTopWidth: 0.5, borderBottomWidth: 0.5, borderColor: C.border },
          V({ flex: 1, alignItems: 'center' }, Tx({ ...F.headline, color: C.textPrimary }, app.rating.toFixed(1)) + V({ marginTop: 5 }, Stars(app.rating, 11))) +
          metric(app.count, '평가', false) + metric('4+', '연령', false) + metric(app.price, '가격', false), M(m, 'metrics')) +
        V({ marginTop: 16 }, DSButton('App Store에서 보기'), M(m, 'store')) +
        Tx({ ...F.title2, color: C.textPrimary, marginTop: 24 }, '미리 보기', M(m, 'shotsTitle')) +
        H({ marginTop: 12, gap: 12, marginRight: -20 },
          [0, 1, 2].map((i) => V({ width: 185, height: 400, borderRadius: 14, backgroundColor: C.surface, borderWidth: 0.5, borderColor: C.border }, '', i === 0 ? M(m, 'shot') : undefined)).join(''),
          M(m, 'shots'))
      : error ? V({ marginTop: 40 }, ErrorState(error, { retry, m: M(m, 'error') }))
      : V({ marginTop: 16 }, Skel(150, 18, {}, M(m, 'skTags')) + Skel('100%', 70, { marginTop: 16 }, M(m, 'skMetrics')) + Skel('100%', 52, { marginTop: 16 }) +
          Skel(120, 28, { marginTop: 24 }) + H({ marginTop: 12, gap: 12 }, Skel(185, 400) + Skel(185, 400)), M(m, 'skeleton'))),
    M(m, 'root'));
}

function DetailBody(m) {
  const info = (k, v, mm) => H({ height: 44, alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: 0.5, borderColor: C.border },
    Tx({ ...F.callout, color: C.textSecondary }, k) + Tx({ ...F.callout, color: C.textPrimary }, v), mm);
  return V({ ...PAD, paddingTop: 8 },
    Tx({ ...F.title2, color: C.textPrimary }, '설명', M(m, 'descTitle')) +
    Tx({ ...F.body, color: C.textPrimary, marginTop: 8, lines: 3 },
      '■ 대한민국 대표 메신저 카카오톡 채팅은 물론 숏폼과 AI까지, 언제 어디서나 무료로 이용할 수 있는 메신저예요. 친구, 가족, 동료와의 1:1채팅과 그룹채팅은 물론 오픈채팅에서 관심사가 같은 사람들과 자유롭게 소통해보세요.', M(m, 'desc')) +
    H({ justifyContent: 'flex-end' }, V({ height: 44, justifyContent: 'center' }, Tx({ ...F.callout, color: C.brandPrimary }, '더 보기'), M(m, 'more'))) +
    H({ marginTop: 16, alignItems: 'baseline', justifyContent: 'space-between' },
      Tx({ ...F.title2, color: C.textPrimary }, '새로운 기능') + Tx({ ...F.caption, color: C.textSecondary }, '버전 26.9.2 · 2026.11.03', M(m, 'version')), M(m, 'newTitle')) +
    Tx({ ...F.body, color: C.textPrimary, marginTop: 8, lines: 3 }, '● 메시지에 다양한 서식을 적용할 수 있어요.\n: 굵게·기울임·취소선·목록 서식을 적용해 보세요.\n● 미니 이모티콘 조합을 추천받아 바로 쓸 수 있어요.', M(m, 'notes')) +
    Tx({ ...F.title2, color: C.textPrimary, marginTop: 24 }, '정보', M(m, 'infoTitle')) +
    V({ marginTop: 8 },
      info('개발사', 'Kakao Corp.', M(m, 'infoRow')) + info('크기', '587.6MB') + info('연령 등급', '4+') + info('호환성', 'iOS 17.0 이상') + info('장르', '소셜 네트워킹'),
      M(m, 'info')),
    M(m, 'root'));
}

function FavoritesBody({ swipe, m } = {}) {
  const rows = FAVS.map((a, i) => {
    const row = AppRow(a, { trailing: false, count: false, m: i === 0 ? M(m, 'row') : undefined });
    if (swipe && i === 0) {
      return V({ marginRight: -20, overflow: 'hidden' },
        V({ transform: 'translateX(-88px)', paddingRight: 20 }, ListCell(row)) +
        V({ position: 'absolute', right: 0, top: 0, bottom: 0, width: 88, backgroundColor: C.error, alignItems: 'center', justifyContent: 'center' },
          Ic('trash', 20, '#FFFFFF') + Tx({ ...SF.footnote, color: '#FFFFFF', marginTop: 2, fontWeight: 600 }, '삭제'), M(m, 'delete')));
    }
    return ListCell(row, { last: i === FAVS.length - 1 });
  }).join('');
  return V({ ...PAD, paddingTop: 8 },
    Tx({ ...F.caption, color: C.textSecondary }, '3개 · 최근 추가순', M(m, 'count')) +
    V({ marginTop: 8 }, rows, M(m, 'list')), M(m, 'root'));
}

function ProfileBody({ uploading, m } = {}) {
  return V({},
    V({ alignItems: 'center', marginTop: 16 },
      Avatar({ uploading, m: M(m, 'avatar') }) +
      Tx({ ...F.title2, color: C.textPrimary, marginTop: 12 }, 'Chris', M(m, 'name')) +
      Tx({ ...F.callout, color: C.textSecondary, marginTop: 2 }, uploading ? '사진을 올리는 중…' : 'chris@example.com', M(m, 'email')),
      M(m, 'head')) +
    GroupTitle('계정 정보', { m: M(m, 'groupTitle') }) +
    Group(ListRow('이름', 'Chris', { m: M(m, 'row') }) + RowSep() + ListRow('이메일', 'chris@example.com', { m: M(m, 'row2') }), { m: M(m, 'group') }),
    M(m, 'root'));
}

function EditBody(text, { counter = '5/20', help = '2~20자', error, disabled, m } = {}) {
  return V({ ...PAD, paddingTop: 16 },
    EditField(text, { error, disabled, m: M(m, 'field') }) +
    (error ? Helper(error, null, { error: true, m: M(m, 'helper') }) : Helper(help, counter, { m: M(m, 'helper') })),
    M(m, 'root'));
}

function Segmented(selected, m) {
  const seg = (t) => V({ flex: 1, alignItems: 'center', justifyContent: 'center', borderRadius: 7,
      backgroundColor: t === selected ? '#FFFFFF' : 'transparent', boxShadow: t === selected ? '0 1px 3px rgba(0,0,0,.14)' : undefined },
    Tx({ ...SF.footnote, fontWeight: t === selected ? 600 : 500, color: C.textPrimary }, t));
  return H({ height: 32, borderRadius: 9, padding: 2, backgroundColor: 'rgba(118,118,128,0.12)' }, seg('시스템') + seg('라이트') + seg('다크'), m);
}
function SettingsBody(m) {
  return V({},
    GroupTitle('화면', { first: true, m: M(m, 'title1') }) +
    Group(V({ paddingVertical: 12 }, Segmented('시스템', M(m, 'seg'))), { m: M(m, 'group1') }) +
    GroupTitle('데이터', { m: M(m, 'title2') }) +
    Group(ListRow('최근 검색어 전체 삭제', null, { chevron: false, color: C.error, m: M(m, 'clear') })) +
    GroupTitle('정보') +
    Group(ListRow('앱 버전', '1.0.0 (1)', { chevron: false, m: M(m, 'version') }) + RowSep() +
      ListRow('서버 주소', 'localhost:8000', { chevron: false, m: M(m, 'server') }) + RowSep() +
      ListRow('오픈소스 라이선스', null, { m: M(m, 'license') })),
    M(m, 'root'));
}
function LicensesBody() {
  const L = [['Pretendard', 'SIL OFL 1.1'], ['swift-composable-architecture', 'MIT'], ['Alamofire', 'MIT'], ['Kingfisher', 'MIT'], ['sqlite-data', 'MIT'], ['GRDB.swift', 'MIT']];
  return V({ paddingTop: 16 }, Group(L.map(([n, l], i) => (i ? RowSep() : '') + ListRow(n, l, { chevron: false })).join('')));
}
