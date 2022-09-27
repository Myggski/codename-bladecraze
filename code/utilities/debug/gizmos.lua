local game_event_manager = require "code.engine.game_event.game_event_manager"
local vector2 = require "code.engine.vector2"

local DRAW_SPACE = {
  HUD = "hud",
  WORLD = "world",
}
local DRAW_MODE = {
  LINE = "line",
  FILL = "fill"
}

local GIZMO_TYPE = {
  LINE = 1,
  CIRCLE = 2,
  ELLIPSE = 3,
  RECTANGLE = 4,
}

--[[
  Create_draw_data initializes to default drawing values if any parameter is nil 
]]
local gizmos = {
  hud_shapes = {},
  world_shapes = {},
  create_draw_data = function(draw_space, mode, color, line_width)
    draw_space = draw_space or DRAW_SPACE.WORLD
    mode = mode or DRAW_MODE.LINE
    color = color or COLOR.WHITE
    line_width = line_width or 1
    return setmetatable({
      draw_space = draw_space,
      mode = mode,
      color = color,
      line_width = line_width
    }, gizmos)
  end,
  __index = gizmos,
}

--[[
  Draw a line with n dots:
  gizmo_data: table (use gizmos.create_draw_data()),
  line_dots: table {x1,y1,x2,y2...xn,yn},
  duration_seconds: float (negative value for permanent shape)
]]
local function draw_line(gizmo_data, line_dots, duration_seconds)
  if not (type(gizmo_data) == "table") then
    gizmo_data = gizmos.create_draw_data()
  end

  local line = { line_dots = line_dots, gizmo_data = gizmo_data, duration = duration_seconds,
    creation_time = love.timer.getTime(), gizmo_type = GIZMO_TYPE.LINE }

  if gizmo_data.draw_space == DRAW_SPACE.HUD then
    table.insert(gizmos.hud_shapes, line)
  else
    table.insert(gizmos.world_shapes, line)
  end
end

--[[
  Draw a circle:
  gizmo_data: table (use gizmos.create_draw_data()),
  position: vector2,
  radius: float,
  duration_seconds: float (negative value for permanent shape)
]]
local function draw_circle(gizmo_data, position, radius, duration_seconds)
  if not (type(gizmo_data) == "table") then
    gizmo_data = gizmos.create_draw_data()
  end
  local circle = {
    gizmo_data = gizmo_data,
    position = position,
    radius = radius,
    duration = duration_seconds,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.CIRCLE
  }
  if gizmo_data.draw_space == DRAW_SPACE.HUD then
    table.insert(gizmos.hud_shapes, circle)
  else
    table.insert(gizmos.world_shapes, circle)
  end
end

--[[
  Draw an ellipse:
  gizmo_data: table (use gizmos.create_draw_data()),
  position: vector2,
  radiuses: vector2,
  segments: nil or integer,
  duration_seconds: float (negative value for permanent shape)
]]
local function draw_ellipse(gizmo_data, position, radiuses, segments, duration_seconds)
  if not (type(gizmo_data) == "table") then
    gizmo_data = gizmos.create_draw_data()
  end

  local ellipse = {
    gizmo_data = gizmo_data,
    position = position,
    radiuses = radiuses,
    segments = segments,
    duration = duration_seconds,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.ELLIPSE
  }
  if gizmo_data.draw_space == DRAW_SPACE.HUD then
    table.insert(gizmos.hud_shapes, ellipse)
  else
    table.insert(gizmos.world_shapes, ellipse)
  end
end

--[[
  Draw a rectangle:
  gizmo_data: table (use gizmos.create_draw_data()),
  position: vector2,
  radiuses: vector2 (rounds corners),
  segments: nil or integer,
  duration_seconds: float (negative value for permanent shape)
]]
local function draw_rectangle(gizmo_data, position, size, radiuses, segments, duration_seconds)
  if not (type(gizmo_data) == "table") then
    gizmo_data = gizmos.create_draw_data()
  end

  radiuses = radiuses or vector2.zero()
  local rectangle = {
    gizmo_data = gizmo_data,
    position = position,
    size = size,
    radiuses = radiuses,
    segments = segments,
    duration = duration_seconds,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.RECTANGLE
  }
  if gizmo_data.draw_space == DRAW_SPACE.HUD then
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
    love.graphics.line(shape.line_dots)
  elseif shape.gizmo_type == GIZMO_TYPE.CIRCLE then
    love.graphics.circle(data.mode,
      shape.position.x,
      shape.position.y,
      shape.radius)
  elseif shape.gizmo_type == GIZMO_TYPE.ELLIPSE then
    love.graphics.ellipse(data.mode,
      shape.position.x,
      shape.position.y,
      shape.radiuses.x,
      shape.radiuses.y,
      shape.segments)
  elseif shape.gizmo_type == GIZMO_TYPE.RECTANGLE then
    love.graphics.rectangle(data.mode,
      shape.position.x,
      shape.position.y,
      shape.size.x,
      shape.size.x,
      shape.radiuses.x,
      shape.radiuses.y,
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
    if line.duration > -1 and current_time - line.creation_time > line.duration then
      table.remove(object_table, i)
    end
  end
end

local function update(_)
  local current_time = love.timer.getTime()
  remove_expired_objects(gizmos.hud_shapes, current_time)
  remove_expired_objects(gizmos.world_shapes, current_time)
end

game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, update)
game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_HUD, draw_hud)
game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, draw_world)

return {
  DRAW_SPACE = DRAW_SPACE,
  DRAW_MODE = DRAW_MODE,
  create_draw_data = gizmos.create_draw_data,
  draw_line = draw_line,
  draw_ellipse = draw_ellipse,
  draw_circle = draw_circle,
  draw_rectangle = draw_rectangle,
}
