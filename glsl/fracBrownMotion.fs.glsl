// Credit goes to the Book of Shaders (https://thebookofshaders.com/13/)
// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com
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
    vec2 tile_uv = ( gl_FragCoord.xy  - iOffset.xy ) / iTileResolution.xy;
    vec2 tile_mouse = ( iMouse.xy - iOffset.xy ) / iTileResolution.xy; 
    float aspect_ratio = iTileResolution.x / iTileResolution.y;
    tile_uv.x *= aspect_ratio;
    tile_mouse.x *= aspect_ratio;

    // First noise layer
    vec2 first = vec2(
        fbm( tile_uv + 0.1*iTime ),
        fbm( tile_uv + vec2(1.0))
    );

    // Second noise layer
    vec2 snd = vec2(
        fbm( tile_uv + 1.0*first + vec2(1.7,9.2) + 0.150*iTime ),
        fbm( tile_uv + 1.0*first + vec2(8.3,2.8) + 0.126*iTime )
    );

    // Third nosie layer
    float third = fbm(tile_uv + snd);

    vec3 color = mix( 
        vec3(0.101961,0.619608,0.666667),
        vec3(0.666667,0.666667,0.498039),
        clamp((third*third)*4.0,0.0,1.0)
    );

    color = mix(
        color,
        vec3(0,0,0.164706),
        clamp(length(first),0.0,1.0)
    );

    color = mix(
        color,
        vec3(0.666667,1,1),
        clamp(length(snd.x),0.0,1.0)
    );


  gl_FragColor = vec4(color,1.0);
}