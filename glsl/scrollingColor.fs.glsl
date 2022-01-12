#include <common>

uniform float iTime;      
uniform vec2 iOffset;         // Tile offset
uniform vec2 iTileResolution; // Tile resolution
uniform vec2 iResolution;     // Screen resolution
uniform vec2 iMouse;          // Centered bottom-left mouse screen position

void main(){
  vec2 screen_uv = gl_FragCoord.xy / iResolution.xy;
  vec2 screen_mouse = iMouse.xy / iResolution.xy;
  vec2 tile_uv = ( gl_FragCoord.xy  - iOffset.xy ) / iTileResolution.xy;
  vec2 tile_mouse = ( iMouse.xy - iOffset.xy ) / iTileResolution.xy; 
  float aspect_ratio = iTileResolution.x/iTileResolution.y;
  tile_uv.x *= aspect_ratio;
  tile_mouse.x *= aspect_ratio;

  gl_FragColor = vec4(0.5*cos(iTime) + 0.5,tile_uv.x,tile_mouse.y,1.0);
}