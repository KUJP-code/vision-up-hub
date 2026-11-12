import { Controller } from "@hotwired/stimulus";

// Opt-in local diagnostics: records geometry without changing the page layout.
export default class extends Controller {
  static values = { url: String };

  connect() {
    this.events = new AbortController();
    this.visit = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
    this.marker = document.createElement("div");
    this.marker.setAttribute("aria-hidden", "true");
    this.marker.dataset.layoutProbeMarker = "true";
    this.marker.style.cssText = "position:fixed;top:0;left:0;right:0;height:2px;background:#ed243b;z-index:2147483647;pointer-events:none";
    document.body.append(this.marker);
    const options = { passive: true, signal: this.events.signal };
    ["resize", "orientationchange"].forEach(name => window.addEventListener(name, () => this.queue(name), options));
    ["touchend", "fullscreenchange", "webkitfullscreenchange"].forEach(name => document.addEventListener(name, () => this.queue(name), options));
    ["resize", "scroll"].forEach(name => window.visualViewport?.addEventListener(name, () => this.queue(`viewport-${name}`), options));
    this.queue("open");
  }

  queue(event) {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => this.report(event), 250);
  }

  async report(event) {
    const viewport = window.visualViewport;
    const probe = document.createElement("div");
    probe.style.cssText = "position:fixed;visibility:hidden;padding:env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left)";
    document.body.append(probe);
    const safe = getComputedStyle(probe);
    const safe_area = { top: safe.paddingTop, right: safe.paddingRight, bottom: safe.paddingBottom, left: safe.paddingLeft };
    probe.remove();
    const elements = ["html", "body", ".lesson-mockup", ".lm-workspace", ".lm-page-header", ".lm-sidebar", ".lm-lesson-dialog", ".lm-lesson-menu", ".lm-splash-viewport", "[data-layout-probe-marker]"]
      .map(name => {
        const node = document.querySelector(name);
        if (!node) return null;
        const rect = node.getBoundingClientRect(), css = getComputedStyle(node);
        return { name, top: rect.top, left: rect.left, width: rect.width, height: rect.height, bottom: rect.bottom,
          margin_top: css.marginTop, padding_top: css.paddingTop, position: css.position, overflow_y: css.overflowY,
          scroll_top: node.scrollTop, scroll_height: node.scrollHeight, client_height: node.clientHeight };
      }).filter(Boolean);
    const report = {
      event, visit: this.visit, user_agent: navigator.userAgent, platform: navigator.platform,
      touch_points: navigator.maxTouchPoints, standalone: !!navigator.standalone,
      dimensions: { inner_width: innerWidth, inner_height: innerHeight, client_width: document.documentElement.clientWidth,
        client_height: document.documentElement.clientHeight, scroll_x: scrollX, scroll_y: scrollY,
        screen_width: screen.width, screen_height: screen.height, dpr: devicePixelRatio },
      viewport: viewport ? { width: viewport.width, height: viewport.height, offset_top: viewport.offsetTop,
        offset_left: viewport.offsetLeft, page_top: viewport.pageTop, page_left: viewport.pageLeft, scale: viewport.scale } : {},
      safe_area, elements
    };
    try {
      const response = await fetch(this.urlValue, { method: "POST", credentials: "same-origin", cache: "no-store",
        signal: this.events.signal, headers: { "Content-Type": "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" },
        body: JSON.stringify({ report }) });
      this.element.dataset.layoutProbeStatus = response.ok ? "sent" : "failed";
    } catch (error) {
      if (error.name !== "AbortError") this.element.dataset.layoutProbeStatus = "failed";
    }
  }

  disconnect() {
    clearTimeout(this.timer);
    this.events.abort();
    this.marker.remove();
  }
}
