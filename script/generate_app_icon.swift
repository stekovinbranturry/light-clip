import AppKit
import CoreGraphics
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("Assets", isDirectory: true)
let iconset = assets.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let png = assets.appendingPathComponent("AppIcon.png")
let icns = assets.appendingPathComponent("AppIcon.icns")

try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let scale = size / 1024.0
    func r(_ value: CGFloat) -> CGFloat { value * scale }

    let basePath = CGPath(
        roundedRect: rect.insetBy(dx: r(54), dy: r(54)),
        cornerWidth: r(218),
        cornerHeight: r(218),
        transform: nil
    )
    context.addPath(basePath)
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
        start: CGPoint(x: r(180), y: r(930)),
        end: CGPoint(x: r(900), y: r(80)),
        options: []
    )

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -r(22)), blur: r(34), color: NSColor.black.withAlphaComponent(0.22).cgColor)
    context.setFillColor(NSColor.white.withAlphaComponent(0.96).cgColor)
    let board = CGRect(x: r(238), y: r(185), width: r(548), height: r(674))
    context.addPath(CGPath(roundedRect: board, cornerWidth: r(74), cornerHeight: r(74), transform: nil))
    context.fillPath()
    context.restoreGState()

    context.setStrokeColor(NSColor(calibratedRed: 0.76, green: 0.80, blue: 0.86, alpha: 1).cgColor)
    context.setLineWidth(r(22))
    context.addPath(CGPath(roundedRect: board.insetBy(dx: r(28), dy: r(28)), cornerWidth: r(52), cornerHeight: r(52), transform: nil))
    context.strokePath()

    context.setFillColor(NSColor(calibratedRed: 0.18, green: 0.22, blue: 0.30, alpha: 1).cgColor)
    let clipTop = CGRect(x: r(369), y: r(792), width: r(286), height: r(95))
    context.addPath(CGPath(roundedRect: clipTop, cornerWidth: r(43), cornerHeight: r(43), transform: nil))
    context.fillPath()

    context.setStrokeColor(NSColor(calibratedRed: 0.33, green: 0.42, blue: 0.55, alpha: 0.34).cgColor)
    context.setLineWidth(r(18))
    context.setLineCap(.round)
    for y in [r(647), r(560), r(473)] {
        context.move(to: CGPoint(x: r(338), y: y))
        context.addLine(to: CGPoint(x: r(686), y: y))
        context.strokePath()
    }

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -r(12)), blur: r(18), color: NSColor.black.withAlphaComponent(0.24).cgColor)
    let zPath = CGMutablePath()
    zPath.move(to: CGPoint(x: r(675), y: r(721)))
    zPath.addCurve(to: CGPoint(x: r(396), y: r(709)), control1: CGPoint(x: r(580), y: r(736)), control2: CGPoint(x: r(480), y: r(730)))
    zPath.addCurve(to: CGPoint(x: r(350), y: r(620)), control1: CGPoint(x: r(346), y: r(696)), control2: CGPoint(x: r(326), y: r(654)))
    zPath.addCurve(to: CGPoint(x: r(508), y: r(594)), control1: CGPoint(x: r(375), y: r(584)), control2: CGPoint(x: r(438), y: r(588)))
    zPath.addCurve(to: CGPoint(x: r(330), y: r(348)), control1: CGPoint(x: r(430), y: r(520)), control2: CGPoint(x: r(368), y: r(438)))
    zPath.addCurve(to: CGPoint(x: r(395), y: r(286)), control1: CGPoint(x: r(315), y: r(312)), control2: CGPoint(x: r(343), y: r(282)))
    zPath.addCurve(to: CGPoint(x: r(676), y: r(307)), control1: CGPoint(x: r(485), y: r(295)), control2: CGPoint(x: r(585), y: r(294)))
    zPath.addCurve(to: CGPoint(x: r(711), y: r(402)), control1: CGPoint(x: r(725), y: r(315)), control2: CGPoint(x: r(739), y: r(364)))
    zPath.addCurve(to: CGPoint(x: r(544), y: r(428)), control1: CGPoint(x: r(686), y: r(437)), control2: CGPoint(x: r(621), y: r(432)))
    zPath.addCurve(to: CGPoint(x: r(718), y: r(671)), control1: CGPoint(x: r(622), y: r(505)), control2: CGPoint(x: r(684), y: r(585)))
    zPath.addCurve(to: CGPoint(x: r(675), y: r(721)), control1: CGPoint(x: r(728), y: r(700)), control2: CGPoint(x: r(712), y: r(719)))
    zPath.closeSubpath()
    context.addPath(zPath)
    context.setFillColor(NSColor(calibratedRed: 0.05, green: 0.38, blue: 1.0, alpha: 1).cgColor)
    context.fillPath()
    context.restoreGState()

    context.setFillColor(NSColor(calibratedRed: 1.0, green: 0.82, blue: 0.26, alpha: 1).cgColor)
    let spark = CGMutablePath()
    spark.move(to: CGPoint(x: r(724), y: r(789)))
    spark.addLine(to: CGPoint(x: r(751), y: r(724)))
    spark.addLine(to: CGPoint(x: r(820), y: r(700)))
    spark.addLine(to: CGPoint(x: r(753), y: r(674)))
    spark.addLine(to: CGPoint(x: r(727), y: r(609)))
    spark.addLine(to: CGPoint(x: r(699), y: r(674)))
    spark.addLine(to: CGPoint(x: r(633), y: r(699)))
    spark.addLine(to: CGPoint(x: r(699), y: r(724)))
    spark.closeSubpath()
    context.addPath(spark)
    context.fillPath()

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
