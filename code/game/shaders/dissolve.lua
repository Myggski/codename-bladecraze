local dissolve = [[
  uniform float dissolve_value;
  uniform Image noise_texture;
  uniform vec2 resolution;

  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
  {
      vec2 uv = pixel_coords / resolution;
      vec4 current_pixel = Texel(texture, texture_coords);
      vec4 noise_pixel = Texel(noise_texture, uv);

      if (noise_pixel.b - dissolve_value <= 0) { discard; }
      if (noise_pixel.b - dissolve_value < 0.032) { current_pixel = vec4(0.701, 0.219, 0.192, current_pixel.w); }
      if (noise_pixel.b - dissolve_value < 0.016) { current_pixel = vec4(0.917, 0.309, 0.211, current_pixel.w); }

      return current_pixel;
  }
]]

return dissolve
