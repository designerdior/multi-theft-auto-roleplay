local screen = {guiGetScreenSize()}
local box = {480,35}
local pos = {screen[1]/2 -box[1]/2,screen[2]/1.2 -box[2]/2+50}
local panelBox = {300,180}
local panelPos = {screen[1] -panelBox[1]-20,screen[2]/2 -panelBox[2]/2}
local opensans = dxCreateFont("files/opensans.ttf",12)
local opensans2 = dxCreateFont("files/opensans.ttf",14)
local opensans3 = dxCreateFont("files/opensans.ttf",16)
local progresText = "Bal első ajtó leszerelése..."
local show = false
local isInPoint = false
local object = nil
local progress = 0
local components = {
	["door_lf_dummy"] = true,
	["door_rf_dummy"] = true,
	["door_lr_dummy"] = true,
	["door_rr_dummy"] = true,
	["bonnet_dummy"] = true,
	["boot_dummy"] = true,
	["wheel_lf_dummy"] = true,
	["wheel_lb_dummy"] = true,
	["wheel_rf_dummy"] = true,
	["wheel_rb_dummy"] = true,
	["bump_front_dummy"] = true,
	["bump_rear_dummy"] = true,
	["windscreen_dummy"] = true,
}

local realComponentNames = {
	["door_lf_dummy"] = "Bal első ajtó",
	["door_rf_dummy"] = "Jobb első ajtó",
	["door_lr_dummy"] = "Bal hátsó ajtó",
	["door_rr_dummy"] = "Jobb hátsó ajtó",
	["bonnet_dummy"] = "Motorháztető",
	["boot_dummy"] = "Csomagtartó",
	["wheel_lf_dummy"] = "Bal első kerék",
	["wheel_lb_dummy"] = "Bal hátsó kerék",
	["wheel_rf_dummy"] = "Jobb első kerék",
	["wheel_rb_dummy"] = "Jobb hátsó kerék",
	["bump_front_dummy"] = "Első lökhárító",
	["bump_rear_dummy"] = "Hátsó lökhárító",
	["windscreen_dummy"] = "Szélvédő",
}

local componentPos = {
	["door_lf_dummy"] = {-0.3,-0.2,0,0,0,-90,2},
	["door_rf_dummy"] = {0.3,-0.2,0,0,0,90,3},
	["door_lr_dummy"] = {0.6,-0.2,0,0,0,-90,4},
	["door_rr_dummy"] = {-0.7,-0.2,0,0,0,90,5},
	["bonnet_dummy"] = {0,-0.8,0.2,0,0,0,0},
	["boot_dummy"] = {0,-1.5,0,180,180,0,1},
	["wheel_lf_dummy"] = {-0.7,-0.3,-1.2,90,90,180,0},
	["wheel_lb_dummy"] = {-0.75,0,1.6,90,90,180,0},
	["wheel_rf_dummy"] = {1.55,-0.3,1,0,0,90,0},
	["wheel_rb_dummy"] = {-1.35,-0.3,1,0,0,-270,0},
	["bump_front_dummy"] = {0,-1.75,0.4,0,0,0,5},
	["bump_rear_dummy"] = {0,-1.75,0.4,0,0,-180,6},
	["windscreen_dummy"] = {0,0,0,0,0,0,4},
}

local doorsStates = {
	["door_lf_dummy"] = {2},
	["door_rf_dummy"] = {3},
	["door_lr_dummy"] = {4},
	["door_rr_dummy"] = {5},
	["bonnet_dummy"] = {0},
	["boot_dummy"] = {1},
}

local wheelStates = {
	["wheel_lf_dummy"] = {1},
	["wheel_rf_dummy"] = {2},
	["wheel_lb_dummy"] = {3},
	["wheel_rb_dummy"] = {4},
}

local panelStates = {
	["bump_front_dummy"] = {5},
	["bump_rear_dummy"] = {6},
	["windscreen_dummy"] = {4},
}

local vehicles = {}
local timers = {}
local dropPositions = {
	{1819.416015625, -1145.7451171875, 23.969541549683},
}
local sounds = {}
local liftSounds = {}
local mechanicCol = nil
local newComponent = {}
local lastTick = 0

