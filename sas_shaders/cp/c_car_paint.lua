Settings = {}
Settings.var = {}
local scx,scy = guiGetScreenSize ()
local grungeVehicles = {}

function setcpRLffectVehicle()
    local v = Settings.var
	v.renderDistance = 60 -- max render distance of the shader effect
	v.scXY = {800,600} -- reflection screensource resolution
	v.normalXY = 0.2 -- deformation strength (0-1.0) 1.0 = the highest (X and Y of vector)
	v.normalZ = 0.2 -- deformation strength (0-1.0) 1.0 = the highest (Z of vector)
	v.bumpSize = 0.7 -- for car paint
	v.envIntensity = {0.25, 0.5} -- intensity of the reflection effect
	v.brightnessMul = {1.0, 1.0} -- multiply after brightpass
	v.brightpassPower = {2.5, 2.0} -- 1-5
	v.brightnessAdd = {0.1, 0.1} -- before bright pass
	v.uvMul = {2.0,0.5} -- uv multiply
	v.uvMov = {0,-2.8} -- uv move
end

local myScreenSource = nil
local textureVol = nil

local grunges = {}
grunges[0] = dxCreateTexture("cp/nogrunge.png")
grunges[1] = dxCreateTexture("cp/midgrunge.jpg")
grunges[2] = dxCreateTexture("cp/defaultgrunge.jpg")
grunges[3] = dxCreateTexture("cp/megagrunge.jpg")

local grunge = {}

--a table of additional texture names:
			
local texturegrun = {
			"predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
			"hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128", 
			"rctiger92body128","rhino92texpage256", "petrotr92interior128","artict1logos","rumpo92adverts256","dash92interior128",
			"coach92interior128","combinetexpage128","hotdog92body256",
			"raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
			"polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , "seasparrow92floats64" , 
			"dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256", 
			"shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256", "xyz" }



