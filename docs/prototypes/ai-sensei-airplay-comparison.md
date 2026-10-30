# AI Sensei AirPlay comparison

An admin can open `/ja/screen_mirroring_test?reference=2.8.3.1` to compare the likely working baseline with the current AI Sensei view. This reference uses the view, controller, and stylesheet from deployment commit `9dacb8fa` (2.8.3.1, September 15, 2026). Only the asset and Stimulus registration names are isolated. It uses the current application's shared layout and shared assets, so it is a playback/view comparison rather than a complete historical deployment.

Use the same iPad, browser, TV, and screen-mirroring connection for both views. Start Basic English in each: both use Vimeo video `1225143839` with the same HLS URL. Record whether the TV switches to video-only playback while the remote remains on the iPad, along with the iPadOS version. Repeat once from a fresh page load for each view.

The old and current views both request fullscreen on the video container, apply the fullscreen layout, and call `video.play()` synchronously in the click handler. The HLS player attributes (`playsinline`, `preload="metadata"`, `x-webkit-airplay="deny"`, and `disableRemotePlayback`) are also unchanged. Differences include the page layout and container styles, modal picker/focus handling, and when activity sources are prepared. Reports affecting Basic English as well as activities make an activity-picker-only cause less likely.

If the baseline routes video correctly and the current view does not, narrow the view differences on that same setup. If both fail, the baseline has not reproduced the remembered behavior; investigate the browser/device/receiver state and any remaining shared-layout differences before attributing the failure to the new launch flow. Desktop tests exercise markup and playback calls; they cannot verify iPad/TV AirPlay routing.

Both reference modes remain restricted to admins. AI Sensei event accounts cannot open them.

## Targeted startup changes

The user confirmed that the 2.7.9.1 reference hands off video correctly on their iPad/TV setup. The current view now prepares sources on pointer/focus events throughout the menus and cards, and prepares the first source when opening a picker. Opening a lesson renders the idle video in a 16:9 surface under the splash; the idle surface remains inert and hidden from assistive technology. Starting a prepared video avoids an extra pause, load, or seek, and requests fullscreen followed synchronously by playback. Position resets happen when stopping. Direct launches avoid focusing Basic English, which would otherwise overwrite their prepared source, and playback no longer forces focus onto the remote.

The current remote's appearance and the video AirPlay attributes are retained so that the iPad/TV retest can isolate startup behavior. Compare the current view with `/ja/screen_mirroring_test?reference=2.7.9.1` using a Story video (both use `1225145089`). The browser checks verify source preparation, a rendered 16:9 surface before fullscreen, and fullscreen-before-play ordering, plus switching and replay controls. Automatic AirPlay routing and any effect of the remote's size/layering still require the physical iPad/TV test.

Source preparation now assigns `src` without following it with `load()`: assigning a new media `src` already invokes the browser's load algorithm. Launching also locks source preparation before closing the picker, so focus changes cannot substitute another video. Duplicate launch events are ignored while the player is active. Tests check a single source assignment, no explicit reload, and one fullscreen/play pair even with a second queued click. These changes remove extra initialization paths; they do not establish the cause of the reported double-opening animation on the iPad.

## Corrected observation: two transitions on the working reference

The user clarified that the apparent double opening occurs only on the **working 2.7.9.1 reference**: the remote is initially visible, then a second presentation transition occurs. It was mistakenly attributed to the current view during the reload investigation above. The reference starts with one fullscreen request and one `play()` call, and neither changes `src` nor invokes `load()` on startup. A possible explanation is the transition from mirrored page content to Safari's video-only external presentation; that remains an inference until route/presentation events are observed on the iPad. Treat this as a clue to the successful handoff, not evidence of duplicate application playback. The current-view source-loading cleanup does not explain this reference behavior.
