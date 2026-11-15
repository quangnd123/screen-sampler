# Contextual Vocabulary prototype

The existing ReplayKit Broadcast Upload Extension now captures one JPEG per second, keeps seven in memory, and sends a batch every 10 seconds to `POST /analyze` (first batch 10 seconds after broadcast starts). A late response from a canceled batch is ignored. Valid results are saved in the App Group container and shown through local notifications. Tapping a notification opens its matching screenshot.

## Before building on an iPhone

1. `backendURL` in `Shared/PrototypeConfig.swift` points to `http://100.99.124.75:8000/analyze`. The current plist allows HTTP for network testing; use HTTPS before deployment outside a trusted network.
2. Replace `com.example.ScreenSampler` bundle IDs and `group.com.example.ScreenSampler` App Group ID with IDs available in your Apple Developer team. Enable the same App Group for both app and extension in signing.
3. From `../backend`, run `uv sync` and `uv run uvicorn main:app --host 0.0.0.0 --port 8000`. Dummy responses are enabled by default and need no Qwen credentials. Set `USE_DUMMY_VLM=false` and configure `QWEN_MODEL`, `QWEN_BASE_URL`, and `QWEN_API_KEY` when ready to use Qwen.
4. The included `dictionary.json` is only a small seed dataset. Expand it with your licensed word/sense dataset for useful coverage.
5. Build with the existing GitHub Actions workflow, or run `xcodegen generate` and build the `ScreenSampler` scheme on macOS. The generated IPA is unsigned; installing on a device still needs signing and App Group provisioning.

The app requests notification permission when opened. Start uses the system broadcast picker restricted to this app's Broadcast Extension; iOS still requires the user to confirm screen sharing. The app shows a countdown, the latest status, and a 40-entry text log from the app and Broadcast Extension. Open the app after a broadcast to inspect the log; screenshots and API keys are never logged. Stop sets a shared flag checked on the next video frame; iOS may show a broadcast-ended message. The iOS status indicator can also stop the broadcast.

Test on a physical iPhone: switching apps, slow reading, fast scrolling, video, notification tap for several results, eviction after six results, and Stop. Linux cannot compile ReplayKit/UIKit code, so the GitHub macOS build is still needed.