addEventHandler("onClientResourceStart",resourceRoot,function()
	setElementData(localPlayer,"componentInHand",false)
	for k,v in ipairs(dropPositions) do
		dropMarker = createMarker(v[1],v[2],v[3]-1,"cylinder",2,124, 197, 118,80)
		setElementData(dropMarker,"dropMarker",true)
	end
	engineImportTXD(engineLoadTXD("files/emelo.txd"), 1277)
	engineReplaceModel(engineLoadDFF("files/emelo.dff", 1277), 1277)
	engineReplaceCOL(engineLoadCOL ("files/emelo.col" ), 1277)
	engineImportTXD(engineLoadTXD("files/border.txd"), 2061)
	engineReplaceModel(engineLoadDFF("files/border.dff", 2061), 2061)
	engineReplaceCOL(engineLoadCOL ("files/border.col" ), 2061)
	engineSetModelLODDistance(1277, 500)
	engineSetModelLODDistance(2061, 500)

	mechanicCol = createColCuboid(1761.4365234375, -1150.037109375, 23,70.0, 58.0, 5.0)
	container = createObject(1358,1805.7265625, -1139.6220703125, 24.085935592651)
	setElementRotation(container,0,0,170)
end)

addEventHandler("onClientElementStreamIn",getRootElement(),function()
	if getElementType(source) == "vehicle" then
		if getElementData(source,"attachedVehicle") then

				setElementAlpha(source,255)
				local r,g,b,r1,g1,b1 = getElementData(source,"attachedColor")[1],getElementData(source,"attachedColor")[2],getElementData(source,"attachedColor")[3],getElementData(source,"attachedColor")[4],getElementData(source,"attachedColor")[5],getElementData(source,"attachedColor")[6]
				--{r,g,b,r1,g1,b1}

				setVehicleColor(source,r,g,b,r1,g1,b1)

				for a in pairs(getVehicleComponents(source)) do
					if getElementData(source,"attachedComponent") ~= a then
						setVehicleComponentVisible(source,a, false)
					end
				end

		end
	end
end)

addEventHandler("onClientElementStreamOut",getRootElement(),function()
	if getElementType(source) == "vehicle" then
		if getElementData(source,"attachedVehicle") then
			outputChatBox("disztroy")
		end
	end
end)

addEventHandler("onClientMarkerHit",getRootElement(),function(hitPlayer,matchingDimension)
	if getElementData(source,"dropMarker") then
		if hitPlayer == localPlayer then
			if getElementData(localPlayer,"componentInHand") then
				for k,v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v,"attachedVehicle") then
						if getElementData(v,"attachedElement") == localPlayer then
							triggerServerEvent("componentChangeServer",localPlayer,localPlayer)
						end
					end
				end
			else
				if newComponent[1] then
					setElementData(localPlayer,"componentInHand",true)
					triggerServerEvent("newComponentAddToHand",localPlayer,localPlayer,newComponent[1],newComponent[2])
					newComponent = {}
				end
			end
		end
	end
end)

