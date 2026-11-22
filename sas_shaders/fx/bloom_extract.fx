// Author: robi
// from mta wiki

float sBloomThreshold = 0.5;
texture sBaseTexture;
texture sLumTexture;

#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture and sampler for the scene luminance texture
//---------------------------------------------------------------------
sampler BaseSampler = sampler_state
{
    Texture = (sBaseTexture);
	AddressU        = Clamp;
    AddressV        = Clamp;
};

sampler LumSampler = sampler_state
{
    Texture = (sLumTexture);
	AddressU        = Clamp;
    AddressV        = Clamp;
};


//---------------------------------------------------------------------
// Structure of data sent to the pixel shader
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
    float lumTexel = tex2D(LumSampler, PS.TexCoord).x;

    float BloomThreshold = saturate(sBloomThreshold + lumTexel * lumTexel);

    float4 base = tex2D(BaseSampler, PS.TexCoord);

    return saturate((base - BloomThreshold) / (1.01 - BloomThreshold));
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