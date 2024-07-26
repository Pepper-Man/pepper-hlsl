//
// File:	 srf_plasma.fx
// Author:	 aluedke
// Date:	 03/08/12
//
// Surface Shader - Constant illumination model with the plasma effect
//
// Copyright (c) 343 Industries. All rights reserved.
//
//

#define DISABLE_NORMAL
#define DISABLE_TANGENT_FRAME
#define ENABLE_DEPTH_INTERPOLATER
#define DISABLE_VERTEX_COLOR

#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


#include "depth_fade.fxh"
#include "plasma_reach.fxh"



struct s_shader_data
{
	s_common_shader_data common;
};


void pixel_pre_lighting(
		in s_pixel_shader_input pixel_shader_input,
		inout s_shader_data shader_data)
{
}

float4 pixel_lighting(
	in s_pixel_shader_input pixel_shader_input,
	inout s_shader_data shader_data)
{
	float depthFade = 1.0f;

#if defined(xenon)
	float2 vPos = shader_data.common.platform_input.fragment_position.xy;
	depthFade = ComputeDepthFade(vPos * psDepthConstants.z, pixel_shader_input.view_vector.w); // stored depth in the view_vector w
#endif

	shader_data.common.selfIllumIntensity = self_illum_intensity;

#if defined(PLASMA_PALETTIZED)
	return float4(GetPlasmaColorPalettized(pixel_shader_input), 1.0f);
#else
	return float4(GetPlasmaColor(pixel_shader_input, depthFade), 1.0f);
#endif
}


#include "techniques.fxh"
