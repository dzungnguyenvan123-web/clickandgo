import SwiftUI
import AppKit

public struct ItemEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let initialItem: LaunchItem?
    private let onSave: (LaunchItem) -> Void

    @State private var title: String
    @State private var targetType: TargetType
    @State private var targetValue: String
    @State private var iconName: String
    @State private var selectedColor: Color

    private let presetSymbols = [
        "app.badge.fill", "terminal.fill", "globe", "bolt.fill",
        "play.fill", "folder.fill", "gearshape.fill", "star.fill",
        "cpu.fill", "hammer.fill", "safari.fill", "sparkles"
    ]

    private let presetColors: [Color] = [
        .blue, .purple, .green, .orange, .red, .pink, .indigo, .teal
    ]

    public init(item: LaunchItem? = nil, onSave: @escaping (LaunchItem) -> Void) {
        self.initialItem = item
        self.onSave = onSave

        _title = State(initialValue: item?.title ?? "")
        _targetType = State(initialValue: item?.targetType ?? .application)
        _targetValue = State(initialValue: item?.targetValue ?? "")
        _iconName = State(initialValue: item?.iconName ?? "bolt.fill")
        let initColor = Color(hex: item?.tintColorHex ?? "#0A84FF") ?? .blue
        _selectedColor = State(initialValue: initColor)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !targetValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(initialItem == nil ? "Thêm Nút Khởi Chạy" : "Chỉnh Sửa Nút")
                    .font(.headline)
                Spacer()
                Button("Hủy") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Type selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Loại mục tiêu:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Picker("", selection: $targetType) {
                            ForEach(TargetType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tiêu đề nút:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Ví dụ: Safari, Docker Dev, Figma...", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Target input based on type
                    VStack(alignment: .leading, spacing: 8) {
                        Text(targetTypeLabel)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        if targetType == .application {
                            HStack {
                                TextField("/Applications/AppName.app", text: $targetValue)
                                    .textFieldStyle(.roundedBorder)
                                Button("Chọn từ Finder...") {
                                    if let res = LaunchViewModel.pickApplicationFile() {
                                        targetValue = res.path
                                        if title.isEmpty {
                                            title = res.name
                                        }
                                    }
                                }
                            }
                        } else if targetType == .script {
                            TextEditor(text: $targetValue)
                                .font(.system(.body, design: .monospaced))
                                .frame(height: 80)
                                .padding(4)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            Text("Gợi ý: Lệnh shell sẽ được chạy qua /bin/zsh -c")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            TextField("https://example.com", text: $targetValue)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // Icon selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Biểu tượng (Icon):")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack(spacing: 12) {
                            ForEach(presetSymbols, id: \.self) { sym in
                                Button(action: {
                                    iconName = sym
                                }) {
                                    Image(systemName: sym)
                                        .font(.system(size: 16))
                                        .frame(width: 32, height: 32)
                                        .background(iconName == sym ? selectedColor.opacity(0.2) : Color.clear)
                                        .foregroundColor(iconName == sym ? selectedColor : .secondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(iconName == sym ? selectedColor : Color.clear, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Color theme
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Màu chủ đạo:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack(spacing: 12) {
                            ForEach(presetColors, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 2.5 : 0)
                                                .padding(-3)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                                .labelsHidden()
                        }
                    }
                }
                .padding(20)
            }

            Divider()

            // Footer
            HStack {
                Spacer()
                Button("Hủy") {
                    dismiss()
                }

                Button(initialItem == nil ? "Thêm Nút" : "Lưu Thay Đổi") {
                    saveAndDismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 520, height: 500)
    }

    private var targetTypeLabel: String {
        switch targetType {
        case .application: return "Đường dẫn file ứng dụng:"
        case .script:      return "Câu lệnh Shell Script:"
        case .url:         return "Địa chỉ trang web (URL):"
        }
    }

    private func saveAndDismiss() {
        let hex = selectedColor.toHex()
        let item = LaunchItem(
            id: initialItem?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            targetType: targetType,
            targetValue: targetValue.trimmingCharacters(in: .whitespacesAndNewlines),
            iconName: iconName,
            tintColorHex: hex,
            createdAt: initialItem?.createdAt ?? Date()
        )
        onSave(item)
        dismiss()
    }
}