addEventHandler("onClientRender",root,function()
	if not isElementWithinColShape ( localPlayer, mechanicCol ) then return end
	selectedVehicle = nil
	if not getElementData(localPlayer,"loggedin") then return end
	if getElementData(localPlayer,"componentInHand") then
		toggleControl("fire", false)
		toggleControl("sprint", false)
		toggleControl("crouch", false)
		toggleControl("jump", false)
	end

	if show then
		toggleAllControls(false)
		toggleControl("chatbox",true)
		local cTick = getTickCount ()
		local process = (cTick - lastTick)/10000
		progress,_,_ = interpolateBetween (
			0,0,0,
			480,0,0,
			process,"Linear"
		)
		if progress >= 480 then
			toggleAllControls(true)
			toggleControl("chatbox",true)
			show = false
			progress = 0
			triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"remove",getElementData(localPlayer,"componentInHand"))
		end
		dxDrawRectangle(pos[1],pos[2],box[1],box[2],tocolor(124, 197, 118,150))
		dxDrawRectangle(pos[1],pos[2],progress,box[2],tocolor(124, 197, 118,200))
		dxDrawBorder(pos[1],pos[2],box[1],box[2],3,tocolor(0,0,0,200))
		dxDrawText(progresText,pos[1],pos[2],pos[1]+box[1],pos[2]+box[2],tocolor(0,0,0,255),1,opensans3, "center", "center")
	end
	--setElementData(localPlayer,"mechanicing",false)

	if isElement(container) then
		--if exports.sas_dashboard:isInGroup(localPlayer,34) then
			local playerX,playerY,playerZ = getElementPosition(localPlayer)
			local objectX,objectY,objectZ = getElementPosition(container)
			if getDistanceBetweenPoints3D(playerX,playerY,playerZ,objectX,objectY,objectZ) <= 3.4 then
				dxDrawText("Alkatrész lerakásához nyomd meg az 'E' betűt.",screen[1]/2-1,screen[2]/1.2+1,screen[1]/2-1,screen[2]/1.2+1,tocolor(0,0,0,255),1,opensans2,"center","center")
				dxDrawText("Alkatrész lerakásához nyomd meg az 'E' betűt.",screen[1]/2,screen[2]/1.2,screen[1]/2,screen[2]/1.2,tocolor(255,255,255,255),1,opensans2,"center","center",true,true,true,true)
			end
		--end
	end

	if not show then
		--if  exports.sas_dashboard:isInGroup(localPlayer,34) then
			if not isPedInVehicle(localPlayer) then
				for k,veh in ipairs(getElementsByType("vehicle")) do
					if not getElementData(veh,"attachedVehicle") then
						for v in pairs ( getVehicleComponents(veh) ) do
							if components[v] then
								local sX,sY,sZ = getVehicleComponentPosition ( veh, v, "world" )
								local posX,posY,posZ = getScreenFromWorldPosition ( sX, sY, sZ )
								x, y, z = getElementPosition(localPlayer)
								vehicleX, vehicleY, vehicleZ = getElementPosition(veh)
								if getDistanceBetweenPoints3D(x, y, z, vehicleX, vehicleY, vehicleZ) <= 6 then
									if getDistanceBetweenPoints3D(x, y, z,sX,sY,sZ) <= 2 then
										selectedVehicle = veh
										--setElementData(localPlayer,"mechanicing",true)
										if posX and posY then
											if doorsStates[v] then
												local doorState = getVehicleDoorState(veh, doorsStates[v][1])
												if (doorState ~= 0) then
													local text = ""
													if getVehicleComponentVisible(veh, v) then
														text = realComponentNames[v].." leszerelése"
													else
														text = realComponentNames[v].." felszerelése"
													end
													if isInSlot(posX,posY,15+dxGetTextWidth(text, 1,opensans),30) then
														dxDrawRectangle(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,tocolor(124, 197, 118,200))
													else
														dxDrawRectangle(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,tocolor(124, 197, 118,150))
													end
													dxDrawBorder(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,2,tocolor(0,0,0,180))
													dxDrawText(text,posX+7,posY+4,0,0,tocolor(0,0,0,255),1,opensans)
												end
											end
											if wheelStates[v] then
												local wheels = {getVehicleWheelStates(veh)}
												if wheels[wheelStates[v][1]] ~= 0 then
													local text = ""
													if getVehicleComponentVisible(veh, v) then
														text = realComponentNames[v].." megszerelése"
													else
														text = realComponentNames[v].." felszerelése"
													end
													if isInSlot(posX,posY,15+dxGetTextWidth(text, 1,opensans),30) then
														dxDrawRectangle(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,tocolor(124, 197, 118,200))
													else
														dxDrawRectangle(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,tocolor(124, 197, 118,150))
													end
													dxDrawBorder(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,2,tocolor(0,0,0,180))
													dxDrawText(text,posX+7,posY+4,0,0,tocolor(0,0,0,255),1,opensans)
												end
											end
											if panelStates[v] then
												local panelState = getVehiclePanelState(veh, panelStates[v][1])
												if (panelState ~= 0) then
													local text = ""
													if getVehicleComponentVisible(veh, v) then
														text = realComponentNames[v].." leszerelése"
													else
														text = realComponentNames[v].." felszerelése"
													end
													if isInSlot(posX,posY,15+dxGetTextWidth(text, 1,opensans),30) then
														dxDrawRectangle(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,tocolor(124, 197, 118,200))
													else
														dxDrawRectangle(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,tocolor(124, 197, 118,150))
													end
													dxDrawBorder(posX,posY,15+dxGetTextWidth(text, 1,opensans),30,2,tocolor(0,0,0,180))
													dxDrawText(text,posX+7,posY+4,0,0,tocolor(0,0,0,255),1,opensans)
												end
											end
											--for i = 0,3 do
											--	local lightState = getVehicleLightState(veh,i)
											--
											--end
										end
									end
								end
							end
						end
					end
				end
			end
		--end
	end
	--if isElement(selectedVehicle) and exports.sas_dashboard:isInGroup(localPlayer,34) then
		dxDrawRectangle(panelPos[1],panelPos[2],panelBox[1],panelBox[2],tocolor(0,0,0,120))
		dxDrawRectangle(panelPos[1],panelPos[2],panelBox[1],40,tocolor(0,0,0,180))
		dxDrawText("Egyéb",panelPos[1],panelPos[2],panelPos[1]+panelBox[1],panelPos[2]+40,tocolor(255,255,255,255),1,opensans3,"center","center")

		if isInSlot(panelPos[1]+20,panelPos[2]+20+40,260,40) then
			dxDrawRectangle(panelPos[1]+20,panelPos[2]+20+40,260,40,tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(panelPos[1]+20,panelPos[2]+20+40,260,40,tocolor(124, 197, 118,150))
		end
		dxDrawText("Motor javítás",panelPos[1]+20,panelPos[2]+20+40,panelPos[1]+20+260,panelPos[2]+20+40+40,tocolor(0,0,0,255),1,opensans3,"center","center")
		if isInSlot(panelPos[1]+20,panelPos[2]+20+40+40+20,260,40) then
			dxDrawRectangle(panelPos[1]+20,panelPos[2]+20+40+40+20,260,40,tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(panelPos[1]+20,panelPos[2]+20+40+40+20,260,40,tocolor(124, 197, 118,150))
		end
		dxDrawText("Lámpa javítás",panelPos[1]+20,panelPos[2]+20+40+40+20,panelPos[1]+20+260,panelPos[2]+20+40+40+20+40,tocolor(0,0,0,255),1,opensans3,"center","center")
	--end
end)



addEventHandler("onClientClick", root, function(btn, st)
	if btn == "left" and st == "down" then
		if not isElementWithinColShape ( localPlayer, mechanicCol ) then return end
		if not show then
			--if  exports.sas_dashboard:isInGroup(localPlayer,34) then
				if not isPedInVehicle(localPlayer) then
					for k,veh in ipairs(getElementsByType("vehicle")) do
						if not getElementData(veh,"attachedVehicle") then
							for v in pairs ( getVehicleComponents(veh) ) do
								if components[v] then
									local sX,sY,sZ = getVehicleComponentPosition ( veh, v, "world" )
									local posX,posY,posZ = getScreenFromWorldPosition ( sX, sY, sZ )
									x, y, z = getElementPosition(localPlayer)
									vehicleX, vehicleY, vehicleZ = getElementPosition(veh)
									if getDistanceBetweenPoints3D(x, y, z, vehicleX, vehicleY, vehicleZ) <= 6 then
										if getDistanceBetweenPoints3D(x, y, z,sX,sY,sZ) <= 2 then
											if posX and posY then
												if doorsStates[v] then
													local doorState = getVehicleDoorState(veh, doorsStates[v][1])
													if (doorState ~= 0) then
														local text = ""
														if getVehicleComponentVisible(veh, v) then
															text = realComponentNames[v].." leszerelése"
														else
															text = realComponentNames[v].." felszerelése"
														end
														if isInSlot(posX,posY,15+dxGetTextWidth(text, 1,opensans),30) then
															if getVehicleComponentVisible(veh, v) then
																if not getElementData(localPlayer,"componentInHand") then
																	if getElementData(localPlayer,"money") >= 40 then
																		triggerServerEvent("sendMeActionToChat",localPlayer, localPlayer, "leszerel", realComponentNames[v])
																		progresText = realComponentNames[v].." leszerelése..."
																		triggerServerEvent("nemtudomServer",localPlayer,localPlayer,veh,false, v)
																		show = true
																		lastTick = getTickCount()
																		triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"create")
																	else
																		exports.sas_hud:addNotification("Nincs nálad elég pénz a szereléshez (40 $)","error")
																	end
																end
															else
																if getElementData(localPlayer,"componentInHand") then
																	local attachedState = getVehicleDoorState(vehicles[veh][v], doorsStates[v][1])
																	if attachedState == 0 then
																		setElementData(localPlayer,"componentInHand",false)
																		triggerServerEvent("sendMeActionToChat",localPlayer, localPlayer, "felszerel", realComponentNames[v])
																		progresText = realComponentNames[v].." felszerelése..."
																		triggerServerEvent("nemtudomServer",localPlayer,localPlayer,veh,true, v)
																		show = true
																		lastTick = getTickCount()
																		lastTick = getTickCount()
																		triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"create")
																	end
																else
																	if not newComponent[1] then
																		newComponent = {v,veh}
																	end
																end
															end
														end
													end
												end

												if panelStates[v] then
													local panelState = getVehiclePanelState(veh, panelStates[v][1])
													if (panelState ~= 0) then
														local text = ""
														if getVehicleComponentVisible(veh, v) then
															text = realComponentNames[v].." leszerelése"
														else
															text = realComponentNames[v].." felszerelése"
														end
														if isInSlot(posX,posY,15+dxGetTextWidth(text, 1,opensans),30) then
															if getVehicleComponentVisible(veh, v) then
																if not getElementData(localPlayer,"componentInHand") then
																	if getElementData(localPlayer,"money") >= 40 then
																		setElementData(localPlayer,"componentInHand",true)
																		triggerServerEvent("sendMeActionToChat",localPlayer, localPlayer, "leszerel", realComponentNames[v])
																		progresText = realComponentNames[v].." leszerelése..."
																		triggerServerEvent("nemtudomServer",localPlayer,localPlayer,veh,false, v)
																		show = true
																		lastTick = getTickCount()
																		triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"create")
																	else
																		exports.sas_hud:addNotification("Nincs nálad elég pénz a szereléshez (40 $)","error")
																	end
																end
															else
																if getElementData(localPlayer,"componentInHand") then
																	local attachedState = getVehiclePanelState(vehicles[veh][v], panelStates[v][1])
																	if attachedState == 0 then
																		setElementData(localPlayer,"componentInHand",false)
																		triggerServerEvent("sendMeActionToChat",localPlayer, localPlayer, "felszerel", realComponentNames[v])
																		progresText = realComponentNames[v].." felszerelése..."
																		triggerServerEvent("nemtudomServer",localPlayer,localPlayer,veh,true, v)
																		show = true
																		lastTick = getTickCount()
																		triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"create")
																	end
																else
																	if not newComponent[1] then
																		newComponent = {v,veh}
																	end
																end
															end
														end
													end
												end

												if wheelStates[v] then
													local wheels = {getVehicleWheelStates(veh)}
													if wheels[wheelStates[v][1]] ~= 0 then
														local text = ""
														if getVehicleComponentVisible(veh, v) then
															text = realComponentNames[v].." leszerelése"
														else
															text = realComponentNames[v].." felszerelése"
														end
														if isInSlot(posX,posY,15+dxGetTextWidth(text, 1,opensans),30) then
															triggerServerEvent("sendMeActionToChat",localPlayer, localPlayer, "megszerel", realComponentNames[v])
															progresText = realComponentNames[v].." megszerelése..."
															show = true
															lastTick = getTickCount()
															triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"create")
															triggerServerEvent("wheelComponentFix",localPlayer,localPlayer,veh,v)
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			--end
			--if isElement(selectedVehicle) and exports.sas_dashboard:isInGroup(localPlayer,34) then
				if isInSlot(panelPos[1]+20,panelPos[2]+20+40,260,40) then
					if getElementHealth(selectedVehicle) <= 648 then
						triggerServerEvent("sendMeActionToChat",localPlayer,localPlayer, "motor")
						progresText = "Motor megszerelése..."
						show = true
						lastTick = getTickCount()
						triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"create")
						triggerServerEvent("setVehicleEngineHealth",localPlayer,localPlayer,selectedVehicle)
					else
						exports.sas_hud:addNotification("A jármű motorja nem sérült.", "error")
					end
				elseif isInSlot(panelPos[1]+20,panelPos[2]+20+40+40+20,260,40) then
					triggerServerEvent("sendMeActionToChat",localPlayer,localPlayer, "lampa")
					progresText = "Lámpa megszerelése..."
					show = true
					lastTick = getTickCount()
					triggerServerEvent("setMechanicAnim",localPlayer,localPlayer,"create")
					triggerServerEvent("setVehicleLampHealth",localPlayer,localPlayer,selectedVehicle)
				end
			--end
		end
	end
