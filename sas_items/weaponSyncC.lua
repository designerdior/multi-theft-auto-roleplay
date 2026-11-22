--if fileExists("weaponSyncC.lua") then
--	fileDelete("weaponSyncC.lua")
--end

setElementData(localPlayer, "Char->usingWeapon", {false, -1, -1, -1, -1, -1})

addEventHandler ( "onClientPlayerSpawn", getLocalPlayer(), function()
	setElementData(localPlayer, "Char->blockFire", false)
	toggleControl("next_weapon",false)
	toggleControl("previous_weapon",false)
end)
addEventHandler("onClientRender",getRootElement(),function()
	toggleControl("next_weapon",false)
	toggleControl("previous_weapon",false)
end)

setAmbientSoundEnabled( "general", false )
setAmbientSoundEnabled( "gunfire", false )