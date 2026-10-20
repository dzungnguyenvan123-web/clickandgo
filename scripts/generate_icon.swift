import AppKit

let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

guard let ctx = NSGraphicsContext.current?.cgContext else { exit(1) }

// Outer squircle margin for standard macOS style
let iconRect = CGRect(x: 90, y: 90, width: 844, height: 844)
let cornerRadius: CGFloat = 190

// Shadow
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -18), blur: 30, color: NSColor.black.withAlphaComponent(0.3).cgColor)

let path = CGPath(roundedRect: iconRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
ctx.addPath(path)
ctx.fillPath()
ctx.restoreGState()

// Blue Gradient Fill
ctx.saveGState()
ctx.addPath(path)
ctx.clip()

let colorSpace = CGColorSpaceCreateDeviceRGB()
let colors = [
    NSColor(red: 0.12, green: 0.58, blue: 1.0, alpha: 1.0).cgColor, // Top blue
    NSColor(red: 0.0, green: 0.36, blue: 0.90, alpha: 1.0).cgColor   // Bottom blue
] as CFArray
let locations: [CGFloat] = [0.0, 1.0]
if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 512, y: 934), end: CGPoint(x: 512, y: 90), options: [])
}
ctx.restoreGState()

// Inner subtle border highlight
ctx.saveGState()
ctx.addPath(path)
ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.25).cgColor)
ctx.setLineWidth(3)
ctx.strokePath()
ctx.restoreGState()

// Draw SF Symbol: bolt.fill
let config = NSImage.SymbolConfiguration(pointSize: 440, weight: .bold)
if let boltSymbol = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
    let tintImage = NSImage(size: boltSymbol.size)
    tintImage.lockFocus()
    NSColor.white.set()
    let rect = NSRect(origin: .zero, size: boltSymbol.size)
    rect.fill()
    boltSymbol.draw(in: rect, from: .zero, operation: .destinationIn, fraction: 1.0)
    tintImage.unlockFocus()

    // Draw centered with slight shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 16, color: NSColor.black.withAlphaComponent(0.2).cgColor)
    let boltRect = NSRect(
        x: (1024 - boltSymbol.size.width) / 2,
        y: (1024 - boltSymbol.size.height) / 2 + 10,
        width: boltSymbol.size.width,
        height: boltSymbol.size.height
    )
    tintImage.draw(in: boltRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    ctx.restoreGState()
}

image.unlockFocus()

// Export to iconset directory
let fm = FileManager.default
let iconsetDir = "AppIcon.iconset"
try? fm.removeItem(atPath: iconsetDir)
try! fm.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

let sizes: [(name: String, px: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for item in sizes {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: item.px,
        pixelsHigh: item.px,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: item.px, height: item.px)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: item.px, height: item.px), from: .zero, operation: .copy, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()

    let pngData = rep.representation(using: .png, properties: [:])!
    try! pngData.write(to: URL(fileURLWithPath: "\(iconsetDir)/\(item.name)"))
}

print("Iconset generated successfully!")
