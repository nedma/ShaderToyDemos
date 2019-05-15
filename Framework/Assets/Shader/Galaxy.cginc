#pragma once

// https://www.shadertoy.com/view/ltVGRz


#include "ShaderToyDefines.cginc"

//precision highp float;


float snoise(vec2 v)
{
	return tex2D(iChannel0, v).r;
}

const mat2 m2 = mat2(0.8, -0.6, 0.6, 0.8);

float fbm(in vec2 p) 
{
	float f = 0.0;
	f += 0.5000f * snoise(p); 
	p =  mul(m2, p) * 2.02f;
	f += 0.2500f*snoise(p); 
	p = mul(m2, p) * 2.03f;
	f += 0.1250f * snoise(p); 
	p = mul(m2, p) * 2.01f;
	f += 0.0625f * snoise(p);

	return f / 0.9375;
}

float dirt(vec2 p) {

	vec2 pos = p + iTime * .0000001;

	float d = 1.0 - max(pow(length(pos - 0.5) / 0.5, 4.0) * (abs(pos.y - 0.5) * 100.0), 0.0);

	float S = 1.0;
	float n = snoise(pos / S);
	float n2 = snoise((pos + 0.1) / S * 2.0);
	float n3 = snoise((pos + 0.2) / S * 3.0);
	float n4 = snoise((pos + 0.2) / S * 4.0);
	n = pow(n * n2 * n3 * n4, 2.0);

	return max(n * d, 0.0);
}

vec3 bgGlow(vec2 pos)
{
	vec3 color = vec3(0.7, 0.65, 0.6);

	float intensity = 1.0 - pow(length(0.5 - pos.y) / 0.5, 8.0);

	intensity = clamp(intensity, 0.0, 1.0);
	intensity /= 4.0;
	return color * intensity * 0.1;
}

vec3 brightClouds(vec2 pos)
{
	vec3 c = vec3(0.4, 0.35, 0.36);
	float intensity = pow(1.0 - length(0.5 - pos), 2.5);

	float ycenter = 1.0 - abs(0.5 - pos.y);
	intensity *= pow(ycenter, 10.0);

	return c * fbm(pos / 20.0) * intensity * 5.0 * fbm(pos / 10.0);
}

vec3 makeStars(vec2 pos)
{
	pos += snoise(pos) / 100.0;
	float S = 1.0;
	float n = snoise(pos / S * 100.0);
	float n2 = snoise((pos + 0.1) / S * 290.0);
	float n3 = snoise((pos + 0.2) / S * 30.0);
	float n4 = snoise((pos + 0.2) / S * 10.0);
	n = pow(n * n2 * n3 * n4, 2.0);
	return vec3(n.xxx);
}

vec3 darkClouds(vec2 pos)
{
	vec3 c = vec3(0.2, 0.23, 0.3);

	float intensity = 1.0 - abs(0.5 - pos.y);

	float ycenter = 1.0 - abs(0.5 - pos.y);
	intensity *= pow(ycenter, 8.0);
	return c * fbm(pos / 100.0) * 1.0 * intensity;
}

float dirtClouds(vec2 pos)
{
	float qwe = max(1. / pow(abs(0.5 - max(pos.y, 1.0)), 1.5), 1.0);
	float intensity = 1.0 - abs(0.5 - pos.y);
	return (fbm(pos * 0.1) * qwe + 1.0) / 2.0 * pow(intensity, 8.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy + iTime * .00001;

	fragColor.rgb = bgGlow(uv) + makeStars(uv) + (brightClouds(uv) + darkClouds(uv)) / 0.5 + dirt(uv);
	//fragColor.rgb = makeStars(uv);
	fragColor.rgb = mix(fragColor.rgb, vec3(0.125, 0.1, 0.1), dirtClouds(uv) * 0.75 * pow(length(uv * 2.0 - 1.0), 0.25));

	fragColor.a = 1.0;
}
