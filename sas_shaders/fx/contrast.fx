// Author: robi
// from mta wiki

float sBrightness = 0.5;
float sContrast = 0.5;
texture sBaseTexture;

//#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (sBaseTexture);
};


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(float2 uv : TEXCOORD0) : COLOR0
{
	float4 Color;
	Color = tex2D(Sampler0, uv.xy);
	Color.rgb /= Color.a;
    Color.rgb = ((Color.rgb - 0.5f) * max(sContrast, 0)) + 0.5f;
    Color.rgb += sBrightness;
    Color.rgb *= Color.a;
    return Color; 
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