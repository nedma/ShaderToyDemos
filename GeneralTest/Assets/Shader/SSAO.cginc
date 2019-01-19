#pragma once


https://blog.csdn.net/gy373499700/article/details/79111091



//总结：从上面的渲染图可以得到一些结论
//1.正常情况下，采样次数越越多效果越好
//2.在较低次数采样下基于View方向的球积分效果表现更好，在较高次数采样下基于normal方向的半球积分表现效果更好。总的来说基于normal方向的计算效果更佳逼真。



inline half calcAO(half2 tcoord, half2 uvoffset, half3 p, half3 norm,half3 viewdir)
{
	half2 t = tcoord + uvoffset;//采样点是UV坐标周围的点 对应的world空间点
	float2 XY_Depth = float2(1.0f,0.003921568627451);	
	float depth = dot(tex2D(_Depth, t).xy, XY_Depth);
	float3 diff = float3(t*2-1, 1)*_FarCorner*depth-p;//viewpos offset
	half3 v = normalize(diff);
	half d = length(diff) *0.11;// _Params1.w/100;//distance

	return dot(viewdir, v);


	//return max(0.0, dot(norm, v))* (1.0 / (1.0 + d)) ;
	//半球积分
}


float4 frag( v2f IN) : COLOR
{
	
	float2   uv=   IN.uv;
	float2 XY_Depth = float2(1.0f,0.003921568627451);			  
	float2 sampleuv = uv;	 
	float4 depth_normal = tex2D(_Depth,sampleuv);	   
	float view_depth = dot(depth_normal.xy,XY_Depth);//
	float3 normal = DecodeNormal(depth_normal.zw);
	float3 view_pos = IN.viewpos*view_depth;
	float3 viewdir = normalize(view_pos);
   
	const half2 CROSS[4] = { half2(1.0, 0.0), half2(-1.0, 0.0), half2(0.0, 1.0), half2(0.0, -1.0) };
	half eyeDepth =view_depth;// LinearEyeDepth(depth);
	half3 position =view_pos;// getWSPosition(uv, depth); // World space
	#if defined(SAMPLE_NOISE)
	half2 random = normalize(tex2D(_Sample2x2, _ScreenParams.xy * uv / _Params1.x).rg * 2.0 - 1.0);
	#endif

	half radius =max(_Params1.y/100, 0.005); 
//	if(view_pos.z>30)
//		return view_depth;// Skip out of range pixels!!!!!!!!!!!!!!!!!!!!!!!!
	half ao = 0;

	// Sampling
	for (int j = 0; j < 4; j++)
	{
		half2 coord1;

		#if defined(SAMPLE_NOISE)
		coord1 = reflect(CROSS[j], random) * radius;//this random important
		#else
		coord1 = CROSS[j] * radius;
		#endif

		#if !SAMPLES_VERY_LOW
		half2 coord2 = coord1 * 0.707;
		coord2 = half2(coord2.x - coord2.y, coord2.x + coord2.y);
		#endif

		#if SAMPLES_Num==20			// 20
		ao += calcAO(uv, coord1 * 0.20, position, normal,viewdir);
		ao += calcAO(uv, coord2 * 0.40, position, normal,viewdir);
		ao += calcAO(uv, coord1 * 0.60, position, normal,viewdir);
		ao += calcAO(uv, coord2 * 0.80, position, normal,viewdir);
		ao += calcAO(uv, coord1, position, normal,viewdir);
		#elif SAMPLES_Num==16			// 16
		ao += calcAO(uv, coord1 * 0.25, position, normal,viewdir);
		ao += calcAO(uv, coord2 * 0.50, position, normal,viewdir);
		ao += calcAO(uv, coord1 * 0.75, position, normal,viewdir);
		ao += calcAO(uv, coord2, position, normal,viewdir);
		#elif SAMPLES_Num==12		// 12
		ao += calcAO(uv, coord1 * 0.30, position, normal,viewdir);
		ao += calcAO(uv, coord2 * 0.60, position, normal,viewdir);
		ao += calcAO(uv, coord1 * 0.90, position, normal,viewdir);
		#elif SAMPLES_Num==8			// 8
		ao += calcAO(uv, coord1 * 0.30, position, normal,viewdir); 
		ao += calcAO(uv, coord2 * 0.80, position, normal,viewdir);
		#elif SAMPLES_Num==4		// 4				
		ao += calcAO(uv, coord1 * 0.50, position, normal,viewdir);
		#endif
	}
	ao /= SAMPLES_Num;	        
	float3 ret =0.5+ao;
		//float3 ret =1-ao;
	if (_Debug==1) 
		return  half4(ret.xyz, 1);   
	
	float4 diff = tex2D(_Diffuse, sampleuv);
	ret*= diff.xyz*_AmbientColor;  				
	float3 WorldN= mul((float3x3)ViewToWorld, normal);
	float3 envDiff = texCUBE(_SkyTexture,WorldN); 
	ret *= envDiff*envDiff;
	
	return  half4(ret.xyz, 1); 

}