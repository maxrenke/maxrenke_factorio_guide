local phases_def = require("phases")
local gui        = require("gui")
local sync       = require("sync")

-- ============================================================
-- Player progress initialisation
-- ============================================================
local function init_player(player_index)
  if not storage.players[player_index] then
    storage.players[player_index] = {
      tasks           = {},  -- [phase_id][task_id] = true
      phases          = {},  -- [phase_id] = true
      expanded_phases = {},  -- [phase_id] = true/false
      crafted_counts  = {},  -- [item_name] = cumulative count
      gui_open        = false,
    }
  end
  -- Ensure sub-tables exist (e.g. after config change)
  local p = storage.players[player_index]
  p.tasks           = p.tasks           or {}
  p.phases          = p.phases          or {}
  p.expanded_phases = p.expanded_phases or {}
  p.crafted_counts  = p.crafted_counts  or {}
  for _, phase in ipairs(phases_def) do
    p.tasks[phase.id] = p.tasks[phase.id] or {}
  end
end

local function init_all_players()
  storage.players = storage.players or {}
  for _, player in pairs(game.players) do
    init_player(player.index)
  end
end

-- ============================================================
-- Task / phase completion
-- ============================================================
local function get_task_def(phase_id, task_id)
  for _, phase in ipairs(phases_def) do
    if phase.id == phase_id then
      for _, task in ipairs(phase.tasks) do
        if task.id == task_id then
          return phase, task
        end
      end
    end
  end
  return nil, nil
end

local function complete_phase(player_index, phase_id, silent)
  local pdata = storage.players[player_index]
  if not pdata then return end
  if pdata.phases[phase_id] then return end  -- already done

  pdata.phases[phase_id] = true

  local player = game.players[player_index]
  if player and player.valid and not silent then
    -- Find phase name
    for _, phase in ipairs(phases_def) do
      if phase.id == phase_id then
        player.print("[Guide] Phase complete: " .. phase.name .. "!")
        break
      end
    end
  end

  gui.rebuild_gui(player_index)
  sync.write_progress(player_index, true)
end

local function complete_task(player_index, phase_id, task_id, silent)
  local pdata = storage.players[player_index]
  if not pdata then return end

  pdata.tasks[phase_id] = pdata.tasks[phase_id] or {}
  if pdata.tasks[phase_id][task_id] then return end  -- already done

  pdata.tasks[phase_id][task_id] = true

  -- Notify player
  local player = game.players[player_index]
  if player and player.valid and not silent then
    local _, task = get_task_def(phase_id, task_id)
    if task then
      player.create_local_flying_text{
        text     = "[Guide] Task complete: " .. task.text,
        create_at_cursor = false,
        position = player.position,
      }
    end
  end

  -- Update checkbox in GUI
  if player and player.valid then
    gui.update_task_checkbox(player, phase_id, task_id, true)
    gui.update_progress_label(player_index)
  end

  -- Check if all tasks in this phase are done
  local phase_def = nil
  for _, p in ipairs(phases_def) do
    if p.id == phase_id then phase_def = p; break end
  end
  if phase_def then
    local all_done = true
    local phase_tasks = pdata.tasks[phase_id]
    for _, task in ipairs(phase_def.tasks) do
      if not phase_tasks[task.id] then
        all_done = false
        break
      end
    end
    if all_done then
      complete_phase(player_index, phase_id, silent)  -- this also writes progress
    else
      sync.write_progress(player_index, true)         -- auto-export on every task (silent)
    end
  end
end

-- ============================================================
-- Trigger checkers
-- ============================================================

-- Factorio 2.0: item production statistics are per-surface via
-- get_item_production_statistics(surface). Vanilla/rocket scope = nauvis only.
local function get_produced_count(force, item_name)
  local surface = game.surfaces["nauvis"] or game.surfaces[1]
  if not surface then return 0 end
  local ok, stats = pcall(function() return force.get_item_production_statistics(surface) end)
  if not ok or not stats then return 0 end
  local ok2, count = pcall(function() return stats.get_input_count(item_name) end)
  if ok2 and type(count) == "number" then return count end
  return 0
end

-- Complete every task for which predicate(task) is true, for one player.
local function complete_matching(player_index, predicate, silent)
  init_player(player_index)
  for _, phase in ipairs(phases_def) do
    for _, task in ipairs(phase.tasks) do
      if predicate(task) then
        complete_task(player_index, phase.id, task.id, silent)
      end
    end
  end
end

-- Same, for every valid player (force-wide events: tech, robot build, rocket).
local function complete_matching_all(predicate, silent)
  for _, player in pairs(game.players) do
    if player.valid then
      complete_matching(player.index, predicate, silent)
    end
  end
end

-- Tech triggers: research is force-wide -> all players
local function check_tech_triggers(tech_name)
  complete_matching_all(function(t)
    return t.trigger.type == "tech" and t.trigger.name == tech_name
  end)
end

-- Built triggers: a specific player, or all players for robot builds
local function check_built_triggers(entity_name, player_index)
  local pred = function(t)
    return t.trigger.type == "built" and t.trigger.name == entity_name
  end
  if player_index then
    complete_matching(player_index, pred)
  else
    complete_matching_all(pred)
  end
end

