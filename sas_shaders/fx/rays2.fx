// Author: robi
// rays

texture TEX0;
float3 sunPos = float3(0,0,0);
float value = 1.0;
float range = -0.3;

#include "mta-helper.fx"


sampler s0 = sampler_state
{
    Texture     = (TEX0);
	AddressU    = Clamp;
    AddressV    = Clamp;
};


struct PSInput
{
	float4 Position : POSITION0;
	float2 TexCoord0 : TEXCOORD0;
};


float4 PS_Example( PSInput PS ) : COLOR
{
	if (value > 0.1)
	{
		float2 dir = (0.5 - PS.TexCoord0) * sunPos.y + sunPos.xz;

		float camera = MTAUnlerp(range, -1.0, sunPos.y);
		if (camera > 1)
			camera = 1;
		else if (camera < 0)
			camera = 0;

		float4 godRays1 = 0;
		float weightTotal = 0;
		for (int i = 0; i < 25; i++)
		{
			float weight = 1 - (i / 10000.0);
			float s = 0.01 + i * 0.005 + i*i*0.0002;
			godRays1 += tex2D(s0, PS.TexCoord0 - dir * s * 0.2) * weight;
			weightTotal += weight;
		} 
		godRays1 /= weightTotal;
		godRays1 *= 0.3 * value * camera;
		return godRays1;
	}
	return float4(0,0,0,0);
}


technique yes_effect
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PS_Example();
    }
}

technique no_effect
{
    pass P0
    {
    }
}