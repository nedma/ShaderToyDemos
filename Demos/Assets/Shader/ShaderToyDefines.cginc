#pragma once


#define vec2 float2
#define vec3 float3
#define vec4 float4
#define ivec2 float2
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4
#define iGlobalTime _Time.y
#define mod fmod
#define mix lerp
#define fract frac
#define texture2D tex2D
#define iResolution _ScreenParams
#define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

#define PI2 6.28318530718
#define pi 3.14159265358979
#define halfpi (pi * 0.5)
#define oneoverpi (1.0 / pi)

#define iTime _Time


fixed4 iMouse;
sampler2D iChannel0;
fixed4 iChannelResolution0;

sampler2D iChannel1;
fixed4 iChannelResolution1;

sampler2D iChannel2;
fixed4 iChannelResolution2;



float4 _texture(sampler2D tex, float2 uv)
{
	return tex2D(tex, float3(uv, 0));
}

float4 _texture(sampler2D tex, float2 uv, float mipBias)
{
	return tex2Dbias(tex, float4(uv, 0, mipBias));
}

float4 _textureLod(sampler2D tex, float2 uv, float mip)
{
	return tex2Dlod(tex, float4(uv, 0, mip));
}