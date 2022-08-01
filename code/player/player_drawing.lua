local function draw_player(player)
  love.graphics.setColor(player.color)
  local sprite_index = math.floor(player.current_animation.current_time / player.current_animation.duration *
    #player.current_animation.quads) + 1
  love.graphics.draw(player.current_animation.sprite_sheet, player.current_animation.quads[sprite_index], player.box.x,
    player.box.y)
end

local function draw_player_bounding_box(player)
  love.graphics.setColor(player.color)
  love.graphics.rectangle("line", player.box.x, player.box.y, player.box.w, player.box.h)
end

local function draw_name(x, y, name)
  local length = #name
  local char_w = 6
  local angle, scale_x, scale_y, offset_x, offset_y, skew_x, skew_y = 0, 1, 1, (length*char_w)/2, 0, 0, 0

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(name, x, y, angle, scale_x,
    scale_y, offset_x, offset_y, skew_x, skew_y)
end

return {
  draw_name = draw_name,
  draw_player = draw_player,
  draw_player_bounding_box = draw_player_bounding_box
}
