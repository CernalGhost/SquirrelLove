# SquirrelLove - Changelog

## 1.0.14

- Set `X-Curse-Project-ID` so GitHub Actions can upload releases to CurseForge.

## 1.0.13

- Panel and docs now say `/love` instead of "hug" (the emote used by the macro).

## 1.0.12

- Added `/sl` as a slash-command alias for `/sqlove`.
- Bumped `## Interface:` for retail 12.0.7 (`120007`) and PTR 12.1.0
  (`120100`).
- Updated README with logo, CurseForge link, and Wowhead achievement links.

## 1.0.11

- Added [To All the Slimes I Love](https://www.wowhead.com/achievement=40475)
  (The Ringing Deeps, 40475) with 18 TomTom waypoints.

## 1.0.10

- Rebuilt critter waypoints from Wowhead with explicit zone coordinates.
- Pest Control row, kill waypoints, and `/sqlove killway`.
- Region labels and compact three-column achievement UI.

## 1.0.3

- Minimap button now sits just outside the minimap rim regardless of
  minimap size or scale (previously could land inside the rim on
  larger/rescaled minimaps).
- Swapped the addon and macro icon to the flying-squirrel icon
  (`inv_squirrelflying`, file ID 3732476).

## 1.0.2

- Added the "To All the Squirrels Hidden Til Now" achievement
  (Dragon Isles, 16729).
- Added 12 Dragon Isles critter waypoints to the TomTom button.

## 1.0.1

First public release.

- Maintains a self-advancing macro (named `SquirrelLove`) that targets and
  `/love`s the critters needed for the "To All the Squirrels..." achievement
  series. Each press hugs nearby critters, then flips the macro to the next
  page.
- Reads every achievement's criteria live from the game, so completed
  critters and achievements are skipped automatically; when everything is
  done the macro becomes a harmless no-op.
- Progress window listing all nine achievements - click any row to open it
  in the Achievement panel.
- "Add TomTom Waypoints" button drops 100+ critter-hunt waypoints into
  TomTom (requires the TomTom addon).
- Minimap button: left-click toggles the window, right-click hides the
  button. `/sqlove minimap` shows/hides it from chat.
- Slash commands: `/sqlove` plus `grab`, `rebuild`, `way`, `minimap`,
  `status` and `debug`.
