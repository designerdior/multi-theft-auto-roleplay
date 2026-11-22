local showPet = false
local pet = nil
local s = {guiGetScreenSize()}
local box = {210,325}
local pos = {s[1]/2 -box[1]/2,s[2]/2 -box[2]/2}
local Roboto = dxCreateFont("files/roboto.ttf",12)
local defX, defY = 0,0
local isMove = false
local eatTimer = nil
local thirstyTimer = nil
local attackedPerson = nil
local attackMode = false

if fileExists("sourceC.lua") then 
	fileDelete("sourceC.lua")
end

function getCursorFuck()
	cX, cY = getCursorPosition()
	cX, cY = cX*s[1], cY*s[2]
	return cX, cY
end

addEventHandler("onClientClick",getRootElement(),function(button,state)
	if showPet then
		if button == "left" and state == "down" then
			if isInSlot(pos[1],pos[2],box[1],30) then
				isMove = true
				local curX, curY = getCursorFuck()
				local x,y = pos[1],pos[2]
				defX, defY = curX - x, curY - y
			end
		elseif button == "left" and state == "up" then
			if isMove then
				isMove = false
			end
		end
	end
end)

function clickPed(button, state, absX, absY, wx, wy, wz, element)
	if element and getElementType(element) == "ped" and state=="down" and getElementData(element,"isPet") then
		local x, y, z = getElementPosition(getLocalPlayer())
		if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3.2 then
			if not showPet then
				showPet = true
				pos[1],pos[2] = absX,absY
				pet = element
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickPed, true)

bindKey("backspace","down",function()
	if showPet then
		showPet = false
	end
end)

