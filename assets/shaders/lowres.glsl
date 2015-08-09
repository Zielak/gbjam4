precision mediump float;

#define BRIGHTNESS 1.0

#define SCREEN_WIDTH 160.
#define SCREEN_HEIGHT 144.


varying vec4 color;
varying vec2 tcoord;


uniform sampler2D tex0;

vec2 iResolution = vec2(SCREEN_WIDTH, SCREEN_HEIGHT);


vec3 find_closest (vec3 ref) {  
    vec3 old = vec3 (100.0*255.0);      
    #define TRY_COLOR(new) old = mix (new, old, step (length (old-ref), length (new-ref))); 
    TRY_COLOR (vec3( 62, 20, 60));
    TRY_COLOR (vec3(146,  0, 91));
    TRY_COLOR (vec3( 42,167,148));
    TRY_COLOR (vec3(246,221,241));

    return old ;
}

float dither_matrix (float x, float y) {
    return mix(mix(mix(mix(mix(mix(0.0,32.0,step(1.0,y)),mix(8.0,40.0,step(3.0,y)),step(2.0,y)),mix(mix(2.0,34.0,step(5.0,y)),mix(10.0,42.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(48.0,16.0,step(1.0,y)),mix(56.0,24.0,step(3.0,y)),step(2.0,y)),mix(mix(50.0,18.0,step(5.0,y)),mix(58.0,26.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(1.0,x)),mix(mix(mix(mix(12.0,44.0,step(1.0,y)),mix(4.0,36.0,step(3.0,y)),step(2.0,y)),mix(mix(14.0,46.0,step(5.0,y)),mix(6.0,38.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(60.0,28.0,step(1.0,y)),mix(52.0,20.0,step(3.0,y)),step(2.0,y)),mix(mix(62.0,30.0,step(5.0,y)),mix(54.0,22.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(3.0,x)),step(2.0,x)),mix(mix(mix(mix(mix(3.0,35.0,step(1.0,y)),mix(11.0,43.0,step(3.0,y)),step(2.0,y)),mix(mix(1.0,33.0,step(5.0,y)),mix(9.0,41.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(51.0,19.0,step(1.0,y)),mix(59.0,27.0,step(3.0,y)),step(2.0,y)),mix(mix(49.0,17.0,step(5.0,y)),mix(57.0,25.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(5.0,x)),mix(mix(mix(mix(15.0,47.0,step(1.0,y)),mix(7.0,39.0,step(3.0,y)),step(2.0,y)),mix(mix(13.0,45.0,step(5.0,y)),mix(5.0,37.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(63.0,31.0,step(1.0,y)),mix(55.0,23.0,step(3.0,y)),step(2.0,y)),mix(mix(61.0,29.0,step(5.0,y)),mix(53.0,21.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(7.0,x)),step(6.0,x)),step(4.0,x));
}

vec3 dither (vec3 color, vec2 uv) { 
    color *= 255.0 * BRIGHTNESS;    
    // color += dither_matrix (mod (uv.x, 8.0), mod (uv.y, 8.0)) ;
    color = find_closest (clamp (color, 0.0, 255.0));
    return color / 255.0;
}

void main(  )
{
    vec2 uv = tcoord;

    float dx = 1./SCREEN_WIDTH;
    float dy = 1./SCREEN_HEIGHT;
    uv = vec2( dx*floor(uv.x/dx) + dx/2. , dy*floor(uv.y/dy) + dy/2.);


    // float brightness = (0.2126*tc.r + 0.7152*tc.g + 0.0722*tc.b);

    vec3 tc = texture2D(tex0, uv).xyz;

    // float brightness = sqrt(
    //     0.299* (tc.r*tc.r) +
    //     0.587* (tc.g*tc.g) +
    //     0.114* (tc.b*tc.b) );

    gl_FragColor = vec4 (dither (tc, uv.xy),1.0);
}
