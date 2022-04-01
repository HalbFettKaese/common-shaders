#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D WorldSampler;

uniform float Time;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    vec4 lastValue = texture(DiffuseSampler, texCoord);
    fragColor = lastValue;
    switch (int(gl_FragCoord.y)) {
        case 0:
            // Row 0: Time
            float time1 = lastValue.y + (floor(lastValue.x*255.) > ceil(Time*255.) ? 1./255. : 0.0);

            float time2 = lastValue.z + floor(time1)/255.;

            fragColor = vec4(Time, fract(time1), fract(time2), 1);
            break;
        case 1:
            // Row 1: Manic
            if (int(gl_FragCoord.x) == 0) {
                vec4 marker = texelFetch(WorldSampler, ivec2(0, 0), 0);
                if (marker.rg * 255. == vec2(254., 253.)) {
                    fragColor = marker;
                }
            } else {
                vec4 target = texelFetch(DiffuseSampler, ivec2(0, 1), 0);
                fragColor = lastValue + sign(target - lastValue)/255.;
                break;
            }
            break;
    }
}