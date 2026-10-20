import Foundation
import AppKit

public enum LaunchResult {
    case success(message: String)
    case failure(error: String)
}

public final class LauncherService {
    public static let shared = LauncherService()

    private init() {}

    public func launch(item: LaunchItem, completion: @escaping (LaunchResult) -> Void) {
        switch item.targetType {
        case .application:
            launchApplication(path: item.targetValue, completion: completion)
        case .script:
            launchScript(command: item.targetValue, completion: completion)
        case .url:
            launchURL(urlString: item.targetValue, completion: completion)
        }
    }

    // MARK: - Launch Application
    private func launchApplication(path: String, completion: @escaping (LaunchResult) -> Void) {
        let cleanedPath = (path as NSString).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: cleanedPath)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completion(.failure(error: "Không tìm thấy ứng dụng tại: \(cleanedPath)"))
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        NSWorkspace.shared.openApplication(at: fileURL, configuration: config) { app, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error: "Lỗi khởi chạy: \(error.localizedDescription)"))
                } else {
                    let appName = app?.localizedName ?? fileURL.deletingPathExtension().lastPathComponent
                    completion(.success(message: "Đã khởi chạy \(appName)"))
                }
            }
        }
    }

    // MARK: - Launch Shell Script
    private func launchScript(command: String, completion: @escaping (LaunchResult) -> Void) {
        Task.detached {
            let process = Process()
            let pipe = Pipe()
            let errorPipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", command]
            process.standardOutput = pipe
            process.standardError = errorPipe

            do {
                try process.run()
                process.waitUntilExit()

                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        completion(.success(message: "Script thực thi thành công!"))
                    } else {
                        let msg = errorOutput.isEmpty ? "Exit code: \(process.terminationStatus)" : errorOutput
                        completion(.failure(error: "Script lỗi: \(msg)"))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error: "Không thể chạy script: \(error.localizedDescription)"))
                }
            }
        }
    }

    // MARK: - Launch URL
    private func launchURL(urlString: String, completion: @escaping (LaunchResult) -> Void) {
        var formattedString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formattedString.lowercased().hasPrefix("http://") && !formattedString.lowercased().hasPrefix("https://") {
            formattedString = "https://" + formattedString
        }

        guard let url = URL(string: formattedString) else {
            completion(.failure(error: "Đường dẫn URL không hợp lệ: \(urlString)"))
            return
        }

        let success = NSWorkspace.shared.open(url)
        if success {
            completion(.success(message: "Đã mở liên kết trong trình duyệt"))
        } else {
            completion(.failure(error: "Không thể mở URL: \(formattedString)"))
        }
    }
}
