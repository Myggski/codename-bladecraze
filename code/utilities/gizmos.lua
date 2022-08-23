local game_event_manager = require "code.engine.game_event.game_event_manager"
local gizmos = {
  hud_shapes = {},
  world_shapes = {}
}

GIZMO_TYPE = {
  LINE = 1,
  CIRCLE = 2,
  ELLIPSE = 3,
}

local shape = {}
shape.prototype = { draw_space = "hud", color = COLOR.WHITE, line_width = 1, duration = 0 }
shape.mt = {}
function shape.new(o)
  setmetatable(o, shape.mt)
  return o
end

shape.mt.__index = shape.prototype


local function add_draw_line(draw_space, dots, color, line_width, duration_seconds)
  local line = shape.new { dots = dots, color = color, line_width = line_width, duration = duration_seconds,
    creation_time = os.clock(), gizmo_type = GIZMO_TYPE.LINE }

  if draw_space == "hud" then
    table.insert(gizmos.hud_shapes, line)
  else
    table.insert(gizmos.world_shapes, line)
  end
end

local function add_draw_circle(draw_space, x, y, radius, color, mode, line_width, duration_seconds)
  mode = mode or "line"
  color = color or COLOR.WHITE
  line_width = line_width or 1
  duration_seconds = duration_seconds or 0
  local circle = {
    mode = mode,
    color = color,
    line_width = line_width,
    x = x,
    y = y,
    radius = radius,
    duration = duration_seconds,
    creation_time = os.clock(),
    gizmo_type = GIZMO_TYPE.CIRCLE
  }
  if draw_space == "hud" then
    table.insert(gizmos.hud_shapes, circle)
  else
    table.insert(gizmos.world_shapes, circle)
  end
end

local function add_draw_ellipse(draw_space, x, y, radius_x, radius_y, segments, color, mode, line_width, duration_seconds)
  mode = mode or "line"
  color = color or COLOR.WHITE
  line_width = line_width or 1
  duration_seconds = duration_seconds or 0
  local ellipse = { mode = mode, color = color, line_width = line_width, x = x, y = y, radius_x = radius_x,
    radius_y = radius_y,
    segments = segments,
    duration = duration_seconds,
    creation_time = os.clock(),
    gizmo_type = GIZMO_TYPE.ELLIPSE
  }
  if draw_space == "hud" then
    table.insert(gizmos.hud_shapes, ellipse)
  else
    table.insert(gizmos.world_shapes, ellipse)
  end
end

local function draw_shape(shape)
  love.graphics.setLineWidth(shape.line_width)
  love.graphics.setColor(shape.color)
  if shape.gizmo_type == GIZMO_TYPE.LINE then
    love.graphics.line(shape.dots)
  elseif shape.gizmo_type == GIZMO_TYPE.CIRCLE then
    love.graphics.circle(shape.mode, shape.x, shape.y, shape.radius)
  elseif shape.gizmo_type == GIZMO_TYPE.ELLIPSE then
    love.graphics.ellipse(shape.mode, shape.x, shape.y, shape.radius_x, shape.radius_y, shape.segments)
  end
  love.graphics.setLineWidth(1)
end

local function draw_in_hud()
  for _, value in ipairs(gizmos.hud_shapes) do
    draw_shape(value)
  end
  love.graphics.setColor(COLOR.WHITE)
end

local function draw_in_world()
  for _, value in ipairs(gizmos.world_shapes) do
    draw_shape(value)
  end
  love.graphics.setColor(COLOR.WHITE)
end

local function remove_expired_objects(object_table, current_time)
  for i = #object_table, 1, -1 do
    local line = object_table[i]
    if line.duration > 0 and current_time - line.creation_time > line.duration then
      table.remove(object_table, i)
    end
  end
end

local function update(_)
  local current_time = os.clock()
  remove_expired_objects(gizmos.hud_shapes, current_time)
  remove_expired_objects(gizmos.world_shapes, current_time)
end

game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, update)
game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_HUD, draw_in_hud)
game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, draw_in_world)

return {
  add_draw_line = add_draw_line,
  add_draw_ellipse = add_draw_ellipse,
  add_draw_circle = add_draw_circle
}
