import Foundation
import SwiftUI
import AppKit

@MainActor
public final class LaunchViewModel: ObservableObject {
    @Published public var items: [LaunchItem] = []
    @Published public var searchText: String = ""
    @Published public var isEditMode: Bool = false
    @Published public var editingItem: LaunchItem? = nil
    @Published public var isShowingAddSheet: Bool = false

    // Toast feedback notification
    @Published public var toastMessage: String? = nil
    @Published public var isToastError: Bool = false
    private var toastDismissTask: Task<Void, Never>? = nil

    private let storage = StorageService.shared
    private let launcher = LauncherService.shared

    public init() {
        loadData()
    }

    public var filteredItems: [LaunchItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return items
        }
        return items.filter { item in
            item.title.localizedCaseInsensitiveContains(searchText) ||
            item.targetValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    public func loadData() {
        self.items = storage.loadItems()
    }

    public func addItem(_ item: LaunchItem) {
        items.append(item)
        storage.saveItems(items)
        showToast("Đã thêm: \(item.title)", isError: false)
    }

    public func updateItem(_ item: LaunchItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            storage.saveItems(items)
            showToast("Đã cập nhật: \(item.title)", isError: false)
        }
    }

    public func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        storage.saveItems(items)
        showToast("Đã xóa mục", isError: false)
    }

    public func deleteItem(_ item: LaunchItem) {
        items.removeAll { $0.id == item.id }
        storage.saveItems(items)
        showToast("Đã xóa: \(item.title)", isError: false)
    }

    public func launch(_ item: LaunchItem) {
        launcher.launch(item: item) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let msg):
                self.showToast(msg, isError: false)
            case .failure(let err):
                self.showToast(err, isError: true)
            }
        }
    }

    public func showToast(_ message: String, isError: Bool = false) {
        toastDismissTask?.cancel()
        withAnimation(.easeInOut(duration: 0.2)) {
            self.toastMessage = message
            self.isToastError = isError
        }

        toastDismissTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            if !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.toastMessage = nil
                }
            }
        }
    }

    // Helper: Select application from Finder
    public static func pickApplicationFile() -> (path: String, name: String, icon: NSImage?)? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.prompt = "Chọn ứng dụng"

        if panel.runModal() == .OK, let url = panel.url {
            let appName = url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            return (path: url.path, name: appName, icon: icon)
        }
        return nil
    }
}
