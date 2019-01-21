// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/HDRIBaker" {
	Properties
	{
		_MainTex("Diffuse", 2D) = "white" { }
	}

	SubShader{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


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

			half4 frag(v2f i) : COLOR
			{
				//half4 color = texCUBE(_MainTex, i.texcoord);
				half4 color = tex2D(_MainTex, i.texcoord);


				color = EncodeLogLuv(color.rgb);

				return color;
			}

			ENDCG
		} // pass
	} // subshader
}