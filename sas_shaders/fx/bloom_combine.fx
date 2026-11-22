// Author: robi
// from mta wiki

float sBloomIntensity = 0.5;
float sBloomSaturation = 0.5;
float sBaseIntensity = 0.5;
float sBaseSaturation = 0.5;
texture sBaseTexture;
texture sBloomTexture;

#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture and sampler for the other texture
//---------------------------------------------------------------------
sampler BaseSampler = sampler_state
{
    Texture = (sBaseTexture);
	AddressU = Clamp;
    AddressV = Clamp;
};

sampler BloomSampler = sampler_state
{
    Texture = (sBloomTexture);
	AddressU = Clamp;
    AddressV = Clamp;
};


//---------------------------------------------------------------------
// Helper for modifying the saturation of a color.
//---------------------------------------------------------------------
float4 AdjustSaturation(float4 color, float saturation)
{
    float grey = dot(color, float3(0.3, 0.59, 0.11));
    return lerp(grey, color, saturation);
}


//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
	float4 Position : POSITION0;
	float2 TexCoord : TEXCOORD0;
};


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 bloom = tex2D(BloomSampler, PS.TexCoord);
    float4 base = tex2D(BaseSampler, PS.TexCoord);

    bloom = AdjustSaturation(bloom, sBloomSaturation) * sBloomIntensity;
    base = AdjustSaturation(base, sBaseSaturation) * sBaseIntensity;

	base *= (1 - saturate(bloom));

    return base + bloom;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback
{
    pass P0
    {
    }
}