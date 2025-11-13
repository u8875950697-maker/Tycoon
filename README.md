# Grovecraft Tycoon

A lightweight Godot 4.5.1 prototype for a pixel-meets-paper tycoon concept. The current build focuses on a bootable loop with a Terraria/Minecraft-inspired title screen that transitions into a simple world scene for future gameplay work.

## Quickstart
1. Install [Godot 4.5.1](https://godotengine.org/).
2. Open `Engine/Godot/project.godot` in the editor.
3. Press <kbd>F5</kbd> to run. The pixel-art title screen (with parallax layers, falling leaves, and hover SFX) appears.
4. Click **Play** to load the world scene; camera, light, and ground are already configured so development can continue immediately.

## Project Structure
```
Engine/Godot/
├── assets/              # Paper + pixel placeholder textures and audio
├── project.godot        # Godot 4.5.1 project definition
├── scenes/
│   └── WorldScene.tscn        # Minimal 3D stage with camera/light/ground
├── ui/
│   └── TitleScreen.tscn       # Pixel title menu with parallax + particles
└── scripts/
    ├── GameState.gd          # Autoload stub for currencies/save shell
    ├── UIManager.gd          # Autoload stub for popup helpers
    ├── WorldController.gd    # Autoload stub for grid math utilities
    ├── ui/TitleScreen.gd     # Menu logic and scene switching
    └── world/WorldScene.gd   # Ensures camera activation on load

Builds/Web/README.md     # HTML5 export instructions
.githooks/no-conflict-markers # Enforces conflict-free commits
```

## Current Features
- Pixel-style title screen with Play, Options (placeholder dialog), and Quit (desktop quit or web notice) actions.
- Play button loads the 3D world scene containing a lit ground plane for immediate visual feedback.
- Basic Godot 4.5.1 configuration with no remaining merge conflicts and clean autoload list.

## Web Export
An HTML5 preset can be added in Godot via **Project → Export**. Target the `Builds/Web/` directory when generating the build. See `Builds/Web/README.md` for the summarized upload workflow.

## Contributing
- Keep commits small and avoid reintroducing Git conflict markers (guarded by `.githooks/no-conflict-markers`).
- Add new features incrementally, preserving the paper-style direction and lightweight asset footprint.
- Prefer Godot 4.5.1-compatible syntax (`@onready`, signal connections via `.connect`).
