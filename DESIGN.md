# Thiết Kế Chi Tiết Kỹ Thuật: ClickAndGo (macOS Native Launcher)

Tài liệu đặc tả kiến trúc và thiết kế kỹ thuật cho ứng dụng **ClickAndGo** chạy trên macOS.

---

## 1. Mục Đích & Phạm Vi (Purpose & Scope)
* **Tên ứng dụng:** ClickAndGo
* **Mục đích:** Bảng điều khiển (Launcher Dashboard) native trên macOS, cho phép người dùng click 1 chạm để mở nhanh các ứng dụng, shell script hoặc liên kết web thường dùng.
* **Đối tượng:** Cá nhân sử dụng macOS (đặc biệt là lập trình viên / power user) cần gom các ứng dụng, script làm việc vào một nơi.
* **Mô hình triển khai:** Local-first, hoàn toàn offline, không cần tài khoản hay backend sync.

---

## 2. Giả Định & Yêu Cầu Phi Chức Năng (Assumptions & NFRs)
* **Hệ điều hành:** macOS 13.0 (Ventura) trở lên, tối ưu cho macOS 14 (Sonoma) và 15 (Sequoia). Hỗ trợ Universal Binary (Apple Silicon M-series & Intel x86_64).
* **Công nghệ:** 100% Swift & SwiftUI native, quản lý bằng Swift Package Manager (SPM).
* **Hiệu năng:** Khởi động ứng dụng $< 0.5$ giây, độ trễ phản hồi khi click nút $< 100$ms.
* **Lưu trữ:** File cấu hình JSON tại `~/Library/Application Support/ClickAndGo/items.json`.
* **Bảo mật & Quyền hạn:** Tắt App Sandbox nghiêm ngặt để cho phép ứng dụng khởi chạy file `.app` ngoài sandbox và thực thi shell script tùy biến.

---

## 3. Nhật Ký Quyết Định (Decision Log)

| Quyết định | Các lựa chọn thay thế | Lý do chọn |
| :--- | :--- | :--- |
| **Giao diện: Cửa sổ chuẩn (Standard App Window)** | Menu Bar App, Floating Quick Palette | Không gian hiển thị rộng rãi, bố cục lưới trực quan, quản lý cấu hình dễ dàng. |
| **Đối tượng hỗ trợ: Đa dạng (Apps, Scripts & URLs)** | Chỉ file `.app` macOS | Tối ưu tính linh hoạt cho developer/power user (chạy lệnh docker, server dev, trang web). |
| **Quản trị cấu hình: Form UI trực quan** | Chỉnh sửa file JSON thủ công | Trải nghiệm thân thiện, có dialog chọn file từ Finder và tự động trích xuất icon/tên. |
| **Công nghệ: Native Swift & SwiftUI** | Tauri, Electron, Python | Khởi động tức thì, siêu nhẹ, giao diện chuẩn Apple HIG, tích hợp mượt với `NSWorkspace`. |
| **Bố cục: Single-Window Card Grid + Form Sheet** | Dual-Mode (Play/Edit), Master-Detail | Đúng trọng tâm "vào là bấm chạy", giao diện gọn gàng, tuân thủ nguyên tắc YAGNI. |

---

## 4. Kiến Trúc Ứng Dụng (Architecture)

Ứng dụng tuân theo mô hình kiến trúc **MVVM (Model-View-ViewModel)**:

```
[ SwiftUI Views ]
       │
       ▼
[ LaunchViewModel ] ──(Binding)──► [ State: [LaunchItem], isEditing, searchText ]
       │
       ├─────────────────────────────────┐
       ▼                                 ▼
[ LauncherService ]              [ StorageService ]
       │                                 │
  (NSWorkspace / Process)         (JSON Local Storage)
```

### 4.1. Data Models (`LaunchItem.swift`)
```swift
import Foundation

public enum TargetType: String, Codable, CaseIterable {
    case application = "Ứng dụng (.app)"
    case script      = "Shell Script"
    case url         = "Đường dẫn Web"
}

public struct LaunchItem: Identifiable, Codable, Equatable {
    public var id: UUID = UUID()
    public var title: String
    public var targetType: TargetType
    public var targetValue: String        // Đường dẫn .app, câu lệnh script, hoặc URL
    public var iconName: String           // SF Symbol name hoặc đường dẫn icon
    public var tintColorHex: String       // Màu card HEX
    public var createdAt: Date = Date()
}
```

