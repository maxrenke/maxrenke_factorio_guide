# Factorio First Run Guide

Interactive HTML guide + companion Factorio mod for your first vanilla playthrough (Space Age patch, no DLC).

## HTML Guide

Open `index.html` in any browser. No server needed.

- Check off tasks as you complete them
- Progress saves automatically in your browser (localStorage)
- 15 phases from crash-landing to rocket launch

## Factorio Mod

The companion mod tracks your in-game progress and auto-checks tasks based on game events.

### Installation

1. Copy the `mod/` folder to your Factorio mods directory:
   - Windows: `%AppData%\Roaming\Factorio\mods\`
   - Rename the folder to: `factorio-first-run-guide_1.0.0`
   - So the full path is: `%AppData%\Roaming\Factorio\mods\factorio-first-run-guide_1.0.0\`

2. Launch Factorio and enable the mod in the Mods menu

3. Start or load a save

### In-game Usage

- Click the **"Guide"** button in the top toolbar to open/close the tracker panel
- Tasks auto-complete as you play:
  - Technologies researched
  - Buildings placed
  - Items crafted
  - Rocket launched
- Check off any task manually by clicking its checkbox
- Click **"Export Progress"** to write progress to a JSON file

### Syncing with the HTML Guide

1. In-game: click **Export Progress** in the Guide panel
2. The file is saved to: `%AppData%\Roaming\Factorio\script-output\guide_progress.json`
3. In the HTML guide: click **"Import from Mod"** at the top
4. Select the `guide_progress.json` file
5. All completed tasks will sync automatically

### Compatibility

- Factorio 2.0+ (Space Age patch)
- Vanilla base game only - no Space Age DLC required
- Multiplayer: each player tracks their own progress

## Development

```bash
# Install mod for dev (symlink from repo to Factorio mods folder)
mklink /D "%AppData%\Roaming\Factorio\mods\factorio-first-run-guide_1.0.0" "C:\Users\<you>\repos\maxrenke_factorio_guide\mod"
```
