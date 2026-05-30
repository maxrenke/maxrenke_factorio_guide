# Factorio First Run Guide - Audit (Opus 4.8)

Scope of audit: (A) the mod, (B) the mod<->HTML sync mechanism, (C) the guide content
itself, grounded in deep research of transcripts guide1-guide5.

---

## CRITICAL FINDING: The mod->HTML sync is broken by design

The sync matches tasks **by positional index only**, but the mod and the HTML have
**different numbers of tasks per phase**. Importing mod progress will check the WRONG
boxes in the HTML, and in most phases silently drop or mis-map tasks.

### The contract, as actually implemented
- `mod/sync.lua` writes `guide_progress.json`: `phases[phase_id].tasks{task_id=bool}` +
  `phases[phase_id].completed`. Task IDs are the real ids (`p1_mine_iron`, etc).
- `index.html` `importFromMod()` (lines 2530-2599) **ignores the task IDs entirely**.
  It does `taskIdx = Object.keys(phaseData.tasks).indexOf(taskId)` and then checks
  `checklistItems[taskIdx]`. The code comments even admit this:
  > "Since we can't import phases_def in JS, we rely on the task order being consistent."
- HTML's own localStorage task IDs are `phase-7_task_0` (DOM index based), unrelated to
  the mod's `p7_...` ids. So there are TWO independent ID schemes that never reconcile.

### Why positional matching fails: task counts do not line up
| Phase | mod tasks (phases.lua) | HTML checklist-items | Match? |
|------:|----:|----:|:--|
| 1  | 6 | 12 | NO |
| 2  | 5 | 9 (cl-2a + cl-2b) | NO |
| 3  | 5 | 11 | NO |
| 4  | 5 | 10 (cl-4 + cl-4b) | NO |
| 5  | 4 | 8 (cl-5 + cl-5b) | NO |
| 6  | 7 | 13 (cl-6 + cl-6b) | NO |
| 7  | 4 | 8  | NO |
| 8  | 4 | 9 (cl-8 + cl-8b) | NO |
| 9  | 4 | 9 (cl-9 + cl-9b) | NO |
| 10 | 4 | 8  | NO |
| 11 | 5 | 11 (cl-11 + cl-11b) | NO |
| 12 | 3 | 6  | NO |
| 13 | 4 | 8  | NO |
| 14 | 6 | 9 (cl-14 + cl-14b; recipe two-col not counted) | NO |
| 15 | 1 | 5  | NO |

VERIFIED: all 15 phases mismatch. The HTML is consistently ~2x richer.

The HTML splits each phase into multiple `checklist` blocks (e.g. `cl-8` + `cl-8b`) and
`querySelectorAll('.checklist-item')` flattens them, so even the index space differs from
the mod's flat task list. Net effect: completing "Research Solar Energy" in-game might tick
"Build Battery production" in the webpage, or nothing at all for tasks beyond the mod's
shorter list.

### Phase-count mismatch is benign but worth noting
Both sides hardcode 15 phases (gui.lua "/ 15 phases" x2; index.html `totalPhases = 15`).
That's consistent today but is a maintenance landmine if phases change.

### Recommended fix (pick one)
1. **Stable data-id attributes (best).** Emit `data-task-id="p8_produce_solar"` on each
   HTML `.checklist-item`, make the HTML task set EXACTLY mirror `phases.lua` (same ids,
   same count, same order), and have `importFromMod()` match by `data-task-id` not index.
   This makes phases.lua the single source of truth.
2. **Generate the HTML checklists from a shared JSON** exported from phases.lua at build
   time, so drift is impossible.
3. At minimum, **add an integrity check**: if `checklistItems.length !=
   Object.keys(phaseData.tasks).length`, warn the user in the import result instead of
   silently mis-checking.

---

## (A) Mod improvements

1. **Surface hardcoded to nauvis.** `get_produced_count` reads only `nauvis`/`surfaces[1]`
   production stats. Fine for the current vanilla/rocket scope, but if the guide ever
   expands to Space Age planets (see section C) production on other surfaces won't count.
   Use `force.get_item_production_statistics` aggregated across surfaces, or per-surface
   keyed to the active planet.
2. **Polling cost.** Production triggers poll every 300 ticks (5s) over all incomplete
   `produced`/`crafted` tasks for all players. Cheap now, but consider unsubscribing the
   nth_tick handler once all production/crafted tasks are complete.
3. **`crafted` vs `produced` semantics.** Phase 1 uses `crafted` for gears (count=1) and
   `produced` for plates. `crafted` = hand/assembler craft cumulative; `produced` =
   production-statistics flow. The guide text says "Craft iron gear wheels" - confirm the
   chosen event matches intent (a player who only ever assembles gears via machine still
   triggers `produced`; `crafted` may require a manual/assembler craft event). Document
   the distinction in code comments.
4. **No "uncomplete" path.** complete_task/complete_phase are one-way. If a player ticks a
   box by mistake in the GUI, verify the checkbox handler can revert state cleanly.
5. **Hand-rolled JSON in sync.lua.** Works, but no escaping of player names with quotes/
   backslashes. A player named `a"b` would emit invalid JSON and break the HTML import.
   Escape strings (or use `helpers.table_to_json` if available in 2.0).
6. **GUI hardcodes "/ 15 phases" and title "Vanilla Rocket Launch".** Drive these from
   `#phases` and a single config string so a scope change is one edit.

---

## (B) Sync mechanism - secondary notes (beyond the critical finding)

- **Import path UX.** Modal instructs reading
  `%AppData%\Roaming\Factorio\script-output\guide_progress.json`. `write_file(..., false)`
  appends? In Factorio `write_file`'s 3rd arg is `append`; `false` = overwrite (correct).
  Good - re-exports won't accumulate stale JSON.
