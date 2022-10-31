#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec2 UV0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform mat4 TextureMat;
uniform int FogShape;

out float vertexDistance;
out vec2 texCoord0;

out vec3 texCorner0;
out vec3 texCorner1;
flat out vec3 texCorner2;

void main() {
    texCorner0 = vec3(0);
    texCorner1 = vec3(0);
    texCorner2 = vec3(0);

    if (gl_VertexID % 4 == 0) texCorner0 = vec3(UV0, 1.0);
    if (gl_VertexID % 4 == 2) texCorner1 = vec3(UV0, 1.0);
    if (gl_VertexID % 2 == 1) texCorner2 = vec3(UV0, 1.0);

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
}
