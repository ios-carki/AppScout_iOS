// ============================================================
// lib.js — 디자인 토큰 + 스타일 → CSS 변환 + 레드라인 엔진
//
// 목업은 SwiftUI 구현 값(pt)을 그대로 CSS로 그립니다. (flexbox ≈ HStack/VStack)
// 그린 뒤 실제 위치를 재서 레드라인과 "측정" 값을 채우므로, 표의 숫자 = 그림의 크기입니다.
// ============================================================

// ---------- 컬러 토큰 (DesignSystem/Resources/Colors.xcassets, 라이트) ----------
const C = {
  brandPrimary: '#4F46E5',
  brandSecondary: '#0F766E',
  onBrand: '#FFFFFF',
  background: '#FFFFFF',
  surface: '#F4F5F9',
  surfaceElevated: '#FFFFFF',
  textPrimary: '#111827',
  textSecondary: '#4B5563',
  textTertiary: '#8A919E',
  border: '#E5E7EB',
  success: '#15803D',
  warning: '#B45309',
  error: '#B91C1C',
  rating: '#F59E0B',
};
const DARK = {
  brandPrimary: '#818CF8', brandSecondary: '#2DD4BF', onBrand: '#0B0D12', background: '#0B0D12', surface: '#161922',
  surfaceElevated: '#1F2330', textPrimary: '#F3F4F6', textSecondary: '#A1A7B3', textTertiary: '#6B7280', border: '#2A2F3C',
  success: '#4ADE80', warning: '#FBBF24', error: '#F87171', rating: '#FBBF24',
};
// 토큰이 아닌 시스템 재질 (그림용)
const SYS = {
  glass: 'rgba(255,255,255,0.86)',
  glassStroke: 'rgba(17,24,39,0.10)',
  scrim: 'rgba(17,24,39,0.36)',
  brandTint: 'rgba(79,70,229,0.12)',
  tealTint: 'rgba(15,118,110,0.12)',
  errorTint: 'rgba(185,28,28,0.10)',
};

// ---------- 타이포 토큰 (DSTypography) ----------
const F = {
  display:  { fontFamily: 'pretendard-bold', fontSize: 28, lineHeight: 36, letterSpacing: -0.4 },
  title1:   { fontFamily: 'pretendard-bold', fontSize: 22, lineHeight: 30, letterSpacing: -0.2 },
  title2:   { fontFamily: 'pretendard-semibold', fontSize: 20, lineHeight: 28, letterSpacing: -0.2 },
  headline: { fontFamily: 'pretendard-semibold', fontSize: 17, lineHeight: 24 },
  body:     { fontFamily: 'pretendard', fontSize: 16, lineHeight: 24 },
  callout:  { fontFamily: 'pretendard-medium', fontSize: 15, lineHeight: 22 },
  caption:  { fontFamily: 'pretendard', fontSize: 13, lineHeight: 18 },
  caption2: { fontFamily: 'pretendard-medium', fontSize: 11, lineHeight: 14 },
};
// 시스템 글꼴 (내비게이션 타이틀 · 탭 바 · 알럿) — DS 토큰 아님
const SF = {
  largeTitle: { fontFamily: 'system-ui', fontSize: 34, lineHeight: 41, fontWeight: 700 },
  headline:   { fontFamily: 'system-ui', fontSize: 17, lineHeight: 22, fontWeight: 600 },
  body:       { fontFamily: 'system-ui', fontSize: 17, lineHeight: 22, fontWeight: 400 },
  footnote:   { fontFamily: 'system-ui', fontSize: 13, lineHeight: 18, fontWeight: 400 },
  tab:        { fontFamily: 'system-ui', fontSize: 10, lineHeight: 12, fontWeight: 600 },
  status:     { fontFamily: 'system-ui', fontSize: 17, lineHeight: 22, fontWeight: 600 },
};

// SF Symbol 자리에 Ionicons 글리프로 그림 (표에는 실제 SF Symbol 이름을 씀)
const GLYPH = {"search": 62815, "heart": 62314, "heart-outline": 62327, "person-circle": 62633, "person-circle-outline": 62634, "settings-outline": 62828, "chevron-forward": 62011, "chevron-back": 61993, "close-circle": 62027, "close": 62026, "time-outline": 62942, "star": 62869, "star-half": 62870, "star-outline": 62873, "pencil": 62620, "warning-outline": 63017, "alert-circle-outline": 61716, "trash": 62962, "refresh": 62740, "open-outline": 62600, "battery-full": 61831, "cellular": 61960, "wifi": 63025, "add": 61699, "checkmark": 61981, "search-outline": 62819, "image-outline": 62351, "information-circle-outline": 62361};

