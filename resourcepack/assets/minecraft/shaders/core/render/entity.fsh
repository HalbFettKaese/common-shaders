#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>
#moj_import <emissive_utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightColor;
in vec4 overlayColor;
in vec2 texCoord;
in vec2 texCoord2;
in vec3 Pos;
in float transition;

flat in int isCustom;
flat in int isGUI;
flat in int isHand;
flat in int noShadow;

in vec4 maxLightColor;
in float zpos;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord);
    float alpha = textureLod(Sampler0, texCoord, 0.0).a * 255.;

    // Switch used parts of the texture depending on where the model is displayed
    if (check_alpha(alpha, 253.0) && vertexDistance < 800) discard; // If it's inside the normal world space, it's always going to want to be the hand texture.

	if (vertexDistance >= 800) { // If it's in a GUI, figure out if it's the paper doll or an inventory slot.

		if (check_alpha(alpha, 254.0) && zpos < 2.0) discard; // If it's far back enough on the z-axis, it's usually in the paper doll's hand. Max set to 2 because nothing should be bigger than that.
		else if (check_alpha(alpha, 253.0) && zpos >= 2.0) discard; // If it's close enough on the z-axis, it's usually in an inventory slot.

	}

    if (color.a < 0.01) {discard;}

    //custom lighting
    #define ENTITY
    #moj_import<objmc.light>

    color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
	color.a = remap_alpha(alpha) / 255.0;
    color.a *= vertexColor.a;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}