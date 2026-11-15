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
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let shared = UserDefaults(suiteName: PrototypeConfig.appGroup)
                let active = shared?.bool(forKey: "broadcastActive") ?? false
                let next = shared?.double(forKey: "nextAnalysisAt") ?? 0
                let remaining = max(0, Int(ceil(next - context.date.timeIntervalSince1970)))
                VStack(spacing: 4) {
                    Text(active ? "Gửi request sau \(remaining) giây" : "Chưa bắt đầu broadcast")
                        .font(.headline)
                    Text(shared?.string(forKey: "analysisStatus") ?? "Nhấn nút trên để bắt đầu")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Button("Stop") {
                UserDefaults(suiteName: PrototypeConfig.appGroup)?.set(true, forKey: "stopRequested")
            }
            .buttonStyle(.bordered)
            Text("Lần gửi đầu sau 10 giây; sau đó cứ 10 giây phân tích 7 ảnh gần nhất. Bạn có thể dừng chia sẻ từ chỉ báo ghi màn hình của iOS.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                let entries = ActivityLog.entries()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Nhật ký").font(.headline)
                        Spacer()
                        Button("Xóa") { ActivityLog.clear() }
                    }
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 5) {
                            ForEach(entries.indices.reversed(), id: \.self) { index in
                                Text(entries[index]).font(.caption.monospaced()).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(height: 180)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error {
                    NSLog("ScreenSampler notification authorization error: %@", error.localizedDescription)
                    ActivityLog.append("Quyền thông báo lỗi: \(error.localizedDescription)")
                } else if !granted {
                    NSLog("ScreenSampler notification permission denied")
                    ActivityLog.append("Quyền thông báo bị từ chối")
                }
            }
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