function startCarPaintReflect()
		if cprEffectEnabled then return end
		local v = Settings.var
		setcpRLffectVehicle()
		-- Create shader
		glassShader = dxCreateShader("fx/car_glass.fx",1 ,v.renderDistance ,false, "vehicle")
		--shatterShader = dxCreateShader("fx/car_glass.fx",1 ,v.renderDistance ,false, "vehicle")		
		--if paintShader then
			myScreenSource = dxCreateScreenSource( v.scXY[1], v.scXY[2])
			addEventHandler("onClientPreRender", getRootElement (), updateScreen)
			-- Set textures
			--textureVol = dxCreateTexture("images/smallnoise3d_car.dds")
			
			--dxSetShaderValue(glassShader, "sRandomTexture", textureVol)
			dxSetShaderValue(glassShader, "sReflectionTexture", myScreenSource)

			dxSetShaderValue(glassShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue(glassShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue(glassShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue(glassShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue(glassShader, "bumpSize", v.bumpSize)
			dxSetShaderValue(glassShader, "envIntensity", v.envIntensity[2])

			dxSetShaderValue(glassShader, "sPower", v.brightpassPower[2])			
			dxSetShaderValue(glassShader, "sAdd", v.brightnessAdd[2])
			dxSetShaderValue(glassShader, "sMul", v.brightnessMul[2])

			--[[
			--dxSetShaderValue(shatterShader, "sRandomTexture", textureVol)
			--dxSetShaderValue(shatterShader, "sReflectionTexture", myScreenSource)
			--dxSetShaderValue(shatterShader, "isShatter", true)
			
			dxSetShaderValue(shatterShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue(shatterShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue(shatterShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue(shatterShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue(shatterShader, "bumpSize", v.bumpSize)
			dxSetShaderValue(shatterShader, "envIntensity", v.envIntensity[2])

			dxSetShaderValue(shatterShader, "sPower", v.brightpassPower[2])			
			dxSetShaderValue(shatterShader, "sAdd", v.brightnessAdd[2])
			dxSetShaderValue(shatterShader, "sMul", v.brightnessMul[2])]]

			--engineApplyShaderToWorldTexture ( paintShader, "vehiclegrunge256" )
			--engineApplyShaderToWorldTexture ( paintShader, "?emap*" )
			
			engineApplyShaderToWorldTexture(glassShader, "vehiclegeneric256")
			engineApplyShaderToWorldTexture(glassShader, "xyz")
			
			--engineApplyShaderToWorldTexture(shatterShader, "vehicleshatter128")
			--engineApplyShaderToWorldTexture(shatterShader, "xyz")
			cprEffectEnabled = true
		--end

	for i, veh in ipairs(getElementsByType("vehicle")) do
		if grunge[vehicle] then
			destroyElement(grunge[vehicle].shader)
			grunge[vehicle] = nil
		end

		local val = getElementData(veh, "grunge") or 0
		setCarPaintGrunge(veh, true, val)
	end
end

function stopCarPaintReflect()
	if not cprEffectEnabled then return end
	removeEventHandler("onClientPreRender", getRootElement (), updateScreen)

	for i, veh in ipairs(getElementsByType("vehicle")) do
		setCarPaintGrunge(veh, false)
	end

	engineRemoveShaderFromWorldTexture(glassShader,"*")
	destroyElement( glassShader)
	glassShader = nil
	--engineRemoveShaderFromWorldTexture(shatterShader,"*")
	--destroyElement( shatterShader)
	--shatterShader = nil
	--destroyElement( textureVol)
	--textureVol = nil
	destroyElement(myScreenSource)
	myScreenSource = nil
	cprEffectEnabled = false

	for i, veh in ipairs(getElementsByType("vehicle")) do
		local val = getElementData(veh, "grunge") or 0
		setVehicleGrunge(veh, val)
	end
end

function updateScreen()
	if myScreenSource then
		dxUpdateScreenSource( myScreenSource)
	end
end

function toggleCP(state)
	if state then
		startCarPaintReflect()
	else
		stopCarPaintReflect()
	end
end
addEvent("switchCPShader", true)
addEventHandler("switchCPShader", root, toggleCP)

function setCarPaintGrunge(vehicle, state, level)
	if not myScreenSource then return false end
	if level == nil then state = false end
	if state then
		local v = Settings.var
		setcpRLffectVehicle()

		grungeVehicles[vehicle] = dxCreateShader("fx/car_paint.fx", 1 ,v.renderDistance, false, "vehicle")
		--dxSetShaderValue(grungeVehicles[vehicle], "sRandomTexture", textureVol)
		dxSetShaderValue(grungeVehicles[vehicle], "sReflectionTexture", myScreenSource)

		dxSetShaderValue(grungeVehicles[vehicle], "sNorFacXY", v.normalXY)
		dxSetShaderValue(grungeVehicles[vehicle], "sNorFacZ", v.normalZ)
		dxSetShaderValue(grungeVehicles[vehicle], "uvMul", v.uvMul[1],v.uvMul[2])
		dxSetShaderValue(grungeVehicles[vehicle], "uvMov", v.uvMov[1],v.uvMov[2])
		dxSetShaderValue(grungeVehicles[vehicle], "bumpSize", v.bumpSize)
		dxSetShaderValue(grungeVehicles[vehicle], "envIntensity", v.envIntensity[1])

		dxSetShaderValue(grungeVehicles[vehicle], "sPower", v.brightpassPower[1])			
		dxSetShaderValue(grungeVehicles[vehicle], "sAdd", v.brightnessAdd[1])
		dxSetShaderValue(grungeVehicles[vehicle], "sMul", v.brightnessMul[1])

		dxSetShaderValue(grungeVehicles[vehicle], "gTexture", grunges[level])

		-- Apply to world texture
		engineApplyShaderToWorldTexture(grungeVehicles[vehicle], "vehiclegrunge256", vehicle)
		engineApplyShaderToWorldTexture(grungeVehicles[vehicle], "?emap*", vehicle)

		for _,addList in ipairs(texturegrun) do
			engineApplyShaderToWorldTexture(grungeVehicles[vehicle], addList, vehicle)
		end

		return true
	else
		if grungeVehicles[vehicle] then
			engineRemoveShaderFromWorldTexture(grungeVehicles[vehicle],"*",vehicle)
			destroyElement(grungeVehicles[vehicle])
			grungeVehicles[vehicle] = nil
			return true
		end
	end
end

function setVehicleGrunge(vehicle, level)
	if not getElementData(vehicle,"paintjobData") then--not exports.rp_livery:getVehiclePaintjobTextureName(getElementModel(vehicle)) then
		if cprEffectEnabled then
			if grungeVehicles[vehicle] then
				setCarPaintGrunge(vehicle, false)
			end

			setCarPaintGrunge(vehicle, true, level)
		else
			if not grunge[vehicle] or grunge[vehicle] == nil then
				grunge[vehicle] = {}
				grunge[vehicle].shader = dxCreateShader("fx/carwash.fx")
			else
				if grunge[vehicle].shader then 
					destroyElement(grunge[vehicle].shader)
					grunge[vehicle].shader = dxCreateShader("fx/carwash.fx")
				end
			end

			engineRemoveShaderFromWorldTexture(grunge[vehicle].shader, "vehiclegrunge256", vehicle)

			if level ~= nil then
				dxSetShaderValue(grunge[vehicle].shader, "Grunge", grunges[level])
				engineApplyShaderToWorldTexture(grunge[vehicle].shader, "vehiclegrunge256", vehicle)
			else
				destroyElement(grunge[vehicle].shader)
				grunge[vehicle] = nil
			end
		end
	end
end