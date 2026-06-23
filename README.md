# SquirrelLove

A World of Warcraft (Retail) addon that helps you finish the **"To All the
Squirrels..."** and **"To All the Slimes..."** critter-hugging achievement series and **Pest Control**. It keeps a smart macro
up to date so you can target and `/love` the critters you still need, and it
can drop TomTom waypoints for the critter hunt.

**Author:** CernalGhost  
**Version:** 1.0.11

---

## What it does

WoW's secure-code rules forbid an addon from automatically targeting and
emoting in a loop (that would be a botting API), so you still press a key.
What SquirrelLove does is keep that key useful:

- It reads each achievement's criteria **live from the game**, so completed
  achievements and already-loved critters are skipped automatically.
- It builds a macro named **`SquirrelLove`** containing `/tar` lines for the
  critters you still need. Because a macro is capped at 255 characters, the
  critter list is split into "pages." Each press hugs nearby critters on the
  current page, then the macro flips itself to the next page.
- When everything is done, the macro becomes a harmless no-op.
- A movable window shows progress per achievement, and a button loads all the
  critter-hunt waypoints into TomTom.

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
| [Pest Control](https://www.wowhead.com/achievement=2556) *(kill pests; TomTom waypoints only)* | — |

Every critter name is read live from each achievement's in-game criteria, so
the addon always reflects your real progress and needs no hand-maintained
critter lists.

## Install

1. Unzip so the folder lands at
   `World of Warcraft\_retail_\Interface\AddOns\SquirrelLove\`
   with `SquirrelLove.toc` and `SquirrelLove.lua` directly inside it.
2. Restart WoW or `/reload`.
3. You should see `[SquirrelLove] v1.0.11 loaded` in chat. If not, see
   Troubleshooting below.

## Usage

- Type `/sqlove` to open the window, or click the minimap button.
- The minimap button: left-click toggles the window, right-click hides
  the button (`/sqlove minimap` brings it back).
- Click **Grab Macro**, then drop the macro onto an action bar.
- Stand among critters and spam the macro key. Each press hugs whatever
  needed critters are nearby and advances to the next page.
- Click **Add TomTom Waypoints** to load all critter locations into TomTom
  (requires the TomTom addon). Clear them later with `/way reset all`.
- Click any achievement name in the window to open it in the Achievement panel.

### Slash commands

| Command | Action |
|---|---|
| `/sqlove` | Toggle the window |
| `/sqlove grab` | Put the macro on your cursor |
| `/sqlove rebuild` | Recheck progress and rebuild the macro |
| `/sqlove way` | Load the TomTom waypoints |
| `/sqlove minimap` | Show or hide the minimap button |
| `/sqlove status` | Print how many critters remain |
| `/sqlove killway` | Load Pest Control kill waypoints (TomTom) |
| `/sqlove debug` | Print internal state (for support) |

## Contributing

Bug reports, feature ideas, and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

## Customizing

Open `SquirrelLove.lua` in a text editor:

- **Critter names** are auto-detected from each achievement's criteria, so
  there is nothing to maintain. If a critter ever mistargets (a criterion
  whose generic name differs from the targetable critter), add an entry to
  the `NAME_FIXES` table near the top: it maps a criterion name to the
  correct `/tar` text, per achievement.
- **Waypoints** live in the `WAYPOINTS` table. Each string is the text that
  follows `/way`.

## Troubleshooting

- **No `[SquirrelLove] loaded` line after `/reload`** — the addon's code is
  not running. Almost always it's flagged "out of date": on the AddOns screen
  tick **"Load out of date AddOns."** Also confirm the folder isn't
  double-nested (`AddOns\SquirrelLove\SquirrelLove\...`).
- **See Lua errors** — run `/console scriptErrors 1` then `/reload`.
- **`/sqlove debug`** prints the macro index, page count and window state.

---

For WoW addon development rules (Midnight / AI agents), see the parent workspace  
`docs-for-ai-agents/` folder — not shipped with the CurseForge package.
