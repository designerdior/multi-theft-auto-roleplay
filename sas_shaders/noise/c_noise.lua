addEvent("switchNoiseShader",true)

local intensity = 0.25
local intensityLines = 0.1
local w, h = guiGetScreenSize( )
local noise = false

--addEventHandler("onClientHUDRender",getRootElement(),
function noiseRender()
	--if noise then
		dxUpdateScreenSource( screenSrcn, true )
		dxSetRenderTarget()
		dxDrawImage( 0, 0, w, h, screenShadern )
	--end
end
--)

addEventHandler("switchNoiseShader",getLocalPlayer(),function(enableNoise)
	if enableNoise then
		screenShadern = dxCreateShader( "fx/noise.fx" )
		screenSrcn = dxCreateScreenSource( w, h )
		if screenShadern and screenSrcn then
			dxSetShaderValue( screenShadern, "PixelShadTexture", screenSrcn )
			dxSetShaderValue( screenShadern, "fNintensity", intensity )
			dxSetShaderValue( screenShadern, "fSintensity", intensityLines )
			noise=true

			addEventHandler("onClientHUDRender",getRootElement(), noiseRender)
		end
	else
		if screenShadern and screenSrcn then
			removeEventHandler("onClientHUDRender",getRootElement(), noiseRender)

			destroyElement( screenShadern )
			destroyElement( screenSrcn )
			screenShadern, screenSrcn = nil, nil
			noise=false
		end
	end
end)