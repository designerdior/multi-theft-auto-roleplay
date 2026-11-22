local sx, sy = guiGetScreenSize()
local renderPanel = false
local creationType = ""
local font = dxCreateFont("files/Roboto.ttf",20)
local atvR, atvG, atvB = 0,0,0
local atv = 0

local namesByCarID = {
	{422, "bobcat", "MAZ 103 See-City", "Tömegközlekedési jármű, az utasok szállítására alkalmas."},
	{498, "boxville", "Postakocsi", "Levélszállítási"},
	{431, "bus", "MAZ 103 See-City", "Tömegközlekedési jármű, az utasok szállítására alkalmas."},
	{578, "dft-30", "MAZ 103 See-City", "Tömegközlekedési jármű, az utasok szállítására alkalmas."},
 	{530, "forklift", "MAZ 103 See-City", "Tömegközlekedési jármű, az utasok szállítására alkalmas."},
	{448, "pizzaboy", "MAZ 103 See-City", "Tömegközlekedési jármű, az utasok szállítására alkalmas."},
	{408, "trashmaster", "MAZ 103 See-City", "Tömegközlekedési jármű, az utasok szállítására alkalmas."},
	{478, "walton", "MAZ 103 See-City", "Tömegközlekedési jármű, az utasok szállítására alkalmas."},
	{456, "yankee", "Yankee", "Az áru szállítására alkalmas jármű."},
}


 function createPanelExport (state, type, vehR, vehG, vehB)
	 if state then
		 if type then
			 if not renderPanel then
				  creationType = type
			 		renderPanel = true
					atvR,atvG,atvB = vehR, vehG, vehB
			 end
		 end
	 end
	 if not state then
		 if renderPanel then
				renderPanel = false
				creationType = ""
		 end
	 end
end


function createVehicleRender ()
	local veh = getPedOccupiedVehicle(localPlayer)
	if renderPanel then
		if not veh then
			for k, v in pairs(namesByCarID) do
				if v[2] == creationType then
					atv = k
				end
			end
			dxDrawRectangle(sx/2-130, sy/2-230,260,470, tocolor(0,0,0,200))
			dxDrawImage(sx/2-255/2+3, sy/2-230+10, 250,250, "files/"..creationType..".png")
			dxDrawText(namesByCarID[atv][3], sx/2-130, sy/2+35, sx/2-130+260, 0, tocolor(255,255,255,255), 1, font, "center", "top", false, true)
			dxDrawText(namesByCarID[atv][4], sx/2-130, sy/2+60+25, sx/2-130+260, 0, tocolor(255,255,255,255), 0.5, font, "center", "top", false, true)

			-- igénylés
			if isInSlot(sx/2-255/2+3, sy/2-230+10+115+245, 245, 40) then
				dxDrawRectangle(sx/2-255/2+3, sy/2-230+10+115+245, 245, 40, tocolor(10, 175,118, 255))
			else
				dxDrawRectangle(sx/2-255/2+3, sy/2-230+10+115+245, 245, 40, tocolor(10, 175,118, 200))
			end
			dxDrawText("Ezt szeretném!", sx/2-255/2+3, sy/2-230+10+115+245, sx/2-255/2+3+245, sy/2-230+10+115+245+40, tocolor(0,0,0,255), 0.75, font, "center", "center", false, true)

			-- kilépés
			if isInSlot(sx/2-255/2+3, sy/2-230+10+115+250+45, 245, 40) then
				dxDrawRectangle(sx/2-255/2+3, sy/2-230+10+115+250+45, 245, 40, tocolor(215, 112, 0, 255))
			else
				dxDrawRectangle(sx/2-255/2+3, sy/2-230+10+115+250+45, 245, 40, tocolor(215, 112, 0, 200))
			end
			dxDrawText("Kilépés",sx/2-255/2+3, sy/2-230+10+115+250+45, sx/2-255/2+3+245, sy/2-230+10+115+250+45+40, tocolor(0,0,0,255), 0.75, font, "center", "center", false, true)
		end
		if veh and getElementModel(veh) == namesByCarID[atv][1] then
			dxDrawRectangle(sx/2-350/2, sy/2-110/2, 350,110, tocolor(0,0,0,200))
			dxDrawText("Le akarod adni a munkajárműved?", sx/2-350/2, sy/2-110/2+20, sx/2-350/2+350, 0, tocolor(255,255,255,255), 0.65, font, "center", "top", false, true)

			if isInSlot(sx/2-350/2+10, sy/2-110/2+60, 160,40) then
				dxDrawRectangle(sx/2-350/2+10, sy/2-110/2+60, 160,40, tocolor(10, 175,118, 255))
			else
				dxDrawRectangle(sx/2-350/2+10, sy/2-110/2+60, 160,40, tocolor(10, 175,118, 200))
			end
			dxDrawText("Igen",sx/2-350/2+10, sy/2-110/2+60, sx/2-350/2+10+160, sy/2-110/2+100, tocolor(0,0,0,255), 0.75, font, "center", "center", false, true)

			if isInSlot(sx/2-350/2+180, sy/2-110/2+60, 160,40) then
				dxDrawRectangle(sx/2-350/2+180, sy/2-110/2+60, 160,40, tocolor(215, 112, 0, 255))
			else
				dxDrawRectangle(sx/2-350/2+180, sy/2-110/2+60, 160,40, tocolor(215, 112, 0, 200))
			end
			dxDrawText("Nem",sx/2-350/2+180, sy/2-110/2+60, sx/2-350/2+180+160, sy/2-110/2+60+40, tocolor(0,0,0,255), 0.75, font, "center", "center", false, true)

		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), createVehicleRender )

function createVehWithClick(button, state)
	if button == "left" and state == "down" then
		if renderPanel then
			local veh = getPedOccupiedVehicle(localPlayer)
			if not veh then
				if isInSlot(sx/2-255/2+3, sy/2-230+10+115+245, 245, 40) then
					triggerServerEvent("createJobVehicle", localPlayer, localPlayer, namesByCarID[atv][1], atvR,atvG,atvB)
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFSikeresen lehívtál egy munkajárművet. Amennyiben le szeretnéd adni, hozd ide.",255,255,255,true)
					if namesByCarID[atv][1] == 431 then
						setTimer(function()
							exports.sas_jobs:startBusJob()
						end, 2500, 1)
					end
					if namesByCarID[atv][1] == 456 then
						setTimer(function()
							exports.sas_jobs:createStartMarkerTruck()
						end, 2500, 1)
					end
					renderPanel = false
				elseif isInSlot(sx/2-255/2+3, sy/2-230+10+115+250+45, 245, 40) then
					renderPanel = false
				end
			end
			if veh and getElementModel(veh) == namesByCarID[atv][1] then
				if isInSlot(sx/2-350/2+10, sy/2-110/2+60, 160,40) then
					triggerServerEvent("deleteJobVehicle", localPlayer, localPlayer)
					renderPanel = false
				elseif isInSlot(sx/2-350/2+180, sy/2-110/2+60, 160,40) then
					renderPanel = false
				end
			end
		end
	end
end
addEventHandler ( "onClientClick", getRootElement(), createVehWithClick )


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

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end
