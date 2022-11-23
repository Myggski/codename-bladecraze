local system = require "code.engine.ecs.system"
local asset_manager = require "code.engine.asset_manager"

local DELAY_BETWEEN_SONGS = 2.5 -- seconds

local function get_random_song(playlist)
  return playlist[love.math.random(#playlist)]
end

local function play_next(self)
  self.current_song = get_random_song(self.playlist)
  self.current_song:setVolume(0.2)
  self.current_song:play()
  self.current_duration = 0
  self.duration = self.current_song:getDuration() + DELAY_BETWEEN_SONGS
end

local music_playlist_system = system(nil, function(self, dt)
  if self.current_duration >= self.duration then
    play_next(self)
  else
    self.current_duration = self.current_duration + dt
  end
end)

function music_playlist_system:on_start()
  local buddy_power = asset_manager:get_audio("music/game/buddy_power.wav")
  local extradimensional_portalhopping = asset_manager:get_audio("music/game/extradimensional_portalhopping.wav")
  local moms_workout_cd = asset_manager:get_audio("music/game/moms_workout_cd.wav")
  local squashin_bugs_fixed = asset_manager:get_audio("music/game/squashin_bugs_fixed.wav")
  local stumble_around = asset_manager:get_audio("music/game/stumble_around.wav")

  self.playlist = {
    buddy_power,
    extradimensional_portalhopping,
    moms_workout_cd,
    squashin_bugs_fixed,
    stumble_around
  }

  play_next(self)
end

function music_playlist_system:on_destroy()
  self.current_song:stop()
  self.current_song = nil
  self.duration = nil
  self.current_duration = nil
end

return music_playlist_system
