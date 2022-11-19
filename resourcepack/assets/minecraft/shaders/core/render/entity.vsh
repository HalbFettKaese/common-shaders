#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>
#moj_import <emissive_utils.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform float FogStart;
uniform int FogShape;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform float GameTime;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightColor;
out vec4 overlayColor;
out vec2 texCoord;
out vec2 texCoord2;
out vec3 Pos;
out float transition;

flat out int isCustom;
flat out int isGUI;
flat out int isHand;
flat out int noshadow;

out vec4 maxLightColor;
out float zpos;

vec2[] corners = vec2[](
    vec2(0.0, 1.0),
    vec2(0.0, 0.0),
    vec2(1.0, 0.0),
    vec2(1.0, 1.0)
);

#moj_import <objmc_tools.glsl>

void main() {
    vec2 samplerSize = vec2(textureSize(Sampler0, 0));
    vec2 newUV0 = UV0;
    if (((gl_VertexID + 1) % 4) / 2 == 1)
        newUV0.y += 1.0/samplerSize.y;
    vec4 texCol = texture(Sampler0, newUV0);
    if (ivec2(texCol.zw * 255. + 0.5) == ivec2(1, 249)) {
        vec2 offset = texCol.rg * 255.;
        offset -= step(127.5, offset) * 256.0;
        newUV0 += (-vec2(0.0, 1.0) + vec2(-1.0, 1.0) * corners[gl_VertexID % 4] - 0.5 + offset)/samplerSize;
    } else {
        newUV0 = UV0;
    }

    zpos = Position.z;
    Pos = Position;
    vec3 normal = (ProjMat * ModelViewMat * vec4(Normal, 0.0)).rgb;
    texCoord = newUV0;
    overlayColor = vec4(1);
    lightColor = minecraft_sample_lightmap(Sampler2, UV2);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);

    maxLightColor = minecraft_sample_lightmap(Sampler2, ivec2(240.0, 240.0));

    //objmc
    #define ENTITY
    #moj_import <objmc_main.glsl>

    gl_Position = ProjMat * ModelViewMat * (vec4(Pos, 1.0));
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Pos, FogShape);
}