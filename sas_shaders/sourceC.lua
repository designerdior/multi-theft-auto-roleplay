addEventHandler("onClientResourceStart",getResourceRootElement(),function()
	if getShaderSetting("rs3") then
		toggleShader("rs3",true)
	end
	
	if getShaderSetting("water") then
		toggleShader("water",true)
	end
	
	if getShaderSetting("con") then
		toggleShader("con",true)
	end
	
	if getShaderSetting("cp") then
		toggleShader("cp",true)
	end
	
	if getShaderSetting("blur") then
		toggleShader("blur",true)
	end	
	
	if getShaderSetting("tex") then
		toggleShader("tex",true)
	end
	
	if getShaderSetting("noire") then
		toggleShader("noire",true)
	end
	
	if getShaderSetting("noise") then
		toggleShader("noise",true)
	end
	
	if getShaderSetting("dof") then
		toggleShader("dof",true)
	end
	
	if getShaderSetting("rays") then
		toggleShader("rays",true)
	end
	
--	if getShaderSetting("snow") then
--		toggleShader("snow",true)
--	else
--		exports.snow:stopSnow ()
--	end

	if getShaderSetting("water2") then
		toggleShader("water2",true)
	end
end)

function setShaderEnabled(name,state)
	toggleShader(name,state)
	saveShaderSetting(name,state)
end

function saveShaderSetting(name,state)
	local root = xmlLoadFile("settings.xml")
	if not  root then
		root = xmlCreateFile("settings.xml","settings")
	end
	
	local node = xmlFindChild(root,name,0)
	if not node then
		node = xmlCreateChild(root,name)
	end
	xmlNodeSetValue(node,tostring(state))
	xmlSaveFile(root)
	xmlUnloadFile(root)
end

function getShaderSetting(name)
	local root = xmlLoadFile("settings.xml")
	if root then
		local node = xmlFindChild(root,name,0)
		if node then
			local val = xmlNodeGetValue(node)
			if val=="true" then
				return true
			else
				return false
			end
		end
	end
	return false
end

function toggleShader(name,state)
	if name then
		if name=="rs3" or name=="roadshine3" then
			triggerEvent("switchRoadshine3",getLocalPlayer(),state)
		elseif name=="water" then
			triggerEvent("switchWaterShader",getLocalPlayer(),state)
		elseif name=="con" or name=="contrast" then
			triggerEvent("switchContrast",getLocalPlayer(),state)
		elseif name=="cp" or name=="car paint" then
			triggerEvent("switchCPShader",getLocalPlayer(),state)
		elseif name=="blur" then
			triggerEvent("switchBlurShader",getLocalPlayer(),state)
		elseif name=="tex" then
			triggerEvent("onClientSwitchDetail",getLocalPlayer(),state)
		elseif name=="snow" then
			triggerEvent("switchGoundSnow",getRootElement(),state)
		elseif name=="noire" then
			triggerEvent("switchNoireShader",getRootElement(),state)
		elseif name=="noise" then
			triggerEvent("switchNoiseShader",getRootElement(),state)
		elseif name=="dof" then
			triggerEvent("switchDof",getRootElement(),state)
		elseif name=="rays" then
			triggerEvent("switchRays",getRootElement(),state)
		elseif name=="water2" then
			triggerEvent("switchWaterRef",getLocalPlayer(),state)
		end
	end
end

addEvent ("switchGoundSnow",true)
