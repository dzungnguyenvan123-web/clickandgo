# ClickAndGo 🚀

Ứng dụng Native Desktop cho macOS cho phép bạn tạo bảng điều khiển khởi chạy nhanh các ứng dụng, shell script và đường dẫn web chỉ với 1 click.

---

## ✨ Tính năng nổi bật
* **100% Native macOS & SwiftUI:** Nhẹ, khởi động tức thì, tiêu tốn cực ít tài nguyên.
* **Đa dạng mục tiêu khởi chạy:**
  * Ứng dụng macOS (`.app`): Tự động lấy icon gốc của app.
  * Shell Script: Chạy các lệnh terminal (Docker, Dev servers, script tự động).
  * Web URLs: Mở nhanh trang web trên trình duyệt mặc định.
* **Giao diện trực quan:** Bố cục dạng lưới (Grid card), tích hợp tìm kiếm tức thời và chế độ chỉnh sửa/xóa trực tiếp.
* **Bộ chọn Finder thông minh:** Tích hợp sẵn hộp thoại chọn ứng dụng từ Finder (`NSOpenPanel`), tự động điền tên và nạp icon.
* **Lưu trữ JSON an toàn:** File cấu hình tự động lưu tại `~/Library/Application Support/ClickAndGo/items.json`.

---

## 🚀 Khởi chạy ứng dụng

### Cách 1: Mở trực tiếp App Bundle
Bạn có thể mở trực tiếp ứng dụng bằng Finder hoặc chạy lệnh Terminal:
```bash
open ClickAndGo.app
```

### Cách 2: Chạy qua Swift Package Manager
```bash
swift run
```

---

## 🛠️ Biên dịch bản Release
Để build bản tối ưu hóa hiệu năng:
```bash
swift build -c release
cp .build/release/ClickAndGo ClickAndGo.app/Contents/MacOS/ClickAndGo
```

---

## 📂 Vị trí lưu trữ dữ liệu
* File cấu hình: `~/Library/Application Support/ClickAndGo/items.json`
* File sao lưu tự động khi lỗi: `~/Library/Application Support/ClickAndGo/items.json.bak`