end)

addEvent("vehicleComponentEvent",true)
addEventHandler("vehicleComponentEvent",root,function(vehicle,state,component,element)
	if not vehicles[vehicle] then
		vehicles[vehicle] = {}
	end
	if state == true then
		if doorsStates[component] then
			local doorState = getVehicleDoorState(vehicles[vehicle][component], doorsStates[component][1])
			if (doorState ~= 0) then
				return
			end
		end
		if panelStates[component] then
			local panelState = getVehiclePanelState(vehicles[vehicle][component], panelStates[component][1])
			if (panelState ~= 0) then
				return
			end
		end

		if isElement(vehicles[vehicle][component]) then
			destroyElement(vehicles[vehicle][component])
		end
		setVehicleComponentVisible(vehicle,component, true)
		if doorsStates[component] then
			setVehicleDoorState(vehicle, componentPos[component][7],0)
		end
		if panelStates[component] then
			setVehiclePanelState(vehicle, componentPos[component][7],0)
		end
	elseif state == false then
		if not isElement(vehicles[vehicle][component]) then
			local x,y,z = getElementPosition(vehicle)
			vehicles[vehicle][component] = createVehicle(getElementModel(vehicle),x,y,z)
			setElementAlpha(vehicles[vehicle][component],0)
			setElementFrozen(vehicles[vehicle][component],true)
			setElementData(vehicles[vehicle][component],"attachedVehicle",true)
			setElementData(vehicles[vehicle][component],"attachedElement",element)
			setElementData(vehicles[vehicle][component],"attachedVehicleElement",vehicles[vehicle][component])
			setElementData(vehicles[vehicle][component],"attachedComponent",component)
			local r,g,b,r1,g1,b1 = getVehicleColor(vehicle)
			setElementData(vehicles[vehicle][component],"attachedColor",{r,g,b,r1,g1,b1})
			setElementCollisionsEnabled(vehicles[vehicle][component], false)
			attachElements(vehicles[vehicle][component],element,componentPos[component][1],componentPos[component][2],componentPos[component][3],componentPos[component][4],componentPos[component][5],componentPos[component][6])
			timers[element] = setTimer(function()
				setElementAlpha(vehicles[vehicle][component],255)
				local r,g,b,r1,g1,b1 = getVehicleColor(vehicle)
				setVehicleColor(vehicles[vehicle][component],r,g,b,r1,g1,b1)
				local hR,hG,hB = getVehicleHeadLightColor(vehicle)
				setVehicleHeadLightColor(vehicles[vehicle][component],hR,hG,hB)
				if doorsStates[component] then
					setVehicleDoorState(vehicles[vehicle][component], componentPos[component][7],2)
				end
				if panelStates[component] then
					setVehiclePanelState(vehicles[vehicle][component], componentPos[component][7],2)
				end
				for a in pairs(getVehicleComponents(vehicles[vehicle][component])) do
					if component ~= a then
						setVehicleComponentVisible(vehicles[vehicle][component],a, false)
					end
				end
				killTimer(timers[element])
			end,50,1)
		end
		setVehicleComponentVisible(vehicle,component, false)
	end
end)

