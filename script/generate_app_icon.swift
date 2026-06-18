import AppKit
import CoreGraphics
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("Assets", isDirectory: true)
let iconset = assets.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let png = assets.appendingPathComponent("AppIcon.png")
let icns = assets.appendingPathComponent("AppIcon.icns")
let statusBarIcon = assets.appendingPathComponent("StatusBarIconTemplate.png")
let docsAssets = root.appendingPathComponent("docs/assets", isDirectory: true)
let readmeLogo = docsAssets.appendingPathComponent("zclips-logo.png")

try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: docsAssets, withIntermediateDirectories: true)

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let scale = size / 1024.0
    func r(_ value: CGFloat) -> CGFloat { value * scale }

    let iconRect = CGRect(x: r(78), y: r(78), width: r(868), height: r(868))
    let iconMask = CGPath(
        roundedRect: iconRect,
        cornerWidth: r(190),
        cornerHeight: r(190),
        transform: nil
    )
    context.addPath(iconMask)
    context.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let baseGradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            NSColor(calibratedRed: 0.98, green: 0.99, blue: 1.0, alpha: 1).cgColor,
            NSColor(calibratedRed: 0.75, green: 0.87, blue: 1.0, alpha: 1).cgColor,
            NSColor(calibratedRed: 0.21, green: 0.45, blue: 0.98, alpha: 1).cgColor
        ] as CFArray,
        locations: [0, 0.55, 1]
    )!
    context.drawLinearGradient(
        baseGradient,
        start: CGPoint(x: iconRect.minX + r(110), y: iconRect.maxY - r(80)),
        end: CGPoint(x: iconRect.maxX - r(80), y: iconRect.minY + r(70)),
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -r(22)), blur: r(34), color: NSColor.black.withAlphaComponent(0.22).cgColor)
    context.setFillColor(NSColor.white.withAlphaComponent(0.96).cgColor)
    let board = CGRect(x: r(282), y: r(232), width: r(460), height: r(558))
    context.addPath(CGPath(roundedRect: board, cornerWidth: r(74), cornerHeight: r(74), transform: nil))
    context.fillPath()
    context.restoreGState()

    context.setStrokeColor(NSColor(calibratedRed: 0.76, green: 0.80, blue: 0.86, alpha: 1).cgColor)
    context.setLineWidth(r(22))
    context.addPath(CGPath(roundedRect: board.insetBy(dx: r(28), dy: r(28)), cornerWidth: r(52), cornerHeight: r(52), transform: nil))
    context.strokePath()

    context.setFillColor(NSColor(calibratedRed: 0.18, green: 0.22, blue: 0.30, alpha: 1).cgColor)
    let clipTop = CGRect(x: r(392), y: r(738), width: r(240), height: r(78))
    context.addPath(CGPath(roundedRect: clipTop, cornerWidth: r(43), cornerHeight: r(43), transform: nil))
    context.fillPath()

    context.setStrokeColor(NSColor(calibratedRed: 0.33, green: 0.42, blue: 0.55, alpha: 0.34).cgColor)
    context.setLineWidth(r(18))
    context.setLineCap(.round)
    for y in [r(610), r(538), r(466)] {
        context.move(to: CGPoint(x: r(350), y: y))
        context.addLine(to: CGPoint(x: r(674), y: y))
        context.strokePath()
    }

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -r(12)), blur: r(18), color: NSColor.black.withAlphaComponent(0.24).cgColor)
    let zPath = CGMutablePath()
    zPath.move(to: CGPoint(x: r(646), y: r(680)))
    zPath.addCurve(to: CGPoint(x: r(414), y: r(668)), control1: CGPoint(x: r(568), y: r(692)), control2: CGPoint(x: r(486), y: r(688)))
    zPath.addCurve(to: CGPoint(x: r(374), y: r(596)), control1: CGPoint(x: r(372), y: r(657)), control2: CGPoint(x: r(354), y: r(624)))
    zPath.addCurve(to: CGPoint(x: r(510), y: r(574)), control1: CGPoint(x: r(396), y: r(566)), control2: CGPoint(x: r(450), y: r(568)))
    zPath.addCurve(to: CGPoint(x: r(356), y: r(366)), control1: CGPoint(x: r(442), y: r(510)), control2: CGPoint(x: r(388), y: r(440)))
    zPath.addCurve(to: CGPoint(x: r(412), y: r(314)), control1: CGPoint(x: r(344), y: r(336)), control2: CGPoint(x: r(368), y: r(311)))
    zPath.addCurve(to: CGPoint(x: r(646), y: r(330)), control1: CGPoint(x: r(488), y: r(322)), control2: CGPoint(x: r(570), y: r(318)))
    zPath.addCurve(to: CGPoint(x: r(676), y: r(408)), control1: CGPoint(x: r(686), y: r(337)), control2: CGPoint(x: r(698), y: r(376)))
    zPath.addCurve(to: CGPoint(x: r(536), y: r(430)), control1: CGPoint(x: r(656), y: r(438)), control2: CGPoint(x: r(600), y: r(434)))
    zPath.addCurve(to: CGPoint(x: r(684), y: r(646)), control1: CGPoint(x: r(604), y: r(496)), control2: CGPoint(x: r(656), y: r(568)))
    zPath.addCurve(to: CGPoint(x: r(646), y: r(680)), control1: CGPoint(x: r(692), y: r(670)), control2: CGPoint(x: r(678), y: r(684)))
    zPath.closeSubpath()
    context.addPath(zPath)
    context.setFillColor(NSColor(calibratedRed: 0.05, green: 0.38, blue: 1.0, alpha: 1).cgColor)
    context.fillPath()
    context.restoreGState()

    context.setFillColor(NSColor(calibratedRed: 1.0, green: 0.82, blue: 0.26, alpha: 1).cgColor)
    let spark = CGMutablePath()
    spark.move(to: CGPoint(x: r(706), y: r(728)))
    spark.addLine(to: CGPoint(x: r(728), y: r(676)))
    spark.addLine(to: CGPoint(x: r(784), y: r(656)))
    spark.addLine(to: CGPoint(x: r(730), y: r(635)))
    spark.addLine(to: CGPoint(x: r(708), y: r(582)))
    spark.addLine(to: CGPoint(x: r(685), y: r(635)))
    spark.addLine(to: CGPoint(x: r(632), y: r(655)))
    spark.addLine(to: CGPoint(x: r(685), y: r(676)))
    spark.closeSubpath()
    context.addPath(spark)
    context.fillPath()

    image.unlockFocus()
    return image
}

