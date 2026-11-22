// Author: robi

texture PixelShadTexture; 

sampler screenSampler = sampler_state
{
	Texture = <PixelShadTexture>;
};

float4 main(float2 uv : TEXCOORD0) : COLOR0 
{ 
    float4 Color; 
	Color = tex2D( screenSampler, uv.xy);
	float value = (Color.r + Color.g + Color.b) / 3;
	if (value > Color.r)
		Color.r = value;
	Color.g = value;
	Color.b = value;
    return Color; 
};

technique PixelShad
{
	pass P1
	{
		PixelShader = compile ps_2_0 main();
	}
}

technique fallback
{
    pass P1
    {
    }
}