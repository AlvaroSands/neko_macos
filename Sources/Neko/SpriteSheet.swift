import AppKit

final class SpriteSheet {
    private let tiles: [[NSImage]]  // [row][col]
    let tileSize: CGFloat = 32

    init?(gifURL: URL) {
        guard let data = try? Data(contentsOf: gifURL),
              let src = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImg = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }

        let cols = cgImg.width / 32
        let rows = cgImg.height / 32
        var grid: [[NSImage]] = []

        for row in 0..<rows {
            var rowImages: [NSImage] = []
            for col in 0..<cols {
                let rect = CGRect(x: col * 32, y: row * 32, width: 32, height: 32)
                guard let cropped = cgImg.cropping(to: rect) else { continue }
                let img = NSImage(cgImage: cropped, size: NSSize(width: 32, height: 32))
                rowImages.append(img)
            }
            grid.append(rowImages)
        }
        self.tiles = grid
    }

    func image(col: Int, row: Int) -> NSImage? {
        guard row < tiles.count, col < tiles[row].count else { return nil }
        return tiles[row][col]
    }
}
