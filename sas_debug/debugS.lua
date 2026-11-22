addEventHandler("onDebugMessage", root, function(dbMsg, dbLevel, dbFile, dbLine)
	triggerClientEvent(root, "debug->Add", root, dbMsg or "", dbLevel or 0, dbFile or 0, dbLine or 0)
end)

addEventHandler("onPlayerCommand", root, function(commandName)
	if commandName == "debug" or commandName == "debug" then
		--if getElementData(source, "charAdmin") >= 8 then
			triggerClientEvent(source, "debug->ChangeState", source)
		cancelEvent()
	end
end)