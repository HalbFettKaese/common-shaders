#version 150

uniform sampler2D DiffuseSampler;

uniform vec2 OutSize;

in vec2 texCoord;

out vec4 fragColor;

#define PI 3.141592653589793


const float tentacleIntensity = 0.275;
const float tentacleCount = 10.;
const float tentacleWiggle = 0.5;
const float tentacleInOutA = 1.0;
const float tentacleInOutF = 1.5;
const float tentacleLimit = 0.4;

const float tentacleFade = 0.5;

float time() {
    vec3 dataTime = texelFetch(DiffuseSampler, ivec2(0, 0), 0).rgb;
    return dataTime.x + 255. * dataTime.y + 65025. * dataTime.z;
}

int rand3(vec3 uv, int seed) {
	return int(4769.*fract(cos(floor(uv.y-5234.)*755.)*245.* sin(floor(uv.x-534.)*531.)*643.)*sin(floor(uv.z-53345.)*765.)*139.);
}

float fade(float t) {
	return t * t * t * (t * (t * 6. - 15.) + 10.);
}

float lerp(float a, float b, float t) {
	return a + fade(t) * (b - a);
}

vec3 randVec3(vec3 uv, int seed) {
	int a = rand3(uv, seed)*5237;
    int p1 = (a & 1) * 2 - 1;
    int p2 = (a & 2) - 1;
    int p3 = (a & 4) / 2 - 1;
    return vec3(p1, p2, p3);
}

float perlin3D(vec3 uv, int seed) {
	vec3 fuv = fract(uv);
    float c1 = dot(fuv - vec3(0, 0, 0), randVec3(floor(uv) + vec3(0, 0, 0), seed));
    float c2 = dot(fuv - vec3(0, 0, 1), randVec3(floor(uv) + vec3(0, 0, 1), seed));
    float c3 = dot(fuv - vec3(0, 1, 0), randVec3(floor(uv) + vec3(0, 1, 0), seed));
    float c4 = dot(fuv - vec3(0, 1, 1), randVec3(floor(uv) + vec3(0, 1, 1), seed));
    float c5 = dot(fuv - vec3(1, 0, 0), randVec3(floor(uv) + vec3(1, 0, 0), seed));
    float c6 = dot(fuv - vec3(1, 0, 1), randVec3(floor(uv) + vec3(1, 0, 1), seed));
    float c7 = dot(fuv - vec3(1, 1, 0), randVec3(floor(uv) + vec3(1, 1, 0), seed));
    float c8 = dot(fuv - vec3(1, 1, 1), randVec3(floor(uv) + vec3(1, 1, 1), seed));
    return (
            lerp(
        		lerp(
            		lerp(c1, c2, fuv.z), 
                    lerp(c3, c4, fuv.z), 
                    fuv.y), 
                lerp(
                    lerp(c5, c6, fuv.z), 
                    lerp(c7, c8, fuv.z), 
                    fuv.y), 
                fuv.x)
           );
}

float layeredPerlin3D(vec3 uv, int layerNumber, float fade, float frequencyShift, int seed) {
    float weight = 1.;
    float frequency = 1.;
    float result = 0.;
    int layer_seed = seed;
    float final_range = 0.;
    for (int i = 0; i < layerNumber; i++) {
        result += perlin3D(uv/frequency, layer_seed) * fade;
        final_range += fade;
        weight *= fade;
        frequency *= frequencyShift;
    	layer_seed = rand3(uv, layer_seed);
    }
    return result/final_range;
}

float pNoise(vec2 uv, float f) {
	vec3 tuv = vec3(uv, (time() + 20.0) * f);
    return layeredPerlin3D(tuv, 8, 2., 2., 4);
}

float tentacles(vec2 uv, float baseIntensity) {
    
    if (baseIntensity < .5)
        return 0.0;

    vec2 polar = vec2(
        length(uv),
        atan(uv.x, uv.y)
    );
    
    // Remap angle to [0, 1]
    polar.y = .5 + .5 * polar.y/PI;
    
    // Repeat tentacleCount times
    float id;
    polar.y = modf(polar.y * tentacleCount, id);
    
    polar.y = (polar.y + tentacleWiggle * pNoise(vec2(polar.x * 20.0, -id), 0.9));
    // Introduce symmetry
    polar.y = 2. * abs(polar.y - .5);
    
    float tentacleStart = tentacleInOutA*pNoise(vec2(id, 20.0), tentacleInOutF) + 1.0 / (tentacleIntensity * baseIntensity);
    
    tentacleStart = max(tentacleStart + tentacleLimit*.7, tentacleLimit);

    // b describes the tentacle color intensity, but I named it that b cuz I like that letter more
    float b = 1. - polar.y - 0.2*tentacleStart / polar.x;
    
    b = clamp(b, 0.0, 1.0);
    
    b = pow(b, 10.0);
    
    return step(.5, smoothstep(.005, 0.01, b));
}

void main() {
    float baseIntensity = (1. - texelFetch(DiffuseSampler, ivec2(1, 1), 0).z) * 10.0;
    float tentacleIntensity = baseIntensity * (1. - texelFetch(DiffuseSampler, ivec2(0, 3), 0).z);
    
    if (tentacleIntensity == 0.0) {
        fragColor = vec4(0);
        return;
    }

    vec2 uv = (texCoord - .5) * OutSize.xy / OutSize.xx;

    vec3 col = vec3(tentacles(uv, tentacleIntensity));

    float fade = clamp(length(texCoord - .5) / tentacleFade, 0.0, 1.0);

    fragColor = vec4(col*fade, 1.0);
}