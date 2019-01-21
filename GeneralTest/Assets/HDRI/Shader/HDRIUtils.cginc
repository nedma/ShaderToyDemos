#pragma once




//FP32(RGB) to LogLUV
fixed4 EncodeLogLuv(fixed3 vRGB)
{
	fixed3x3 M = fixed3x3(
		0.2209, 0.3390, 0.4184,
		0.1138, 0.6780, 0.7319,
		0.0102, 0.1130, 0.2969);

	fixed4 vResult;
	fixed3 Xp_Y_XYZp = mul(vRGB, M);
	Xp_Y_XYZp = max(Xp_Y_XYZp, fixed3(1e-6, 1e-6, 1e-6));
	vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
	fixed Le = 2 * log2(Xp_Y_XYZp.y) + 127;
	vResult.w = frac(Le);
	vResult.z = (Le - (floor(vResult.w*255.0f)) / 255.0f) / 255.0f;

	return vResult;
}

//LogLuv to FP32(RGB)
fixed3 DecodeLogLuv(in fixed4 vLogLuv)
{
	fixed3x3 InverseM = fixed3x3(
		6.0014, -2.7008, -1.7996,
		-1.3320, 3.1029, -5.7721,
		0.3008, -1.0882, 5.6268);

	fixed Le = vLogLuv.z * 255 + vLogLuv.w;
	fixed3 Xp_Y_XYZp;
	Xp_Y_XYZp.y = exp2((Le - 127) / 2);
	Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
	Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
	fixed3 vRGB = mul(Xp_Y_XYZp, InverseM);

	return max(vRGB, 0);
}