addEvent("componentChangeClient",true)
addEventHandler("componentChangeClient",getRootElement(),function(element)
	for k,v in ipairs(getElementsByType("vehicle")) do
		if getElementData(v,"attachedVehicle") then
			if getElementData(v,"attachedElement") == element then
				for k in pairs(getVehicleComponents(v)) do
					if getVehicleComponentVisible(v,k) then
						if doorsStates[k] then
							setVehicleDoorState(v, componentPos[k][7],0)
						end
						if panelStates[k] then
							setVehiclePanelState(v, componentPos[k][7],0)
						end
					end
				end
				setPedAnimation(element,"CARRY","liftup",1100,false,false,false,false)
			end
		end
	end
end)

addEvent("newComponentAddClient",true)
addEventHandler("newComponentAddClient",getRootElement(),function(component,vehicle,element)
	if not vehicles[vehicle] then
		vehicles[vehicle] = {}
	end
	if not isElement(vehicles[vehicle][component]) then
		local x,y,z = getElementPosition(vehicle)
		vehicles[vehicle][component] = createVehicle(getElementModel(vehicle),x,y,z)
		setElementAlpha(vehicles[vehicle][component],0)
		setElementFrozen(vehicles[vehicle][component],true)
		setElementData(vehicles[vehicle][component],"attachedVehicle",true)
		setElementData(vehicles[vehicle][component],"attachedElement",element)
		setElementData(vehicles[vehicle][component],"attachedVehicleElement",vehicles[vehicle][component])
		setElementData(vehicles[vehicle][component],"attachedComponent",component)
		local r,g,b,r1,g1,b1 = getVehicleColor(vehicle)
		setElementData(vehicles[vehicle][component],"attachedColor",{r,g,b,r1,g1,b1})
		setElementCollisionsEnabled(vehicles[vehicle][component], false)
		attachElements(vehicles[vehicle][component],element,componentPos[component][1],componentPos[component][2],componentPos[component][3],componentPos[component][4],componentPos[component][5],componentPos[component][6])
		setPedAnimation(element,"CARRY","liftup",1100,false,false,false,false)
		timers[element] = setTimer(function()
			setElementAlpha(vehicles[vehicle][component],255)
			local r,g,b,r1,g1,b1 = getVehicleColor(vehicle)
			setVehicleColor(vehicles[vehicle][component],r,g,b,r1,g1,b1)
			local hR,hG,hB = getVehicleHeadLightColor(vehicle)
			setVehicleHeadLightColor(vehicles[vehicle][component],hR,hG,hB)
			if doorsStates[component] then
				setVehicleDoorState(vehicles[vehicle][component], componentPos[component][7],0)
			end
			if panelStates[component] then
				setVehiclePanelState(vehicles[vehicle][component], componentPos[component][7],0)
			end
			for a in pairs(getVehicleComponents(vehicles[vehicle][component])) do
				if component ~= a then
					setVehicleComponentVisible(vehicles[vehicle][component],a, false)
				end
			end
			killTimer(timers[element])
		end,50,1)
	end
	setVehicleComponentVisible(vehicle,component, false)
end)

