function addNotification(player, value, str)
	if isElement(player) then
		triggerClientEvent(player, "addNewNotification", getRootElement(), value, str)
	end
end