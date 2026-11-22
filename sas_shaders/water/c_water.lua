--
-- c_water_ref.lua
--
local waterTimer = nil
local waterShader
local scx, scy = guiGetScreenSize()
local ScreenOutPut = dxCreateScreenSource( scx/3, scy/3)

addEvent("switchWaterShader",true)
addEventHandler( "switchWaterShader", getLocalPlayer(),
	function()

		if getVersion ().sortable < "1.3.0" then
			return
		end
		
		if not waterShader then
            waterShader = dxCreateShader ( "fx/water.fx" )
			local textureVol = dxCreateTexture ( "images/waterNoise.dds" )
			dxSetShaderValue ( waterShader, "sRandomTexture", textureVol )
			local textureCube = dxCreateTexture ( "images/cube_env256.dds" )
			dxSetShaderValue ( waterShader, "showroomMapCube_Tex", textureCube )
			dxSetShaderValue ( waterShader, "sReflectionTexture", ScreenOutPut )

			engineApplyShaderToWorldTexture ( waterShader, "waterclear256" )
			addEventHandler ( "onClientPreRender", getRootElement (), getScreen )

			waterTimer = setTimer(function()
				local vx
				local pogoda = getWeather()
				if (pogoda == 8 or pogoda == 16) then
					vx = 2
					setWaveHeight ( 1.4 )
				elseif (pogoda == 9 or pogoda == 19 or pogoda == 20) then
					vx = 1.4
					setWaveHeight ( 0.7 )
				else
					vx = 0.8
					setWaveHeight ( 0.2 )
				end
				dxSetShaderValue ( waterShader, "Wind", vx)
				local r,g,b = getSkyGradient()
				dxSetShaderValue ( waterShader, "sWaterColor", r/255, g/255, b/255)
			end,1000,0 )
		elseif waterShader then
			removeEventHandler ( "onClientPreRender", getRootElement (), getScreen )
			destroyElement(waterShader)
			waterShader = nil
			if waterTimer then 
				killTimer(waterTimer)
				waterTimer = nil
			end
		end
	end
)

function getScreen()
	dxUpdateScreenSource( ScreenOutPut)
end