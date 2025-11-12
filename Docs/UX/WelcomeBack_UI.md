# Welcome Back UI Specification

## Layout
- **Header**: "Welcome back!"
- **Body summary**
  - Line 1: Time away (formatted `hh:mm`).
  - Line 2: Coins, Mana, Essence earned; include rare drop callout if applicable.
  - Line 3: Highlight top-performing tree with icon/tagline.
- **Buttons row** (large touch targets)
  - `Collect`
  - `Collect x2 (Ad)` — hidden when ads disabled or daily limit reached.
  - `Collect x2 (Gems)` — shows cost, disabled if insufficient Gems.
- **Footnote**
  - "Offline earnings capped at {CapHours}h. Doubles apply to Coins only."
  - Clear "No thanks" secondary action equivalent to closing the popup.

## Interaction Notes
- Present immediately on login/return, before the player can interact with the forest.
- Esc/Back/Close triggers the standard Collect (no double) flow, never forcing ads.
- Ad button shows cooldown timer when unavailable.

## Accessibility & UX
- Use high-contrast typography and iconography matching the paper style.
- Support controller/keyboard focus order: Collect → Collect x2 (Ad) → Collect x2 (Gems) → Close.
- Provide voice-over / screen reader labels for resource totals and each button.
- Keep animation subtle: small cardboard tilt and sparkle accent, under 0.5s.
