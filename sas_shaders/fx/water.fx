// Author: Ren712/AngerMAN and robi
// Bumps from water_shader on mta wiki

texture sReflectionTexture;
texture sRandomTexture;
texture showroomMapCube_Tex;
float Wind = 1.0;
float3 sWaterColor = float3(90 / 255.0, 170 / 255.0, 170 / 255.0);
float sAnisotropy = 1.0;
int gCapsMaxAnisotropy                      < string deviceCaps="MaxAnisotropy"; >; 

#include "mta-helper.fx"


//----------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//----------------------------------------------------------------------
sampler3D RandomSampler = sampler_state
{
	Texture = (sRandomTexture);
	MipFilter = Anisotropic;
    MaxAnisotropy = gCapsMaxAnisotropy;
    MinFilter = Anisotropic;
};

sampler2D envMapSampler = sampler_state
{
	Texture = (sReflectionTexture);
	AddressU = Mirror;
	AddressV = Mirror;
};

samplerCUBE showroomMapCube = sampler_state
{
	Texture = (showroomMapCube_Tex);
    MipFilter = Anisotropic;
    MaxAnisotropy = gCapsMaxAnisotropy;
    MinFilter = Anisotropic;
};


//---------------------------------------------------------------------
//-- Structure of data sent to the vertex shader
//--------------------------------------------------------------------- 
 struct VSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0;
	float4 Diff : COLOR0;
};


//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0; 
	float4 Diff : COLOR0;
	float4 SparkleTex : TEXCOORD1;
	float3 WorldPos : TEXCOORD2;
	float4 DistFade : TEXCOORD3;
};


//----------------------------------------------------------------------
//-- VertexShader
//----------------------------------------------------------------------
PSInput VertexShaderSB(VSInput VS)
{
    PSInput PS = (PSInput)0;

	PS.Position = MTACalcScreenPosition( VS.Position );
	float4 pPos = mul(VS.Position, gWorldViewProjection); 
	PS.TexCoord.xy = 0.5 * (pPos.w + pPos.xy);
	PS.TexCoord.z = pPos.w;

	float3 water = sWaterColor * float3(0.2,0.6,1.4);
	water = (water.r+water.g+water.b)/6 + water/3;
    PS.Diff = (float4(0,0.16,0.2,1)+float4(water,1))/2;
	
	float4 uvpos = 0;
    uvpos.x = -sin(gTime/50*Wind);
    uvpos.y = -fmod(gTime/35*Wind,1);
    uvpos.z = -sin(gTime/5*Wind);
    uvpos.w = -fmod(gTime/7*Wind,1);

	PS.WorldPos = MTACalcWorldPosition( VS.Position.xyz );
    PS.SparkleTex.x = PS.WorldPos.x / 50 + uvpos.x * 1;
    PS.SparkleTex.y = PS.WorldPos.y / 50 + uvpos.y * 1;
    PS.SparkleTex.z = PS.WorldPos.x / 5 + uvpos.z * 1;
    PS.SparkleTex.w = PS.WorldPos.y / 5 + uvpos.w * 1;

 	float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, PS.WorldPos );
	PS.DistFade.x = MTAUnlerp(40, 0, DistanceFromCamera); //bliskie odbicia do 36 metrów
	PS.DistFade.y = MTAUnlerp(5, 15, DistanceFromCamera); //przezroczystoœæ do 15 metrów
	PS.DistFade.z = MTAUnlerp(300, 99, DistanceFromCamera); //dalekie odbicia do 300 metrów
	PS.DistFade.w = MTAUnlerp(8, 40, DistanceFromCamera); //dalekie odbicia od 8 metrów

    return PS;
}


//----------------------------------------------------------------------
//-- PixelShader
//----------------------------------------------------------------------
float4 PixelShaderSB(PSInput PS) : COLOR0
{

    float3 vFlakesNormal = tex3D(RandomSampler, float3(PS.SparkleTex.xy,1)).rgb;
    float3 vFlakesNormal2 = tex3D(RandomSampler, float3(PS.SparkleTex.zw,2)).rgb;

    vFlakesNormal += vFlakesNormal2 - 1.0;
    float3 vNp2 = vFlakesNormal + float3(0,0,1);
	
	float2 lookup = (PS.TexCoord.xy/PS.TexCoord.z) + vNp2.xy*0.4;
	lookup.x -= 0.03;
	
	float4 reflection = tex2D(envMapSampler,lookup);
	reflection.rgb *= reflection.a * 0.25;

	float3 vView = normalize( gCameraPosition - PS.WorldPos );
    float3 vNormalWorld = float3(0,0,1);
	
    float fNdotV = saturate(dot( vNormalWorld, vView));
    float3 vReflection = 2 * vNormalWorld * fNdotV - vView;
    vReflection += vNp2*3;

    float4 envMap = texCUBE( showroomMapCube, vReflection );
	envMap.rgb = (envMap.r + envMap.g + envMap.b)/3;
	float diffuse = PS.Diff.rgb * 0.4;
    envMap.rgb *= envMap.a * (diffuse + 0.03) * (saturate(PS.DistFade.z) * saturate(PS.DistFade.w) + 0.5);

    float4 Far = saturate(envMap + PS.Diff * 0.4);
    Far += envMap * PS.Diff;
	Far.a = saturate(PS.DistFade.y);

	float4 Near = saturate(reflection) * saturate(PS.DistFade.x);
    Near.a = 0.2;
    return (Near + Far);
}


//----------------------------------------------------------------------
//-- Techniques
//----------------------------------------------------------------------
technique Water_refract
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderSB();
        PixelShader = compile ps_2_0 PixelShaderSB();
    }
}

technique fallback
{
    pass P0
    {
    }
}