-- FILE: 	mapEditorScriptingExtension_c.lua
-- PURPOSE:	Prevent the map editor feature set being limited by what MTA can load from a map file by adding a script file to maps
-- VERSION:	RemoveWorldObjects (v1) AutoLOD (v1) BreakableObjects (v1)

function requestLODsClient()
	triggerServerEvent("requestLODsClient", resourceRoot)
end
addEventHandler("onClientResourceStart", resourceRoot, requestLODsClient)

function setLODsClient(lodTbl)
	for i, model in ipairs(lodTbl) do
		engineSetModelLODDistance(model, 300)
	end
end
addEvent("setLODsClient", true)
addEventHandler("setLODsClient", resourceRoot, setLODsClient)

function applyBreakableState()
	for k, obj in pairs(getElementsByType("object", resourceRoot)) do
		local breakable = getElementData(obj, "breakable")
		if breakable then
			setObjectBreakable(obj, breakable == "true")
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, applyBreakableState)

-- Nem robbanó benzinkút
local gastanks = 
{
	-- IDLEWOOD GAS
	{ 1941.65625, -1774.3125, 14.640625 },
	{ 1941.65625, -1767.2890625, 14.640625 },
	{ 1941.65625, -1771.34375, 14.640625 },
	{ 1941.65625, -1778.453125, 14.640625 },
	
	{  -85.2421875, -1165.03125, 3.1328125 },
	{ -92.1015625, -1161.7890625, 3.4609375 },
	{ -97.0703125, -1173.75, 3.53125 },
	{ -90.140625, -1176.625, 3.1328125 }
}


function nemSerulAKut(x, y, z, type)
	if type == 9 then
		for k, v in ipairs( gastanks ) do
			if x == v[1] and y == v[2] and z == v[3] then
				cancelEvent()
			end
		end
	end
end
addEventHandler( "onClientExplosion", getRootElement(), nemSerulAKut )

local obj = {createObject(1337, 1524.6708984375, -1782.712890625, 13.95), createObject(1337, 1249.9853515625, -1755.251953125, 14.25)}
local moving = false
local rot = 0

addEventHandler("onClientPreRender", getRootElement(), function(time)
	rot = rot + 0.01*time
	setElementRotation(obj[1], 0, 0, rot)
	setElementRotation(obj[2], 0, 0, rot)
end)

setOcclusionsEnabled(false)