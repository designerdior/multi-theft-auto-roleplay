// Author: robi
// from mta wiki

float sMultAmount = 0.5;
float sMult = 0.5;
float sAdd = 0.5;
texture sBaseTexture;
float sExtraFrom = 0.08;
float sExtraTo = 0.59;
float sExtraMult = 1;
texture sLumTexture;

#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture and sampler for the scene luminance texture
//---------------------------------------------------------------------
sampler BaseSampler = sampler_state
{
    Texture = (sBaseTexture);
};

sampler LumSampler = sampler_state
{
    Texture = (sLumTexture);
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
	
    float lumNormalized = saturate( MTAUnlerp( sExtraTo, sExtraFrom, lumTexel ) );
    float Mult = lerp( sMult, sExtraMult, lumNormalized );

    float4 base = tex2D(BaseSampler, PS.TexCoord);

    float4 grey = float4(0.5, 0.5, 0.5, 0.5);
    float4 result = base * lerp(grey,base,sMultAmount) * Mult + sAdd;

    result.a = 1;
    return result;
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