addEvent("componentDestroyClient",true)
addEventHandler("componentDestroyClient",getRootElement(),function(element)
	for k,v in ipairs(getElementsByType("vehicle")) do
		if getElementData(v,"attachedVehicle") then
			if getElementData(v,"attachedElement") == element then
				destroyElement(v)
			end
		end
	end
end)

addEvent("wheelChangeClient",true)
addEventHandler("wheelChangeClient",getRootElement(),function(vehicle,component)
	if wheelStates[component] then
		local wheels = {getVehicleWheelStates(vehicle)}
		for k,v in ipairs(wheels) do
			if wheelStates[component][1] == k then
				if wheels[k] == 1 then
					wheels[k] = 0
				end
				setVehicleWheelStates(vehicle,wheels[1],wheels[2],wheels[3],wheels[4])
			end
		end
	end
end)

addEvent("createMechanicSound",true)
addEventHandler("createMechanicSound",getRootElement(),function(element)
	local x,y,z = getElementPosition(element)
	if not isElement(sounds[element]) then
		sounds[element] = playSound3D("files/repair.mp3",x,y,z, true)
		setElementInterior(sounds[element], 0)
		setElementDimension(sounds[element], 0)
	end
end)

addEvent("destroyLiftSound",true)
addEventHandler("destroyLiftSound",getRootElement(),function(element)
	if isElement(liftSounds[element]) then
		destroyElement(liftSounds[element])
	end
end)

