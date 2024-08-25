# Pepper-HLSL
A collection of modified HLSL source files that add various shader features and functionality, generally those present in previous engines but missing in H4/2AMP.
**Only for H4EK or H2AMPEK**

# Current features
- Alpha Test from opacity texture with test strength slider
- Self illumination from RGB texture with colour and strength modifiers
- Self illumination detail texture support (multiplied over base self-illum)
- Bungie-style 3-channel self illumination
- Bungie-style "plasma" self illumination (alpha mask, 2x noise maps)
- Simple parallax from height map
- Decals with optional alpha map and normal/bump map
- Reach-style decal tinting with intensity and modulation sliders

# Usage
- Download the full shader source for either [Halo 4](https://github.com/halohlsl/Halo4-Shader-Source) or [Halo 2AMP](https://github.com/halohlsl/Halo2AMP-Shader-Source) depending on the engine you are using.
- Extract the zip to `"data\shaders\material_shaders"`, such that you have `"data\shaders\material_shaders\decals"`, `"data\shaders\material_shaders\explicit_shaders"` etc.
- Place the `pepper` folder from this repo into `"data\shaders\material_shaders"`.
- Run the tool command `tool material-shaders no_durango bank pepper` to compile. Should only take about 10-15 seconds.
- You can now switch the shader template in your materials to one of the custom ones, located in `"tags\shaders\materials_shaders\pepper"`.

# Legal Disclaimer
- All original shader source code downloaded from [the halohlsl repository](https://github.com/halohlsl), extracted from the publicly available Editing Kit(s)
- All original shader source code is property/copyright of 343 Industries/Certain Affinity, I own nothing. See file headers

# Credits
- TheHostileNegotiator for answering my many questions about HLSL and for the parallax code.