local game_event_manager = require "code.engine.game_event.game_event_manager"
local vector2 = require "code.engine.vector2"
local gizmos = {
  hud_shapes = {},
  world_shapes = {}
}

GIZMO_TYPE = {
  LINE = 1,
  CIRCLE = 2,
  ELLIPSE = 3,
  RECTANGLE = 4,
}

DRAW_SPACE = {
  HUD = 1,
  WORLD = 2,
}

GIZMO_DATA = {
  create = function(draw_space, mode, color, line_width)
    draw_space = draw_space or "hud"
    mode = mode or "line"
    color = color or COLOR.WHITE
    line_width = line_width or 1
    return setmetatable({
      draw_space = draw_space,
      mode = mode,
      color = color,
      line_width = line_width
    }, GIZMO_DATA)
  end,
  __index = GIZMO_DATA,
}

local function add_draw_line(gizmo_data, dots, duration_seconds)
  gizmo_data = gizmo_data or GIZMO_DATA.create()
  local line = { dots = dots, gizmo_data = gizmo_data, duration = duration_seconds,
    creation_time = os.clock(), gizmo_type = GIZMO_TYPE.LINE }


  if gizmo_data.draw_space == "hud" then
    table.insert(gizmos.hud_shapes, line)
  else
    table.insert(gizmos.world_shapes, line)
  end
end

local function add_draw_circle(gizmo_data, v2_position, radius, duration_seconds)
  gizmo_data = gizmo_data or GIZMO_DATA.create()
  local circle = {
    gizmo_data = gizmo_data,
    position = v2_position,
    radius = radius,
    duration = duration_seconds,
    creation_time = os.clock(),
    gizmo_type = GIZMO_TYPE.CIRCLE
  }
  if gizmo_data.draw_space == "hud" then
    table.insert(gizmos.hud_shapes, circle)
  else
    table.insert(gizmos.world_shapes, circle)
  end
end

local function add_draw_ellipse(gizmo_data, v2_position, v2_radius, segments, duration_seconds)
  gizmo_data = gizmo_data or GIZMO_DATA.create()
  local ellipse = {
    gizmo_data = gizmo_data,
    position = v2_position,
    v2_radius = v2_radius,
    segments = segments,
    duration = duration_seconds,
    creation_time = os.clock(),
    gizmo_type = GIZMO_TYPE.ELLIPSE
  }
  if gizmo_data.draw_space == "hud" then
    table.insert(gizmos.hud_shapes, ellipse)
  else
    table.insert(gizmos.world_shapes, ellipse)
  end
end

local function add_draw_rectangle(gizmo_data, position_vector, v2_size, v2_radius, segments, duration_seconds)
  gizmo_data = gizmo_data or GIZMO_DATA.create()
  local rectangle = {
    gizmo_data = gizmo_data,
    position = position_vector,
    v2_size = v2_size,
    v2_radius = v2_radius,
    segments = segments,
    duration = duration_seconds,
    creation_time = os.clock(),
    gizmo_type = GIZMO_TYPE.RECTANGLE
  }
  if gizmo_data.draw_space == "hud" then
    table.insert(gizmos.hud_shapes, rectangle)
  else
    table.insert(gizmos.world_shapes, rectangle)
  end
end

local function draw_shape(shape)
  local data = shape.gizmo_data
  love.graphics.setLineWidth(data.line_width)
  love.graphics.setColor(data.color)

  if shape.gizmo_type == GIZMO_TYPE.LINE then
    love.graphics.line(shape.dots)
  elseif shape.gizmo_type == GIZMO_TYPE.CIRCLE then
    love.graphics.circle(data.mode, shape.position.x, shape.position.y, shape.radius)
  elseif shape.gizmo_type == GIZMO_TYPE.ELLIPSE then
    love.graphics.ellipse(data.mode, shape.position.x, shape.position.y, shape.v2_radius.x, shape.v2_radius.y,
      shape.segments)
  elseif shape.gizmo_type == GIZMO_TYPE.RECTANGLE then
    love.graphics.rectangle(data.mode, shape.position.x, shape.position.y, shape.v2_size.x, shape.v2_size.x,
      shape.v2_radius.x,
      shape.v2_radius.y,
      shape.segments)
  end
  love.graphics.setLineWidth(1)
end

local function draw_world()
  for _, value in ipairs(gizmos.world_shapes) do
    draw_shape(value)
  end
  love.graphics.setColor(COLOR.WHITE)
end

local function draw_hud()
  for _, value in ipairs(gizmos.hud_shapes) do
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
game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_HUD, draw_hud)
game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, draw_world)

return {
  add_draw_line = add_draw_line,
  add_draw_ellipse = add_draw_ellipse,
  add_draw_circle = add_draw_circle,
  add_draw_rectangle = add_draw_rectangle,
}
