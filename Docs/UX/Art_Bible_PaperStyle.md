# Art Bible — Paper Style Direction

## Core Style
- 2D paper-craft look with bold, high-contrast shapes and soft drop shadows.
- Clean outlines (1–3 px) keep elements readable on small screens.
- Motion uses gentle easing to evoke handcrafted cut-outs.

## Faux-3D Treatment
- Parallax stack of 3–5 layers: background sky, mid trees, ground, foreground props, UI topper.
- Hover or selection tilts elements by 2–5 degrees like cardboard.
- Depth indicated with subtle shadow offsets instead of 3D lighting.

## Tree Construction
- Each tree uses 2–4 paper layers: trunk base, canopy, fruit layer, optional magical effect.
- Idle animation = soft sway; harvest triggers confetti-like paper scrap burst.
- Rare/event variants add illuminated edges or spark overlays.

## Texture Guidance
- Use simple vector fills, watercolor washes, or scanned paper textures (digitally recreated) — never photo realism.
- Palette stays cohesive and limited per world for quick readability.

## Placeholder Palette
- See `Art/Placeholder/palette.md` for the current color shortlist.

## Performance Notes
- Prefer sprite sheets instead of many individual files.
- Target maximum 1024px per sheet for web delivery.
- Maintain alpha-friendly PNG or vector exports sized for quick loads.

## Deliverables & References
- Layer breakdown for modular tree assembly documented in `Art/Guides/paper_components.md`.
- Capture reference shots of parallax mockups once UI wireframes exist (future task).
