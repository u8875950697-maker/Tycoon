# Evergrove Tycoon (Paper 2.5D Prototype)

A lightweight Godot 4.5.1 prototype prepared for a paper-craft tycoon game. This repository currently provides a minimal bootable project with a title menu that transitions into a simple world scene for further development.

## Quickstart
1. Install [Godot 4.5.1](https://godotengine.org/).
2. Open `Engine/Godot/project.godot` in the editor.
3. Press <kbd>F5</kbd> to run the project. The title screen appears with Play, Options, and End buttons.
4. Click **Play** to load the world scene with camera, light, and ground visible.

## Project Structure
```
Engine/Godot/
├── assets/              # Paper-style SVG textures (existing library)
├── project.godot        # Godot 4.5.1 project definition
├── scenes/
│   ├── WorldScene.tscn  # Minimal 3D stage with camera/light/ground
│   └── ui/
│       └── TitleScreen.tscn  # Title menu with navigation buttons
└── scripts/
    ├── ui/TitleScreen.gd     # Menu logic and scene switching
    └── world/WorldScene.gd   # Ensures camera activation on load

Builds/Web/README.md     # HTML5 export instructions
.githooks/no-conflict-markers # Enforces conflict-free commits
```

## Current Features
- Title screen with Play, Options (placeholder dialog), and End (desktop quit or web info) actions.
- Play button loads the 3D world scene containing a lit ground plane for immediate visual feedback.
- Basic Godot 4.5.1 configuration with no remaining merge conflicts and clean autoload list.

## Web Export
An HTML5 preset can be added in Godot via **Project → Export**. Target the `Builds/Web/` directory when generating the build. See `Builds/Web/README.md` for the summarized upload workflow.

## Contributing
- Keep commits small and avoid reintroducing Git conflict markers (guarded by `.githooks/no-conflict-markers`).
- Add new features incrementally, preserving the paper-style direction and lightweight asset footprint.
- Prefer Godot 4.5.1-compatible syntax (`@onready`, signal connections via `.connect`).
