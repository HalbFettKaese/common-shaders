#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;

in float vertexDistance;
in vec2 texCoord0;

in vec3 texCorner0;
in vec3 texCorner1;
flat in vec3 texCorner2;

out vec4 fragColor;

void main() {
    vec2 corner0 = texCorner0.xy/texCorner0.z;
    vec2 corner1 = texCorner1.xy/texCorner1.z;
    vec2 corner2 = texCorner2.xy/texCorner2.z;
    vec2 uvSize = 65536.0 * (max(corner0, max(corner1, corner2)) - min(corner0, min(corner1, corner2)));

    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    float fade = linear_fog_fade(vertexDistance, FogStart, FogEnd);
    if (int(round(uvSize.x)) > 0 && int(round(uvSize.y)) == 0) {
        discard;
    } else {
        fragColor = vec4(color.rgb * fade, color.a);
    }
}
