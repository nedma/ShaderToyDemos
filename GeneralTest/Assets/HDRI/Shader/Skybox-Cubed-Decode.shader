// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Test/Cubemap Decode" {
Properties {
	_Tint ("Tint Color", Color) = (.5, .5, .5, .5)
	_Exposure ("Exposure", Range(0, 16)) = 1.0
	_Gamma("Gamma", Range(0, 8)) = 2.2
	_Rotation ("Rotation", Range(0, 360)) = 0
	[NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" {}
	[NoScaleOffset] _Tex2("Cubemap   (HDR)", Cube) = "grey" {}
}

SubShader {
	Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
	Cull Off ZWrite Off

	Pass {
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0

		#pragma multi_compile _ LogLuv RGBM RGBE RGBLum

		#include "UnityCG.cginc"
		#include "HDRIUtils.cginc"


		samplerCUBE _Tex;
		half4 _Tex_HDR;

		samplerCUBE _Tex2;
		half4 _Tex_HDR2;

		half4 _Tint;
		half _Exposure;
		half _Gamma;
		float _Rotation;

		float3 RotateAroundYInDegrees (float3 vertex, float degrees)
		{
			float alpha = degrees * UNITY_PI / 180.0;
			float sina, cosa;
			sincos(alpha, sina, cosa);
			float2x2 m = float2x2(cosa, -sina, sina, cosa);
			return float3(mul(m, vertex.xz), vertex.y).xzy;
		}
		
		struct appdata_t {
			float4 vertex : POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct v2f {
			float4 vertex : SV_POSITION;
			float3 texcoord : TEXCOORD0;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		v2f vert (appdata_t v)
		{
			v2f o;
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
			o.vertex = UnityObjectToClipPos(rotated);
			o.texcoord = v.vertex.xyz;
			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			half4 tex = texCUBE (_Tex, i.texcoord);
			half4 tex2 = texCUBE(_Tex2, i.texcoord);

		#if defined(LogLuv)
			half3 c = DecodeLogLuv(tex);
		#elif defined(RGBM)
			half3 c = DecodeRgbm(half4(tex.rgb, tex2.r), _RgbmMaxValue);
		#elif defined(RGBE)
			half3 c = DecodeRgbe(half4(tex.rgb, tex2.r));
		#elif defined(RGBLum)
			half3 c = tex * tex2.a * _RgbmMaxValue;
			//half3 c = tex2;
		#else
			half3 c = DecodeHDR(tex, _Tex_HDR);
		#endif
			

			c = c * _Tint.rgb;
			c *= _Exposure;

			c.rgb = pow(c.rgb, _Gamma);
			

			return half4(c, 1);
		}
		ENDCG 
	}
} 	


Fallback Off

}