func drawStatusBarIcon(pixelSize: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let scale = pixelSize / 64.0
    func r(_ value: CGFloat) -> CGFloat { value * scale }

    context.clear(CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    context.setStrokeColor(NSColor.black.cgColor)
    context.setLineCap(.round)
    context.setLineJoin(.round)

    let badge = CGRect(x: r(6), y: r(5), width: r(52), height: r(54))
    context.setLineWidth(r(5.6))
    context.addPath(CGPath(roundedRect: badge, cornerWidth: r(11), cornerHeight: r(11), transform: nil))
    context.strokePath()

    context.setLineWidth(r(6.2))
    context.move(to: CGPoint(x: r(20), y: r(42)))
    context.addLine(to: CGPoint(x: r(44), y: r(42)))
    context.addLine(to: CGPoint(x: r(20), y: r(22)))
    context.addLine(to: CGPoint(x: r(44), y: r(22)))
    context.strokePath()

    image.unlockFocus()
    return image
}

func drawRoundedReadmeLogo(from source: NSImage, size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = size * 0.225
    context.addPath(CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
    context.clip()
    source.draw(in: rect)

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to url: URL, pixelSize: Int) throws {
    guard let resized = NSImage(size: NSSize(width: pixelSize, height: pixelSize), flipped: false, drawingHandler: { rect in
        image.draw(in: rect)
        return true
    }).tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: resized),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "zClipsIcon", code: 1)
    }
    try data.write(to: url, options: [.atomic])
}

let master = drawIcon(size: 1024)
try writePNG(master, to: png, pixelSize: 1024)
try writePNG(drawStatusBarIcon(pixelSize: 18), to: statusBarIcon, pixelSize: 18)
try writePNG(drawRoundedReadmeLogo(from: master, size: 512), to: readmeLogo, pixelSize: 512)

let variants: [(String, Int)] = [
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

for (name, size) in variants {
    try writePNG(master, to: iconset.appendingPathComponent(name), pixelSize: size)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconset.path, "-o", icns.path]
try process.run()
process.waitUntilExit()
if process.terminationStatus != 0 {
    throw NSError(domain: "zClipsIcon", code: Int(process.terminationStatus))
}

print(icns.path)
