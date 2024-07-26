#if !defined(_MATERIALS_SHARED_PLASMA_FXH__)
#define _MATERIALS_SHARED_PLASMA_FXH__


DECLARE_SAMPLER(alpha_mask_map, "Alpha Mask Map", "Alpha Mask Map", "shaders/default_bitmaps/bitmaps/alpha_white.tif")
#include "next_texture.fxh"

DECLARE_SAMPLER(noise_a_map, "Noise Map A", "Noise Map A", "shaders/default_bitmaps/bitmaps/gray_50_percent.tif")
#include "next_texture.fxh"

DECLARE_SAMPLER(noise_b_map, "Noise Map B", "Noise Map B", "shaders/default_bitmaps/bitmaps/gray_50_percent.tif")
#include "next_texture.fxh"

DECLARE_SAMPLER(palette, "Palette", "Palette", "shaders/default_bitmaps/bitmaps/gray_50_percent.tif")
#include "next_texture.fxh"


DECLARE_RGB_COLOR_WITH_DEFAULT(color_medium,		"Color Medium", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(color_medium_alpha,	"Color Medium Alpha", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(color_wide,		"Color Wide", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(color_wide_alpha,		"Color Wide Alpha", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(color_sharp,		"Color Sharp", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(color_sharp_alpha,	"Color Sharp Alpha", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(thinness_medium, 	"Thinness Medium", "", 0, 32, float(16.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(thinness_wide, 	"Thinness Wide", "", 0, 128, float(4.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(thinness_sharp, 	"Thinness Sharp", "", 0, 16, float(32.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(self_illum_color,	"Self Illum Color", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(self_illum_intensity,	"Self Illum Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"


float3 GetPlasmaColor(
	in s_pixel_shader_input pixel_shader_input,
	in float depthFade)
{
	float alpha =	sample2D(alpha_mask_map, transform_texcoord(pixel_shader_input.texcoord.xy, alpha_mask_map_transform)).a;
	float noise_a =	sample2D(noise_a_map, transform_texcoord(pixel_shader_input.texcoord.xy, noise_a_map_transform)).r;
	float noise_b =	sample2D(noise_b_map, transform_texcoord(pixel_shader_input.texcoord.xy, noise_b_map_transform)).r;

	float diff = max(0, 1.0f - abs(noise_a - noise_b));
	float medium_diff = pow(diff, thinness_medium);
	float sharp_diff = pow(diff, thinness_sharp);
	float wide_diff = pow(diff, thinness_wide);

	wide_diff -= medium_diff;
	medium_diff -= sharp_diff;

	float3 plasmaColor = color_medium.rgb * color_medium_alpha * medium_diff 
						+ color_sharp.rgb * color_sharp_alpha * sharp_diff 
						+ color_wide.rgb * color_wide_alpha * wide_diff; 

	return plasmaColor * alpha * self_illum_intensity;
}


float3 GetPlasmaColorPalettized(
	in s_pixel_shader_input pixel_shader_input)
{
	float alpha =	sample2D(alpha_mask_map, transform_texcoord(pixel_shader_input.texcoord.xy, alpha_mask_map_transform)).a;
	float noise_a =	sample2D(noise_a_map, transform_texcoord(pixel_shader_input.texcoord.xy, noise_a_map_transform)).r;
	float noise_b =	sample2D(noise_b_map, transform_texcoord(pixel_shader_input.texcoord.xy, noise_b_map_transform)).r;
	float index =	abs(noise_a - noise_b);

	float2 paletteCoords = transform_texcoord(float2(index, 0), palette_transform);
	float4 paletteValue = sample2D(palette, paletteCoords);

	return paletteValue.rgb * self_illum_color.rgb * self_illum_intensity;
}


#endif  // !defined(_MATERIALS_SHARED_PLASMA_FXH__)