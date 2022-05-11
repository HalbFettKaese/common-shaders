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

const float[] offsets = float[](
    0.0,
    -1.0,
    1.0,
    -2.0,
    2.0
);

float to_offset(float col) {
    int idx = int(col * 255.);
    return idx < offsets.length() ? offsets[idx] : 0.0;;
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    bool marker = abs(Color.z * 255. - 253.) < 0.5;
    if (marker) {
        gl_Position.xy += gl_Position.w * vec2(to_offset(Color.x), to_offset(Color.y));
    }

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
    if (!marker)
        vertexColor *= Color;
    texCoord0 = UV0;
}
