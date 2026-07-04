[![SquirrelLove logo](squirrellove-logo.png)](https://www.curseforge.com/wow/addons/squirrel-love/preview)

# SquirrelLove

**Finish the entire "To All the Squirrels…" critter achievement line and Pest Control without spreadsheets, guesswork, or tabbing out to Wowhead.**

SquirrelLove tracks which critters you still need, builds a smart macro that targets and `/love`s them, and drops TomTom waypoints for every location. Press one key near a pack of critters — the macro `/love`s what you need, skips what you've already done, and automatically advances to the next batch.

**Author:** CernalGhost  
**Version:** 1.0.16  
**Slash command:** `/sqlove` or `/sl`  
**Download:** [CurseForge (preview — moderation)](https://www.curseforge.com/wow/addons/squirrel-love/preview) · [GitHub](https://github.com/CernalGhost/SquirrelLove)

---

## Features

- **Live progress tracking** — reads achievement criteria from the game, so completed achievements and already-loved critters are skipped automatically.
- **Self-advancing macro** — creates a macro named `SquirrelLove` with `/tar` lines for critters you still need. Macros cap at 255 characters, so the list is split into pages; each press `/love`s nearby critters, then flips to the next page. When everything's done, the macro becomes a harmless no-op.
- **Progress window** — lists all achievements with completion status; click any row to open it in the Achievement panel.
- **TomTom waypoints** — map pin on each achievement (one region at a time), or **Add Remaining Pins** for incomplete achievements only. Pest Control has its own kill pins.
- **Minimap button** — left-click toggles the window, right-click hides the button.

## Achievements covered

| Achievement | Region |
|---|---|
| [To All the Squirrels I've Loved Before](https://www.wowhead.com/achievement=1206) | Eastern Kingdoms / Kalimdor |
| [To All the Squirrels Who Shared My Life](https://www.wowhead.com/achievement=2557) | Northrend |
| [To All the Squirrels Who Cared for Me](https://www.wowhead.com/achievement=5548) | Cataclysm |
| [To All the Squirrels I Once Caressed](https://www.wowhead.com/achievement=6350) | Pandaria |
| [To All the Squirrels Through Time and Space](https://www.wowhead.com/achievement=14728) | Draenor |
| [To All the Squirrels I Love Despite Their Scars](https://www.wowhead.com/achievement=14729) | Legion |
| [To All the Squirrels I Set Sail to See](https://www.wowhead.com/achievement=14730) | Battle for Azeroth |
| [To All the Squirrels I've Loved and Lost](https://www.wowhead.com/achievement=14731) | Shadowlands |
| [To All the Squirrels Hidden Til Now](https://www.wowhead.com/achievement=16729) | Dragon Isles |
| [To All the Squirrels Burrowed Beneath](https://www.wowhead.com/achievement=18361) | Zaralek Cavern |
| [To All the Slimes I Love](https://www.wowhead.com/achievement=40475) | The Ringing Deeps |
| [Pest Control](https://www.wowhead.com/achievement=2556) | Various (kill pests) |

Every critter name is read live from in-game criteria, so the addon always reflects your real progress — even after Blizzard adds new critters.

## Requirements

- Retail World of Warcraft.
- **TomTom** (optional) — required only for the waypoint buttons.

## Installation

1. Extract **SquirrelLove** into `World of Warcraft\_retail_\Interface\AddOns\SquirrelLove\` with `SquirrelLove.toc` and `SquirrelLove.lua` directly inside it.
2. `/reload`. You'll see `[SquirrelLove] loaded` in chat.

Enable **Load out of date AddOns** if the Interface number lags a patch.

## Commands

| Command | Action |
|---|---|
| `/sqlove` or `/sl` | Toggle the window |
| `/sqlove grab` | Put the macro on your cursor |
| `/sqlove rebuild` | Recheck progress and rebuild the macro |
| `/sqlove way` | TomTom pins for incomplete love achievements |
| `/sqlove wayall` | TomTom pins for every love achievement |
| `/sqlove killway` | Pest Control kill waypoints (TomTom) |
| `/sqlove minimap` | Show / hide the minimap button |
| `/sqlove status` | Print how many critters remain |
| `/sqlove debug` | Print internal state (for support) |

## Usage

1. Open the window with `/sqlove` or the minimap button.
2. Click **Grab Macro** and drop it on an action bar.
3. Stand near critters and press the key — each press `/love`s what you still need and advances to the next page.
4. Click the **map icon** on an achievement row for that region's TomTom pins, or **Add Remaining Pins** for all incomplete ones (clear with `/way reset all`).

## Troubleshooting

- **No `[SquirrelLove] loaded` line after `/reload`** — tick **Load out of date AddOns** on the AddOns screen. Also confirm the folder isn't double-nested (`AddOns\SquirrelLove\SquirrelLove\...`).
- **See Lua errors** — run `/console scriptErrors 1` then `/reload`.
- **`/sqlove debug`** prints the macro index, page count, and window state.

## Customizing

Open `SquirrelLove.lua` in a text editor:

- **Critter names** are auto-detected from each achievement's criteria. If a critter ever mistargets, add an entry to the `NAME_FIXES` table near the top.
- **Waypoints** live in the `WAYPOINTS` table. Each string is the text that follows `/way`.

## Contributing

Bug reports, feature ideas, and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

---

For WoW addon development rules (Midnight / AI agents), see the parent workspace  
`docs-for-ai-agents/` folder — not shipped with the CurseForge package.