### 4.2. Core Services
* **`StorageService`**:
  * Tự động tạo thư mục `~/Library/Application Support/ClickAndGo/` nếu chưa có.
  * Đọc / ghi file `items.json` với cơ chế sao lưu `items.json.bak` khi gặp lỗi giải mã JSON.
* **`LauncherService`**:
  * `.application`: Gọi `NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: path), configuration: ...)`
  * `.script`: Thực thi bất đồng bộ bằng `Process()` qua `/bin/zsh -c "<command>"` trong `Task.detached`.
  * `.url`: Chuẩn hóa URL (thêm `https://` nếu thiếu) và mở qua `NSWorkspace.shared.open(url)`.

---

## 5. Thiết Kế Giao Diện & Tương Tác (UI / UX)

### 5.1. Cửa sổ chính (`MainWindowView`)
* **Toolbar trên cùng:**
  * `SearchField`: Lọc tức thời danh sách ứng dụng theo tên.
  * `Button("+ Thêm")`: Kích hoạt mở modal `ItemEditorSheet`.
  * `Button("Sắp xếp / Sửa")`: Bật/tắt chế độ hiển thị nút xóa nhanh trên từng card.
* **Vùng nút bấm (`LaunchGridView`):**
  * `LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 180))])`.
  * Bọc bên ngoài bằng `ScrollView(.vertical)`.

### 5.2. Thẻ nút bấm (`LaunchCardView`)
* Icon trung tâm nổi bật (lấy icon gốc của `.app` bằng `NSWorkspace.shared.icon(forFile:)` hoặc SF Symbol).
* Nhãn tiêu đề in đậm kèm Badge nhỏ thể hiện loại target.
* **Hành vi tương tác:**
  * **Click chuột trái:** Kích hoạt hoạt họa nhấn nhẹ (spring scale) kèm viền sáng phản hồi, sau đó chạy target.
  * **Click chuột phải (Context Menu):** Cho phép `Chạy thử`, `Sửa`, `Mở trong Finder` hoặc `Xóa`.

### 5.3. Sheet chỉnh sửa (`ItemEditorSheet`)
* Form nhập liệu thân thiện:
  * Tên nút bấm.
  * Picker chọn loại (`.application`, `.script`, `.url`).
  * Nút "Chọn từ Finder" (`NSOpenPanel`) khi chọn loại `.application` để người dùng không phải gõ đường dẫn thủ công.
  * Bảng chọn màu chủ đạo và SF Symbol.

---

## 6. Xử Lý Lỗi & Trường Hợp Ngoại Lệ (Error Handling & Edge Cases)

1. **Ứng dụng không tìm thấy:** Kiểm tra bằng `FileManager.default.fileExists`. Nếu file không tồn tại, hiện thông báo nhẹ cảnh báo đường dẫn không hợp lệ.
2. **Lỗi thực thi Script:** Bắt stderr và exit code từ `Process()`. Nếu có lỗi, hiển thị Alert/Toast thông báo chi tiết mã lỗi.
3. **Script chạy ngầm lâu dài:** Tách rời (detached) hoàn toàn khỏi tiến trình chính của app để đảm bảo giao diện luôn mượt mà.
4. **Dữ liệu cấu hình bị hỏng:** Tự động tạo file backup `items.json.bak` và khôi phục template rỗng an toàn.

---

## 7. Cấu Trúc Thư Mục Đề Xuất (Project Structure)

```
clickandgo/
├── DESIGN.md
├── Package.swift
└── Sources/
    └── ClickAndGo/
        ├── App/
        │   └── ClickAndGoApp.swift
        ├── Models/
        │   └── LaunchItem.swift
        ├── Services/
        │   ├── LauncherService.swift
        │   └── StorageService.swift
        ├── ViewModels/
        │   └── LaunchViewModel.swift
        └── Views/
            ├── MainWindowView.swift
            ├── LaunchGridView.swift
            ├── LaunchCardView.swift
            └── ItemEditorSheet.swift
```
