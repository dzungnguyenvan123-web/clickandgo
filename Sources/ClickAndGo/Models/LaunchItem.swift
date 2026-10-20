import Foundation
import SwiftUI

public enum TargetType: String, Codable, CaseIterable, Identifiable {
    case application = "Ứng dụng (.app)"
    case script      = "Shell Script"
    case url         = "Đường dẫn Web"

    public var id: String { rawValue }

    public var systemIcon: String {
        switch self {
        case .application: return "app.badge.fill"
        case .script:      return "terminal.fill"
        case .url:         return "globe"
        }
    }

    public var badgeColor: Color {
        switch self {
        case .application: return .blue
        case .script:      return .purple
        case .url:         return .green
        }
    }
}

public struct LaunchItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var targetType: TargetType
    public var targetValue: String        // Đường dẫn .app, câu lệnh script, hoặc web URL
    public var iconName: String           // SF Symbol name hoặc system icon
    public var tintColorHex: String       // Mã màu HEX
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        targetType: TargetType,
        targetValue: String,
        iconName: String = "bolt.fill",
        tintColorHex: String = "#0A84FF",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.targetType = targetType
        self.targetValue = targetValue
        self.iconName = iconName
        self.tintColorHex = tintColorHex
        self.createdAt = createdAt
    }

    public static let sampleItems: [LaunchItem] = [
        LaunchItem(
            title: "Safari",
            targetType: .application,
            targetValue: "/Applications/Safari.app",
            iconName: "safari.fill",
            tintColorHex: "#007AFF"
        ),
        LaunchItem(
            title: "Terminal",
            targetType: .application,
            targetValue: "/System/Applications/Utilities/Terminal.app",
            iconName: "terminal.fill",
            tintColorHex: "#34C759"
        ),
        LaunchItem(
            title: "Docker Check",
            targetType: .script,
            targetValue: "docker ps || echo 'Docker not running'",
            iconName: "cube.fill",
            tintColorHex: "#5856D6"
        ),
        LaunchItem(
            title: "GitHub",
            targetType: .url,
            targetValue: "https://github.com",
            iconName: "globe",
            tintColorHex: "#FF9500"
        )
    ]
}
