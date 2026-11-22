addEvent("switchNoireShader",true)
local w, h = guiGetScreenSize( )
local noire = false

--addEventHandler("onClientHUDRender",getRootElement(),
function noireRender ()
	if noire then
		dxUpdateScreenSource( screenSrc, true )
		dxSetRenderTarget()
		dxDrawImage( 0, 0, w, h, screenShader )
	end
end
--)

addEventHandler("switchNoireShader",getLocalPlayer(),function(enable)
	if enable then
		screenShader = dxCreateShader( "fx/noire.fx" )
		screenSrc = dxCreateScreenSource( w, h )
		if screenShader and screenSrc then
			dxSetShaderValue( screenShader, "PixelShadTexture", screenSrc )
			noire=true

			addEventHandler("onClientHUDRender",getRootElement(), noireRender)
		end
	else
		if screenShader and screenSrc then
			removeEventHandler("onClientHUDRender",getRootElement(), noireRender)
			destroyElement( screenShader )
			destroyElement( screenSrc )
			screenShader, screenSrc = nil, nil
			noire=false
		end
	end
end)