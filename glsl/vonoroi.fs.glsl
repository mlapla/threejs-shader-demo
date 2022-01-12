// Credit goes to the Book of Shaders (https://thebookofshaders.com/12/)
// Author: @patriciogv
// Title: CellularNoise

#include <common>

uniform float iTime;      
uniform vec2 iOffset;         // Tile offset
uniform vec2 iTileResolution; // Tile resolution
uniform vec2 iResolution;     // Screen resolution
uniform vec2 iMouse;          // Centered bottom-left mouse screen position


// "The book of Shaders"'s random number generator
float random(vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}
// "The book of Shaders"'s random2 number generator
vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float vonoroi(in vec2 st, in vec2 mouse){

  float aspect_ratio = iTileResolution.x/iTileResolution.y;

  const int nSeeds = 10;
  const int seedOffset = -5;
  vec2 seeds[nSeeds];

  for (int i = seedOffset; i < nSeeds - 1 + seedOffset; i++){
    seeds[i - seedOffset] = random2(vec2(float(i),float(i)));
    seeds[i - seedOffset].x *= aspect_ratio;
    seeds[i - seedOffset] += 0.2*vec2(cos(iTime * random(vec2(float(i),float(i)))),sin(iTime * random(vec2(float(i-1),float(i+1)))));
  }

  seeds[nSeeds - 1] = mouse;

  // Compute minimal distance
  float mDist = 1000.0;

  for (int i = 0; i < nSeeds; i++){
    mDist = min( mDist, distance( seeds[i], st ) );
  }

  return mDist;
}

void main(){


  vec2 tile_uv = ( gl_FragCoord.xy  - iOffset.xy ) / iTileResolution.xy;
  vec2 tile_mouse = ( iMouse.xy - iOffset.xy ) / iTileResolution.xy;
  float aspect_ratio = iTileResolution.x/iTileResolution.y;
  tile_uv.x *= aspect_ratio;
  tile_mouse.x *= aspect_ratio;

  vec3 color = vec3(vonoroi(tile_uv,tile_mouse));
  // color += 0.9-step(.005, color[0]);

  gl_FragColor = vec4(color,1.0);
}