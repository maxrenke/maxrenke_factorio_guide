local gui = {}
local phases_def = require("phases")

-- ============================================================
-- Toggle button in top bar
-- ============================================================
function gui.create_toggle_button(player)
  if player.gui.top["guide_tracker_toggle_btn"] then return end
  player.gui.top.add{
    type    = "button",
    name    = "guide_tracker_toggle_btn",
    caption = "Guide",
    tooltip = "Toggle First Run Guide Tracker",
  }
end

-- ============================================================
-- Destroy helpers
-- ============================================================
local function destroy_if_exists(elem)
  if elem and elem.valid then
    elem.destroy()
  end
end

-- ============================================================
-- Build the full guide frame
-- ============================================================
function gui.create_guide_frame(player)
  local player_index = player.index
  local pdata = storage.players[player_index]
  if not pdata then return end

  -- Remove existing frame
  destroy_if_exists(player.gui.screen["guide_tracker_frame"])

  -- Count completed phases
  local completed_count = 0
  for _, phase in ipairs(phases_def) do
    if pdata.phases[phase.id] then
      completed_count = completed_count + 1
    end
  end

  -- Root frame
  local frame = player.gui.screen.add{
    type      = "frame",
    name      = "guide_tracker_frame",
    direction = "vertical",
  }
  frame.style.minimal_width  = 460
  frame.style.minimal_height = 400
  frame.location = { x = 50, y = 60 }
  frame.auto_center = false

  -- Title bar (draggable)
  local titlebar = frame.add{ type = "flow", direction = "horizontal", drag_target = frame }
  titlebar.style.horizontally_stretchable = true
  titlebar.style.height = 28
  titlebar.drag_target = frame

  local title = titlebar.add{
    type    = "label",
    caption = "First Run Guide - Vanilla Rocket Launch",
    ignored_by_interaction = true,
  }
  title.style.font = "default-bold"
  title.style.horizontally_stretchable = true

  -- Top bar: progress label + close button
  local topbar = frame.add{ type = "flow", direction = "horizontal" }
  topbar.style.horizontally_stretchable = true

  local progress_label = topbar.add{
    type    = "label",
    caption = "Progress: " .. completed_count .. " / 15 phases complete",
    name    = "guide_tracker_progress_label",
  }
  progress_label.style.font = "default-bold"
  progress_label.style.horizontally_stretchable = true

  topbar.add{
    type    = "button",
    name    = "guide_tracker_close_btn",
    caption = "X",
    tooltip = "Close",
    style   = "red_back_button",
  }

  -- Scroll pane
  local scroll = frame.add{
    type           = "scroll-pane",
    name           = "guide_tracker_scroll",
    direction      = "vertical",
    vertical_scroll_policy = "always",
  }
  scroll.style.horizontally_stretchable = true
  scroll.style.vertically_stretchable   = true
  scroll.style.minimal_height           = 300

  local expanded = pdata.expanded_phases or {}

  -- Phase sections
  for _, phase in ipairs(phases_def) do
    local phase_done = pdata.phases[phase.id]
    local is_expanded = expanded[phase.id] == true

    -- Phase header flow
    local phase_flow = scroll.add{
      type      = "flow",
      name      = "phase_flow_" .. phase.id,
      direction = "vertical",
    }
    phase_flow.style.horizontally_stretchable = true

    -- Header button row
    local header_flow = phase_flow.add{
      type      = "flow",
      direction = "horizontal",
    }
    header_flow.style.horizontally_stretchable = true

    local status_icon = phase_done and "[color=green]✓[/color] " or "  "
    local header_btn = header_flow.add{
      type    = "button",
      name    = "phase_hdr_" .. phase.id,
      caption = status_icon .. phase.name,
      tooltip = phase.short_desc,
      style   = "list_box_item",
    }
    header_btn.style.horizontally_stretchable = true
    header_btn.style.font = "default-bold"

    -- Task list (visible only when expanded)
    local task_list = phase_flow.add{
      type      = "flow",
      name      = "task_list_" .. phase.id,
      direction = "vertical",
    }
    task_list.style.left_padding = 16
    task_list.visible = is_expanded

    local phase_tasks = pdata.tasks[phase.id] or {}
    for _, task in ipairs(phase.tasks) do
      local task_done = phase_tasks[task.id] == true

      local row = task_list.add{
        type      = "flow",
        direction = "horizontal",
      }
      row.style.vertical_align = "center"

      local cb = row.add{
        type    = "checkbox",
        name    = "task_cb_" .. phase.id .. "_" .. task.id,
        state   = task_done,
        enabled = not task_done,
      }
      cb.style.width = 20

      local lbl = row.add{
        type    = "label",
        caption = task.text,
      }
      if task_done then
        lbl.style.font_color = { r = 0.5, g = 0.5, b = 0.5 }
      end
    end

    -- Separator line
    scroll.add{ type = "line", direction = "horizontal" }
  end

  -- Export button at bottom of frame
  frame.add{
    type    = "button",
    name    = "guide_tracker_export_btn",
    caption = "Export Progress",
    tooltip = "Write progress JSON to script-output/guide_progress.json",
  }