addEventHandler("onClientRender",getRootElement(),function()

	if getElementData(localPlayer,"loggedin") == 1 then
		if showPet then
			pX,pY,pZ = getElementPosition(localPlayer)
			petX,petY,petZ = getElementPosition(pet)
			if getDistanceBetweenPoints3D(pX,pY,pZ,petX,petY,petZ) >= 3.2 then
				showPet = false
			end
		end
	end

	if showPet then
		if isMove then
			if isCursorShowing() then
				local x, y = getCursorFuck()
				pos[1],pos[2] = x - defX,y - defY
			end
		end
		exports.sas_system:radarKeret(pos[1],pos[2],box[1],box[2], 2, 255)
		dxDrawText("#7cc576"..getElementData(pet,"name"),pos[1]+6,pos[2]+10,0,0,tocolor(255,255,255,255),0.9,Roboto,"left","top",true,true,true,true)
		dxDrawRectangle(pos[1],pos[2],box[1],box[2],tocolor(0,0,0,120))

		if not getElementData(pet,"pet:follow") then
			dxDrawText("Kövess",pos[1]+5,pos[2]+40,pos[1]+5+box[1]-10,pos[2]+40+30,tocolor(255,255,255,255),0.9,Roboto,"center","center",true,true,true,true)
		else
			dxDrawText("Marad",pos[1]+5,pos[2]+40,pos[1]+5+box[1]-10,pos[2]+40+30,tocolor(255,255,255,255),0.9,Roboto,"center","center",true,true,true,true)
		end
		if isInSlot(pos[1]+5,pos[2]+40,box[1]-10,30) then
			dxDrawRectangle(pos[1]+5,pos[2]+40,box[1]-10,30,tocolor(51, 204, 255,200))
		else
			dxDrawRectangle(pos[1]+5,pos[2]+40,box[1]-10,30,tocolor(255,255,255,40))
		end

		dxDrawText("Simogatás",pos[1]+5,pos[2]+80,pos[1]+5+box[1]-10,pos[2]+110,tocolor(255,255,255,255),0.9,Roboto,"center","center",true,true,true,true)
		if isInSlot(pos[1]+5,pos[2]+80,box[1]-10,30) then
			dxDrawRectangle(pos[1]+5,pos[2]+80,box[1]-10,30,tocolor(51, 204, 255,200))
		else
			dxDrawRectangle(pos[1]+5,pos[2]+80,box[1]-10,30,tocolor(255,255,255,40))
		end

		dxDrawText("Etetés",pos[1]+5,pos[2]+120,pos[1]+5+box[1]-10,pos[2]+150,tocolor(255,255,255,255),0.9,Roboto,"center","center",true,true,true,true)
		if isInSlot(pos[1]+5,pos[2]+120,box[1]-10,30) then
			dxDrawRectangle(pos[1]+5,pos[2]+120,box[1]-10,30,tocolor(51, 204, 255,200))
		else
			dxDrawRectangle(pos[1]+5,pos[2]+120,box[1]-10,30,tocolor(255,255,255,40))
		end

		dxDrawText("Támadás",pos[1]+5,pos[2]+160,pos[1]+5+box[1]-10,pos[2]+190,tocolor(255,255,255,255),0.9,Roboto,"center","center",true,true,true,true)
		if isInSlot(pos[1]+5,pos[2]+160,box[1]-10,30) then
			dxDrawRectangle(pos[1]+5,pos[2]+160,box[1]-10,30,tocolor(51, 204, 255,200))
		else
			dxDrawRectangle(pos[1]+5,pos[2]+160,box[1]-10,30,tocolor(255,255,255,40))
		end

		dxDrawText("Ugattatás",pos[1]+5,pos[2]+200,pos[1]+5+box[1]-10,pos[2]+230,tocolor(255,255,255,255),0.9,Roboto,"center","center",true,true,true,true)
		if isInSlot(pos[1]+5,pos[2]+200,box[1]-10,30) then
			dxDrawRectangle(pos[1]+5,pos[2]+200,box[1]-10,30,tocolor(51, 204, 255,200))
		else
			dxDrawRectangle(pos[1]+5,pos[2]+200,box[1]-10,30,tocolor(255,255,255,40))
		end

		dxDrawText("Bezárás",pos[1]+5,pos[2]+280,pos[1]+5+box[1]-10,pos[2]+310,tocolor(255,255,255,255),0.9,Roboto,"center","center",true,true,true,true)
		if isInSlot(pos[1]+5,pos[2]+280,box[1]-10,30) then
			dxDrawRectangle(pos[1]+5,pos[2]+280,box[1]-10,30,tocolor(217, 83, 79,200))
		else
			dxDrawRectangle(pos[1]+5,pos[2]+280,box[1]-10,30,tocolor(255,255,255,40))
		end
	end
		if isElement(attackedPerson) then
			if isInSlot(s[1]/2-143, s[2]-150, 286, 40) then
				dxDrawImage(s[1]/2-143, s[2]-150, 286, 40, "files/cback2.png")
			else
				dxDrawImage(s[1]/2-143, s[2]-150, 286, 40, "files/cback1.png")
			end
		end
end)

