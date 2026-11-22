local lifts = {
	{1825.78125, -1127.8740234375, 24.13906288147,0,0,0},
}
local timers = {}

addEventHandler("onResourceStart",resourceRoot,function()
	for k,v in ipairs(lifts) do
		local lift = createObject(1277,v[1],v[2],v[3]-1)
		setElementRotation(lift,v[4],v[5],v[6])
		setElementData(lift,"isLift",true)
		setElementData(lift,"number",0)
		setElementData(lift,"defaultZ",v[3]-1)
		local border = createObject(2061,v[1],v[2],v[3]-1)
		setElementRotation(border,v[4],v[5],v[6])
		setElementData(border,"border",true)
		setElementData(border,"lift",lift)
	end
end)

function nemtudomServer(playerSource,vehicle,state, component)
    triggerClientEvent(root,"vehicleComponentEvent",playerSource,vehicle, state, component,playerSource)
end
addEvent("nemtudomServer",true)
addEventHandler("nemtudomServer",getRootElement(),nemtudomServer)

addEvent("componentChangeServer",true)
addEventHandler("componentChangeServer",getRootElement(),function(playerSource)
	triggerClientEvent(root,"componentChangeClient",playerSource,playerSource)
end)

addEvent("newComponentAddToHand",true)
addEventHandler("newComponentAddToHand",getRootElement(),function(playerSource,component,vehicle)
	triggerClientEvent(root,"newComponentAddClient",playerSource,component,vehicle,playerSource)
end)

addEvent("setMechanicAnim",true)
addEventHandler("setMechanicAnim",getRootElement(),function(playerSource,typ,state)
	if typ == "create" then
		setPedAnimation (playerSource, "bomber", "bom_plant", -1, true, false, true, true)
		triggerClientEvent(root, "createMechanicSound", playerSource,playerSource)
	elseif typ == "remove" then
		if tostring(state) == "true" then
			setPedAnimation(playerSource, "CARRY", "crry_prtial", 0, true, false, true, true)
		else
			setPedAnimation(playerSource,nil,nil)
		end
		triggerClientEvent(root, "destroyMechanicSound", playerSource,playerSource)
	end
end)

addEvent("PedWalkingWithObject", true)
addEventHandler("PedWalkingWithObject", getRootElement(), function(playerSource, animName, animtoName)
	setPedAnimation(playerSource, animName, animtoName, -1, true, false, false, false)
end)

addEvent("wheelComponentFix",true)
addEventHandler("wheelComponentFix",getRootElement(),function(playerSource,vehicle,component)
	triggerClientEvent(root,"wheelChangeClient",playerSource,vehicle,component)
end)

addEvent("moveLiftObject",true)
addEventHandler("moveLiftObject",getRootElement(),function(playerSource,object,number,vehicle)
	--outputChatBox(getVehicleName(vehicle))
	local lift = getElementData(object,"lift")
	if number ~= getElementData(lift,"number") then
		if isElement(vehicle) then
			local x,y,z = getElementPosition(vehicle)
			local rx,ry,rz = getElementRotation(vehicle)
			if  rz >= 0 and rz <= 90 or rz >= 270 and rz <= 360 then
				rotx, roty, rotz =  0, 0, 0
			else
				rotx, roty, rotz = 0, 0, 180
			end
			attachElements(vehicle,lift, 0,0,0.75, rotx, roty, rotz)
		end
		local x,y,z = getElementPosition(lift)
		if number == 0 then
			moveObject(lift,2000,x,y,getElementData(lift,"defaultZ"))
			triggerClientEvent(root, "createLiftSound", playerSource,playerSource)
			setElementData(lift,"moving",true)
			timers[lift] = setTimer(function()
				triggerClientEvent(root, "destroyLiftSound", playerSource,playerSource)
				setElementData(lift,"moving",false)
				if isElement(vehicle) then
					if isElementAttached(vehicle) then
						detachElements(vehicle)
					end
				end
				killTimer(timers[lift])
			end,2000,1)
			setElementData(lift,"number",0)
		else
			if getElementData(lift,"number") == 1 and number == 2 then
				number = 1
			else
				setElementData(lift,"number",number)
			end
			triggerClientEvent(root, "createLiftSound", playerSource,playerSource)
			setElementData(lift,"moving",true)
			timers[lift] = setTimer(function()
				triggerClientEvent(root, "destroyLiftSound", playerSource,playerSource)
				setElementData(lift,"moving",false)
				killTimer(timers[lift])
			end,2000,1)
			moveObject(lift,2000,x,y,z+(number))
		end
	end
end)

addEvent("setVehicleEngineHealth",true)
addEventHandler("setVehicleEngineHealth",getRootElement(),function(playerSource,vehicle)
	setElementHealth(vehicle,1000)
	setVehicleDamageProof(vehicle, false)
	setElementData(vehicle, "enginebroke", 0)
end)

addEvent("componentDestroyFromHand",true)
addEventHandler("componentDestroyFromHand",getRootElement(),function(playerSource)
	triggerClientEvent(root,"componentDestroyClient",playerSource,playerSource)
end)

addEventHandler("onPlayerQuit",getRootElement(),function()
	if getElementData(source,"loggedin") == 1 then
		if getElementData(source,"componentInHand") then
			triggerClientEvent(root,"componentDestroyClient",source,source)
		end
	end
end)

addEvent("setVehicleLampHealth",true)
addEventHandler("setVehicleLampHealth",getRootElement(),function(playerSource,vehicle)
	if getElementHealth(vehicle) > 648 then
		setElementHealth(vehicle,1000)
		setVehicleDamageProof(vehicle, false)
		setElementData(vehicle, "enginebroke", 0)
	end
	for i = 0,3 do
		setVehicleLightState(vehicle,i,0)
	end
end)

addEvent("sendMeActionToChat",true)
addEventHandler("sendMeActionToChat",getRootElement(),function(playerSource, type, component)
	if type == "leszerel" then
		exports.sas_chat:sendLocalMeAction(playerSource, "elkezdte leszerelni a(z) "..component.."-t")
		setElementData(playerSource,"money",getElementData(playerSource,"money")-40)
	elseif type == "felszerel" then
		exports.sas_chat:sendLocalMeAction(playerSource, "elkezdte felszerelni a(z) "..component.."-t.")
	elseif type == "lampa" then
		exports.sas_chat:sendLocalMeAction(playerSource, "elkezdte megjavítani a lámpát.")
	elseif type == "motor" then
		exports.sas_chat:sendLocalMeAction(playerSource, "elkezdte megjavítani a motort.")
	elseif type == "megszerel" then
		exports.sas_chat:sendLocalMeAction(playerSource, "elkezdte megszerelni a "..component.."-t.")
	end
end)
