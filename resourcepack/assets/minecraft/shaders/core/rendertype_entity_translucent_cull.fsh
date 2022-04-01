#version 150

#moj_import <fog.glsl>
#moj_import <emissive_utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
	
in float zpos; 
in float vertexDistance;
in vec4 vertexColor;
in vec4 lightColor;
in vec4 maxLightColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;

    // Switch used parts of the texture depending on where the model is displayed
    if (check_alpha(alpha, 253.0) && vertexDistance < 800) discard; // If it's inside the normal world space, it's always going to want to be the hand texture.
	
	if (vertexDistance >= 800) { // If it's in a GUI, figure out if it's the paper doll or an inventory slot.
	
		if (check_alpha(alpha, 254.0) && zpos < 2.0) discard; // If it's far back enough on the z-axis, it's usually in the paper doll's hand. Max set to 2 because nothing should be bigger than that.
		else if (check_alpha(alpha, 253.0) && zpos >= 2.0) discard; // If it's close enough on the z-axis, it's usually in an inventory slot.
		
	}
    // Apply emissivity
    color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
	color.a = remap_alpha(alpha) / 255.0;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}