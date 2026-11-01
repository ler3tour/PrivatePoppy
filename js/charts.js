/*
 * Mini-moteur de graphiques SVG sans dépendance.
 * - lineChart : multi-séries, grille, légende, infobulle au survol.
 * - barChart : barres horizontales, une mesure, étiquettes directes.
 * Les couleurs viennent des variables CSS (--series-1, --series-2, encres),
 * donc les graphiques suivent automatiquement le thème clair / sombre.
 */
(function () {
  const NS = "http://www.w3.org/2000/svg";

  function cssVar(name) {
    return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
  }

  function el(tag, attrs) {
    const node = document.createElementNS(NS, tag);
    for (const k in attrs) node.setAttribute(k, attrs[k]);
    return node;
  }

  function niceTicks(min, max, count) {
    if (min === max) { max = min + 1; }
    const span = max - min;
    const step0 = span / Math.max(1, count);
    const mag = Math.pow(10, Math.floor(Math.log10(step0)));
    const norm = step0 / mag;
    const step = (norm >= 5 ? 10 : norm >= 2 ? 5 : norm >= 1 ? 2 : 1) * mag;
    const lo = Math.floor(min / step) * step;
    const hi = Math.ceil(max / step) * step;
    const ticks = [];
    for (let v = lo; v <= hi + step / 2; v += step) ticks.push(v);
    return ticks;
  }

  function fmtCompact(v) {
    const abs = Math.abs(v);
    if (abs >= 1e6) return (v / 1e6).toLocaleString("fr-FR", { maximumFractionDigits: 1 }) + " M";
    if (abs >= 1e3) return (v / 1e3).toLocaleString("fr-FR", { maximumFractionDigits: 0 }) + " k";
    return v.toLocaleString("fr-FR", { maximumFractionDigits: 0 });
  }

  /**
   * lineChart(host, {series:[{name, color, values:[{x,y}]}], xLabel, formatY, formatX})
   */
  function lineChart(host, cfg) {
    host.innerHTML = "";
    const W = Math.max(320, host.clientWidth || 560);
    const H = 280;
    const pad = { top: 14, right: 16, bottom: 30, left: 56 };

    const legend = document.createElement("div");
    legend.className = "chart-legend";
    cfg.series.forEach(function (s) {
      const key = document.createElement("span");
      key.className = "key";
      key.innerHTML = '<span class="swatch" style="background:' + s.color + '"></span>' + s.name;
      legend.appendChild(key);
    });
    if (cfg.series.length >= 2) host.appendChild(legend);

    const svg = el("svg", { viewBox: "0 0 " + W + " " + H, role: "img" });
    host.appendChild(svg);

    const xs = cfg.series[0].values.map(function (p) { return p.x; });
    let yMin = Infinity, yMax = -Infinity;
    cfg.series.forEach(function (s) {
      s.values.forEach(function (p) {
        if (p.y < yMin) yMin = p.y;
        if (p.y > yMax) yMax = p.y;
      });
    });
    if (yMin > 0) yMin = 0;
    if (yMax < 0) yMax = 0;
    const yTicks = niceTicks(yMin, yMax, 5);
    yMin = yTicks[0];
    yMax = yTicks[yTicks.length - 1];

    const xMin = Math.min.apply(null, xs), xMax = Math.max.apply(null, xs);
    const sx = function (x) { return pad.left + (x - xMin) / (xMax - xMin || 1) * (W - pad.left - pad.right); };
    const sy = function (y) { return pad.top + (1 - (y - yMin) / (yMax - yMin || 1)) * (H - pad.top - pad.bottom); };

    const gridColor = cssVar("--grid-line") || "#e1e0d9";
    const axisColor = cssVar("--axis") || "#c3c2b7";
    const muted = cssVar("--text-muted") || "#898781";

    yTicks.forEach(function (t) {
      svg.appendChild(el("line", { x1: pad.left, y1: sy(t), x2: W - pad.right, y2: sy(t), stroke: gridColor, "stroke-width": 1 }));
      const label = el("text", { x: pad.left - 8, y: sy(t) + 4, "text-anchor": "end", "font-size": 11, fill: muted });
      label.textContent = fmtCompact(t);
      svg.appendChild(label);
    });

    // Ligne de zéro plus marquée quand les valeurs sont signées.
    if (yMin < 0 && yMax > 0) {
      svg.appendChild(el("line", { x1: pad.left, y1: sy(0), x2: W - pad.right, y2: sy(0), stroke: axisColor, "stroke-width": 1 }));
    }

    const xTickEvery = Math.max(1, Math.ceil(xs.length / 7));
    xs.forEach(function (x, i) {
      const dernier = i === xs.length - 1;
      // Le dernier point remplace le tick régulier s'ils sont trop proches.
      if (!dernier && (i % xTickEvery !== 0 || xs.length - 1 - i < xTickEvery)) return;
      const label = el("text", { x: sx(x), y: H - 8, "text-anchor": dernier ? "end" : "middle", "font-size": 11, fill: muted });
      label.textContent = cfg.formatXTick ? cfg.formatXTick(x) : (cfg.formatX ? cfg.formatX(x) : x);
      svg.appendChild(label);
    });

    cfg.series.forEach(function (s) {
      const d = s.values.map(function (p, i) {
        return (i === 0 ? "M" : "L") + sx(p.x).toFixed(1) + " " + sy(p.y).toFixed(1);
      }).join(" ");
      svg.appendChild(el("path", { d: d, fill: "none", stroke: s.color, "stroke-width": 2, "stroke-linejoin": "round", "stroke-linecap": "round" }));
    });

    // Couche interactive : ligne-repère + points + infobulle.
    const cursor = el("line", { x1: 0, y1: pad.top, x2: 0, y2: H - pad.bottom, stroke: axisColor, "stroke-width": 1, visibility: "hidden" });
    svg.appendChild(cursor);
    const dots = cfg.series.map(function (s) {
      const surface = cssVar("--surface-1") || "#fcfcfb";
      const dot = el("circle", { r: 4.5, fill: s.color, stroke: surface, "stroke-width": 2, visibility: "hidden" });
      svg.appendChild(dot);
      return dot;
    });

    const tooltip = document.createElement("div");
    tooltip.className = "chart-tooltip";
    host.appendChild(tooltip);

    function onMove(evt) {
      const rect = svg.getBoundingClientRect();
      const px = (evt.clientX - rect.left) * (W / rect.width);
      let best = 0, bestDist = Infinity;
      xs.forEach(function (x, i) {
        const d = Math.abs(sx(x) - px);
        if (d < bestDist) { bestDist = d; best = i; }
      });
      const x = xs[best];
      cursor.setAttribute("x1", sx(x));
      cursor.setAttribute("x2", sx(x));
      cursor.setAttribute("visibility", "visible");

      let rows = "";
      cfg.series.forEach(function (s, si) {
        const p = s.values[best];
        dots[si].setAttribute("cx", sx(p.x));
        dots[si].setAttribute("cy", sy(p.y));
        dots[si].setAttribute("visibility", "visible");
        rows += '<div class="tt-row"><span class="swatch" style="background:' + s.color + '"></span>' +
          s.name + ' : <b>' + (cfg.formatY ? cfg.formatY(p.y) : p.y) + "</b></div>";
      });
      tooltip.innerHTML = '<div class="tt-title">' + (cfg.formatX ? cfg.formatX(x) : x) + "</div>" + rows;
      tooltip.style.display = "block";
      const hostRect = host.getBoundingClientRect();
      let left = evt.clientX - hostRect.left + 14;
      if (left + tooltip.offsetWidth > hostRect.width - 4) left = left - tooltip.offsetWidth - 28;
      tooltip.style.left = Math.max(0, left) + "px";
      tooltip.style.top = Math.max(0, evt.clientY - hostRect.top - tooltip.offsetHeight - 10) + "px";
    }

    function onLeave() {
      cursor.setAttribute("visibility", "hidden");
      dots.forEach(function (d) { d.setAttribute("visibility", "hidden"); });
      tooltip.style.display = "none";
    }

    svg.addEventListener("mousemove", onMove);
    svg.addEventListener("mouseleave", onLeave);
  }

  /**
   * barChart(host, {items:[{label, value, highlight}], color, formatV})
   * Barres horizontales, valeur en étiquette directe au bout de chaque barre.
   */
  function barChart(host, cfg) {
    host.innerHTML = "";
    const W = Math.max(320, host.clientWidth || 560);
    const rowH = 30, barH = 18;
    const pad = { top: 6, right: 104, bottom: 6, left: 110 };
    const H = pad.top + pad.bottom + cfg.items.length * rowH;

    const svg = el("svg", { viewBox: "0 0 " + W + " " + H, role: "img" });
    host.appendChild(svg);

    const vMax = Math.max.apply(null, cfg.items.map(function (d) { return d.value; }));
    const plotW = W - pad.left - pad.right;
    const muted = cssVar("--text-muted") || "#898781";
    const ink = cssVar("--text-primary") || "#0b0b0b";
    const secondary = cssVar("--text-secondary") || "#52514e";

    const tooltip = document.createElement("div");
    tooltip.className = "chart-tooltip";
    host.appendChild(tooltip);

    cfg.items.forEach(function (d, i) {
      const y = pad.top + i * rowH + (rowH - barH) / 2;
      const w = Math.max(2, d.value / vMax * plotW);

      const name = el("text", { x: pad.left - 8, y: y + barH / 2 + 4, "text-anchor": "end", "font-size": 12, fill: d.highlight ? ink : secondary, "font-weight": d.highlight ? 700 : 400 });
      name.textContent = d.label;
      svg.appendChild(name);

      // Bout arrondi côté valeur, carré côté axe.
      const r = 4;
      const path = "M" + pad.left + " " + y +
        " H" + (pad.left + w - r) +
        " Q" + (pad.left + w) + " " + y + " " + (pad.left + w) + " " + (y + r) +
        " V" + (y + barH - r) +
        " Q" + (pad.left + w) + " " + (y + barH) + " " + (pad.left + w - r) + " " + (y + barH) +
        " H" + pad.left + " Z";
      const bar = el("path", { d: path, fill: cfg.color, opacity: d.highlight ? 1 : 0.75 });
      svg.appendChild(bar);

      const val = el("text", { x: pad.left + w + 8, y: y + barH / 2 + 4, "font-size": 12, fill: muted, "font-variant": "tabular-nums" });
      val.textContent = cfg.formatV ? cfg.formatV(d.value) : d.value;
      svg.appendChild(val);

      const hit = el("rect", { x: 0, y: pad.top + i * rowH, width: W, height: rowH, fill: "transparent" });
      hit.addEventListener("mousemove", function (evt) {
        tooltip.innerHTML = '<div class="tt-title">' + d.label + '</div><div class="tt-row"><b>' +
          (cfg.formatV ? cfg.formatV(d.value) : d.value) + "</b></div>";
        tooltip.style.display = "block";
        const hostRect = host.getBoundingClientRect();
        let left = evt.clientX - hostRect.left + 14;
        if (left + tooltip.offsetWidth > hostRect.width - 4) left = left - tooltip.offsetWidth - 28;
        tooltip.style.left = Math.max(0, left) + "px";
        tooltip.style.top = (evt.clientY - hostRect.top - tooltip.offsetHeight - 10) + "px";
      });
      hit.addEventListener("mouseleave", function () { tooltip.style.display = "none"; });
      svg.appendChild(hit);
    });
  }

  window.PoppyCharts = { lineChart: lineChart, barChart: barChart };
})();