addEvent("createLiftSound",true)
addEventHandler("createLiftSound",getRootElement(),function(element)
	local x,y,z = getElementPosition(element)
	if not isElement(liftSounds[element]) then
		liftSounds[element] = playSound3D("files/lift.mp3",x,y,z, true)
		setElementInterior(liftSounds[element], 0)
		setElementDimension(liftSounds[element], 0)
	end
end)

addEvent("destroyMechanicSound",true)
addEventHandler("destroyMechanicSound",getRootElement(),function(element)
	if isElement(sounds[element]) then
		destroyElement(sounds[element])
	end
end)

bindKey("e","down",function()
	if getElementData(localPlayer,"loggedin") then
		--if isElement(container) and exports.sas_dashboard:isInGroup(localPlayer,34) then
			local playerX,playerY,playerZ = getElementPosition(localPlayer)
			local objectX,objectY,objectZ = getElementPosition(container)
			if getDistanceBetweenPoints3D(playerX,playerY,playerZ,objectX,objectY,objectZ) <= 3.4 then
				for k,v in ipairs(getElementsByType("vehicle")) do
					if getElementData(v,"attachedVehicle") then
						if getElementData(v,"attachedElement") == localPlayer then
							setElementData(localPlayer,"componentInHand",false)
							toggleControl("fire", true)
							toggleControl("sprint", true)
							toggleControl("crouch", true)
							toggleControl("jump", true)
							triggerServerEvent("componentDestroyFromHand",localPlayer,localPlayer)
						end
					end
				end
			end
		--end
	end
end)

