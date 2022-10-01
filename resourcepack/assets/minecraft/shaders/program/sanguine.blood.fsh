#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DataSampler;
uniform sampler2D TentacleSampler;
uniform sampler2D EyesSampler;

uniform vec2 OutSize;
uniform float Time;

in vec2 texCoord;

out vec4 fragColor;

// Settings

float lightAmplifier = 3.0;

void main() {
    float intensity = (1. - texelFetch(DataSampler, ivec2(1, 6), 0).z);

    vec3 col = texture(DiffuseSampler, texCoord).rgb;

    if (intensity > 0.0) {
        float brightness = dot(col, vec3(.33));

        float saturation = length(col - brightness);

        // Apply smoothstep function with dynamic degree
        brightness = mix(pow(brightness, lightAmplifier), 1. - pow(1. - brightness, lightAmplifier), brightness);

        // Set hue to red
        vec3 red = brightness + vec3(1., 0., 0.) * saturation;
        // Mix with multiplicatively applied red tint
        red = mix(red, col * vec3(1., 0., 0.), .5*intensity);

        // Mix with regular color depending on intensity
        col =  mix(col, red, intensity);
    }

    fragColor = vec4(col, 1);
}
