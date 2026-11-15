import SwiftUI
import ReplayKit

struct BroadcastStartButton: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 220, height: 56))
        picker.preferredExtension = Bundle.main.bundleIdentifier.map { "\($0).BroadcastExtension" }
        picker.showsMicrophoneButton = false
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}
