# AI Sensei viewport and scrolling

The prototype uses a fixed application frame. `html.lesson-prototype-root` and
`.lesson-prototype-body` do not scroll; `.lm-workspace` owns menu scrolling.
The sidebar and sticky menu header stay at the page edges. Section navigation
resets the workspace scroll position, and closing a lesson restores it.

The touch guard covers the whole application, including the menu. It allows
movement within scrollable content and cancels outward movement at a boundary.
Two-finger gestures and native timeline dragging remain available. Restricting
the guard to an open lesson leaves the main menu vulnerable to page overscroll.

The lesson menu starts at the page origin. Do not turn Safari's reported
`visualViewport.offsetTop` into extra positioning above it. The artwork has a
separate clipped container below the menu; the image and speech hotspots scale
together at the image's native aspect ratio, centred and sized to cover that
container. Video fullscreen remains a separate presentation path.

## Verification

Browser coverage includes native Chromium touch scrolling at both menu
boundaries, lesson return-position restoration, panel scrolling, centred image
cropping, and actual video fullscreen. These checks do not reproduce Safari's
native rubber-band rendering on an iPad; device verification is still needed.

On November 2, 2026, the running local server returned 404 for the freshly
generated lesson stylesheet digest. Restarting Puma through `tmp/restart.txt`
cleared its stale asset mapping; the current stylesheet then returned 200, and
the served application JavaScript contained the current page-level touch guard.
When local behaviour differs from fresh test-server results, check the assets
actually served by the running process. Refresh the page after the restart so
it requests the new asset URLs. The lesson stylesheet is tracked by Turbo to
reload when its digest or the application layout changes.

The iPad user confirmed that the excess scrolling was gone, but still reported
a strip above the menu. Do not treat the Chromium checks as confirmation that
this remaining Safari gap is fixed.

## Local iPad measurements

Open `/ja/ai-sensei?layout_probe=1` in development to show a thin red line at the
webpage's top edge. The opt-in Stimulus controller sends viewport dimensions,
safe-area values, element bounds, computed top spacing, and browser information
to `POST /ja/ai-sensei/layout-report`. Reports are stored locally in
`tmp/ai-sensei-layout-reports-development.jsonl`; test reports use a separate file.
The endpoint requires an Admin or AiSensei session, filters the fields, rejects
requests larger than 16 KB, and is unavailable outside local environments.
Opening the ordinary URL attaches no diagnostic controller or marker.

A gap above the marker suggests space outside the webpage; a gap below it
suggests spacing inside the page. Compare the visible result with recorded
element bounds and viewport offsets before changing positioning again.