addCommandHandler("lift",function(cmd,number)
	--if exports.sas_dashboard:isInGroup(localPlayer,34) then
		if not number then
			outputChatBox("#7cc576[SeeMTA]: #ffffff /"..cmd.." [0,1,2]",61,122,188,true)
		end
	--end
	if getElementData(localPlayer,"loggedin") then
		--if exports.sas_dashboard:isInGroup(localPlayer,34) then
			isInPoint = false
			object = nil
			for k, v in ipairs(getElementsByType("object")) do
				if getElementData(v,"border") then
					local x, y, z = getElementPosition(localPlayer)
					local vehicleX, vehicleY, vehicleZ = getElementPosition(v)
					if getDistanceBetweenPoints3D(x, y, z, vehicleX, vehicleY, vehicleZ) <= 4 then
						local rotX, rotY, rotZ = getElementRotation(v)
						local angle = math.rad(45 + rotZ)
						local cornerX, cornerY = vehicleX, vehicleY
						local pointX, pointY = vehicleX-1.7, vehicleY+1.2
						local rotatedX = math.cos(angle) * (pointX - cornerX) - math.sin(angle) * (pointY- cornerY) + cornerX
						local rotatedY = math.sin(angle) * (pointX - cornerX) + math.cos(angle) * (pointY - cornerY) + cornerY
						if getDistanceBetweenPoints3D(x, y, z, rotatedX, rotatedY, vehicleZ) <= 2 then
							isInPoint = true
							object = v
						end
					end
				end
			end
			if isInPoint then
				if (tostring(type(tonumber(number))) == "number") then
					if tonumber(number) <= 2 then
						local lift = getElementData(object,"lift")
						if getElementData(lift,"moving") then
							outputChatBox("#d9534f[SeeMTA]: #FFFFFF Várj! A lift még mozgásban van.",61,122,188,true)
						else
							if getElementData(lift,"number") > tonumber(number) then
								if tonumber(number) == 0 then
									triggerServerEvent("moveLiftObject",localPlayer,localPlayer,object,tonumber(number),getLiftVehicleDistance())
								end
							else
								triggerServerEvent("moveLiftObject",localPlayer,localPlayer,object,tonumber(number),getLiftVehicleDistance())
							end
						end
					else
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFElérhető számok: 0,1,2.",61,122,188,true)
					end
				end
			end
		--end
	end
end)

function getLiftVehicleDistance()
	if isInPoint then
		for k,v in ipairs(getElementsByType("vehicle")) do
			if getElementData(v,"dbid") then
				local lift = getElementData(object,"lift")
				local objX,objY,objZ = getElementPosition(lift)
				local vehX,vehY,vehZ = getElementPosition(v)
				if getDistanceBetweenPoints3D(objX,objY,objZ,vehX,vehY,vehZ) <= 2 then
					return v
				end
			end
		end
	end
	return false
end

function dxDrawBorder(x, y, w, h, radius, color)
	dxDrawRectangle(x - radius, y, radius, h, color)
	dxDrawRectangle(x + w, y, radius, h, color)
	dxDrawRectangle(x - radius, y - radius, w + (radius * 2), radius, color)
	dxDrawRectangle(x - radius, y + h, w + (radius * 2), radius, color)
end

function inBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(inBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end
