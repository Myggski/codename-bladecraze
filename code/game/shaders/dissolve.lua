local dissolve = [[  
  uniform float dissolve_value;
  uniform Image noise_texture;
  uniform vec2 resolution;

  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
  {
      vec4 current_pixel = Texel(texture, texture_coords);
      vec4 noise_pixel = Texel(noise_texture, texture_coords);
      float dissolve_pixel = noise_pixel.r - dissolve_value;

      if (dissolve_pixel <= 0) { discard; }
      if (dissolve_pixel < 0.120) { current_pixel = vec4(0.984, 0.725, 0.329, current_pixel.w); }
      if (dissolve_pixel < 0.060) { current_pixel = vec4(0.701, 0.219, 0.192, current_pixel.w); }
      
      

      current_pixel = mix(current_pixel, vec4(0.917, 0.309, 0.211, current_pixel.a), dissolve_value * 1.125);

      return current_pixel;
  }
]]

return dissolve
