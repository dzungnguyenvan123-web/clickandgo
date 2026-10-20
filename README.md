# ClickAndGo 🚀

A native macOS launcher dashboard that allows you to configure and launch applications, shell scripts, and web URLs with a single click.

Built 100% native with Swift and SwiftUI, following Apple's Human Interface Guidelines (HIG).

---

## ✨ Features

* **100% Native macOS & SwiftUI:** Ultra-lightweight, near-instant startup, and minimal system resource consumption.
* **Versatile Launch Targets:**
  * **macOS Applications (`.app`):** Automatically extracts and displays the native app icon from Finder.
  * **Shell Scripts:** Run custom terminal commands and scripts asynchronously (e.g., Docker commands, dev servers, automation scripts) without freezing the UI.
  * **Web URLs:** Open web links directly in your default browser.
* **Modern & Clean UI/UX:**
  * Responsive and adaptive card grid layout.
  * Real-time search bar for instant filtering.
  * Interactive animations (spring press effects and hover highlights).
  * Edit mode toggle for quick deletion and reorganization.
  * Context menu (Right-click) to run, edit, show in Finder, or remove items.
* **Smart Finder File Picker:** Built-in `NSOpenPanel` integration allowing you to select `.app` bundles with automatic name and icon population.
* **Local-First & Safe Persistence:**
  * Stores items in JSON format at `~/Library/Application Support/ClickAndGo/items.json`.
  * Automatic backup recovery (`items.json.bak`) if data corruption occurs.
* **Native macOS Dock Icon:** Includes a custom high-resolution squircle app icon featuring the signature lightning bolt design.

---

## 💻 System Requirements

* **OS:** macOS 13.0 (Ventura) or later (Optimized for macOS 14 Sonoma & macOS 15 Sequoia).
* **Architecture:** Universal Binary (Apple Silicon M-series & Intel x86_64).

---

## 🚀 Getting Started

### Option 1: Open the App Bundle Directly (Recommended)
You can launch the pre-packaged application bundle:
```bash
open ClickAndGo.app
```
*(Or double-click `ClickAndGo.app` in Finder).*

### Option 2: Run via Swift Package Manager
```bash
swift run
```

---

## 🛠️ Building & Packaging

### Build Debug
```bash
swift build
cp .build/debug/ClickAndGo ClickAndGo.app/Contents/MacOS/ClickAndGo
```

### Build Release
For maximum performance and smallest binary footprint:
```bash
swift build -c release
cp .build/release/ClickAndGo ClickAndGo.app/Contents/MacOS/ClickAndGo
```

### Regenerate App Icons
If you ever need to recreate or modify the app icon assets:
```bash
swift scripts/generate_icon.swift
iconutil -c icns AppIcon.iconset -o ClickAndGo.app/Contents/Resources/AppIcon.icns
touch ClickAndGo.app
```

---

## 📂 Configuration & Data Storage

* **Active Configuration:** `~/Library/Application Support/ClickAndGo/items.json`
* **Automatic Backup:** `~/Library/Application Support/ClickAndGo/items.json.bak`

Sample configuration entry:
```json
{
  "id": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
  "title": "Safari",
  "targetType": "application",
  "targetValue": "/Applications/Safari.app",
  "iconName": "safari.fill",
  "tintColorHex": "#007AFF",
  "createdAt": "2026-10-20T00:00:00Z"
}
```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
