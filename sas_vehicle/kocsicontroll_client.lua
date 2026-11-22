local vehControlPanelState = false
local vehParts = {
	{"Motorháztető"},
	{"Csomagtartó"},
	{"Bal első ajtó"},
	{"Jobb első ajtó"},
	{"Bal hátsó ajtó"},
	{"Jobb hátsó ajtó"},
}
local sx, sy = guiGetScreenSize()
local panelX, panelY = sx/2, sy/2
local seefont = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 12)
local nyitasTiltas = false
local doorText = "Kinyit"
local message = ""
local movingOffsetX, movingOffsetY = 0, 0;
local cursorP = {}

function drawControlPanel()
	if vehControlPanelState then
		local playerVehicle = getPedOccupiedVehicle(localPlayer)
		dxDrawRectangle(panelX-140,panelY-335/2 ,280,335, tocolor(0,0,0,220))
		dxDrawRectangle(panelX-140,panelY-335/2 ,280,30, tocolor(0,0,0,220))
		--dxDrawRectangle(panelX-140+280-30, panelY-335/2+5, 20, 20)
		dxDrawText("See#7cc576MTA v3 #FFFFFF- Jármű ajtó",panelX-130, panelY-335/2, 0, panelY-335/2+30, tocolor(255,255,255,255), 1, seefont, "left", "center", false, false, false, true)
		if isInSlot(panelX-140+280-30, panelY-335/2, 20, 20) then
			exports.sas_system:kisIkonRender("fa_close", panelX-140+280-30, panelY-335/2, tocolor(217, 83, 79,255), 0.9, 0)
			--dxDrawText("X", panelX-140+280-30, panelY-335/2, 0, panelY-335/2+30, tocolor(217, 83, 79,255), 1, seefont, "left", "center", false, false, false, true)
		else
			exports.sas_system:kisIkonRender("fa_close", panelX-140+280-30, panelY-335/2, tocolor(255,255,255,255), 0.9, 0)
			--dxDrawText("X", panelX-140+280-30, panelY-335/2, 0, panelY-335/2+30, tocolor(255,255,255,255), 1, seefont, "left", "center", false, false, false, true)
		end
		for k, v in pairs(vehParts) do
			dxDrawText(v[1],panelX-130, panelY-335/2+40+(k*50)-50, 0, 0, tocolor(255,255,255,255), 0.9, seefont, "left", "top", false, false, false, true)
			if isInSlot(panelX+-130+165, panelY-335/2+40+(k*50)-50, 90, 30) then
				dxDrawRectangle(panelX+-130+165, panelY-335/2+40+(k*50)-55, 90, 30, tocolor(124, 197, 118, 225))
				if getVehicleDoorOpenRatio(playerVehicle, (k-1)) == 0 then
					doorText = "Kinyit"
				elseif getVehicleDoorOpenRatio(playerVehicle, (k-1)) == 1 then
					doorText = "Bezár"
				end
			else
				if getVehicleDoorOpenRatio(playerVehicle, (k-1)) == 0 then
					doorText = "Kinyit"
				elseif getVehicleDoorOpenRatio(playerVehicle, (k-1)) == 1 then
					doorText = "Bezár"
				end
				dxDrawRectangle(panelX+-130+165, panelY-335/2+40+(k*50)-55, 90, 30, tocolor(124, 197, 118, 190))
			end
			dxDrawText(doorText,panelX+-130+165, panelY-335/2+40+(k*50)-55, panelX+-130+165+90, panelY-335/2+40+(k*50)-55+30, tocolor(0,0,0,255), 1, seefont, "center", "center", false, false, false, true)
		end
		if panelMoving then
			local cursorW = {getCursorPosition()}
			local cursorP = {cursorW[1]*sx, cursorW[2]*sy}
			panelX = cursorP[1] - movingOffsetX
			panelY = cursorP[2] - movingOffsetY
		end
	end
end

function clickOnOpen(button, state)
	if vehControlPanelState and not nyitasTiltas then
		if button == "left" and state == "down" then
			local playerVehicle = getPedOccupiedVehicle(localPlayer)
			for k, v in pairs(vehParts) do
				if isInSlot(panelX+-130+165, panelY-335/2+40+(k*50)-50, 90, 30) then
					doorToOpen = k-1
					if doorToOpen == 0 then
						if getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 0 then
							message = "felnyitja a motorháztetőt."
						elseif getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 1 then
							message = "lecsukja a motorháztetőt."
						end
					end
					if doorToOpen == 1 then
						if getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 0 then
							message = "felnyitja a csomagtatót."
						elseif getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 1 then
							message = "lecsukja a csomagtatót."
						end
					end
					if doorToOpen == 2 then
						if getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 0 then
							message = "kinyitja a bal első ajtót."
						elseif getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 1 then
							message = "becsukja a bal első ajtót."
						end
					end
					if doorToOpen == 3 then
						if getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 0 then
							message = "kinyitja a jobb első ajtót."
						elseif getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 1 then
							message = "becsukja a jobb első ajtót."
						end
					end
					if doorToOpen == 4 then
						if getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 0 then
							message = "kinyitja a bal hátsó ajtót."
						elseif getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 1 then
							message = "becsukja a bal hátsó ajtót."
						end
					end
					if doorToOpen == 5 then
						if getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 0 then
							message = "kinyitja a jobb hátsó ajtót."
						elseif getVehicleDoorOpenRatio(playerVehicle, doorToOpen) == 1 then
							message = "becsukja a jobb hátsó ajtót."
						end
					end
					--setVehicleDoorOpenRatio(playerVehicle, doorToOpen, 1 - getVehicleDoorOpenRatio ( playerVehicle, doorToOpen ))
					triggerServerEvent("moveThisShit", getLocalPlayer(), doorToOpen)
					triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, message)
					nyitasTiltas = true
					setTimer(function()
						nyitasTiltas = false
					end, 800, 1)
				end
			end
			if isInSlot(panelX-140+280-30, panelY-335/2+5, 20, 20) then
				vehControlPanelState = false
				nyitasTiltas = false
			end
			if isInSlot(panelX-140,panelY-335/2 ,280,30) then
				panelMoving = true
				local cursorW = {getCursorPosition()}
				local cursorP = {cursorW[1]*sx, cursorW[2]*sy}
				movingOffsetX = cursorP[1] - panelX
				movingOffsetY = cursorP[2] - panelY
			end
		else
			panelMoving = false
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickOnOpen)





function enableVehicleControl()
	if isPedInVehicle( localPlayer ) then
		if not vehControlPanelState then
			vehControlPanelState = true
			addEventHandler("onClientRender", getRootElement(), drawControlPanel)
			--showCursor(true)
		else
			vehControlPanelState = false
			removeEventHandler("onClientRender", getRootElement(), drawControlPanel)
			--showCursor(false)
		end
	end
end
addCommandHandler("cveh", enableVehicleControl)



--	triggerServerEvent("moveThisShit", getLocalPlayer(), door, position)


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
