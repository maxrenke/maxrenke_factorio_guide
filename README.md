# Factorio Vanilla Progress Guide

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
   - Rename the folder to: `vanilla-progress-guide_1.0.0`
   - So the full path is: `%AppData%\Roaming\Factorio\mods\vanilla-progress-guide_1.0.0\`

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

There are two ways to sync. Both work; pick whichever you like.

#### Option A - Manual (no server, works offline)

1. In-game: progress auto-exports on every task; or click **Export Progress** to force a write
2. The file is saved to: `%AppData%\Roaming\Factorio\script-output\guide_progress.json`
3. Open `index.html` in a browser, click **"Import from Mod"** at the top
4. Select the `guide_progress.json` file. All completed tasks sync.

#### Option B - Live sync (automatic, via local server)

Runs a tiny local web server that serves the guide and the mod's live progress, so
the page updates by itself every few seconds while you play.

1. Make sure Python 3 is installed (`python --version`)
2. Start the server (any one of these):
   - Double-click `server\start-server.bat`
   - Or run `pwsh -File server\start-server.ps1`
   - Or run `python server\serve.py`
3. Your browser opens `http://localhost:8777/` automatically
4. Play Factorio. A status badge in the top bar shows the live connection:
   - green "Factorio connected - live" = updating in real time
   - amber "Factorio idle" = server up, showing the last export
   - red "Sync server unreachable" = the server isn't running (use Option A)

The mod auto-exports progress and writes a heartbeat every ~5 seconds. The server
reads those from `script-output\` and the page polls them. Factorio cannot launch the
server or read the network itself (mod sandbox), so you start the server once - see
auto-start below.

**"Start Live Server" button:** when the page can't reach a server, a button appears in
the top bar. Browsers can't launch programs directly, so it works via a one-time custom
protocol registration. Run this once:

```
pwsh -File server\register-protocol.ps1      # undo with: -Unregister
```

After that, clicking **Start Live Server** launches `launch-server-silent.bat` for you;
reload the page and it goes live. If you skip registration, the button still opens a panel
with the exact command to run.

**Why two files:** `guide_progress.json` (your task state) and `guide_heartbeat.json`
(freshness marker the page uses to show the green/amber connection status).

**Custom port / script-output path:**

```
python server\serve.py --port 9000 --script-output "D:\Factorio\script-output"
```

#### Auto-start the server on login (closest thing to "it just happens")

The mod can't launch the server, but Windows can start it for you:

1. Press `Win+R`, type `shell:startup`, Enter
2. Put a shortcut to `server\start-server.bat` in that folder (add `--no-browser` to the
   shortcut target if you don't want a browser tab each login)

Now the server runs whenever you log in; just open `http://localhost:8777/` when you want
the guide.

### Compatibility

- Factorio 2.0+ (Space Age patch)
- Vanilla base game only - no Space Age DLC required
- Multiplayer: each player tracks their own progress

## Credits - Source Material

The guide content is distilled from these excellent community tutorials. All credit for
the gameplay strategies, ratios, and tips goes to their creators - please watch and support
the originals:

| Channel | Title | Link |
| --- | --- | --- |
| [Trupen](https://www.youtube.com/channel/UC6kQdIS4TJwUURNu0NPoVgw) | Your First Rocket in Factorio: Space Age | [video](https://www.youtube.com/watch?v=xy77YMCCMfk) |
| [Rkadindoubt](https://www.youtube.com/channel/UC6obSe9KghAkZwusQ9TsdFA) | New Player's Guide - Factorio Space Age \| Going from Start to Space (Walkthrough Supercut) | [video](https://www.youtube.com/watch?v=E7ShDWXvD4M) |
| [Nilaus](https://www.youtube.com/channel/UCD80bzqJh1N7lOqn7n0vKTg) | HOW TO PLAY FACTORIO \| 7000+ Hours of experience explained in 30 min | [video](https://www.youtube.com/watch?v=chavhzKpZwM) |
| [Trupen](https://www.youtube.com/channel/UC6kQdIS4TJwUURNu0NPoVgw) | Your First Hour in Factorio | [video](https://www.youtube.com/watch?v=MtypKdgWWtk) |

## Development

```bash
# Install mod for dev (symlink from repo to Factorio mods folder)
mklink /D "%AppData%\Roaming\Factorio\mods\vanilla-progress-guide_1.0.0" "C:\Users\<you>\repos\maxrenke_factorio_guide\mod"
```

## Publishing to the Factorio Mod Portal

The mod is portal-ready. To build and upload:

1. Build the zip:
   ```
   pwsh -File build-mod.ps1
   ```
   This produces `dist\vanilla-progress-guide_1.0.0.zip` containing a single top
   folder `vanilla-progress-guide_1.0.0\` with `info.json` at its root (the structure
   the portal requires). The HTML guide and server are NOT included - the mod is
   standalone.

2. Sign in at https://mods.factorio.com/ with your Factorio.com account.

3. Click **Upload a Mod**, fill in the details (the `name` field must match
   `vanilla-progress-guide` and is permanent), select the **MIT** license, and upload
   the zip. The portal reads `title`, `description`, `thumbnail.png`, and
   `changelog.txt` from inside the zip.

4. For later updates: bump `version` in `mod/info.json`, add a matching block to
   `mod/changelog.txt`, re-run `build-mod.ps1`, and upload the new zip to the same
   mod page.

What ships in the zip: `control.lua`, `gui.lua`, `phases.lua`, `sync.lua`,
`info.json`, `changelog.txt`, `thumbnail.png`, `LICENSE`.