addEventHandler("onClientClick",getRootElement(),function(button,state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	if button == "left" and state == "down" then
		if isElement(attackedPerson) then
			if isInSlot(s[1]/2-143, s[2]-150, 286, 40) then
				followElement = attackerPet
				setElementData(attackerPet,"pet:follow",true)
				attackMode = false
				attackerPet = nil
				attackedPerson= nil
			end
		end
		if attackMode and clickedElement then
			if getElementType ( clickedElement ) == "ped" then
				--outputChatBox("támadhat")
				setElementData(pet,"pet:follow",false)
				followElement = nil
				attackedPerson = clickedElement
				attackerPet = pet
			end
		end
	end
	if showPet then
		local rand = math.random(1,5)
		if button == "left" and state == "down" then
			if isInSlot(pos[1]+5,pos[2]+80,box[1]-10,30) then
				triggerServerEvent("playPetSound", localPlayer, pet, "simogat")
				triggerServerEvent("setSimiAnim",localPlayer,localPlayer)
				setElementFrozen(localPlayer,true)
				exports["sas_global"]:sendLocalMeAction(localPlayer,"megsimogatja "..getElementData(pet,"name").." -t.")
				showPet = false
				simiTimer = setTimer(function()
					triggerServerEvent("removeSimiAnim",localPlayer,localPlayer)
					setElementFrozen(localPlayer,false)
					killTimer(simiTimer)
				end,8000,1)
			elseif isInSlot(pos[1]+5,pos[2]+40,box[1]-10,30) then
				if getElementData(pet,"pet:owner") == getElementData(localPlayer,"dbid") then
					if not getElementData(pet,"pet:follow") then
						setElementData(pet,"pet:follow",true)
						setElementData(pet,"pet:useing",localPlayer)
						if attackerPet then
							attackerPet = nil
							attackedPerson= nil
						end
						followElement = pet
						triggerServerEvent("playPetSound", localPlayer, pet, "follownew")
					else
						local x,y,z = getElementPosition(pet)
						setElementPosition(pet,x,y,z)
						setElementData(pet,"pet:follow",false)
						setElementData(pet,"pet:useing",nil)
						followElement = nil
						if isElement(tempSound) then
							stopSound(tempSound)
						end
					end
				else
					outputChatBox("[SeeMTA]:#ffffff Nem te vagy a kutya tulajdonosa.",61,122,188,true)
				end
			elseif isInSlot(pos[1]+5,pos[2]+120,box[1]-10,30) then
				if getElementData(pet,"pet:owner") == getElementData(localPlayer,"dbid") then
						if exports["sas_items"]:hasItem(159,1) then
							if getElementData(pet,"pet:food")+rand <= 100 then
								if isTimer(eatTimer) then outputChatBox("[SeeMTA]:#ffffff Várj 5 másodpercet.",61,122,188,true) return end
								exports["sas_global"]:sendLocalMeAction(localPlayer,"megeteti a háziállatát.")
								exports["sas_items"]:takeItem(159)
								showPet = false
								setElementData(pet,"pet:food",getElementData(pet,"pet:food")+rand)
								eatTimer = setTimer(function() end,5000,1)
							else
								outputChatBox("#d9534f[SeeMTA]: #FFFFFF Háziállatod nem éhes.",61,122,188,true)
							end
						elseif exports["sas_items"]:hasItem(160,1) then
							if getElementData(pet,"pet:food")+rand <= 100 then
								if isTimer(eatTimer) then outputChatBox("[SeeMTA]:#ffffff Várj 5 másodpercet.",61,122,188,true) return end
								exports["sas_global"]:sendLocalMeAction(localPlayer,"megeteti a háziállatát.")
								exports["sas_items"]:takeItem(160)
								showPet = false
								setElementData(pet,"pet:food",getElementData(pet,"pet:food")+rand)
								eatTimer = setTimer(function() end,5000,1)
							else
								outputChatBox("#d9534f[SeeMTA]: #FFFFFF Háziállatod nem éhes.",61,122,188,true)
							end
						elseif exports["sas_items"]:hasItem(161,1) then
							if getElementData(pet,"pet:food")+rand <= 100 then
								if isTimer(eatTimer) then outputChatBox("[SeeMTA]:#ffffff Várj 5 másodpercet.",61,122,188,true) return end
								exports["sas_global"]:sendLocalMeAction(localPlayer,"megeteti a háziállatát.")
								exports["sas_items"]:takeItem(161)
								showPet = false
								setElementData(pet,"pet:food",getElementData(pet,"pet:food")+rand)
								eatTimer = setTimer(function() end,5000,1)
							else
								outputChatBox("#d9534f[SeeMTA]: #FFFFFF Háziállatod nem éhes.",61,122,188,true)
							end
						elseif exports["sas_items"]:hasItem(162,1) then
							if getElementData(pet,"pet:food")+rand <= 100 then
								if isTimer(eatTimer) then outputChatBox("[SeeMTA]:#ffffff Várj 5 másodpercet.",61,122,188,true) return end
								exports["sas_global"]:sendLocalMeAction(localPlayer,"megeteti a háziállatát.")
								exports["sas_items"]:takeItem(162)
								showPet = false
								setElementData(pet,"pet:food",getElementData(pet,"pet:food")+rand)
								eatTimer = setTimer(function() end,5000,1)
							else
								outputChatBox("#d9534f[SeeMTA]: #FFFFFF Háziállatod nem éhes.",61,122,188,true)
							end
						else
							outputChatBox("#d9534f[SeeMTA]: #FFFFFF Nincs nálad kutyatáp.",61,122,188,true)
						end
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFF Nem te vagy a kutya tulajdonosa.",61,122,188,true)
				end
			elseif isInSlot(pos[1]+5,pos[2]+280,box[1]-10,30) then
				if showPet then
					showPet = false
				end
			elseif isInSlot(pos[1]+5,pos[2]+200,box[1]-10,30) then
				if getElementData(pet,"pet:owner") == getElementData(localPlayer,"dbid") then
					if not isTimer(ugatTimer) then
						ugatTimer = setTimer(function()
							ugatTimer = nil
						end, 10000, 1)
						triggerServerEvent("playPetSound", localPlayer, pet, "ugat")
					end
				end
			elseif isInSlot(pos[1]+5,pos[2]+160,box[1]-10,30) then
				attackMode = true
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFBal kattintással válaszd ki a megtámadni kívánt személyt!", 255,255,255,true)
			end
		end
	end
end)

function syncAttack()
	if isElement(attackerPet) and isElement(attackedPerson) then
		local x,y,z = getElementPosition(attackedPerson)
		local px,py,pz = getElementPosition(attackerPet)
		if getElementHealth(attackedPerson) <= 0 then
			followElement = attackerPet
			setElementData(attackerPet,"pet:follow",true)
			attackMode = false
			attackerPet = nil
			attackedPerson= nil
		end
		if getDistanceBetweenPoints3D(x, y, z, px,py,pz)<=1 then
			setPedControlState(attackerPet, "forwards", false)
			setPedControlState(attackerPet, "walk", false)
			if not getPedControlState(attackerPet, "fire") then
				setPedControlState(attackerPet, "fire", true)
			else
				setPedControlState(attackerPet, "fire", false)
			end

		else
			setPedRotation(attackerPet, (math.atan2(y - py, x - px) * 180 / math.pi)-90)
			if getDistanceBetweenPoints3D(x, y, z, px,py,pz)>=2 then
				setPedControlState(attackerPet, "forwards", true)
				setPedControlState(attackerPet, "sprint", true)
				setPedControlState(followElement, "fire", false)
			else
				if getPedControlState(attackerPet, "sprint") then
					setPedControlState(attackerPet, "sprint", false)
				end
				setPedControlState(attackerPet, "forwards", true)
				setPedControlState(attackerPet, "walk", true)
			end
		end
	end
end
addEvent ( "syncAttack", true )
addEventHandler ( "syncAttack", root, syncAttack)

function petIntoVehicle()
	if not isElement(followElement) then return end
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		triggerServerEvent("warpPetIntoVehicle", followElement, followElement, veh)
	end
end
addEventHandler("onClientPlayerVehicleEnter", getRootElement(), petIntoVehicle)

function petOutVehicle()
	if not isElement(followElement) then return end
	triggerServerEvent("removePetFromVehicle", followElement, followElement)
end
addEventHandler("onClientPlayerVehicleExit", getRootElement(), petOutVehicle)

function syncMoving ()
	if isElement(followElement) then
		local x,y,z = getElementPosition(localPlayer)
		local px,py,pz = getElementPosition(followElement)
		setPedControlState(followElement, "fire", false)
		if getDistanceBetweenPoints3D(x, y, z, px,py,pz)<=1 then
			setPedControlState(followElement, "forwards", false)
			setPedControlState(followElement, "walk", false)
		else
			setPedRotation(followElement, (math.atan2(y - py, x - px) * 180 / math.pi)-90)
			if getDistanceBetweenPoints3D(x, y, z, px,py,pz)>=2 then
				setPedControlState(followElement, "forwards", true)
				setPedControlState(followElement, "sprint", true)
			else
				if getPedControlState(followElement, "sprint") then
					setPedControlState(followElement, "sprint", false)
				end
				setPedControlState(followElement, "forwards", true)
				setPedControlState(followElement, "walk", true)
			end
		end
	end
end
addEvent ( "syncMoving", true )
addEventHandler ( "syncMoving", root, syncMoving)

addEvent("playPetSound", true)
addEventHandler("playPetSound", root, function(pet, file)
 	tempSound = playSound3D("files/"..file..".mp3",0,0,3,false)
	setElementInterior(tempSound, getElementInterior(pet))
	setElementDimension(tempSound, getElementDimension(pet))
	attachElements(tempSound, pet)
end)

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
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
		if(dobozbaVan(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end
