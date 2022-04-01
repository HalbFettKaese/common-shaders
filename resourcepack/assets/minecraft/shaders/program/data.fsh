#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D WorldSampler;

uniform float Time;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    vec4 lastValue = texture(DiffuseSampler, texCoord);
    fragColor = lastValue;
    switch (int(gl_FragCoord.x)) {
        case 0:
            float time1 = lastValue.y + (floor(lastValue.x*255.) > ceil(Time*255.) ? 1./255. : 0.0);

            float time2 = lastValue.z + floor(time1)/255.;

            fragColor = vec4(Time, fract(time1), fract(time2), 1);
            break;
        case 1:
            vec4 marker = texelFetch(WorldSampler, ivec2(0, 0), 0);
            if (marker.r * 255. == 254.) {
                fragColor = marker;
            }
            break;
        default:
            vec4 target = texelFetch(DiffuseSampler, ivec2(1, 0), 0);
            fragColor = lastValue + sign(target - lastValue)/255.;
            break;
    }
}