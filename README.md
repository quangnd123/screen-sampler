# ScreenSampler ReplayKit prototype

Prototype flow:

1. Open app.
2. Tap **START**.
3. Confirm the iOS broadcast sheet.
4. Switch to another app.
5. Broadcast Upload Extension receives ReplayKit video sample buffers.
6. It encodes roughly 1 frame/second as a JPEG, resized so the longest side is at most 720 px.
7. It keeps only the latest 7 JPEGs.
8. Roughly every 60 seconds it snapshots the current cache and calls `MockUploader`.

`MockUploader` only writes a log entry. No server is required yet.

## Important for iOS 26

This prototype deliberately uses ReplayKit + Broadcast Upload Extension. The project deployment target is iOS 17; that is fine for a device running iOS 26.

## Edit on Ubuntu / VS Code

You can edit every Swift/YAML/plist file in VS Code. Ubuntu cannot compile UIKit/ReplayKit because the iOS SDK comes with Xcode on macOS.

An optional GitHub Actions workflow is included at `.github/workflows/compile.yml`. It only checks that the project compiles; it deliberately disables code signing and does not produce an installable iPhone IPA.

## Bundle IDs

Before device signing, replace these two IDs if needed:

- `com.example.ScreenSampler`
- `com.example.ScreenSampler.BroadcastExtension`

They occur in `project.yml`, `App/ContentView.swift`, and the extension logging subsystem strings.

## Generate the Xcode project on macOS/CI

```bash
brew install xcodegen
xcodegen generate
```

Then build the `ScreenSampler` scheme.

## Tuning

Edit `BroadcastExtension/SampleHandler.swift`:

- `sampleInterval = 1.0`
- `uploadInterval = 60.0`
- `maxCachedFrames = 7`

Edit JPEG settings here:

```swift
FrameEncoder(maxDimension: 720, jpegQuality: 0.55)
```

## Later: real POST

Replace `MockUploader.upload(frames:)` with URLSession code. Keep the cached batch small because broadcast extensions are memory-constrained.
