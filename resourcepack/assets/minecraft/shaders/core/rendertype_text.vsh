#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    int p = (int(Color.x * 255.) << 16) | (int(Color.y * 255.) << 8) | int(Color.z * 255.);
    bool marker = (p & 0xf) == 0xd;
    if (marker) {
        gl_Position = ProjMat * ModelViewMat * vec4(Position.xy, Position.z - 2.0, 1.0);

        vec2 offset = vec2(
            float((p >> 14) & 0x3ff),
            float((p >>  4) & 0x3ff)
        ) / 1024.0;

        offset = (offset - .5) * 4.;

        gl_Position.xy += gl_Position.w * offset;
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    }

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
    if (!marker)
        vertexColor *= Color;
    texCoord0 = UV0;
}
