# Tycoon

## Project Structure
- `Assets/` – Placeholder for audio, VFX, and shared asset references.
- `Art/` – Concept, textures, UI mockups, and model references.
- `Scripts/` – Future gameplay or tool scripts (currently empty).
- `Scenes/` – Scene or level files once an engine is chosen.
- `Docs/` – Design notes, roadmap, contributing info, and changelog.
- `Builds/` – Reserved for packaged builds or demos.
- `Tools/` – Pipelines, importers, or automation helpers.
- `Tests/` – Testing plans or automation.
- `Config/` – Project-wide configuration or environment files.
- `.github/` – Issue and PR templates plus workflow definitions.

## Short-Session Design & Monetization Overview
- Worlds operate as short-form stages with themed biomes and clear completion rewards.
- Tree slots expand gradually within each world, keeping runs readable and strategic.
- Breeding unlocks in later worlds to blend traits for hybrid seeds without overwhelming early play.
- Rewarded ads stay optional, offering double-harvest moments, slot tokens, or brief speed boosts.
- Paper-inspired art direction guides layered, faux-3D presentation for trees and UI.

## Offline/AFK & Welcome-Back Overview
- Offline earnings accrue at 60% of online rates with stage-based hour caps and Prestige multipliers.
- Welcome-back popups highlight time away, resources gained, and offer optional ad or gem doubles for Coins only with strict daily caps.
- Ethical guardrails ensure clear opt-outs, no forced prompts, and respect for short-session pacing.
- Daily streaks and catch-up boosts keep returning players rewarded without encouraging grind.

## Paper-Style Texture Placeholders
- All interim textures rely on shared SVG paper patterns, layered sprites, and parallax depth with no photographic sources.

## Engine & Build
- The full Godot 4.x project lives in `Engine/Godot` with layered Sprite3D trees, parallax terrain, and autoload singletons for state, UI, and world control.
- Open the project in the Godot editor to play the short-session loop or tweak design data in `Engine/Godot/data`.
- A ready-to-use HTML5 export preset writes to `Builds/Web/`; see `Builds/Web/README.md` for the upload checklist.

## Playable Loop Highlights
- Five themed worlds (Meadow through Dream Isles) each provide a 4×4 grid, hazards, and short-run objectives with selectable session lengths.
- Tree care, fruit harvesting, processing buffs, breeding (World 2+), offline rewards, and prestige systems are implemented without placeholder logic.
- Ethical rewarded-ad stubs gate optional coin doubles and slot unlocks while dev cheats stay toggleable for quick QA.

## World Dressing & UI Polish
- Each biome now features layered paper parallax, decals, and lightweight particles to reinforce its atmosphere without heavy post-process.
- Hazards and one-per-run world buffs surface through the top HUD with clear iconography, tooltips, and cooldown feedback.
- Tree panels expose care timers with iconography while the press and buff badge communicate active boosts at a glance.
- Plot tiles include paper frames, price tags, and celebratory unlock particles to highlight slot expansion moments.
