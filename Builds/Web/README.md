# Web Export Instructions

1. Open the project in Godot 4.x.
2. Install the official HTML5 export templates if prompted.
3. Choose **Project → Export…**, select the **Web** preset, and click **Export Project**.
4. Upload the resulting `Evergrove.html`, `.wasm`, and `.pck` files from this folder to CrazyGames or your hosting provider.

**QA tip:** Launch the exported build locally to confirm the welcome-back popup appears after a simulated clock advance and that the optional ad/gem doubles respect the one-per-day rule.

The exported build stays under the 35 MB target when textures remain vector-based. No additional optimization steps are required for this prototype.
