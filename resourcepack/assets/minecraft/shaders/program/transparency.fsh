#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentSampler;
uniform sampler2D TranslucentDepthSampler;
uniform sampler2D ItemEntitySampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D ParticlesSampler;
uniform sampler2D ParticlesDepthSampler;
uniform sampler2D WeatherSampler;
uniform sampler2D WeatherDepthSampler;
uniform sampler2D CloudsSampler;
uniform sampler2D CloudsDepthSampler;

uniform vec2 OutSize;

in vec2 texCoord;
in vec2 oneTexel;

#define NUM_LAYERS 6

vec4 color_layers[NUM_LAYERS];
float depth_layers[NUM_LAYERS];
int active_layers = 0;

out vec4 fragColor;

void try_insert( vec4 color, float depth ) {
    if ( color.a == 0.0 ) {
        return;
    }

    color_layers[active_layers] = color;
    depth_layers[active_layers] = depth;

    int jj = active_layers++;
    int ii = jj - 1;
    while ( jj > 0 && depth_layers[jj] > depth_layers[ii] ) {
        float depthTemp = depth_layers[ii];
        depth_layers[ii] = depth_layers[jj];
        depth_layers[jj] = depthTemp;

        vec4 colorTemp = color_layers[ii];
        color_layers[ii] = color_layers[jj];
        color_layers[jj] = colorTemp;

        jj = ii--;
    }
}

vec3 blend( vec3 dst, vec4 src ) {
    return ( dst * ( 1.0 - src.a ) ) + src.rgb;
}

void main() {
    vec2 uv = texCoord;
    if (ivec2(texCoord * OutSize) == ivec2(0)) {
        uv.y += oneTexel.y;
    }
    color_layers[0] = vec4( texture( DiffuseSampler, uv ).rgb, 1.0 );
    depth_layers[0] = texture( DiffuseDepthSampler, uv ).r;
    active_layers = 1;

    try_insert( texture( TranslucentSampler, uv ), texture( TranslucentDepthSampler, uv ).r );
    try_insert( texture( ItemEntitySampler, uv ), texture( ItemEntityDepthSampler, uv ).r );
    try_insert( texture( ParticlesSampler, uv ), texture( ParticlesDepthSampler, uv ).r );
    try_insert( texture( WeatherSampler, uv ), texture( WeatherDepthSampler, uv ).r );
    try_insert( texture( CloudsSampler, uv ), texture( CloudsDepthSampler, uv ).r );

    vec3 texelAccum = color_layers[0].rgb;
    for ( int ii = 1; ii < active_layers; ++ii ) {
        texelAccum = blend( texelAccum, color_layers[ii] );
    }

    fragColor = vec4( texelAccum.rgb, 1.0 );
}
