function onGuiHandbrakeStateChange(state, veh)
	if state == true then
		setElementFrozen(veh, true)
		setElementData(veh, "handbrake", 1)
	else
		setElementFrozen(veh, false)
		setElementData(veh, "handbrake", 0)
	end
end
addEvent("onGuiHandbrakeStateChange", true)
addEventHandler("onGuiHandbrakeStateChange", getRootElement(), onGuiHandbrakeStateChange)
