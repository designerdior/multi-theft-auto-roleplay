// Author: robi
// from mta wiki

texture sDetailTexture;
float sDetailScale = 4;
float sFadeStart = 60;
float sFadeEnd = 100;
float sStrength = 0.5;
texture sReflectionTexture;
texture sRandomTexture;
float4 sValue = float4(0.12, 0.8, 0.4, 90);
bool g_bRainy;
int gCapsMaxAnisotropy                      < string deviceCaps="MaxAnisotropy"; >; 

#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture and sampler for the detail texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy;
    MinFilter = Anisotropic;
};

sampler SamplerDetail = sampler_state
{
    Texture = (sDetailTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy;
    MinFilter = Anisotropic;
};

sampler3D RandomSampler = sampler_state
{
   Texture = (sRandomTexture);
   MipFilter = Anisotropic;
   MaxAnisotropy = gCapsMaxAnisotropy;
   MinFilter = Anisotropic;
};

samplerCUBE ReflectionSampler = sampler_state
{
   Texture = (sReflectionTexture);
   MipFilter = Anisotropic;
   MaxAnisotropy = gCapsMaxAnisotropy;
   MinFilter = Anisotropic; 
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VertexShaderInput
{
	float3 Position : POSITION0;
	float3 Normal : NORMAL0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
};


//---------------------------------------------------------------------
// Structure of data sent to the pixel shader
//---------------------------------------------------------------------
struct PixelShaderInput
{
	float4 Position : POSITION0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
	float DistFade : TEXCOORD1;
	float DistFade2 : TEXCOORD2;
	float3 WorldPosition : TEXCOORD3;
	float4 SparkleTex : TEXCOORD4;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PixelShaderInput VertexShaderFunction(VertexShaderInput VS)
{
    PixelShaderInput PS = (PixelShaderInput)0;

    PS.Position = MTACalcScreenPosition( VS.Position );

    PS.TexCoord = VS.TexCoord;

    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );

    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, MTACalcWorldPosition( VS.Position ) );
    PS.DistFade = 1 - ( ( DistanceFromCamera - sFadeStart ) / ( sFadeEnd - sFadeStart ) );

    PS.WorldPosition = mul(float4(VS.Position, 1), (float4x3)gWorld);
    PS.SparkleTex.x = PS.WorldPosition.x * sValue.y ;
    PS.SparkleTex.y = PS.WorldPosition.y * sValue.y ;
    PS.SparkleTex.z = PS.WorldPosition.x * sValue.z ;
    PS.SparkleTex.w = PS.WorldPosition.y * sValue.z ;
	
	PS.DistFade2 = MTAUnlerp ( sValue.w, sValue.w/4, DistanceFromCamera );
	
    return PS;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PixelShaderInput PS) : COLOR0
{
    float4 texel = tex2D(Sampler0, PS.TexCoord);

    float4 texelDetail1 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale );
    float4 texelDetail2 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale * 1.9 );
    float4 texelDetail3 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale * 3.6 );
    float4 texelDetail4 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale * 7.4 );
    float4 texelDetail = texelDetail1 * texelDetail2 * 2 * texelDetail3 * 2 * texelDetail4 * 2;
    float4 Color = texel * PS.Diffuse;
    float detailAmount = saturate( PS.DistFade ) * sStrength;
    float4 texelDetailToUse = lerp ( 0.5, texelDetail, detailAmount );
    float4 Color2 = Color * texelDetailToUse * 2;
	
	if (g_bRainy == true)
	{
		float3 vFlakesNormal = tex3D(RandomSampler, float3(PS.SparkleTex.xy,1)).rgb;
		float3 vFlakesNormal2 = tex3D(RandomSampler, float3(PS.SparkleTex.zw,2)).rgb;
		vFlakesNormal += vFlakesNormal2 - 1.0;
		float3 vNp2 = vFlakesNormal + float3(0,0,1) ;
		float3 vView = normalize( gCameraPosition - PS.WorldPosition );
		float3 vNormalWorld = float3(0,0,1);
		float fNdotV = saturate(dot( vNormalWorld, vView));
		float3 vReflection = 2 * vNormalWorld * fNdotV - vView;
		vReflection += vNp2;
		float4 envMap = texCUBE( ReflectionSampler, vReflection );
		float4 finalColor;
		finalColor = Color2 + (envMap * sValue.x * saturate( PS.DistFade2 )* PS.Diffuse);
		finalColor.a = Color.a;
		return finalColor;
	}
	else
	{
		Color2.a = Color.a;
		return Color2;
	}
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique detail
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback
{
    pass P0
    {
    }
}