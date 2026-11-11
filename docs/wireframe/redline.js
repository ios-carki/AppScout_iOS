/*
 * 와이어프레임 화면 위에 레드라인(치수)을 그린다.
 *
 * 폰 안의 요소에 data-rl="..." 을 붙이면, 그 요소의 실제 위치를 재서 분홍 선과 라벨을 그린다.
 * 라벨 숫자는 그림의 픽셀이 아니라 실제 구현 값(pt)이다. (와이어프레임은 축소 그림)
 *
 *   w:350      요소 너비. 요소 아래쪽에 가로선
 *   h:44       요소 높이. 요소 오른쪽에 세로선 (hl:44 는 왼쪽)
 *   ml:20      화면 왼쪽 끝 → 요소 왼쪽 (mr:20 은 오른쪽)
 *   gt:8       바로 앞 형제 요소의 아래 → 이 요소의 위 (세로 간격)
 *   gl:12      이 요소의 오른쪽 → 다음 형제 요소의 왼쪽 (가로 간격)
 *   sz:60×60   요소 왼쪽 위에 크기 배지
 *   t:문구     요소 오른쪽 위에 메모 배지 (tl:문구 는 왼쪽 위)
 * 여러 개는 ; 로 구분한다.
 */
(function () {
  function layerFor(host) {
    var layer = host.querySelector(':scope > .rl-layer');
    if (!layer) {
      layer = document.createElement('div');
      layer.className = 'rl-layer';
      host.appendChild(layer);
    }
    return layer;
  }

  function box(host, el) {
    var hr = host.getBoundingClientRect();
    var r = el.getBoundingClientRect();
    return {
      x: r.left - hr.left - host.clientLeft,
      y: r.top - hr.top - host.clientTop,
      w: r.width,
      h: r.height,
      W: host.clientWidth,
      H: host.clientHeight
    };
  }

  function add(layer, cls, x, y, w, h, text) {
    var d = document.createElement('div');
    d.className = cls;
    d.style.left = x + 'px';
    d.style.top = y + 'px';
    if (w != null) d.style.width = w + 'px';
    if (h != null) d.style.height = h + 'px';
    if (text != null) d.textContent = text;
    layer.appendChild(d);
    return d;
  }

  function label(layer, text, cx, cy, side) {
    var d = add(layer, 'rl-label', 0, 0, null, null, text);
    var lw = d.offsetWidth, lh = d.offsetHeight;
    var x = cx - lw / 2, y = cy - lh / 2;
    if (side === 'right') x = cx + 3;
    if (side === 'above') y = cy - lh - 2;
    d.style.left = x + 'px';
    d.style.top = y + 'px';
  }

  // 가로 치수선 (x1 → x2, 높이 y)
  function hline(layer, x1, x2, y, text) {
    var len = Math.max(x2 - x1, 1);
    add(layer, 'rl-h', x1, y, len, null);
    add(layer, 'rl-tick-v', x1, y - 3, null, 7);
    add(layer, 'rl-tick-v', x2 - 1, y - 3, null, 7);
    label(layer, text, x1 + len / 2, y, len < 22 ? 'above' : null);
  }

  // 세로 치수선 (y1 → y2, 가로 위치 x)
  function vline(layer, y1, y2, x, text) {
    var len = Math.max(y2 - y1, 1);
    add(layer, 'rl-v', x, y1, null, len);
    add(layer, 'rl-tick-h', x - 3, y1, 7, null);
    add(layer, 'rl-tick-h', x - 3, y2 - 1, 7, null);
    label(layer, text, x, y1 + len / 2, len < 16 ? 'right' : null);
  }

  function prevVisible(el) {
    var p = el.previousElementSibling;
    while (p && (p.offsetHeight === 0 || p.classList.contains('callout'))) p = p.previousElementSibling;
    if (p) return p;
    return el.parentElement;
  }

  function nextVisible(el) {
    var n = el.nextElementSibling;
    while (n && (n.offsetWidth === 0 || n.classList.contains('callout'))) n = n.nextElementSibling;
    return n;
  }

  document.querySelectorAll('[data-rl]').forEach(function (el) {
    var host = el.closest('[data-rl-host]') || el.closest('.phone');
    if (!host) return;
    var layer = layerFor(host);
    var b = box(host, el);

    el.getAttribute('data-rl').split(';').forEach(function (part) {
      var i = part.indexOf(':');
      if (i < 0) return;
      var k = part.slice(0, i).trim();
      var v = part.slice(i + 1).trim();
      var o;
      switch (k) {
        case 'w': hline(layer, b.x, b.x + b.w, b.y + b.h + 4, v); break;
        case 'h': vline(layer, b.y, b.y + b.h, Math.min(b.x + b.w + 4, b.W - 4), v); break;
        case 'hl': vline(layer, b.y, b.y + b.h, Math.max(b.x - 4, 4), v); break;
        case 'ml': hline(layer, 0, b.x, b.y + b.h * 0.7, v); break;
        case 'mr': hline(layer, b.x + b.w, b.W, b.y + b.h * 0.7, v); break;
        case 'gt':
          var p = prevVisible(el);
          o = box(host, p);
          var top = (p === el.parentElement) ? o.y : o.y + o.h;
          vline(layer, top, b.y, b.x + 14, v);
          break;
        case 'gl':
          var n = nextVisible(el);
          if (!n) break;
          o = box(host, n);
          hline(layer, b.x + b.w, o.x, b.y + b.h / 2, v);
          break;
        case 'sz':
          var s = add(layer, 'rl-badge', b.x + 2, b.y + 2, null, null, v);
          break;
        case 't':
          var t = add(layer, 'rl-badge', 0, b.y - 5, null, null, v);
          t.style.left = Math.max(2, Math.min(b.x + b.w - t.offsetWidth + 4, b.W - t.offsetWidth - 2)) + 'px';
          break;
        case 'tl':
          add(layer, 'rl-badge', Math.max(2, b.x - 4), b.y - 5, null, null, v);
          break;
      }
    });
  });
})();