// ---------- 스타일 객체 → CSS ----------
const UNITLESS = new Set(['opacity', 'zIndex', 'flexGrow', 'flexShrink', 'fontWeight']);
const kebab = (k) => k.replace(/[A-Z]/g, (m) => '-' + m.toLowerCase());
const px = (v) => (typeof v === 'number' ? v + 'px' : v);

function css(st) {
  const out = [];
  for (const [k, v] of Object.entries(st || {})) {
    if (v === undefined || v === null || v === false) continue;
    switch (k) {
      case 'paddingHorizontal': out.push(`padding-left:${px(v)};padding-right:${px(v)}`); break;
      case 'paddingVertical': out.push(`padding-top:${px(v)};padding-bottom:${px(v)}`); break;
      case 'marginHorizontal': out.push(`margin-left:${px(v)};margin-right:${px(v)}`); break;
      case 'marginVertical': out.push(`margin-top:${px(v)};margin-bottom:${px(v)}`); break;
      case 'flex': out.push(`flex:${v} 1 0px`); break;
      case 'fontFamily': out.push(v.startsWith('system') ? `font-family:${v}` : `font-family:'${v}'`); break;
      case 'borderWidth': out.push(`border-width:${px(v)};border-style:solid`); break;
      case 'borderTopWidth': case 'borderBottomWidth': case 'borderLeftWidth': case 'borderRightWidth': {
        const side = k.replace('border', '').replace('Width', '').toLowerCase();
        out.push(`border-${side}-width:${px(v)};border-${side}-style:solid`); break;
      }
      case 'lines': out.push(`display:-webkit-box;-webkit-line-clamp:${v};-webkit-box-orient:vertical;overflow:hidden;white-space:normal`); break;
      default: out.push(`${kebab(k)}:${UNITLESS.has(k) ? v : px(v)}`);
    }
  }
  return out.join(';');
}

// meta: { n, b(배지 위치), pad, gap('b'|'r'), dim('w'|'h'|'wh'), nobox, hide, nb }
function attrs(m) {
  if (!m) return '';
  let s = '';
  if (m.n !== undefined) s += ` data-n="${m.n}"`;
  if (m.b) s += ` data-b="${m.b}"`;
  if (m.pad) s += ` data-pad="1"`;
  if (m.gap) s += ` data-gap="${m.gap}"`;
  if (m.dim) s += ` data-dim="${m.dim}"`;
  if (m.nobox) s += ` data-nobox="1"`;
  if (m.hide) s += ` data-hide="1"`;
  if (m.nb) s += ` data-nb="1"`;
  return s;
}

// 기본 요소 (VStack 기본값: column)
const V = (st, kids = '', m) => `<div class="v"${attrs(m)} style="${css(st)}">${kids}</div>`;
const H = (st, kids = '', m) => V({ flexDirection: 'row', ...st }, kids, m);
const Tx = (st, text, m, lines) => `<div class="t${lines === 1 ? ' l1' : ''}"${attrs(m)} style="${css(st)}">${text}</div>`;
const Ic = (name, size, color, st = {}, m) =>
  `<div class="ic"${attrs(m)} style="width:${size}px;height:${size}px;font-size:${size}px;line-height:${size}px;color:${color};${css(st)}">&#${GLYPH[name]};</div>`;
const Spinner = (size, color = C.textSecondary, st = {}, m) =>
  `<div class="spin"${attrs(m)} style="width:${size}px;height:${size}px;border-color:${color};${css(st)}"></div>`;

// ---------- 레드라인 엔진 ----------
const MEAS = {};
function el(parent, cls, st, text) {
  const d = document.createElement('div');
  d.className = cls;
  Object.assign(d.style, st);
  if (text !== undefined) d.textContent = text;
  parent.appendChild(d);
  return d;
}
const r1 = (v) => Math.round(v * 10) / 10;
const fmt = (v) => (Math.abs(v - Math.round(v)) < 0.05 ? String(Math.round(v)) : r1(v).toFixed(1));

