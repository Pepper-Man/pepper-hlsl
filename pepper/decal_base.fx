//
// File:	 decals/base.fx
// Author:	 aluedke
// Date:	 03/21/11
//
// Copyright (c) 343 Industries. All rights reserved.
//
// Notes:
//

#define DISABLE_VERTEX_COLOR

#if !defined(FORGE_HOTNESS)
#define DISABLE_VIEW_VECTOR
#endif

#define DECAL_OUTPUT_COLOR
#define PEPPER_DECAL_TINT

#if !defined(DECAL_OUTPUT_NORMAL)
#define DISABLE_NORMAL
#define DISABLE_TANGENT_FRAME
#endif

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

//.. Artistic Parameters

#if defined(DECAL_OUTPUT_COLOR)

DECLARE_SAMPLER(color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"

#if defined(DECAL_ALPHA_MAP)
DECLARE_SAMPLER(alpha_map, "Alpha Map", "Alpha Map", "shaders/default_bitmaps/bitmaps/alpha_grey50.tif")
#include "next_texture.fxh"
#endif

#if defined(VECTOR_ALPHA_MAP)
DECLARE_SAMPLER(vector_map, "Vector Map", "Vector Map", "shaders/default_bitmaps/bitmaps/reference_grids.tif")
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(vector_sharpness, 		"Vector Sharpness", "", 0, 2000, float(1000));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(antialias_tweak,	 		"Antialias Tweak", "", 0, 1, float(0.025));
#include "used_float.fxh"

#endif

#if defined(DECAL_PALETTIZED)
DECLARE_SAMPLER(palette_map, "Palette Map", "Palette Map", "shaders/default_bitmaps/bitmaps/gray_50_percent.tif")
#include "next_texture.fxh"
#endif

#endif

#if defined(DECAL_OUTPUT_NORMAL)
DECLARE_SAMPLER(normal_map, "Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"
#endif

DECLARE_RGB_COLOR_WITH_DEFAULT(tint_color, "Tint Color", "", float3(1, 1, 1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(tint_intensity,	"Tint Intensity", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(tint_modulation_factor,	"Tint Modulation Factor", "", 0, 1, float(1.0));
#include "used_float.fxh"

#if defined(DECAL_GRADIENT_MODULATED_TINT)
DECLARE_SAMPLER(gradient_map, "Gradient Map", "Gradient Map", "shaders/default_bitmaps/bitmaps/gradient_white_to_black.tif");
#include "next_texture.fxh"
#endif

#if defined(FORGE_HOTNESS)
DECLARE_SAMPLER(forge_gradient_map, "Forge Gradient", "Forge Gradient", "shaders/default_bitmaps/bitmaps/gradient_white_to_black.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(forge_gradient_v, "Gradient V Coordinate", "Gradient V Coordinate", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(forge_gradient_power, "Gradient Power", "Gradient Power", 0, 10, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(forge_gradient_intensity, "Gradient Intensity", "Gradient Intensity", 0, 10, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(forge_gradient_tint_factor, "Gradient Tint Factor", "Gradient Tint Factor", 0, 1, float(0.5));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fresnel_mask_power, "Fresnel Mask Power", "Fresnel Mask Power", 0, 10, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnel_mask_intensity, "Fresnel Mask Intensity", "Fresnel Mask Intensity", 0, 1, float(0.0));
#include "used_float.fxh"
#endif

struct s_shader_data {
    s_common_shader_data common;
};

#if defined(VECTOR_ALPHA_MAP)
float GetVectorAlpha(float2 texCoord) {
    float vector_distance = sample2D(vector_map, texCoord).g;
    
    float scale = antialias_tweak;
#if defined(xenon)
    float4 gradients;
    asm {
        getGradients gradients, texCoord, vector_map
    };
    scale /= sqrt(dot(gradients.xyzw, gradients.xyzw));
#else	// defined(xenon)
    scale /= 0.001f;
#endif	// defined(xenon)
    
    scale = max(scale, 1.0f);		// scales smaller than 1.0 result in '100% transparent' areas appearing as semi-opaque
    
    return saturate((vector_distance - 0.5f) * min(scale, vector_sharpness) + 0.5f);
}
#endif

void pixel_pre_lighting(
    in s_pixel_shader_input pixel_shader_input,
    inout s_shader_data shader_data)
{
    float2 uv = pixel_shader_input.texcoord.xy;

    #if defined(DECAL_OUTPUT_COLOR)
    {
        // Sample color map.
        float2 color_map_uv = transform_texcoord(uv, color_map_transform);
        shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);

        #if defined(DECAL_ALPHA_MAP)
            #if !defined(DECAL_PALETTIZED)
            	float2 alpha_map_uv = transform_texcoord(uv, alpha_map_transform);
            #else
            	float2 alpha_map_uv = color_map_uv;
            #endif
            shader_data.common.albedo.w = sample2D(alpha_map, alpha_map_uv).w;
        #endif

        #if defined(DECAL_PALETTIZED)
        	float2 palette_uv = float2(shader_data.common.albedo.x, 0.0f);
        	shader_data.common.albedo.rgb = sample2D(palette_map, palette_uv).rgb;
        #endif

        #if defined(VECTOR_ALPHA_MAP)
        	float vectorAlpha = GetVectorAlpha(uv);            // vector alpha uses the unmodified decal UV
        	shader_data.common.albedo.rgb *= vectorAlpha;      // vector alpha modulated on color
        	shader_data.common.albedo.w = vectorAlpha;
        #endif
    }
    #endif

    #if defined(DECAL_OUTPUT_NORMAL)
    {
        // Sample normal map.
        float2 normal_map_uv = transform_texcoord(uv, normal_map_transform);
        shader_data.common.normal = sample_2d_normal_approx(normal_map, normal_map_uv);
        shader_data.common.normal = normalize(mul(shader_data.common.normal, shader_data.common.tangent_frame));
    }
    #endif

    #if defined(DECAL_UNMODULATED_TINT)
    shader_data.common.albedo.rgb *= pixel_shader_input.texcoord.z * tint_color.rgb;
    #elif defined(DECAL_MODULATED_TINT)
    // float modulationValue = length(shader_data.common.albedo.rgb) / 1.7320508f; // sqrt(3)
    shader_data.common.albedo.rgb *= pixel_shader_input.texcoord.z; // lerp(tint_color.xyz, 1.0f, tint_modulation_factor) * modulationValue * tint_intensity;
    #elif defined(DECAL_GRADIENT_MODULATED_TINT)
    float2 sampleCoords = float2(pixel_shader_input.texcoord.z, 0.5f);
    shader_data.common.albedo *= sample2D(gradient_map, sampleCoords);
    #elif defined(PEPPER_DECAL_TINT)
    float3 modulated_tint_color = lerp(float3(1.0, 1.0, 1.0), tint_color.rgb, tint_modulation_factor);
    shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, 
                                     shader_data.common.albedo.rgb * modulated_tint_color, 
                                     tint_intensity);
    #endif

    #if defined(FORGE_HOTNESS)
    // Do the hotness, primarily used for the forge selection tint material
    float dot_lookup = 0.0f;
    float fresnel_mask = 1.0f;
    {
        float3 view = -shader_data.common.view_dir_distance.xyz;
        float3 n = normalize(shader_data.common.normal);
        float view_dot_n = dot(view, n);

        dot_lookup = 1.0 - saturate(pow(view_dot_n, forge_gradient_power));
        fresnel_mask = lerp(1.0, pow(dot_lookup, fresnel_mask_power), fresnel_mask_intensity);
    }

    float4 dot_sample = (float4)1;
    dot_sample.rgb = sample2D(forge_gradient_map, float2(dot_lookup, forge_gradient_v)).rgb *
                     forge_gradient_intensity *
                     lerp((float3)1, tint_color, forge_gradient_tint_factor);

    shader_data.common.albedo = (shader_data.common.albedo + dot_sample) * fresnel_mask;

    // Respect vertex alpha
    shader_data.common.albedo.a *= shader_data.common.vertexColor.a;
    #endif
}


float4 pixel_lighting(
    in s_pixel_shader_input pixelShaderInput,
    inout s_shader_data shader_data) {
    // input from shader_data 
    // Make sure the alpha is handled correctly
    shader_data.common.albedo.w = max(shader_data.common.albedo.w, 0.01f); // Ensure non-zero alpha
    return shader_data.common.albedo;
}

#include "techniques_decals.fxh"