# Offline & AFK Rewards

## Purpose
Short-session friendly catch-up that respects time away, avoids pay-to-win spikes, and supports returning players without demanding constant attention.

## Accrual Formula (Specification)
- **BaseOfflineGain** = `OnlineRate * min(OfflineHours, CapHours) * OfflineMultiplier * PrestigeMult`
- **Suggested defaults**
  - `CapHours = 8`
  - `OfflineMultiplier = 0.6` (60% of equivalent online activity)
- **Prestige** bonuses stack multiplicatively via `PrestigeMult`.
- **Anti-exploit guard**: if a device clock anomaly greater than 30 minutes is detected, set offline earnings to 0 until the next valid session.

### Stage Caps
- **Early worlds**: `CapHours = 4`
- **Mid worlds**: `CapHours = 6`
- **Late worlds**: `CapHours = 8`
- **Endgame with Prestige perk**: up to `CapHours = 12`

## Return Bonus & Welcome-Back Flow
- Display a Welcome Back popup summarizing Coins, Mana, and Essence earned offline.
- Optional **Collect x2 (Ad)** or **Collect x2 (Gems)** choice doubles **Coins only**; Mana, Essence, Gems remain unchanged.
- Daily limit: **one double** every 24 hours.
- Clear "Collect" path with no multipliers for players who opt out.

## Session Catch-Up
- If the previous active session lasted under 10 minutes, grant an additional **+20% offline boost** on the next collection to prevent early churn.

## Streaks & Goodwill
- Daily **3-day streak** rewards a "Starlit Boost" (5 minutes of +25% growth on the next run).
- Missing a day resets the streak, but the first session after a miss grants a **+10% goodwill bonus** to offline earnings.

## Ethical Notes
- Explicit opt-out for ad or gem doubling.
- No forced prompts or energy timers; players collect whenever they return.
- Messaging explains caps, streak resets, and optional bonuses clearly.
