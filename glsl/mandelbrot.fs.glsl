#include <common>
#define CARRE(X) ((X)*(X))
#define EPISLON 1.0
precision highp float;

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

float circle(in vec2 st, in vec2 c, in float r){
  if (distance(st,c) < r)
    return 0.0;
  else{
    return 1.0;
  }
}

vec2 cmul(in vec2 z1, in vec2 z2){
  return vec2(z1.x*z2.x - z1.y*z2.y, z1.x*z2.y + z2.x*z1.y);
}

vec2 cinv(in vec2 z){
  vec2 inv = vec2(z.x, -z.y);
  return inv / dot(z,z);
}

vec2 cdiv(in vec2 z1, in vec2 z2){
  return cmul(z1,cinv(z2));
}

vec2 ccube(in vec2 z){
  return cmul(z,cmul(z,z));
}

vec2 cphase(in vec2 z){
  return normalize(z);
}

vec3 mandelbrot(in vec2 st, in vec2 mouse){

  vec2 zero1 = cmul(vec2(1.0,0.0), mouse);
  vec2 zero2 = cmul(vec2(-0.5,sqrt(3.0)/2.0), mouse);
  vec2 zero3 = cmul(vec2(-0.5,-sqrt(3.0)/2.0), mouse);

  // Display black circles at zeros
    //   if (distance(st, zero1) < 0.02)
    //     return vec3(0.0);
    //   if (distance(st, zero2) < 0.02)
    //     return vec3(0.0);
    //   if (distance(st, zero3) < 0.02)
    //     return vec3(0.0);


  // Compute minimal distance
  vec2 z = st;

  int nIter = 20; 

  for(int i = 0; i < nIter; i++){
    z = cmul(z,z) + st;
  }

  float d1 = distance(z,zero1);
  float d2 = distance(z,zero2);
  float d3 = distance(z,zero3);

  if (d1 < d2 && d1 < d3)
  {
    return vec3(1.0,d1/d2,d1/d3);
  }
  else if (d2 < d3)
  {
    return vec3(d2/d1,1.0,d2/d3);
  }
  else {
    return vec3(d3/d1,d3/d2,1.0);
  }

  return vec3(0.0);
}

void main(){
  vec2 centering = 0.5*iTileResolution;
  vec2 tile_uv = ( gl_FragCoord.xy  - iOffset.xy - centering ) / iTileResolution.xy;
  vec2 tile_mouse = ( iMouse.xy - iOffset.xy - centering ) / iTileResolution.xy;
  float aspect_ratio = iTileResolution.x/iTileResolution.y;
  float zoom = 0.5;
  tile_uv.x *= aspect_ratio;
  tile_uv /= zoom;
  tile_mouse.x *= aspect_ratio;
  tile_mouse /= zoom;

  vec3 color = mandelbrot(tile_uv - vec2(0.5,0.0), tile_mouse);
  // color += 0.9-step(.005, color[0]);

  gl_FragColor = vec4(color,1.0);
}