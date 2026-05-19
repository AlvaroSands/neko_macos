import AppKit

final class NekoView: NSView {
    var spriteSheet: SpriteSheet?
    var currentFrame: SpriteFrame = SpriteFrame(col: 3, row: 3)
    var nekoPosition: CGPoint = .zero  // en coords de pantalla (AppKit, Y hacia arriba)

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill(using: .copy)   // borra el contenido anterior de la región sucia

        guard let sheet = spriteSheet else { return }
        guard let img = sheet.image(col: currentFrame.col, row: currentFrame.row) else { return }

        let half: CGFloat = 16
        let drawRect = NSRect(
            x: nekoPosition.x - half,
            y: nekoPosition.y - half,
            width: 32,
            height: 32
        )
        img.draw(in: drawRect,
                 from: .zero,
                 operation: .sourceOver,
                 fraction: 1.0,
                 respectFlipped: false,
                 hints: [.interpolation: NSNumber(value: NSImageInterpolation.none.rawValue)])
    }
}
