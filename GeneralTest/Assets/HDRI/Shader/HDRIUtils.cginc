#ifndef HDRI_UTILS
#define HDRI_UTILS



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








// ---- Accurate, but slow RGBE encoding
// Reference: Wolfgang Engel, "Programming Vertex and Pixel Shader", pp. 230

// Constants for RGBE encoding.
static const float RgbeBase = 1.04;
static const float RgbeOffset = 64.0;


/// Calculates the logarithm for a given y and base, such that base^x = y.
/// param[in] base    The base of the logarithm.
/// param[in] y       The number of whic to calculate the logarithm.
/// \return The logarithm of y.
float LogEnc(float base, float y)
{
	// We use an "obsfuscated" name because the same method is declared in
	// Misc.fxh but we don't want to include that or create a duplicate definition.
	return log(y) / log(base);
}


/// Encodes the given color to RGBE 8-bit format.
/// \param[in] color    The original color.
/// \return The color encoded as RGBE.
float4 EncodeRgbe_Engel(float3 color)
{
	// Get the largest component.
	float maxValue = max(max(color.r, color.g), color.b);

	float exponent = floor(LogEnc(RgbeBase, maxValue));

	float4 result;

	// Store the exponent in the alpha channel.
	result.a = clamp((exponent + RgbeOffset) / 255, 0.0, 1.0);

	// Convert the color channels.
	result.rgb = color / pow(RgbeBase, result.a * 255 - RgbeOffset);

	return result;
}


/// Decodes the given color from RGBE 8-bit format.
/// \param[in] rgbe   The color encoded as RGBE.
/// \return The orginal color.
float3 DecodeRgbe_Engel(float4 rgbe)
{
	// Get exponent from alpha channel.
	float exponent = rgbe.a * 255 - RgbeOffset;
	float scale = pow(RgbeBase, exponent);

	return rgbe.rgb * scale;
}
// -----


/// Encodes the given color to RGBE 8-bit format.
/// \param[in] color    The original color.
/// \return The color encoded as RGBE.
float4 EncodeRgbe(float3 color)
{
	// Get the largest component.
	float maxValue = max(max(color.r, color.g), color.b);

	float exponent = ceil(log2(maxValue));

	float4 result;

	// Store the exponent in the alpha channel.
	result.a = (exponent + 128) / 255;

	// Convert the color channels.
	result.rgb = color / exp2(exponent);

	return result;
}


/// Decodes the given color from RGBE 8-bit format.
/// \param[in] rgbe   The color encoded as RGBE.
/// \return The orginal color.
float3 DecodeRgbe(float4 rgbe)
{
	// Get exponent from alpha channel.
	float exponent = rgbe.a * 255 - 128;

	return rgbe.rgb * exp2(exponent);
}





////////////////////////////////////////////////////////////////////////////////////////////
// RGBM

/// Encodes the given color to RGBM format.
/// \param[in] color    The original color.
/// \param[in] maxValue The max value, e.g. 6 (if color is gamma corrected) =
///                     6 ^ 2.2 (if color is in linear space).
/// \return The color in RGBM format.
/// \remarks
/// The input color can be in linear space or in gamma space. It is recommended
/// convert the color to gamma space before encoding as RGBM.
/// See http://graphicrants.blogspot.com/2009/04/rgbm-color-encoding.html.
float4 EncodeRgbm(float3 color, float maxValue)
{
	float4 rgbm;
	color /= maxValue;
	rgbm.a = saturate(max(max(color.r, color.g), max(color.b, 1e-6)));
	rgbm.a = ceil(rgbm.a * 255.0) / 255.0;
	rgbm.rgb = color / rgbm.a;
	return rgbm;
}


/// Decodes the given color from RGBM format.
/// \param[in] rgbm      The color in RGBM format.
/// \param[in] maxValue  The max value, e.g. 6 (if color is gamma corrected) =
///                      6 ^ 2.2 (if color is in linear space).
/// \return The original RGB color (can be in linear or gamma space).
float3 DecodeRgbm(float4 rgbm, float maxValue)
{
	return maxValue * rgbm.rgb * rgbm.a;
}


#define RgbmMaxValue 3





#endif