# Contextual Vocabulary prototype

The existing ReplayKit Broadcast Upload Extension now captures one JPEG per second, keeps seven in memory, and sends a batch every 30 seconds to `POST /analyze`. A late response from a canceled batch is ignored. Valid results are saved in the App Group container and shown through local notifications. Tapping a notification opens its matching screenshot.

## Before building on an iPhone

1. Set `backendURL` in `Shared/PrototypeConfig.swift` to the LAN address of the machine running the backend. The placeholder `192.168.1.2` must be changed. The current plist allows HTTP for LAN testing; use HTTPS before deployment outside a trusted network.
2. Replace `com.example.ScreenSampler` bundle IDs and `group.com.example.ScreenSampler` App Group ID with IDs available in your Apple Developer team. Enable the same App Group for both app and extension in signing.
3. From `../backnend`, install `requirements.txt`, copy `.env.example` to `.env`, fill in provider credentials and the verified vision-capable model ID, then run `uvicorn main:app --host 0.0.0.0 --port 8000`.
4. The included `dictionary.json` is only a small seed dataset. Expand it with your licensed word/sense dataset for useful coverage.
5. Build with the existing GitHub Actions workflow, or run `xcodegen generate` and build the `ScreenSampler` scheme on macOS. The generated IPA is unsigned; installing on a device still needs signing and App Group provisioning.

The app requests notification permission when opened. Start uses the existing system broadcast picker. Stop sets a shared flag checked on the next video frame; iOS may show a broadcast-ended message. The iOS status indicator can also stop the broadcast.

Test on a physical iPhone: switching apps, slow reading, fast scrolling, video, notification tap for several results, eviction after six results, and Stop. Linux cannot compile ReplayKit/UIKit code, so the GitHub macOS build is still needed.
