import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "rectangle.inset.filled.and.person.filled")
                .font(.system(size: 52))

            Text("Screen Sampler")
                .font(.title.bold())

            Text("Tap START, confirm the iOS broadcast prompt, then switch to any other app.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            BroadcastStartButton()
                .frame(width: 220, height: 56)

            Text("Prototype: 1 frame/sec • keep last 7 • mock upload every ~60 sec")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
