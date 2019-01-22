// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/HDRIBaker" 
{
	Properties
	{
		_MainTex("Diffuse", 2D) = "white" { }
	}


	SubShader
	{

		CGINCLUDE

		#include "HDRIUtils.cginc"

		sampler2D _MainTex;
		//samplerCUBE _MainTex;
		half4 _MainTex_HDR;

		struct a2v {
			float4 vertex : POSITION;
			float3  texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 vertex : POSITION;
			float3  texcoord : TEXCOORD0;
		};

		v2f vert(a2v v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.texcoord = v.texcoord;
			return o;
		}

		ENDCG

		// 0 - encode LogLUV
		Pass
		{
			CGPROGRAM

			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				half4 outputColor = EncodeLogLuv(tex.rgb);

				return outputColor;
			}

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		} // pass

		// 1 - encode LogLUV, output alpha
		Pass
		{
			CGPROGRAM

			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				half4 outputColor = EncodeLogLuv(tex.rgb);

				return outputColor.a;
			}

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}


		// 2 - encode RGBM
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				//tex = pow(tex, 1.5);

				half4 color = EncodeRgbm(tex.rgb, _RgbmMaxValue);

				return color;
			}

			ENDCG
		}

		// 3 - encode RGBM
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				//tex = pow(tex, 1.5);

				half4 color = EncodeRgbm(tex.rgb, _RgbmMaxValue);

				return color.a;
			}

			ENDCG
		}


		// 4 - encode RGBE
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				//tex = pow(tex, 1.5);

				half4 color = EncodeRgbe(tex.rgb);

				return color;
			}

			ENDCG
		}

		// 5 - encode RGBE
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				//tex = pow(tex, 1.5);

				half4 color = EncodeRgbe(tex.rgb);

				return color.aaaa;
			}

			ENDCG
		}

		// 6 - encode RGBE
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				half lum = _Luminance(tex);

				if (lum > 1)
				{
					tex.rgb /= lum;
				}

				half4 color = half4(tex.rgb, lum);
				return color;
			}

			ENDCG
		}

		// 7 - encode RGBE
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 tex = tex2D(_MainTex, i.texcoord);

				half lum = _Luminance(tex);

				if (lum > 1)
				{
					return lum / _RgbmMaxValue;
				}
				else
				{
					return 1 / _RgbmMaxValue;
				}
			}

			ENDCG
		}

	} // subshader
}