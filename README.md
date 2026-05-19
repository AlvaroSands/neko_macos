# Neko for macOS

A native macOS replica of the classic **Oneko** — a tiny pixel-art cat that chases your cursor around the screen.

![Neko chasing the cursor](screenshot.gif)

## Features

- Floats over all windows and fullscreen apps
- Follows your cursor in 8 directions
- Idles, scratches, yawns and falls asleep when left alone
- Wakes up with a surprised pose when you move again
- Status bar icon to pause/resume or quit
- No accessibility permissions required
- Does not appear in the Dock

## Requirements

- macOS 13 or later
- Xcode Command Line Tools (`xcode-select --install`)

## Run (development)

```bash
swift run
```

## Build a standalone app

```bash
bash build.sh
```

This produces `Neko.app` — double-click to launch.

## Credits

Sprite sheet: [oneko.js](https://github.com/adryd325/oneko.js) by adryd325.  
Original Neko concept by Masayuki Koba (1989).
