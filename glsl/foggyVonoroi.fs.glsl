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

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}


// From the book of shaders
#define NSEEDS 10
float vonoroi(in vec2 st, in vec2 mouse){

  float aspect_ratio = iTileResolution.x/iTileResolution.y;

  const int seedOffset = -5;
  vec2 seeds[NSEEDS];

  for (int i = seedOffset; i < NSEEDS - 1 + seedOffset; i++){
    seeds[i - seedOffset] = random2(vec2(float(i),float(i)));
    seeds[i - seedOffset].x *= aspect_ratio;
    seeds[i - seedOffset] += 0.2*vec2(cos(iTime * random(vec2(float(i),float(i)))),sin(iTime * random(vec2(float(i-1),float(i+1)))));
  }

  seeds[NSEEDS - 1] = mouse;

  // Compute minimal distance
  float mDist = 1000.0;

  for (int i = 0; i < NSEEDS; i++){
    mDist = min( mDist, distance( seeds[i], st ) );
  }

  return mDist;
}

#define OCTAVES 6
float fbm (in vec2 st) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st *= 2.;
        amplitude *= .5;
    }
    return value;
}

void main(){
  vec2 screen_uv = gl_FragCoord.xy / iResolution.xy;
  vec2 screen_mouse = iMouse.xy / iResolution.xy;
  vec2 tile_uv = ( gl_FragCoord.xy  - iOffset.xy ) / iTileResolution.xy;
  vec2 tile_mouse = ( iMouse.xy - iOffset.xy ) / iTileResolution.xy; 
  float aspect_ratio = iTileResolution.x/iTileResolution.y;
  tile_uv.x *= aspect_ratio;
  tile_mouse.x *= aspect_ratio;

  const float white_threshold = 0.9;

  // Color nucleus
  float dist = vonoroi(tile_uv,vec2(-1.0));
  float r = fbm(tile_uv + iTime*vec2(0.1));

  vec3 spec = dist*vec3(1.0,1.0,1.0);

  vec3 color = vec3(0.0,0.8,1.0);

  gl_FragColor = vec4(mix(spec,color,r),1.0);
}