end

-- ============================================================
-- Rebuild entire GUI for a player
-- ============================================================
function gui.rebuild_gui(player_index)
  local player = game.players[player_index]
  if not player or not player.valid then return end

  gui.create_toggle_button(player)

  local pdata = storage.players[player_index]
  if not pdata then return end

  -- If the frame exists, rebuild it (to refresh state)
  if player.gui.screen["guide_tracker_frame"] then
    gui.create_guide_frame(player)
  end
end

-- ============================================================
-- Update a single task checkbox without full rebuild
-- ============================================================
function gui.update_task_checkbox(player, phase_id, task_id, completed)
  local frame = player.gui.screen["guide_tracker_frame"]
  if not frame or not frame.valid then return end

  local cb_name = "task_cb_" .. phase_id .. "_" .. task_id
  -- Walk the scroll pane to find the checkbox
  local scroll = frame["guide_tracker_scroll"]
  if not scroll then return end

  local function find_cb(elem)
    if elem.name == cb_name then return elem end
    for _, child in pairs(elem.children) do
      local found = find_cb(child)
      if found then return found end
    end
    return nil
  end

  local cb = find_cb(scroll)
  if cb and cb.valid then
    cb.state   = completed
    cb.enabled = not completed
    -- Grey the label if done
    if cb.parent and cb.parent.children[2] then
      local lbl = cb.parent.children[2]
      if completed then
        lbl.style.font_color = { r = 0.5, g = 0.5, b = 0.5 }
      else
        lbl.style.font_color = { r = 1, g = 1, b = 1 }
      end
    end
  end
end

-- ============================================================
-- Update progress label in frame
-- ============================================================
function gui.update_progress_label(player_index)
  local player = game.players[player_index]
  if not player or not player.valid then return end
  local frame = player.gui.screen["guide_tracker_frame"]
  if not frame or not frame.valid then return end

  local pdata = storage.players[player_index]
  if not pdata then return end

  local count = 0
  for _, phase in ipairs(phases_def) do
    if pdata.phases[phase.id] then count = count + 1 end
  end

  local topbar = frame.children[1]
  if topbar then
    local lbl = topbar["guide_tracker_progress_label"]
    if lbl and lbl.valid then
      lbl.caption = "Progress: " .. count .. " / 15 phases complete"
    end
  end
end

-- ============================================================
-- Toggle expanded/collapsed state for a phase section
-- ============================================================
function gui.toggle_phase_section(player_index, phase_id)
  local player = game.players[player_index]
  if not player or not player.valid then return end

  local pdata = storage.players[player_index]
  if not pdata then return end

  pdata.expanded_phases = pdata.expanded_phases or {}
  pdata.expanded_phases[phase_id] = not pdata.expanded_phases[phase_id]

  -- Update visibility in existing frame without full rebuild
  local frame = player.gui.screen["guide_tracker_frame"]
  if not frame or not frame.valid then return end

  local scroll = frame["guide_tracker_scroll"]
  if not scroll then return end

  local phase_flow = scroll["phase_flow_" .. phase_id]
  if phase_flow and phase_flow.valid then
    local task_list = phase_flow["task_list_" .. phase_id]
    if task_list and task_list.valid then
      task_list.visible = pdata.expanded_phases[phase_id]
    end
  end
end

return gui
