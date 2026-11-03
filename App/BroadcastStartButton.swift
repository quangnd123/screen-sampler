import SwiftUI
import ReplayKit

/// Wraps Apple's RPSystemBroadcastPickerView so the user starts a system-wide
/// ReplayKit broadcast with an explicit user tap.
struct BroadcastStartButton: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.label
        container.layer.cornerRadius = 14
        container.clipsToBounds = true

        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.showsMicrophoneButton = false
        picker.preferredExtension = "com.example.ScreenSampler.BroadcastExtension"

        // Hide the default glyph visually; the system picker remains the
        // actual tappable control underneath our label.
        picker.tintColor = .clear

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "START"
        label.textColor = UIColor.systemBackground
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.isUserInteractionEnabled = false

        container.addSubview(picker)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            picker.topAnchor.constraint(equalTo: container.topAnchor),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
