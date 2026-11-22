function updateHudClock()
	-- 			watch											cellphone                                      PDA
	if exports.sas_global:hasItem(getLocalPlayer(), 17) or exports.sas_global:hasItem(getLocalPlayer(), 2) or exports.sas_global:hasItem(getLocalPlayer(), 96) then
		-- showPlayerHudComponent("clock", false)
	else
		-- showPlayerHudComponent("clock", false)
	end
end
addEvent ( "updateHudClock", true )
addEventHandler ( "updateHudClock", getRootElement(), updateHudClock )