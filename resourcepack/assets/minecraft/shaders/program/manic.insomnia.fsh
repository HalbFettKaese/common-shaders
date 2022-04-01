#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DataSampler;
uniform sampler2D TentacleSampler;
uniform sampler2D EyesSampler;

uniform vec2 OutSize;
uniform float Time;

in vec2 texCoord;

out vec4 fragColor;

#define PI 3.141592653589793

// Settings

// Set base intensity to value between 0 and 10
//const float baseIntensity = 0.0;


const float minSaturation = 0.3;

const float greyscaleRadius = 1.0;
const float vignetteRadius = 0.25;
const float vignetteIntensity = 0.27;

const vec3 eyeColor = vec3(255, 255, 255)/255.;

// curl is wobble
// Detail scale describes spatial curl frequency
const float curlIntensity = 0.4;
const float wobbleDownfall = .33;
const float detailScale = 10.;

float time() {
    vec3 dataTime = texelFetch(DataSampler, ivec2(0, 0), 0).rgb;
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

float pNoise(vec2 uv, float time) {
	vec3 tuv = vec3(uv, time);
    return layeredPerlin3D(tuv, 4, 2., 2., 4);
}

vec2 curl(vec2 uv, float time)
{
    float eps = .005;
	float pN = pNoise( uv + vec2(0,eps), time);
	float pS = pNoise( uv - vec2(0,eps), time);
	float pE = pNoise( uv + vec2(eps,0), time);
	float pW = pNoise( uv - vec2(eps,0), time);

	return vec2((pN - pS), -(pE - pW));

}

void main() {
    float baseIntensity = (1. - texelFetch(DataSampler, ivec2(1, 1), 0).z) * 10.0;
    
    if (baseIntensity == 0.0) {
        fragColor = texture(DiffuseSampler, texCoord);
        return;
    }

    float time = time();

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = texCoord;
    
    float s = length(uv - .5) * baseIntensity;
    
    // Apply curl
    uv += curl(uv * detailScale, time + 20.0) * curlIntensity * pow(s, wobbleDownfall);
    
    uv = clamp(uv, 0., 1.);
    
    // Read base screen view (in this case, constant texture)
    vec3 col = texture(DiffuseSampler, uv).rgb;
    
    // Apply greyscale
    float saturation = minSaturation + (1. - minSaturation) * (1. - baseIntensity / 10.0);
    
    float greyscale = dot(col, vec3(.33));
    col = greyscale + saturation * (col - greyscale);
    
    // Render vignette
    float vignette = s*vignetteIntensity;
    
    vignette = (vignette - 1.5)/vignetteRadius + 1.5;
    
    // Apply darkness
    col *= 1. - clamp(vignette - 0.5, 0.0, 1.0);
    
    // Apply tentacles
    col = mix(col, vec3(0), texture(TentacleSampler, texCoord).r);

    // Apply eyes
    float eyesScale = vignetteIntensity * baseIntensity * 0.37;

    vec4 eyes = texture(EyesSampler, (vec2(0., 1.) + vec2(1., -1.) * texCoord - 0.5)*eyesScale + 0.5);

    float eyeProgress = (sin(time * (1. + .1 * sin(eyes.g*255.*10353.7319)) + 173. * eyes.g * 255.) + .3);

    col = mix(col, eyeColor * eyes.xxx, step(1. - eyes.z, eyeProgress) * eyes.a);
    
    // Output color
    fragColor = vec4(col, 1.);
}
