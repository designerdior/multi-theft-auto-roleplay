function addKickban(player, value, str, text2)
	if isElement(player) then
		triggerClientEvent(player, "addNewKickban", getRootElement(), value, str, text2)
	end
end
