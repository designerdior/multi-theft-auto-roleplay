// Author: robi
// depth buffer

texture gDepthBuffer : DEPTHBUFFER;
matrix gProjectionMainScene : PROJECTION_MAIN_SCENE;
float3 sunColor = float3(1,1,1);
float value = 1.0;
 
sampler SamplerDepth = sampler_state
{
    Texture     = (gDepthBuffer);
    AddressU    = Clamp;
    AddressV    = Clamp;
};
 

struct PSInput
{
	float4 Position : POSITION0;
	float2 TexCoord0 : TEXCOORD0;
};
 

float FetchDepthBufferValue( float2 uv )
{
	float4 texel = tex2D(SamplerDepth, uv);
	#if IS_DEPTHBUFFER_RAWZ
		float3 rawval = floor(255.0 * texel + 0.5);
		float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
		return dot(rawval, valueScaler);
	#else
		return texel.r;
	#endif
}
 

float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}
 

float4 PS_Example( PSInput In ) : COLOR
{
	if (value > 0.1)
	{
		float BufferValue = FetchDepthBufferValue( In.TexCoord0.xy );
		float Depth = Linearize( BufferValue );
		Depth *= 0.005f;
		Depth -= 1.0;
		if (Depth > 1)
			Depth = 1;
		float3 OutColor = Depth;
		OutColor.r *= sunColor.r;
		OutColor.g *= sunColor.g;
		OutColor.b *= sunColor.b;
		return float4(OutColor,1);
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