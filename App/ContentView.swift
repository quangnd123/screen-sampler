import SwiftUI
import UserNotifications

struct ContentView: View {
    let delegate: AppDelegate
    @State private var selectedID: String?
    @State private var showingDetail = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "text.book.closed")
                .font(.system(size: 52))
            Text("Contextual Vocabulary")
                .font(.title.bold())
            Text("Nhấn Start, xác nhận chia sẻ màn hình, rồi chuyển sang ứng dụng khác.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            BroadcastStartButton()
                .frame(width: 220, height: 56)
            Button("Stop") {
                UserDefaults(suiteName: PrototypeConfig.appGroup)?.set(true, forKey: "stopRequested")
            }
            .buttonStyle(.bordered)
            Text("Mỗi 30 giây phân tích 7 ảnh gần nhất. Bạn có thể dừng chia sẻ từ chỉ báo ghi màn hình của iOS.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
            delegate.onSelect = { id in selectedID = id; showingDetail = true }
            if let id = delegate.selectedRequestID { selectedID = id; showingDetail = true }
        }
        .sheet(isPresented: $showingDetail) {
            if let id = selectedID { ResultDetail(requestID: id) }
        }
    }
}

private struct ResultDetail: View {
    let requestID: String
    @State private var loaded: (StoredResult, Data)?

    var body: some View {
        ScrollView {
            if let loaded, let image = UIImage(data: loaded.1) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(loaded.0.word).font(.largeTitle.bold())
                    Text(loaded.0.meaning).font(.title3)
                    Image(uiImage: image).resizable().scaledToFit()
                }.padding()
            } else {
                Text("Kết quả này đã hết hạn").padding()
            }
        }
        .onAppear { loaded = ResultStore.load(requestID) }
    }
}