-- Crafted triggers: cumulative per player
local function check_crafted_triggers(item_name, count, player_index)
  init_player(player_index)
  local pdata = storage.players[player_index]
  pdata.crafted_counts[item_name] = (pdata.crafted_counts[item_name] or 0) + count
  local total = pdata.crafted_counts[item_name]
  complete_matching(player_index, function(t)
    return t.trigger.type == "crafted" and t.trigger.name == item_name and total >= t.trigger.count
  end)
end

-- Production triggers: polled every 5 seconds
local function check_production_triggers()
  local force = game.forces["player"]
  if not force then return end
  for _, player in pairs(game.players) do
    if player.valid then
      complete_matching(player.index, function(t)
        return t.trigger.type == "produced"
          and get_produced_count(force, t.trigger.name) >= t.trigger.count
      end)
    end
  end
end

-- Rocket trigger: apply to all players
local function complete_rocket_task()
  complete_matching_all(function(t) return t.trigger.type == "rocket" end)
end

-- ============================================================
-- Catch-up: run all checks for a player on join/init (silent)
-- ============================================================
local function check_all_triggers_for_player(player_index)
  local player = game.players[player_index]
  if not player or not player.valid then return end
  local force = player.force

  complete_matching(player_index, function(t)
    if t.trigger.type == "tech" then
      local tech = force.technologies[t.trigger.name]
      return tech and tech.researched or false
    elseif t.trigger.type == "produced" then
      return get_produced_count(force, t.trigger.name) >= t.trigger.count
    end
    return false
  end, true)
end

-- ============================================================
-- GUI event handling
-- ============================================================
local function on_gui_click(event)
  local player = game.players[event.player_index]
  if not player or not player.valid then return end
  local elem = event.element
  if not elem or not elem.valid then return end

  local name = elem.name

  -- Toggle guide frame
  if name == "guide_tracker_toggle_btn" then
    local frame = player.gui.screen["guide_tracker_frame"]
    if frame and frame.valid then
      frame.destroy()
      storage.players[event.player_index].gui_open = false
    else
      gui.create_guide_frame(player)
      storage.players[event.player_index].gui_open = true
    end
    return
  end

  -- Close button
  if name == "guide_tracker_close_btn" then
    local frame = player.gui.screen["guide_tracker_frame"]
    if frame and frame.valid then
      frame.destroy()
      storage.players[event.player_index].gui_open = false
    end
    return
  end

  -- Export button
  if name == "guide_tracker_export_btn" then
    sync.write_progress(event.player_index)
    return
  end

  -- Phase header toggle (expands/collapses task list)
  if name and name:sub(1, 10) == "phase_hdr_" then
    local phase_id = name:sub(11)
    gui.toggle_phase_section(event.player_index, phase_id)
    return
  end
end

-- Manual checkbox toggle (player checks a task manually)
local function on_gui_checked_state_changed(event)
  local elem = event.element
  if not elem or not elem.valid then return end
  local name = elem.name

  -- task_cb_<phase_id>_<task_id>
  if name and name:sub(1, 8) == "task_cb_" then
    local rest = name:sub(9)  -- "phase_id_task_id" but phase_id may contain underscores
    -- Phase IDs are like "phase_1", task IDs are like "p1_mine_iron"
    -- Format: task_cb_phase_X_pY_task_name
    -- We find the boundary by matching known phase ids
    local player_index = event.player_index
    local pdata = storage.players[player_index]
    if not pdata then return end

    -- Try to extract phase_id and task_id by brute force match
    for _, phase in ipairs(phases_def) do
      local prefix = phase.id .. "_"
      if rest:sub(1, #prefix) == prefix then
        local task_id = rest:sub(#prefix + 1)
        -- Verify task exists in this phase
        for _, task in ipairs(phase.tasks) do
          if task.id == task_id then
            if elem.state then
              complete_task(player_index, phase.id, task.id)
            else
              -- Allow unchecking only if phase not complete
              if not pdata.phases[phase.id] then
                pdata.tasks[phase.id][task.id] = nil
                gui.update_task_checkbox(game.players[player_index], phase.id, task.id, false)
              else
                -- Phase already marked complete, re-check silently
                elem.state = true
              end
            end
            return
          end
        end
      end
    end
  end
end

-- ============================================================
-- Event registration
-- ============================================================
script.on_init(function()
  storage.players = storage.players or {}
  init_all_players()
  for _, player in pairs(game.players) do
    if player.valid then
      check_all_triggers_for_player(player.index)
    end
  end
end)

script.on_configuration_changed(function()
  storage.players = storage.players or {}
  init_all_players()
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  init_player(event.player_index)
  check_all_triggers_for_player(event.player_index)
  local player = game.players[event.player_index]
  if player and player.valid then
    gui.create_toggle_button(player)
  end
  gui.rebuild_gui(event.player_index)
end)

script.on_event(defines.events.on_research_finished, function(event)
  check_tech_triggers(event.research.name)
end)

script.on_event(defines.events.on_built_entity, function(event)
  local pindex = event.player_index
  if pindex then
    check_built_triggers(event.entity.name, pindex)
  end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  -- Robots build for the force; apply to all players
  check_built_triggers(event.entity.name, nil)
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
  local item_name  = event.item_stack.name
  local item_count = event.item_stack.count
  check_crafted_triggers(item_name, item_count, event.player_index)
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  complete_rocket_task()
end)

script.on_nth_tick(300, function(event)
  check_production_triggers()
  sync.write_heartbeat()
end)

script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_checked_state_changed, on_gui_checked_state_changed)