let ZOOM = 1; // 배지·숫자 라벨은 스테이지 확대와 상관없이 같은 크기
function lab(parent, cls, x, y, text, tf) {
  const d = el(parent, cls, { left: x * ZOOM + 'px', top: y * ZOOM + 'px', zoom: 1 / ZOOM }, text);
  if (tf) d.style.transform = tf;
  return d;
}
function drawRedlines(root) {
  const src = root.querySelector('.rlsrc');
  const ov = root.querySelector('.rlov');
  const key = root.dataset.key;
  const draw = root.dataset.draw !== '0';
  const z = root.style.zoom ? +root.style.zoom || 1 : 1;
  if (z !== 1) root.style.zoom = 1;
  const sr = src.getBoundingClientRect();
  const scale = z !== 1 ? 1 : sr.width / src.offsetWidth || 1;
  const rel = (node) => {
    const r = node.getBoundingClientRect();
    return { x: (r.left - sr.left) / scale, y: (r.top - sr.top) / scale, w: r.width / scale, h: r.height / scale };
  };
  const nextRel = (node) => {
    let nx = node.nextElementSibling;
    while (nx && (nx.offsetParent === null || getComputedStyle(nx).position === 'absolute')) nx = nx.nextElementSibling;
    return nx ? rel(nx) : null;
  };
  const items = [...src.querySelectorAll('[data-n]')].map((node) => ({ node, r: rel(node), q: nextRel(node) }));
  if (z !== 1) root.style.zoom = z;
  ZOOM = z;
  items.forEach(({ node, r, q }) => {
    const n = node.dataset.n;
    if (key && !node.dataset.nb) MEAS[`${key}-${n}`] = r;
    if (!draw || node.dataset.hide) return;
    const cs = getComputedStyle(node);

    if (node.dataset.pad) {
      const p = { t: parseFloat(cs.paddingTop), r: parseFloat(cs.paddingRight), b: parseFloat(cs.paddingBottom), l: parseFloat(cs.paddingLeft) };
      const bw = { t: parseFloat(cs.borderTopWidth), r: parseFloat(cs.borderRightWidth), b: parseFloat(cs.borderBottomWidth), l: parseFloat(cs.borderLeftWidth) };
      const ix = r.x + bw.l, iy = r.y + bw.t, iw = r.w - bw.l - bw.r, ih = r.h - bw.t - bw.b;
      const plab = (x, y, v) => lab(ov, 'rl-num pad', x, y, fmt(v), 'translate(-50%,-50%)');
      if (p.t > 0) el(ov, 'rl-pad', { left: ix + 'px', top: iy + 'px', width: iw + 'px', height: p.t + 'px' });
      if (p.b > 0) el(ov, 'rl-pad', { left: ix + 'px', top: iy + ih - p.b + 'px', width: iw + 'px', height: p.b + 'px' });
      if (p.l > 0) el(ov, 'rl-pad', { left: ix + 'px', top: iy + p.t + 'px', width: p.l + 'px', height: ih - p.t - p.b + 'px' });
      if (p.r > 0) el(ov, 'rl-pad', { left: ix + iw - p.r + 'px', top: iy + p.t + 'px', width: p.r + 'px', height: ih - p.t - p.b + 'px' });
      if (p.t > 0) plab(ix + iw * 0.5, iy + p.t / 2, p.t);
      if (p.b > 0) plab(ix + iw * 0.5, iy + ih - p.b / 2, p.b);
      if (p.l > 0) plab(ix + p.l / 2, iy + ih / 2, p.l);
      if (p.r > 0) plab(ix + iw - p.r / 2, iy + ih / 2, p.r);
    }

    if (!node.dataset.nobox) el(ov, 'rl-box', { left: r.x + 'px', top: r.y + 'px', width: r.w + 'px', height: r.h + 'px' });

    if (node.dataset.gap && q) {
      if (node.dataset.gap === 'b') {
        const g = q.y - (r.y + r.h);
        if (g > 0.5) {
          const x = r.x + r.w * 0.82;
          el(ov, 'rl-gap', { left: r.x + 'px', top: r.y + r.h + 'px', width: r.w + 'px', height: g + 'px' });
          el(ov, 'rl-gapline', { left: x + 'px', top: r.y + r.h + 'px', width: '1px', height: g + 'px' });
          lab(ov, 'rl-num gap', x, r.y + r.h + g / 2, fmt(g), 'translate(-50%,-50%)');
        }
      } else {
        const g = q.x - (r.x + r.w);
        if (g > 0.5) {
          const y = r.y + r.h * 0.5;
          el(ov, 'rl-gap', { left: r.x + r.w + 'px', top: r.y + 'px', width: g + 'px', height: r.h + 'px' });
          el(ov, 'rl-gapline', { left: r.x + r.w + 'px', top: y + 'px', width: g + 'px', height: '1px' });
          lab(ov, 'rl-num gap', r.x + r.w + g / 2, y, fmt(g), 'translate(-50%,-50%)');
        }
      }
    }

    const dim = node.dataset.dim || '';
    if (dim.includes('w')) {
      el(ov, 'rl-dimw', { left: r.x + 'px', top: r.y + r.h - 1 + 'px', width: r.w + 'px' });
      lab(ov, 'rl-num dim', r.x + r.w * 0.22, r.y + r.h - 1, 'W ' + fmt(r.w), 'translate(-50%,-50%)');
    }
    if (dim.includes('h')) {
      el(ov, 'rl-dimh', { left: r.x + r.w - 1 + 'px', top: r.y + 'px', height: r.h + 'px' });
      lab(ov, 'rl-num dim', r.x + r.w - 1, r.y + r.h * 0.78, 'H ' + fmt(r.h), 'translate(-100%,-50%)');
    }

    const pos = { tl: [r.x - 9, r.y - 9], tr: [r.x + r.w - 9, r.y - 9], l: [r.x - 22, r.y + r.h / 2 - 9], r: [r.x + r.w + 4, r.y + r.h / 2 - 9],
      in: [r.x + 3, r.y + 3], bl: [r.x - 9, r.y + r.h - 9], br: [r.x + r.w - 9, r.y + r.h - 9], c: [r.x + r.w / 2 - 9, r.y + r.h / 2 - 9],
      tc: [r.x + r.w / 2 - 9, r.y - 9], bc: [r.x + r.w / 2 - 9, r.y + r.h - 9], ir: [r.x + r.w - 21, r.y + 3] }[node.dataset.b || 'tl'];
    if (!node.dataset.nb) lab(ov, 'rl-badge', pos[0] + 9 - 9 / ZOOM, pos[1] + 9 - 9 / ZOOM, n);
  });
}

