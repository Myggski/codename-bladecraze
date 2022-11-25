local asset_manager = require "code.engine.asset_manager"

local audio = {
  sfx_volume = 1,
  music_volume = 0.125,
  master_volume = 1,
}

function audio:_get_volume(audio_type)
  if audio_type == AUDIO_TYPES.MUSIC then
    return self.master_volume * self.music_volume
  else
    return self.master_volume * self.sfx_volume
  end
end

function audio:play(path, pitch, audio_type)
  local sound = asset_manager:get_audio(path):clone()

  sound:setPitch(pitch or 1)
  sound:setVolume(self:_get_volume(audio_type or AUDIO_TYPES.SFX))
  sound:play()

  return sound
end

return audio
