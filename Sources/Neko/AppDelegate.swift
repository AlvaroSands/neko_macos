import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var nekoView: NekoView!
    private var engine: NekoEngine!
    private var timer: Timer?
    private var statusItem: NSStatusItem!
    private var paused = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupSpriteSheet()
        setupWindow()
        setupStatusItem()
        startTimer()
    }

    private func setupSpriteSheet() {
        guard let url = Bundle.module.url(forResource: "oneko", withExtension: "gif")
                     ?? Bundle.main.url(forResource: "oneko", withExtension: "gif") else {
            fatalError("No se encontró oneko.gif en el bundle")
        }
        let sheet = SpriteSheet(gifURL: url)!
        let allScreens = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
        let center = CGPoint(x: allScreens.midX, y: allScreens.midY)
        engine = NekoEngine(startPosition: center)
        nekoView = NekoView()
        nekoView.spriteSheet = sheet
        nekoView.nekoPosition = windowPoint(from: center, windowFrame: allScreens)
    }

    private func setupWindow() {
        let allScreens = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
        window = NSWindow(
            contentRect: allScreens,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)) + 1)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        window.contentView = nekoView
        nekoView.frame = allScreens
        window.orderFrontRegardless()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "pawprint.fill", accessibilityDescription: "Neko")
        }
        let menu = NSMenu()
        let pauseItem = NSMenuItem(title: "Pausar", action: #selector(togglePause), keyEquivalent: "")
        pauseItem.target = self
        menu.addItem(pauseItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Salir", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    @objc private func togglePause() {
        paused.toggle()
        if let item = statusItem.menu?.item(at: 0) {
            item.title = paused ? "Reanudar" : "Pausar"
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        guard !paused else { return }

        let cursor = NSEvent.mouseLocation
        engine.update(cursorPosition: cursor)

        let allScreens = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
        let viewPoint = windowPoint(from: engine.position, windowFrame: allScreens)
        nekoView.nekoPosition = viewPoint
        nekoView.currentFrame = engine.currentImage

        nekoView.needsDisplay = true
    }

    // Convierte coords de pantalla (AppKit, Y↑, origen pantalla principal) a coords de la vista
    private func windowPoint(from screen: CGPoint, windowFrame: CGRect) -> CGPoint {
        return CGPoint(x: screen.x - windowFrame.origin.x,
                       y: screen.y - windowFrame.origin.y)
    }
}
