import Foundation
import UserNotifications

private struct AnalyzeResponse: Decodable {
    let request_id: String
    let status: String
    let frame_index: Int?
    let word: String?
    let sense_idx: Int?
    let dictionary_meaning: String?
}

final class Analyzer {
    private let lock = NSLock()
    private var task: URLSessionDataTask?
    private var activeID: String?
    private var activeFrames: [Data] = []

    private func setStatus(_ value: String) {
        UserDefaults(suiteName: PrototypeConfig.appGroup)?.set(value, forKey: "analysisStatus")
    }

    func stop() {
        lock.lock()
        defer { lock.unlock() }
        task?.cancel()
        task = nil
        activeID = nil
        activeFrames.removeAll()
    }

    func analyze(_ frames: [Data]) {
        stop()
        guard frames.count == PrototypeConfig.rollingFrameCount else { return }
        let id = UUID().uuidString
        lock.lock()
        activeID = id
        activeFrames = frames
        lock.unlock()
        let boundary = "Boundary-\(id)"
        var body = Data()
        func append(_ value: String) { body.append(Data(value.utf8)) }
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"request_id\"\r\n\r\n\(id)\r\n")
        for (index, frame) in frames.enumerated() {
            append("--\(boundary)\r\nContent-Disposition: form-data; name=\"frame_\(index)\"; filename=\"frame.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n")
            body.append(frame)
            append("\r\n")
        }
        append("--\(boundary)--\r\n")
        var request = URLRequest(url: PrototypeConfig.backendURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = PrototypeConfig.requestTimeoutSeconds
        let newTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            self.lock.lock()
            defer { self.lock.unlock() }
            guard self.activeID == id else { return }
            if let error {
                NSLog("ScreenSampler analyze request failed: %@", error.localizedDescription)
                ActivityLog.append("Request lỗi: \(error.localizedDescription)")
                self.setStatus("Lỗi gửi request: \(error.localizedDescription)")
                return
            }
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                NSLog("ScreenSampler analyze HTTP status: %d", (response as? HTTPURLResponse)?.statusCode ?? -1)
                ActivityLog.append("HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                self.setStatus("Server trả HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return
            }
            guard let data, let result = try? JSONDecoder().decode(AnalyzeResponse.self, from: data) else {
                NSLog("ScreenSampler analyze response decode failed")
                ActivityLog.append("Không đọc được response")
                self.setStatus("Không đọc được response")
                return
            }
            guard result.request_id == id else {
                NSLog("ScreenSampler analyze request ID mismatch")
                ActivityLog.append("Response sai request ID")
                return
            }
            guard result.status == "FOUND" else {
                NSLog("ScreenSampler analyze status: %@", result.status)
                ActivityLog.append("Response: \(result.status)")
                self.setStatus("Response: \(result.status)")
                return
            }
            guard
                  let index = result.frame_index, self.activeFrames.indices.contains(index),
                  let word = result.word, let sense = result.sense_idx,
                  let meaning = result.dictionary_meaning else {
                NSLog("ScreenSampler analyze FOUND response missing fields")
                ActivityLog.append("Response FOUND thiếu dữ liệu")
                return
            }
            let stored = StoredResult(requestID: id, word: word, senseIndex: sense, meaning: meaning, createdAt: Date())
            guard ResultStore.save(stored, image: self.activeFrames[index]) else {
                ActivityLog.append("Không lưu được kết quả vào App Group")
                self.setStatus("Không lưu được kết quả vào App Group")
                return
            }
            let content = UNMutableNotificationContent()
            content.title = word
            content.body = meaning
            content.sound = .default
            content.userInfo = ["request_id": id]
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: nil)) { error in
                if let error {
                    NSLog("ScreenSampler notification scheduling failed: %@", error.localizedDescription)
                    ActivityLog.append("Lỗi thông báo: \(error.localizedDescription)")
                    self.setStatus("Lỗi thông báo: \(error.localizedDescription)")
                } else {
                    NSLog("ScreenSampler notification scheduled for request %@", id)
                    ActivityLog.append("Đã tạo thông báo: \(word)")
                    self.setStatus("Đã gửi thông báo: \(word)")
                }
            }
        }
        lock.lock()
        task = newTask
        lock.unlock()
        newTask.resume()
    }
}
