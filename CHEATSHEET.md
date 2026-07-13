# Factorio Keybind & Mod Config Cheat Sheet

Personal reference for the current mod loadout. Factorio 2.0.77 stable, vanilla base
game (no Space Age DLC). Last audited 2026-07-12.

Bindings marked (rebound) are custom values written to `config.ini` to resolve
conflicts; everything else is the mod's default. Contextual overlaps (keys that only
fire with a blueprint in cursor or inside a GUI) were left on their defaults on purpose.

## Planning & analysis

| Key | Action | Mod |
| --- | --- | --- |
| ALT + X | Rate calculator selection tool | Rate Calculator |
| CTRL + E | Toggle Recipe Book | Recipe Book |
| ALT + click | Open selected in Recipe Book | Recipe Book |
| U | Open/close Helmod | Helmod |
| SHIFT + O | Recipe selector (rebound) | Helmod |
| CTRL + SHIFT + U | Recipe explorer (rebound, was Y) | Helmod |
| CTRL + U | Where-used search | Helmod |
| ALT + Z | Select analysis zone | Assembly Analyst |
| CTRL + ALT + C | Clear analysis zones | Assembly Analyst |
| CTRL + ALT + T | Toggle craft-time display | Actual Craft Time |
| ALT + T | Tapeline measure tool (rebound, was ALT+M) | Tapeline |
| CTRL + ALT + M | Toggle Milestones window | Milestones |

## Factory visibility

| Key | Action | Mod |
| --- | --- | --- |
| G | Highlight hovered belt ghost | Belt Visualizer |
| SHIFT + G | Highlight hovered belt line | Belt Visualizer |
| Y | Visualize hovered pipe network | Pipe Visualizer |
| SHIFT + Y | Full pipe overlay | Pipe Visualizer |
| ALT + Y | Mouseover pipe mode | Pipe Visualizer |
| CTRL + SHIFT + Y | Color by fluid system | Pipe Visualizer |
| ALT + C | Visualize circuit connections (user bind) | Circuit Connection Visualizer |
| CTRL + SHIFT + C | Clear rendered circuit lines (user bind) | Circuit Connection Visualizer |
| SHIFT + F | Search the factory | Factory Search |
| SHIFT + ALT + click | Search for hovered prototype | Factory Search |
| SHIFT + H | Highlight resources | Resource Highlighter |
| CTRL + Y | YARM resource-site selector (rebound, was ALT+Y) | YARM |
| CTRL + G | Ghost counter selection | Ghost Counter |
| CTRL + H | Train log | Train Log |

## Building & logistics

| Key | Action | Mod |
| --- | --- | --- |
| CTRL-drag | Evenly distribute items into machines | Even Distribution |
| SHIFT + C | Inventory cleanup (drop trash to chests) | Even Distribution |
| CTRL + M | Mining patch planner (R / SHIFT+R rotate) | Mining Patch Planner |
| ALT + M | Give module inserter (SHIFT+wheel cycles module) | Module Inserter Simplified |
| SHIFT + arrows | Nudge hovered entity | Even Pickier Dollies |
| KP_0 | Rotate rectangular entity in place | Even Pickier Dollies |
| ALT + P | Rail signal planner menu | Rail Signal Planner |
| SHIFT + P | Toggle signals-with-rail-planner | Rail Signal Planner |
| CTRL + ALT + P | Toggle unidirectional signals (rebound) | Rail Signal Planner |
| ALT + U | P.U.M.P. pumpjack planner (rebound) | P.U.M.P. |
| SHIFT + ALT + P | Pipe painting planner (rebound) | Color Coded Pipe Planner |
| CTRL + ALT + B | Toggle autobuild (rebound, was SHIFT+B) | Autobuild |
| CTRL + SHIFT + B | Toggle autobuild tiles | Autobuild |
| SHIFT + ALT + C | Constructron selection tool (rebound) | Constructron |
| CTRL + P | Collapse Placeables panel | Placeables |
| CTRL + SHIFT + P | Toggle Placeables panel | Placeables |
| ALT + Q | Queue research to front | Queue To Front |
| CTRL + SHIFT + T | Toggle auto-research (rebound, was SHIFT+T) | Some Autoresearch |

## Blueprints

| Key | Action | Mod |
| --- | --- | --- |
| SHIFT + B | Configure blueprint in cursor | Blueprint Tools |
| SHIFT + G | Quick grid (blueprint in cursor) | Blueprint Tools |
| SHIFT + T | Set tiles (blueprint in cursor) | Blueprint Tools |
| SHIFT + C | Swap wire colors (blueprint in cursor) | Blueprint Tools |
| ALT + I | Import blueprint string | Blueprint Tools |
| SHIFT/CTRL + mouse-3 | Pipette add / remove entity in blueprint | Blueprint Tools |
| SHIFT + B | Toggle blueprint sandbox (no blueprint in cursor) | Blueprint Sandboxes |

## Character & misc

| Key | Action | Mod |
| --- | --- | --- |
| SHIFT + J | Toggle jetpack (user bind) | Jetpack |
| CTRL + I | Informatron (user bind) | Informatron |
| CTRL + SHIFT + Q | Quick item menu | qiMenu |
| SHIFT + T | Toggle todo list | Todo-List |
| CTRL + SHIFT + F | Todo search (rebound, was CTRL+F) | Todo-List |
| SHIFT + RETURN | Enter/exit nearest vehicle | Spidertron Enhancements |
| SHIFT + E | Open vehicle inventory remotely | Spidertron Enhancements |
| ALT + S | Recall spidertron | Spidertron Enhancements |
| CTRL + ALT + Q | Spidertron patrol pipette (rebound) | Spidertron Enhancements |

Unbound on purpose: Recipe Book's debug keys (`rb-debug-reload-mods` was ALT+M and
reloaded every mod when fat-fingered).

## Mod settings (non-default)

Set via `mod-settings.dat` (per-user unless noted):

| Setting | Value | Why |
| --- | --- | --- |
| Rate Calculator: show power consumption | on | see machine power draw in rate panels |
| Recipe Book: auto-focus search | on | type immediately on CTRL+E |
| YARM: adjust for mining productivity (map) | on | accurate depletion estimates |
| Even Distribution: custom trash | plates/bricks kept at set amounts | inventory cleanup targets |
| Gun Turret Alerts: threshold 8, selected mode | - | fewer alert pings |
| StatsGui: single line, research + evolution + playtime + daytime | - | compact top bar |
| Extra Zoom: min 4x, max 400x | - | full zoom range |
| BottleneckLite: small indicators + glow, includes drills | - | readable status dots |
| qiMenu: auto-open, remember selections | - | fast item grabbing |

Housekeeping applied 2026-07-12: 230 orphaned settings from uninstalled mods purged
from `mod-settings.dat`; backups at `mod-settings.dat.bak` / `config.ini.bak`.
CopyPasteModules and Fill4Me disabled - vanilla 2.0 covers both (module insert plans
in copy/paste and auto ammo/fuel insert on place).

## Integrations (researched, none installed)

- **Spotify**: no in-game integration exists or is possible - Factorio mods run in a
  sandboxed Lua environment with no network access. The official Factorio and Space Age
  soundtracks are on Spotify as albums; music *replacement* mods (e.g. Music Editor)
  can swap the in-game tracks.
- **Twitch**: possible only via an external bridge. [Twitch Chat Announcer](https://mods.factorio.com/mod/twitch_chat)
  shows chat in-game but needs a companion program feeding it over RCON;
  [Chat To File](https://mods.factorio.com/mod/ChatToFile) does the reverse (game chat
  out to a bot). Nothing is install-and-done; skip unless streaming.
