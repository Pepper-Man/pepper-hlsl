//
// File:	 srf_blinn.fx
// Author:	 hocoulby
// Date:	 06/16/10
//
// Surface Shader - Standard Blinn
//
// Copyright (c) 343 Industries. All rights reserved.
//
// Notes:
//

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

//.. Artistic Parameters

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_SAMPLER( normal_map, "Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"
DECLARE_SAMPLER( specular_map, "Specular Map", "Specular Map", "shaders/default_bitmaps/bitmaps/default_spec.tif");
#include "next_texture.fxh"

// Option to enable alpha-test
DECLARE_BOOL_WITH_DEFAULT(alpha_test_on, "Alpha Test Enabled", "", false);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER( alpha_test_map, "Alpha Test Map", "alpha_test_on", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
// Alpha Test Threshold
DECLARE_FLOAT_WITH_DEFAULT(alpha_test_threshold, "Alpha Test Threshold", "alpha_test_on", 0, 1, float(0.1));
#include "used_float.fxh"

#if defined(REFLECTION) || defined(SELFILLUM)
DECLARE_SAMPLER( control_map_SpGlRf, "Control Map SpGlRf", "Control Map SpGlRf", "shaders/default_bitmaps/bitmaps/default_control.tif")
#include "next_texture.fxh"
#endif

#if defined(SELFILLUM) && defined(SELFILLUM_MOD)
DECLARE_SAMPLER( selfillum_mod_map, "Selfillum Modulate Map", "Selfillum Modulate Map", "shaders/default_bitmaps/bitmaps/default_control.tif")
#include "next_texture.fxh"
#endif

#if defined (SPEC_NORMAL_MAP)
DECLARE_SAMPLER( spec_normal_map, "Spec Normal Map", "Spec Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif" )
#include "next_texture.fxh"
#endif //SPEC_NORMAL_MAP

#if defined(REFLECTION)
DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"
#endif

#if defined(COLOR_DETAIL)
DECLARE_SAMPLER(color_detail_map,		"Color Detail Map", "Color Detail Map", "shaders/default_bitmaps/bitmaps/default_detail.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(detail_alpha_mask_specular, "Detail Alpha Masks Spec", "", 0, 1, float(0.0));
#include "used_float.fxh"
#endif

// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(diffuse_intensity,		"Diffuse Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

// Self Illum
#if defined(SELFILLUM_MAP)
DECLARE_SAMPLER( selfillum_map, "Self-Illum Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"
#endif

#if defined(SELFILLUM) || defined(SELFILLUM_MAP)
DECLARE_RGB_COLOR_WITH_DEFAULT(si_color,	"SelfIllum Color", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_intensity,	"SelfIllum Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_amount,	"SelfIllum Amount", "", 0, 1, float(1.0));
#include "used_float.fxh"

#endif

// 3-Channel Self Illum
#if defined(SELFILLUM_3C)
DECLARE_SAMPLER( selfillum_map_3c, "Self-Illum Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(si_color_r,	"Channel A Color", "", float3(1,0,0));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_alpha_r,	"Channel A Alpha", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(si_color_g,	"Channel B Color", "", float3(1,0,0));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_alpha_g,	"Channel B Alpha", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(si_color_b,	"Channel C Color", "", float3(1,0,0));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_alpha_b,	"Channel C Alpha", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_intensity_3c,	"SelfIllum Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
#endif

// Self Illum Detail
#if defined(SELFILLUM_MAP) || defined(SELFILLUM_3C)
DECLARE_BOOL_WITH_DEFAULT(illum_detail_on, "Self Illum Detail Enabled", "Self Illum Detail Enabled", false);
#include "next_bool_parameter.fxh"
DECLARE_SAMPLER(selfillum_detail_map, "Self-Illum Detail Map", "illum_detail_on", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"
#endif


#if defined(REFLECTION)
DECLARE_FLOAT_WITH_DEFAULT(diffuse_mask_reflection,	"Diffuse Mask Reflection", "", 0, 1, float(1.0));
#include "used_float.fxh"
#endif

DECLARE_FLOAT_WITH_DEFAULT(diffuse_alpha_mask_specular, "Diffuse Alpha Masks Specular", "", 0, 1, float(0.0));
#include "used_float.fxh"

// Specular
DECLARE_RGB_COLOR_WITH_DEFAULT(specular_color,		"Specular Color", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_intensity,		"Specular Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_power_min,		"Specular Power White", "", 0, 1, float(0.01));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_power_max,		"Specular Power Black", "", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_mix_albedo,		"Specular Mix Albedo", "", 0, 1, float(0.0));
#include "used_float.fxh"

#if defined(TWO_TONE_SPECULAR)
// Glancing specular
DECLARE_RGB_COLOR_WITH_DEFAULT(glancing_specular_color,"Glancing Specular Color", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnel_power,			"Fresnel Power", "", 0, 10, float(5.0));
#include "used_float.fxh"
#endif

#if defined(REFLECTION)
// Reflection
DECLARE_RGB_COLOR_WITH_DEFAULT(reflection_color,	"Reflection Color", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity,		"Reflection Intensity", "", 0, 1, float(0.8));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(reflection_normal,		"Reflection Normal", "", 0, 1, float(0.0));
#include "used_float.fxh"

// Fresnel
DECLARE_FLOAT_WITH_DEFAULT(fresnel_intensity,		"Fresnel Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

#if !defined(TWO_TONE_SPECULAR)
DECLARE_FLOAT_WITH_DEFAULT(fresnel_power,			"Fresnel Power", "", 0, 10, float(3.0));
#include "used_float.fxh"
#endif

DECLARE_FLOAT_WITH_DEFAULT(fresnel_mask_reflection,	"Fresnel Mask Reflection", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnel_inv,				"Fresnel Invert", "", 0, 1, float(1.0));
#include "used_float.fxh"
#endif

// Detail Normal Map
DECLARE_BOOL_WITH_DEFAULT(detail_normals, "Detail Normals Enabled", "", true);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(normal_detail_map,		"Detail Normal Map", "detail_normals", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(normal_detail_dist_max,	"Detail Start Dist.", "detail_normals", 0, 1, float(5.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(normal_detail_dist_min, 	"Detail End Dist.", "detail_normals", 0, 1, float(1.0));
#include "used_float.fxh"

#if defined(PRIMARY_CHANGE_COLOR)
DECLARE_FLOAT_WITH_DEFAULT(pcc_amount, "Primary Change Color Amount", "", 0, 1, float(0.0));
#include "used_float.fxh"
#endif

#if defined(PRIMARY_CHANGE_COLOR_MAP)
DECLARE_SAMPLER(pcc_amount_map,		"Color Change Map", "", "shaders/default_bitmaps/bitmaps/default_monochrome.tif");
#include "next_texture.fxh"
#endif

// vertex occlusion
DECLARE_FLOAT_WITH_DEFAULT(vert_occlusion_amt,  "Vertex Occlusion Amount", "", 0, 1, float(0.0));
#include "used_float.fxh"

// diffuse fill lighting control
#if defined(USE_DIFFUSE_FILL)
	DECLARE_FLOAT_WITH_DEFAULT(direct_fill_int,  "Direct Fill Intensity", "", 0, 1, float(0.15));
	#include "used_float.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(indirect_fill_int, "Indirect Fill Intensity", "", 0, 1, float(0.15));
	#include "used_float.fxh"
#endif

#if defined(ALPHA_CLIP)
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
#endif

///
#if defined(ALPHA_CLIP) && !defined(ALPHA_CLIP_ALBEDO_ONLY)
DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"
#elif defined(ALPHA_CLIP)
static const float clip_threshold = 240.0f / 255.0f;
#endif

#if defined(PLASMA)
#include "shared/plasma.fxh"
#endif

struct s_shader_data {
	s_common_shader_data common;

    float  alpha;
};



void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;

	if (alpha_test_on)
	{
		// Sample the alpha test texture
		float2 alpha_test_transformed_uv = transform_texcoord(uv, alpha_test_map_transform);
		float alpha_test_value = sample2DGamma(alpha_test_map, alpha_test_transformed_uv).a;

		// Perform alpha test
		if (alpha_test_value < alpha_test_threshold)
		{
			discard; // Discard the pixel if alpha is below the threshold
		}
	}


	float2 color_detail_uv   = pixel_shader_input.texcoord.xy;
#if defined(COLOR_DETAIL_UV2)
		color_detail_uv = pixel_shader_input.texcoord.zw;
#endif



	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	// Calculate the normal map value
    {
		// Sample normal maps
    	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
        float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);

		STATIC_BRANCH
		if (detail_normals)
		{
			// Composite detail normal map onto the base normal map
			float2 detail_uv = pixel_shader_input.texcoord.xy;
			#if defined(NORMAL_DETAIL_UV2)
				detail_uv =  pixel_shader_input.texcoord.zw;
			#endif
			
			detail_uv = transform_texcoord(detail_uv, normal_detail_map_transform);
			
			shader_data.common.normal = CompositeDetailNormalMap(shader_data.common,
																 base_normal,
																 normal_detail_map,
																 detail_uv,
																 normal_detail_dist_min,
																 normal_detail_dist_max);
		}
		else
		{
			// Use the base normal map
			shader_data.common.normal = base_normal;
		}

		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }



    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);

#if defined(PRIMARY_CHANGE_COLOR) || defined (PRIMARY_CHANGE_COLOR_MAP)
        // apply primary change color
        float4 primary_cc = ps_material_object_parameters[0];
        float albedo_lum = color_luminance(shader_data.common.albedo.rgb);

#if defined (PRIMARY_CHANGE_COLOR_MAP)
    	float2 pcc_amount_map_uv   = transform_texcoord(uv, pcc_amount_map_transform);
        float pcc_amount = sample2D(pcc_amount_map, pcc_amount_map_uv).r;

#if !defined(REFLECTION) && defined(SELFILLUM)
		shader_data.common.shaderValues.y = pcc_amount;//this is not compatible with reflection.
#endif

#endif

        shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb,
                                             albedo_lum * primary_cc.rgb,
                                             primary_cc.a * pcc_amount);
#endif

#if defined(COLOR_DETAIL)

		const float DETAIL_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)

	    float2 color_detail_map_uv = transform_texcoord(color_detail_uv, color_detail_map_transform);
	    float4 color_detail = sample2DGamma(color_detail_map, color_detail_map_uv);
	    color_detail.rgb *= DETAIL_MULTIPLIER;

		shader_data.common.albedo.rgb *= color_detail;
		shader_data.common.shaderValues.x *= shader_data.common.albedo.w;

		// specular detail mask in alpha, artist weighted influence.
		float specularMask = lerp(1.0f, color_detail.a, detail_alpha_mask_specular);
		shader_data.common.shaderValues.x *= specularMask;

#else

		float specularMask = lerp(1.0f, shader_data.common.albedo.w, diffuse_alpha_mask_specular);
		shader_data.common.shaderValues.x *= specularMask;

#endif

#if defined(FIXED_ALPHA)
        float2 alpha_uv		= uv;
		shader_data.alpha	= sample2DGamma(color_map, alpha_uv).a;
#else
        shader_data.alpha	= shader_data.common.albedo.a;
#endif

#if defined(VERTEX_ALPHA)
		shader_data.alpha *= shader_data.common.vertexColor.a;
#endif

#if defined(ALPHA_CLIP) && defined(ALPHA_CLIP_ALBEDO_ONLY)
		// Tex kill non-opaque pixels in albedo pass; tex kill opaque pixels in all other passes
		if (shader_data.common.shaderPass != SP_SINGLE_PASS_LIGHTING)
		{
			// Clip anything that is less than white in the alpha
			clip(shader_data.alpha - clip_threshold);
		}
		else
		{
			// Reverse the order, so anything larger than the near-white threshold is clipped
			clip(clip_threshold - shader_data.alpha);
		}
#elif defined(ALPHA_CLIP)
		// Tex kill pixel
		clip(shader_data.alpha - clip_threshold);
#endif


		shader_data.common.albedo.rgb *= albedo_tint;
        shader_data.common.albedo.a = shader_data.alpha;

#if defined(REFLECTION)
		float fresnel = 0.0f;
		{ // Compute fresnel to modulate reflection
			float3 view = -shader_data.common.view_dir_distance.xyz;
			float  vdotn = saturate(dot(view, shader_data.common.normal));
			fresnel = vdotn + fresnel_inv - 2 * fresnel_inv * vdotn;	// equivalent to lerp(vdotn, 1 - vdotn, fresnel_inv);
			fresnel = pow(fresnel, fresnel_power) * fresnel_intensity;
		}

		// Fresnel mask for reflection
		shader_data.common.shaderValues.y = lerp(1.0, fresnel, fresnel_mask_reflection);
#endif

		// Bake the vertex ambient occlusion amount into scaling parameters for lighting components
		float vertOcclusion = lerp(1.0f, shader_data.common.vertexColor.a, vert_occlusion_amt);

		shader_data.common.albedo.rgb *= vertOcclusion;				// albedo * vertex occlusion
		shader_data.common.shaderValues.x *= vertOcclusion;			// specular mask * vertex occlusion
#if defined(REFLECTION)
		shader_data.common.shaderValues.y *= vertOcclusion;			// reflection mask * vertex occlusion
#endif
	}
}



float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;

	if (alpha_test_on)
	{
		// Sample the alpha test texture
		float2 alpha_test_transformed_uv = transform_texcoord(uv, alpha_test_map_transform);
		float alpha_test_value = sample2DGamma(alpha_test_map, alpha_test_transformed_uv).a;

		// Perform alpha test
		if (alpha_test_value < alpha_test_threshold)
		{
			discard; // Discard the pixel if alpha is below the threshold
		}
	}


    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;

	// Sample specular map
	float2 specular_map_uv	= transform_texcoord(uv, specular_map_transform);
	float4 specular_mask 	= sample2DGamma(specular_map, specular_map_uv);

	// Apply the specular mask from the albedo pass
	specular_mask.rgb *= shader_data.common.shaderValues.x;

#if defined(REFLECTION) || defined(SELFILLUM)

	// Sample control mask
	float2 control_map_uv	= transform_texcoord(uv, control_map_SpGlRf_transform);
	float4 control_mask		= sample2DGamma(control_map_SpGlRf, control_map_uv);

	specular_mask.rgb *= control_mask.r;
    specular_mask.a  = control_mask.g;

	// Multiply the control mask by the reflection fresnel multiplier (calculated in albedo pass)
	float reflectionMask = shader_data.common.shaderValues.y * control_mask.b;

#endif

#if defined(SPEC_NORMAL_MAP)
	//Sample the spec/reflect only normal map.
	float3 specNormalMod = sample2DVector(spec_normal_map, transform_texcoord(uv, spec_normal_map_transform));
#endif

    float3 specular = 0.0f;

	{ // Compute Specular
		float3 specNormal = normal;

#if defined(SPEC_NORMAL_MAP)
		//Apply the spec only normal map to the supplied normal.
		specNormal.xy = specNormal.xy  + specNormalMod.xy;
		specNormal.z = sqrt(saturate(1.0f + dot(specNormal.xy, -specNormal.xy)));
#endif

        // pre-computing roughness with independent control over white and black point in gloss map
        float power = calc_roughness(specular_mask.a, specular_power_min, specular_power_max );

	    // using blinn specular model
    	calc_specular_blinn(specular, shader_data.common, specNormal, albedo.a, power);

#if defined(TWO_TONE_SPECULAR)
        // Use the view angle to mix the two specular colors, as well as the albedo color
        float3 specular_col = CalcSpecularColor(
        	-shader_data.common.view_dir_distance.xyz,
        	specNormal,
        	albedo.rgb,
        	specular_mix_albedo,
        	specular_color,
        	glancing_specular_color,
        	fresnel_power);
#else
        // mix specular_color with albedo_color
        float3 specular_col = lerp(specular_color, albedo.rgb, specular_mix_albedo);
#endif

        // modulate by mask, color, and intensity
        specular *= specular_mask.rgb * specular_col * specular_intensity;
	}


    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;

	{ // Compute Diffuse

        #if defined(USE_DIFFUSE_FILL)
            calc_diffuse_lambert_fill(
                        diffuse,
                        shader_data.common,
                        normal,
                        direct_fill_int,
                        indirect_fill_int);
        #else
            // using standard lambert model
            calc_diffuse_lambert(diffuse, shader_data.common, normal);
        #endif

		// Store the mask for diffuse reflection
        diffuse_reflection_mask = diffuse;

        // modulate by albedo, color, and intensity
    	diffuse *= albedo.rgb * diffuse_intensity;
    }

#if defined(REFLECTION)
	float3 reflection = 0.0f;
	if (AllowReflection(shader_data.common))
	{
		// sample reflection
		float3 view = shader_data.common.view_dir_distance.xyz;
		float3 rNormal = lerp(shader_data.common.geometricNormal, shader_data.common.normal, reflection_normal);

#if defined(SPEC_NORMAL_MAP)
		//Apply the spec only normal map to the reflections normal.
		rNormal.xy = rNormal.xy  + specNormalMod.xy;
		rNormal.z = sqrt(saturate(1.0f + dot(rNormal.xy, -rNormal.xy)));
#endif

		float3 rVec = reflect(view, rNormal);
		float4 reflectionMap = sampleCUBEGamma(reflection_map, rVec);

		reflection =
			reflectionMap.rgb *							// reflection cube sample
			reflection_color *							// RGB reflection color from material
			reflection_intensity *						// scalar reflection intensity from material
			reflectionMask *							// control mask reflection intensity channel * fresnel intensity
			reflectionMap.a;							// intensity scalar from reflection cube

		reflection = lerp(reflection, reflection * diffuse_reflection_mask, diffuse_mask_reflection);
	}
#endif


	//.. Finalize Output Color
    float4 out_color;
	out_color.rgb = diffuse + specular;
	out_color.a   = shader_data.alpha;

#if defined(REFLECTION)
	out_color.rgb += reflection;
#endif


#if defined(SELFILLUM)
	// self illum
	if (AllowSelfIllum(shader_data.common))
	{

		#if defined(SELFILLUM_MOD)
			// texture parameter that modulates the existing emissive component from the control map
			float2 selfillum_mod_uv	= transform_texcoord(uv, selfillum_mod_map_transform);
			float4 selfillum_mod		= sample2DGamma(selfillum_mod_map, selfillum_mod_uv);
			control_mask.a *= selfillum_mod;
		#endif

#if defined(PRIMARY_CHANGE_COLOR_MAP) //if we have a color change map, allow it to effect the color of the self illum map, fakes team colored glows/lights.
        float4 primary_cc = ps_material_object_parameters[0];

#if !defined(REFLECTION)
		float pcc_amount = shader_data.common.shaderValues.y;
#else
		float2 pcc_amount_map_uv  = transform_texcoord(uv, pcc_amount_map_transform);//If we are already using the shaderValues for reflection we will need to sample this texture again.
        float pcc_amount = sample2D(pcc_amount_map, pcc_amount_map_uv).r;
#endif

		float3 selfIllumeColor = lerp( si_color, primary_cc, pcc_amount );
		float3 selfIllum = albedo.rgb * selfIllumeColor * si_intensity * control_mask.a;
#else
		float3 selfIllum = albedo.rgb * si_color * si_intensity * control_mask.a;
#endif
		float3 si_out_color = out_color.rgb + selfIllum;
		float3 si_no_color  = out_color.rgb * (1-control_mask.a);

		out_color.rgb = lerp(si_no_color, si_out_color, min(1, si_amount));


		// Output self-illum intensity as linear luminance of the added value
		shader_data.common.selfIllumIntensity = GetLinearColorIntensity(selfIllum);
	}
#endif

#if defined(SELFILLUM_MAP)
    // self illum
    if (AllowSelfIllum(shader_data.common))
    {
        // Sample self-illumination texture
        float2 self_illum_uv = transform_texcoord(uv, selfillum_map_transform);
        float3 self_illum = sample2DGamma(selfillum_map, self_illum_uv).rgb;

		if (illum_detail_on)
		{
			// Sample self-illumination detail texture
			float2 self_illum_detail_uv = transform_texcoord(uv, selfillum_detail_map_transform);
        	float3 self_illum_detail = sample2DGamma(selfillum_detail_map, self_illum_detail_uv).rgb;

			self_illum = self_illum * self_illum_detail;
		}
		

        #if defined(PRIMARY_CHANGE_COLOR_MAP) // if we have a color change map, allow it to affect the color of the self-illum map, fakes team-colored glows/lights.
            float4 primary_cc = ps_material_object_parameters[0];

            #if !defined(REFLECTION)
                float pcc_amount = shader_data.common.shaderValues.y;
            #else
                float2 pcc_amount_map_uv = transform_texcoord(uv, pcc_amount_map_transform); // If we are already using the shaderValues for reflection we will need to sample this texture again.
                float pcc_amount = sample2D(pcc_amount_map, pcc_amount_map_uv).r;
            #endif

            float3 selfIllumeColor = lerp(si_color, primary_cc, pcc_amount);
            float3 selfIllum = self_illum * selfIllumeColor * si_intensity;
        #else
            float3 selfIllum = self_illum * si_color * si_intensity;
        #endif
        
        float3 si_out_color = out_color.rgb + selfIllum;
        float3 si_no_color = out_color.rgb;

        out_color.rgb = lerp(si_no_color, si_out_color, min(1, si_amount));

        // Output self-illum intensity as linear luminance of the added value
        shader_data.common.selfIllumIntensity = GetLinearColorIntensity(selfIllum);
    }
#endif

#if defined(SELFILLUM_3C)
	// 3-Channel Self Illum
    if (AllowSelfIllum(shader_data.common))
    {
		// Sample self-illumination texture
    	float2 self_illum_3c_uv = transform_texcoord(uv, selfillum_map_3c_transform);
        float3 self_illum_3c = sample2DGamma(selfillum_map_3c, self_illum_3c_uv).rgb;

		if (illum_detail_on)
        {
            // Sample self-illumination detail texture
            float2 self_illum_detail_uv = transform_texcoord(uv, selfillum_detail_map_transform);
            float3 self_illum_detail = sample2DGamma(selfillum_detail_map, self_illum_detail_uv).rgb;

            self_illum_3c = self_illum_3c * self_illum_detail;
        }

		// Apply different colors to each channel
        float3 selfIllum_3c = float3(0, 0, 0);
        selfIllum_3c += self_illum_3c.r * si_color_r * si_intensity_3c * si_alpha_r;
        selfIllum_3c += self_illum_3c.g * si_color_g * si_intensity_3c * si_alpha_g;
        selfIllum_3c += self_illum_3c.b * si_color_b * si_intensity_3c * si_alpha_b;

        out_color.rgb += selfIllum_3c;

		// Output self-illum intensity as linear luminance of the added value
        shader_data.common.selfIllumIntensity = GetLinearColorIntensity(selfIllum_3c);
	}
#endif

#if defined(PLASMA)
	out_color.rgb += GetPlasmaColor(pixel_shader_input, 0.0f);
#endif

	return out_color;
}


#include "techniques.fxh"