- **One-directional sync.** Mod -> HTML only. The HTML "Import from Mod" cannot push back
  to the mod. That's fine, but document it so users don't expect webpage ticks to appear
  in-game.
- **`phaseData.completed` force-checks all HTML items** (lines 2575-2586) regardless of the
  count mismatch - this is the one place it "self-heals" a completed phase, masking the
  per-task mismatch and making the bug harder to notice during testing.

---

## (C) Guide content quality vs transcript research

The guide is a **well-structured vanilla-to-rocket** guide (15 phases). It is internally
coherent, has good why-blocks, trap callouts, and ratios. Findings:

### Strengths (corroborated by transcripts)
- **Yellow-before-purple science** (Phase 9 why-block) matches guide3 (Nielas) rationale.
- **25:21 solar:accumulator ratio** (Phase 8) matches guide3 (25:21 at 25:21 timestamp).
- **Robot rush priority** (Phase 7) matches guide2/guide3 emphasis on bots ASAP.
- **Prod-3 in silo 1000->~715 parts** (Phase 13/14) - correct vanilla math.
- **Nuclear before purple** (Phase 11 why) is sound for a beaconed endgame.

### Accuracy items to verify/fix
- **Nuclear ratio callout (Phase 11)** states `1 Reactor (160 MW effective) : 8 Heat
  Exchangers : 14 Steam Turbines`. Vanilla canonical is per single reactor 40MW base; in a
  2x2 with neighbor bonus an *array* yields the higher numbers. The text mixes "480 MW for
  4-reactor" (earlier task) with "160 MW effective" (ratio). Reconcile the per-reactor vs
  per-array numbers - real figure: 4-reactor 2x2 = 480 MW; canonical ratio ~ per reactor
  ~10 heat exchangers : 17 turbines at full neighbor bonus. Recompute and state one
  consistent basis.
- **Steam engine vs turbine** terminology is consistent.
- Phase 8 laser turret "needs batteries in recipe" - correct.

### The big content gap: SCOPE
The guide ends at the **vanilla rocket launch**. Transcripts guide1, guide2/guide5
(Arcaden), and parts of guide4 cover **Space Age**: space platforms, asteroid collectors/
crushers, thrusters (fuel+oxidizer), space science, and the four planets (Vulcanus
foundry, Fulgora scrap/recycling, Gleba spoilage, Aquilo constraints), plus defender
capsules, land-grab vs standard defensive perimeter, trains-vs-belts, stack inserters.
None of this is in the guide or the mod.

**Two coherent product directions:**
1. **Keep vanilla scope, polish it.** Then the Arcaden Space Age material is out of scope -
   leave guide5/guide2 as reference only. Fix the sync bug + content accuracy and ship.
2. **Expand to Space Age (matches the newest transcript).** Add Phases 16+ for: first space
   platform, reach first planet, per-planet loops, space science, Aquilo/aquilo tech, and
   the promethium/endgame. This is a large effort: new phases.lua entries (with multi-
   surface production triggers - see A1), new HTML phase cards, and the sync fix becomes a
   hard prerequisite because task counts will balloon.

Recommendation: **Fix the sync bug first (it is a correctness bug affecting the current
product), reconcile the nuclear numbers, THEN decide vanilla-polish vs Space-Age-expansion
as a separate scoped effort.**

---

## Priority-ordered action list
1. [P0][DONE] Fix mod->HTML sync. Implemented `MOD_TASK_MAP` in index.html: explicit
   mod-task-id -> HTML-checklist-index map per phase, replacing the broken positional
   `indexOf` matching. `importFromMod` now looks up each done mod task in the map and
   checks the correct HTML item. Unmapped mod tasks (no representative HTML item:
   p4_steel_research, p4_smelt_steel, p13_kovarex) intentionally don't auto-check.
2. [P0][DONE] Escape strings in sync.lua JSON. Added `safe_name` gsub for `\` and `"`
   before interpolating player name.
3. [P1][DONE] Reconcile Phase 11 nuclear power numbers. Rewrote the ratio callout on a
   single consistent 2x2 basis: per reactor 120 MW = 12 heat exchangers : 21 turbines;
   full 4-reactor array 480 MW = ~48 exchangers : ~83 turbines (matches the 480 MW line
   already in the phase tasks).
4. [P1][DONE] Drive phase count from data, not hardcoded literals.
   - Mod: gui.lua uses #phases_def in both progress captions.
   - HTML: updateProgress() derives totalPhases and completed count from the DOM
     (.phase-card[id^="phase-"] / .completed) instead of the literal 15 and stale
     state.phases keys.
5. [P2] Add import integrity warning on count mismatch (defense in depth). NOT done
   (the id-map fix makes silent mis-checking impossible, lowering urgency).
6. [P2] Multi-surface production stats in control.lua (only if Space Age expansion happens).
7. [Decision][RESOLVED] Vanilla-polish chosen. The HTML is explicitly vanilla-scoped
   (title/subtitle "vanilla only. No DLC content", tags, Phase 15 frames DLC as an
   optional next step) and info.json now says "vanilla base-game". Space Age expansion
   remains a separate future effort.

## Code-quality follow-ups (this pass)
- control.lua: the 5 duplicated phase/task trigger loops collapsed into two shared
  helpers (complete_matching / complete_matching_all) + thin per-event predicates.
- HTML: setLiveStatus() param renamed level (was shadowing the global state object);
  markPhaseComplete() null-guards a missing card so stale localStorage can't crash restore.
- Auto-uncomplete of a phase on task-uncheck intentionally NOT added: per-phase manual
  "complete" buttons exist, so reverting would undo deliberate manual completions.
