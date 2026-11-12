import SwiftUI
import ReplayKit

/// Bundle ID của Broadcast Upload Extension (phải khớp project.yml).
let broadcastExtensionBundleID = "com.example.ScreenSampler.BroadcastExtension"

/// Nút START: giữ một RPSystemBroadcastPickerView ẩn, trỏ thẳng vào extension
/// của app mình (preferredExtension) rồi "bấm" nút bên trong nó bằng code.
struct BroadcastStartButton: View {
    private let picker: RPSystemBroadcastPickerView = {
        let p = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        p.preferredExtension = broadcastExtensionBundleID
        p.showsMicrophoneButton = false
        return p
    }()

    var body: some View {
        Button {
            UserDefaults(suiteName: PrototypeConfig.appGroup)?.set(false, forKey: "stopRequested")
            for case let button as UIButton in picker.subviews {
                button.sendActions(for: .allTouchEvents)
            }
        } label: {
            Text("START")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .label), in: RoundedRectangle(cornerRadius: 14))
        }
        .background(PickerHost(picker: picker).frame(width: 1, height: 1).opacity(0.01))
    }
}

/// Cần đưa picker vào view hierarchy thì nút bên trong mới hoạt động.
private struct PickerHost: UIViewRepresentable {
    let picker: RPSystemBroadcastPickerView
    func makeUIView(context: Context) -> UIView { picker }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
