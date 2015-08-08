precision mediump float;

#define DITHER
#define AUTO_MODE
#define DOWN_SCALE 4.

#define SCREEN_WIDTH 160.
#define SCREEN_HEIGHT 144.

#define PI 3.14159265359

#define PALETTE_SIZE 4

#define RGB(r,g,b) (vec3(r,g,b) / 255.0);


varying vec4 color;
varying vec2 tcoord;


uniform sampler2D tex0;


vec3 palette[PALETTE_SIZE];

//Initalizes the color palette.
void InitPalette()
{
    //nope.
    palette[0] = RGB( 61, 20, 60);
    palette[1] = RGB(146,  0, 91);
    palette[2] = RGB( 42,167,148);
    palette[3] = RGB(246,221,241);
}


//Blends the nearest two palette colors with dithering.
vec3 GetDitheredPalette(float x,vec2 pixel)
{
    float idx = clamp(x,0.0,1.0)*float(PALETTE_SIZE-1);
    
    vec3 c1 = vec3(0);
    vec3 c2 = vec3(0);
    
    //Loop to workaround constant array indexes.
    for(int i = 0;i < PALETTE_SIZE;i++)
    {
        if(float(i) == floor(idx))
        {
            c1 = palette[i];
            c2 = palette[i + 1];
            break;
        }   
    }
    
    float mixAmt = float(fract(idx) > 0.);
    
    return mix(c1,c2,mixAmt);
}


void main(  )
{
    InitPalette();
    
    // fragCoord = floor(fragCoord / DOWN_SCALE) * DOWN_SCALE;

    vec2 uv = tcoord;

    float dx = 1./SCREEN_WIDTH;
    float dy = 1./SCREEN_HEIGHT;
    uv = vec2( dx*floor(uv.x/dx), dy*floor(uv.y/dy));


    // float brightness = (0.2126*color4.r + 0.7152*color4.g + 0.0722*color4.b);

    vec4 color4 = texture2D(tex0, uv);

    float brightness = sqrt(
        0.299* (color4.r*color4.r) +
        0.587* (color4.g*color4.g) +
        0.114* (color4.b*color4.b) );
    vec3 outColor = GetDitheredPalette(brightness, uv /* / DOWN_SCALE */);
    
    //Palette preview
    if(uv.x < 0.03) 
    {
        outColor = GetDitheredPalette(uv.y, tcoord / (1./SCREEN_HEIGHT));
    }
    
    gl_FragColor = vec4(outColor, 1.0);
}
