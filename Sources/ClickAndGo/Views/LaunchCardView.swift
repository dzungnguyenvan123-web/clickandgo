import SwiftUI
import AppKit

public struct LaunchCardView: View {
    public let item: LaunchItem
    public let isEditMode: Bool
    public let onLaunch: () -> Void
    public let onEdit: () -> Void
    public let onDelete: () -> Void

    @State private var isHovered: Bool = false
    @State private var isPressed: Bool = false

    public init(
        item: LaunchItem,
        isEditMode: Bool,
        onLaunch: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.item = item
        self.isEditMode = isEditMode
        self.onLaunch = onLaunch
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    private var accentColor: Color {
        Color(hex: item.tintColorHex) ?? .blue
    }

    private var appIcon: NSImage? {
        if item.targetType == .application {
            let expanded = (item.targetValue as NSString).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expanded) {
                return NSWorkspace.shared.icon(forFile: expanded)
            }
        }
        return nil
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                if isEditMode {
                    onEdit()
                } else {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isPressed = false
                        onLaunch()
                    }
                }
            }) {
                VStack(spacing: 12) {
                    // Icon representation
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(accentColor.opacity(0.12))
                            .frame(width: 64, height: 64)

                        if let icon = appIcon {
                            Image(nsImage: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } else {
                            Image(systemName: item.iconName.isEmpty ? item.targetType.systemIcon : item.iconName)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(accentColor)
                        }
                    }

                    // Title
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.primary)

                    // Target Type Badge
                    HStack(spacing: 4) {
                        Image(systemName: item.targetType.systemIcon)
                            .font(.system(size: 9))
                        Text(item.targetType.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(item.targetType.badgeColor.opacity(0.15))
                    .foregroundColor(item.targetType.badgeColor)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(
                            color: Color.black.opacity(isHovered ? 0.12 : 0.04),
                            radius: isHovered ? 8 : 3,
                            x: 0,
                            y: isHovered ? 4 : 1
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isHovered ? accentColor.opacity(0.6) : Color.gray.opacity(0.15), lineWidth: isHovered ? 1.5 : 1)
                )
                .scaleEffect(isPressed ? 0.94 : (isHovered && !isEditMode ? 1.02 : 1.0))
                .animation(.easeInOut(duration: 0.15), value: isHovered)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovered = hovering
            }
            .contextMenu {
                Button(action: onLaunch) {
                    Label("Khởi chạy ngay", systemImage: "play.fill")
                }
                Button(action: onEdit) {
                    Label("Chỉnh sửa", systemImage: "pencil")
                }
                if item.targetType == .application {
                    Button(action: {
                        let expanded = (item.targetValue as NSString).expandingTildeInPath
                        NSWorkspace.shared.selectFile(expanded, inFileViewerRootedAtPath: "")
                    }) {
                        Label("Hiện trong Finder", systemImage: "folder")
                    }
                }
                Divider()
                Button(role: .destructive, action: onDelete) {
                    Label("Xóa nút này", systemImage: "trash")
                }
            }

            // Delete Button overlay in Edit Mode
            if isEditMode {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white))
                }
                .buttonStyle(.plain)
                .offset(x: -6, y: 6)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// Color Hex Extension
extension Color {
    init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") { cleanHex.removeFirst() }

        guard cleanHex.count == 6, let intVal = UInt64(cleanHex, radix: 16) else {
            return nil
        }

        let red = Double((intVal >> 16) & 0xFF) / 255.0
        let green = Double((intVal >> 8) & 0xFF) / 255.0
        let blue = Double(intVal & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }

    func toHex() -> String {
        guard let components = NSColor(self).usingColorSpace(.deviceRGB) else {
            return "#0A84FF"
        }
        let r = Int(components.redComponent * 255)
        let g = Int(components.greenComponent * 255)
        let b = Int(components.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
