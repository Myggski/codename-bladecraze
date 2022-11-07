local game_event_manager = require "code.engine.game_event.game_event_manager"
local vector2 = require "code.engine.vector2"
local asset_manager = require "code.engine.asset_manager"

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
  ROUNDED_RECTANGLE = 5,
  TEXT = 6,
}

local gizmos = {
  hud_shapes = {},
  world_shapes = {},
}

--[[
  line_dots: table {x1,y1...xn,yn},
  optional: {
    color: table {rgba},
    line_width: number,
    duration: number (seconds),
    draw_space: string ("world" or "hud")
  }
]]
local function draw_line(line_dots, color, line_width, duration, draw_space)
  color = color or COLOR.WHITE
  line_width = line_width or 1
  duration = duration or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local line = {
    line_dots = line_dots,
    duration = duration,
    creation_time = love.timer.getTime(),
    color = color,
    line_width = line_width,
    gizmo_type = GIZMO_TYPE.LINE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, line)
end

--[[
  position: table {x,y},
  radius: number,
  optional:{
    draw_mode: string ("line" or "fill"),
    color: table {rgba},
    line_width: number,
    duration: number (seconds),
    draw_space: string ("world" or "hud")
  }
]]
local function draw_circle(position, radius, draw_mode, color, line_width, duration, draw_space)
  color = color or COLOR.WHITE
  draw_mode = draw_mode or DRAW_MODE.LINE
  line_width = line_width or 1
  duration = duration or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local circle = {
    color = color,
    position = position,
    radius = radius,
    line_width = line_width,
    duration = duration,
    draw_mode = draw_mode,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.CIRCLE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, circle)
end

--[[
  position: table {x,y},
  radiuses: table {x,y},
  optional:{
    segments: number,
    draw_mode: string ("line" or "fill"),
    color: table {rgba},
    line_width: number,
    duration: number (seconds),
    draw_space: string ("world" or "hud")
  }
]]
local function draw_ellipse(position, radiuses, segments, draw_mode, color, line_width, duration, draw_space)
  color = color or COLOR.WHITE
  draw_mode = draw_mode or DRAW_MODE.LINE
  line_width = line_width or 1
  duration = duration or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local ellipse = {
    color = color,
    line_width = line_width,
    draw_mode = draw_mode,
    position = position,
    radiuses = radiuses,
    segments = segments,
    duration = duration,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.ELLIPSE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, ellipse)
end

--[[
  position: table {x,y},
  size: table {x,y},
  optional:{
    draw_mode: string ("line" or "fill"),
    color: table {rgba},
    line_width: number,
    duration: number (seconds),
    draw_space: string ("world" or "hud")
  }
]]
local function draw_rectangle(position, size, draw_mode, color, line_width, duration, draw_space)

  color = color or COLOR.WHITE
  draw_mode = draw_mode or DRAW_MODE.LINE
  line_width = line_width or 1
  duration = duration or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local rectangle = {
    color = color,
    line_width = line_width,
    draw_mode = draw_mode,
    position = position,
    size = size,
    duration = duration,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.RECTANGLE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, rectangle)
end

--[[
  position: table {x,y},
  size: table {x,y},
  radiuses: table {x,y},
  optional:{
    segments: number (or nil for auto),
    draw_mode: string ("line" or "fill"),
    color: table {rgba},
    line_width: number,
    duration: number (seconds),
    draw_space: string ("world" or "hud")
  }
]]
local function draw_rounded_rectangle(position, size, radiuses, segments, draw_mode, color, line_width, duration,
                                      draw_space)
  radiuses = radiuses or vector2.zero()
  color = color or COLOR.WHITE
  draw_mode = draw_mode or DRAW_MODE.LINE
  line_width = line_width or 1
  duration = duration or 0
  draw_space = draw_space or DRAW_SPACE.WORLD
  local squircle = {
    color = color,
    line_width = line_width,
    draw_mode = draw_mode,
    position = position,
    size = size,
    radiuses = radiuses,
    segments = segments,
    duration = duration,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.ROUNDED_RECTANGLE
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, squircle)
end

local function draw_text(text, position, size, should_center_x, should_center_y, color, duration, draw_space)
  draw_space = draw_space or DRAW_SPACE.WORLD
  color = color or COLOR.WHITE
  duration = duration or 0
  scale = scale or vector2.one()
  should_center_x = should_center_x or false
  should_center_y = should_center_y or false
  local font = asset_manager:get_font("Silver.ttf", size)

  if should_center_x then
    local w = font:getWidth(text)
    position.x = position.x - w * 0.5
  end
  if should_center_y then
    local h = font:getHeight(text)
    position.y = position.y - h * 0.5
  end



  local shape = {
    line_width = 1,
    text = text,
    font = font,
    position = position,
    color = color,
    duration = duration,
    creation_time = love.timer.getTime(),
    gizmo_type = GIZMO_TYPE.TEXT
  }
  local shape_table = draw_space == DRAW_SPACE.WORLD and gizmos.world_shapes or gizmos.hud_shapes
  table.insert(shape_table, shape)
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
  elseif shape.gizmo_type == GIZMO_TYPE.RECTANGLE or shape.gizmo_type == GIZMO_TYPE.ROUNDED_RECTANGLE then
    love.graphics.rectangle(shape.draw_mode,
      shape.position.x,
      shape.position.y,
      shape.size.x,
      shape.size.y)
  elseif shape.gizmo_type == GIZMO_TYPE.ROUNDED_RECTANGLE then
    love.graphics.rectangle(shape.draw_mode,
      shape.position.x,
      shape.position.y,
      shape.size.x,
      shape.size.x,
      shape.radiuses.x,
      shape.radiuses.y,
      shape.segments)
  elseif shape.gizmo_type == GIZMO_TYPE.TEXT then
    love.graphics.print(shape.text, shape.font, shape.position.x, shape.position.y, 0, 1, 1, 0, 0)
  end
  love.graphics.setLineWidth(1)
end

local function draw_shapes(shape_table)
  for i = 1, #shape_table do
    draw_shape(shape_table[i])
  end
  love.graphics.setColor(COLOR.WHITE)
end

local function draw_world()
  draw_shapes(gizmos.world_shapes)
end

local function draw_hud()
  draw_shapes(gizmos.hud_shapes)
end

local function remove_expired_objects(object_table, current_time)
  for i = #object_table, 1, -1 do
    local shape = object_table[i]
    if shape.duration > -1 and current_time - shape.creation_time > shape.duration then
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
  draw_line = draw_line,
  draw_ellipse = draw_ellipse,
  draw_circle = draw_circle,
  draw_rectangle = draw_rectangle,
  draw_rounded_rectangle = draw_rounded_rectangle,
  draw_text = draw_text
}
