import AppKit

enum NekoState {
    case idle
    case alert
    case running(Direction)
    case scratchSelf
    case tired
    case sleeping
    case scratchWall(WallSide)
}

enum Direction: CaseIterable {
    case n, ne, e, se, s, sw, w, nw
}

enum WallSide {
    case north, south, east, west
}

struct SpriteFrame {
    let col: Int
    let row: Int
}

final class NekoEngine {
    var position: CGPoint
    var currentFrames: [SpriteFrame] = []
    var frameIndex: Int = 0
    private var state: NekoState = .idle
    private var idleTicks: Int = 0
    private var alertTicks: Int = 0
    let speed: CGFloat = 16
    private var screenBounds: CGRect = .zero
    private var tickCount: Int = 0

    init(startPosition: CGPoint) {
        self.position = startPosition
        self.screenBounds = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
        self.currentFrames = Self.frames(for: .idle)
    }

    func update(cursorPosition: CGPoint) {
        screenBounds = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
        tickCount += 1

        let dx = cursorPosition.x - position.x
        let dy = cursorPosition.y - position.y
        let distance = sqrt(dx * dx + dy * dy)

        switch state {
        case .alert:
            alertTicks -= 1
            if alertTicks <= 0 {
                state = .running(direction(dx: dx, dy: dy))
            }
            currentFrames = Self.frames(for: state)
            return

        case .running:
            if distance < speed {
                idleTicks = 0
                state = .idle
                currentFrames = Self.frames(for: state)
                return
            }
            let dir = direction(dx: dx, dy: dy)
            state = .running(dir)
            currentFrames = Self.frames(for: state)
            frameIndex = tickCount % 2
            move(dx: dx, dy: dy, distance: distance)
            return

        case .sleeping:
            if distance >= speed {
                alertTicks = 3
                state = .alert
                currentFrames = Self.frames(for: state)
            } else {
                frameIndex = tickCount % 2
            }
            return

        case .tired:
            idleTicks += 1
            if idleTicks > 4 {
                state = .sleeping
                idleTicks = 0
                currentFrames = Self.frames(for: state)
            }
            if distance >= speed {
                alertTicks = 3
                state = .alert
                currentFrames = Self.frames(for: state)
            }
            return

        case .scratchSelf:
            idleTicks += 1
            frameIndex = (idleTicks / 2) % 3
            if idleTicks > 9 {
                idleTicks = 0
                state = .idle
                currentFrames = Self.frames(for: state)
            }
            if distance >= speed {
                alertTicks = 2
                state = .alert
                currentFrames = Self.frames(for: state)
            }
            return

        case .scratchWall:
            idleTicks += 1
            frameIndex = idleTicks % 2
            if idleTicks > 6 {
                idleTicks = 0
                state = .idle
                currentFrames = Self.frames(for: state)
            }
            if distance >= speed {
                alertTicks = 2
                state = .alert
                currentFrames = Self.frames(for: state)
            }
            return

        case .idle:
            if distance >= speed {
                alertTicks = 2
                state = .alert
                currentFrames = Self.frames(for: state)
                return
            }
            idleTicks += 1

            let edge = nearEdge()
            if let side = edge, idleTicks > 5 && idleTicks % 20 < 6 {
                state = .scratchWall(side)
                idleTicks = 0
                currentFrames = Self.frames(for: state)
                return
            }
            if idleTicks > 10 && idleTicks % 30 < 8 {
                state = .scratchSelf
                idleTicks = 0
                currentFrames = Self.frames(for: state)
                frameIndex = 0
                return
            }
            if idleTicks > 50 {
                state = .tired
                idleTicks = 0
                currentFrames = Self.frames(for: state)
                return
            }
        }
    }

    private func move(dx: CGFloat, dy: CGFloat, distance: CGFloat) {
        let norm = min(speed, distance)
        var newX = position.x + (dx / distance) * norm
        var newY = position.y + (dy / distance) * norm
        newX = max(screenBounds.minX + 16, min(screenBounds.maxX - 16, newX))
        newY = max(screenBounds.minY + 16, min(screenBounds.maxY - 16, newY))
        position = CGPoint(x: newX, y: newY)
    }

    private func direction(dx: CGFloat, dy: CGFloat) -> Direction {
        let angle = atan2(dy, dx) * 180 / .pi
        switch angle {
        case -22.5..<22.5:   return .e
        case 22.5..<67.5:    return .ne
        case 67.5..<112.5:   return .n
        case 112.5..<157.5:  return .nw
        case 157.5...180,
             -180..<(-157.5): return .w
        case -157.5..<(-112.5): return .sw
        case -112.5..<(-67.5):  return .s
        default:             return .se
        }
    }

    private func nearEdge() -> WallSide? {
        let margin: CGFloat = 20
        if position.x <= screenBounds.minX + margin { return .west }
        if position.x >= screenBounds.maxX - margin { return .east }
        if position.y <= screenBounds.minY + margin { return .south }
        if position.y >= screenBounds.maxY - margin { return .north }
        return nil
    }

    var currentImage: SpriteFrame {
        guard !currentFrames.isEmpty else { return SpriteFrame(col: 3, row: 3) }
        return currentFrames[frameIndex % currentFrames.count]
    }

    static func frames(for state: NekoState) -> [SpriteFrame] {
        switch state {
        case .idle:          return [SF(3,3)]
        case .alert:         return [SF(7,3)]
        case .tired:         return [SF(3,2)]
        case .sleeping:      return [SF(2,0), SF(2,1)]
        case .scratchSelf:   return [SF(5,0), SF(6,0), SF(7,0)]
        case .running(let d): return runFrames(d)
        case .scratchWall(let s): return wallFrames(s)
        }
    }

    private static func runFrames(_ d: Direction) -> [SpriteFrame] {
        switch d {
        case .n:  return [SF(1,2), SF(1,3)]
        case .ne: return [SF(0,2), SF(0,3)]
        case .e:  return [SF(3,0), SF(3,1)]
        case .se: return [SF(5,1), SF(5,2)]
        case .s:  return [SF(6,3), SF(7,2)]
        case .sw: return [SF(5,3), SF(6,1)]
        case .w:  return [SF(4,2), SF(4,3)]
        case .nw: return [SF(1,0), SF(1,1)]
        }
    }

    private static func wallFrames(_ s: WallSide) -> [SpriteFrame] {
        switch s {
        case .north: return [SF(0,0), SF(0,1)]
        case .south: return [SF(7,1), SF(6,2)]
        case .east:  return [SF(2,2), SF(2,3)]
        case .west:  return [SF(4,0), SF(4,1)]
        }
    }

    private static func SF(_ col: Int, _ row: Int) -> SpriteFrame { SpriteFrame(col: col, row: row) }
}