function fillMeasures() {
  document.querySelectorAll('.meas[data-key]').forEach((s) => {
    const r = MEAS[s.dataset.key];
    s.textContent = r ? `측정 ${fmt(r.w)} × ${fmt(r.h)}` : '';
  });
}

// ---------- 문서 헬퍼 ----------
const sw = (name) => `<span class="tok"><span class="sw" style="background:${C[name]}"></span><code>${name}</code></span>`;
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
// "{brandPrimary}" → 스와치 + 토큰명 / "`x`" → code
function rich(s) {
  if (s === undefined || s === null || s === '') return '—';
  return String(s).split(/(`[^`]+`)/g).map((part) =>
    part.startsWith('`') && part.endsWith('`') && part.length > 1
      ? `<code>${esc(part.slice(1, -1))}</code>`
      : part.replace(/\{([a-zA-Z]+[0-9]*)\}/g, (m, k) => (C[k] ? sw(k) : m))
  ).join('');
}
const code = (s, style = '') => `<pre class="code" style="${style}">${esc(s.replace(/^\n/, ''))}</pre>`;
const B = (n) => `<span class="badge">${n}</span>`;

// 레이어 스펙 표. rows: { n, d(깊이), layer, sub, layout, size, pad, gap, bg, border, text, act }
const SPEC_COLS = [
  ['#', 30], ['레이어 (SwiftUI)', 150], ['레이아웃', 104], ['크기 W × H', 112], ['padding', 70], ['간격 · 위치', 80],
  ['배경', 110], ['모서리 · 테두리', 92], ['텍스트', 120], ['동작 · 상태 · 제약', 0],
];
function specTable(key, rows, opts = {}) {
  const cols = opts.cols || SPEC_COLS;
  const head = cols.map(([t, w]) => `<th${w ? ` style="width:${w}px"` : ''}>${t}</th>`).join('');
  const body = rows.map((r) => {
    const indent = (r.d || 0) * 12;
    const n = r.n !== undefined ? `<span class="badge">${r.n}</span>` : '';
    const meas = r.n !== undefined && key && !r.nomeas ? `<span class="meas" data-key="${r.key || key}-${r.n}"></span>` : '';
    return `<tr>
      <td class="n">${n}</td>
      <td><div class="lay" style="padding-left:${indent}px">${r.d ? '└ ' : ''}${rich(r.layer)}${r.sub ? `<small>${rich(r.sub)}</small>` : ''}</div></td>
      <td>${rich(r.layout)}</td>
      <td>${rich(r.size)}${meas}</td>
      <td>${rich(r.pad)}</td>
      <td>${rich(r.gap)}</td>
      <td>${rich(r.bg)}</td>
      <td>${rich(r.border)}</td>
      <td>${rich(r.text)}</td>
      <td>${rich(r.act)}</td>
    </tr>`;
  }).join('');
  return `<table class="t"><tr>${head}</tr>${body}</table>`;
}

function simpleTable(cols, rows, opts = {}) {
  const head = cols.map(([t, w]) => `<th${w ? ` style="width:${w}px"` : ''}>${t}</th>`).join('');
  const body = rows.map((r) => `<tr>${r.map((c) => `<td>${rich(c)}</td>`).join('')}</tr>`).join('');
  return `<table class="t"${opts.style ? ` style="${opts.style}"` : ''}><tr>${head}</tr>${body}</table>`;
}

// 기기 프레임 (393 × 852). scale은 페이지 배치용 — 측정값은 항상 1배 기준
function device(inner, { key, scale = 1, draw = true, bg = C.background } = {}) {
  const W = 413 * scale, Hh = 872 * scale;
  return `<div class="scaler" style="width:${W}px;height:${Hh}px">
    <div class="device rlroot" data-key="${key || ''}" data-draw="${draw ? 1 : 0}" style="${draw ? `transform:scale(${scale})` : `zoom:${scale}`}">
      <div class="frame rlsrc" style="background:${bg}">${inner}</div>
      <div class="overlay rlov"></div>
    </div></div>`;
}

// 컴포넌트 단독 스테이지. cw = 실제 콘텐츠 폭(pt), w = 페이지에서 차지할 폭(px) → 배율 자동
function stage(inner, { key, draw = true, w, bg = C.background, pad = 24, scale = 1, hug = false, cw } = {}) {
  if (cw && w) scale = (w - pad * 2) / cw;
  else cw = w ? (w - pad * 2) / scale : undefined;
  return `<div style="background:${bg};border:1px solid #E5E7EB;border-radius:8px;padding:${pad}px;${w ? `width:${w}px;` : ''}">
    <div class="rlstage rlroot" data-key="${key || ''}" data-draw="${draw ? 1 : 0}" style="zoom:${scale}">
      <div class="rlsrc" style="display:flex;flex-direction:column;${hug ? 'align-items:flex-start;' : ''}${cw ? `width:${cw}px;` : ''}">${inner}</div>
      <div class="overlay2 rlov"></div>
    </div></div>`;
}

const LEGEND = `<div class="legend">
  <span><span class="badge">1</span> 표의 # 번호</span>
  <span><span class="lg-box"></span> 뷰 경계</span>
  <span><span class="lg-pad"></span> padding</span>
  <span><span class="lg-gap"></span> spacing / 요소 간격</span>
  <span><span class="lg-dim">W 353</span> 크기</span>
  <span class="muted">단위: pt · 프레임 393 × 852 · Safe Area 위 59 / 아래 34 · 화면 좌우 여백 20</span>
</div>`;

let PAGE_NO = 0;
const TOC = [];
function page(id, title, sub, body, toc) {
  PAGE_NO += 1;
  TOC.push([id, toc || title, String(PAGE_NO)]);
  return `<section class="page">
    <div class="ph"><div><h1>${title}</h1>${sub ? `<div class="sub">${rich(sub)}</div>` : ''}</div><span class="pid">${id}</span></div>
    ${body}
    <div class="pf"><span>AppScout · TCA 복습 프로젝트 · 와이어프레임 & 디자인 스펙 v2.0 · 2026-11-11</span><span>${PAGE_NO}</span></div>
  </section>`;
}
