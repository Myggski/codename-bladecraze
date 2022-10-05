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
}

local function draw_line(line_dots, color, line_width, duration_seconds, draw_space)
  color = color or COLOR.WHITE
  line_width = line_width or 1
  duration_seconds = duration_seconds or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local line = {
    line_dots = line_dots,
    duration = duration_seconds,
    creation_time = love.timer.getTime(),
    color = color,
    line_width = line_width,
    gizmo_type = GIZMO_TYPE.LINE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, line)
end

local function draw_circle(position, radius, draw_mode, color, line_width, duration_seconds)
  color = color or COLOR.WHITE
  draw_mode = draw_mode or DRAW_MODE.LINE
  line_width = line_width or 1
  duration_seconds = duration_seconds or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local circle = {
    color = color,
    position = position,
    radius = radius,
    line_width = line_width,
    duration = duration_seconds,
    draw_mode = draw_mode,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.CIRCLE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, circle)
end

local function draw_ellipse(position, radiuses, segments, draw_mode, color, line_width, duration_seconds, draw_space)
  color = color or COLOR.WHITE
  draw_mode = draw_mode or DRAW_MODE.LINE
  line_width = line_width or 1
  duration_seconds = duration_seconds or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local ellipse = {
    color = color,
    line_width = line_width,
    draw_mode = draw_mode,
    position = position,
    radiuses = radiuses,
    segments = segments,
    duration = duration_seconds,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.ELLIPSE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, ellipse)
end

local function draw_rectangle(position, size, radiuses, segments, draw_mode, color, line_width, duration_seconds,
                              draw_space)
  radiuses = radiuses or vector2.zero()
  color = color or COLOR.WHITE
  draw_mode = draw_mode or DRAW_MODE.LINE
  line_width = line_width or 1
  duration_seconds = duration_seconds or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local rectangle = {
    color = color,
    line_width = line_width,
    draw_mode = draw_mode,
    position = position,
    size = size,
    radiuses = radiuses,
    segments = segments,
    duration = duration_seconds,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.RECTANGLE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, rectangle)
end

local function draw_shape(shape)
  love.graphics.setLineWidth(shape.line_width)
  love.graphics.setColor(shape.color)
  if shape.gizmo_type == GIZMO_TYPE.LINE then
    love.graphics.line(shape.line_dots)
  elseif shape.gizmo_type == GIZMO_TYPE.CIRCLE then
    love.graphics.circle(shape.draw_mode,
      shape.position.x,
      shape.position.y,
      shape.radius)
  elseif shape.gizmo_type == GIZMO_TYPE.ELLIPSE then
    love.graphics.ellipse(shape.draw_mode,
      shape.position.x,
      shape.position.y,
      shape.radiuses.x,
      shape.radiuses.y,
      shape.segments)
  elseif shape.gizmo_type == GIZMO_TYPE.RECTANGLE then
    love.graphics.rectangle(shape.draw_mode,
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
