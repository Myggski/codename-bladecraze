local system = require "code.engine.ecs.system"
local audio = require "code.engine.audio"

local DELAY_BETWEEN_SONGS = 2.5 -- seconds

local function get_random_song(playlist)
  return playlist[love.math.random(#playlist)]
end

local function play_next(self)
  self.current_song = audio:play(get_random_song(self.playlist), 1, AUDIO_TYPES.MUSIC)
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
  self.playlist = {
    "music/game/buddy_power.mp3",
    "music/game/extradimensional_portalhopping.mp3",
    "music/game/moms_workout_cd.mp3",
    "music/game/squashin_bugs_fixed.mp3",
    "music/game/stumble_around.mp3"
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
