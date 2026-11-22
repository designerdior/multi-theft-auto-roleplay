local bekapcs = true
local alpha = 0
local seefont = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 15)

addEventHandler("onClientRender",root,function()
	if not bekapcs then return end
	local x, y, z = getElementPosition(localPlayer)
	local vehs = getElementsByType("vehicle", getRootElement(), true)

	for k, v in ipairs(vehs) do
		if isElement(v) then
			if not getElementData(v, "attachedVehicle") then
				if v ~= getPedOccupiedVehicle(localPlayer) then
					local vehX, vehY, vehZ = getElementPosition(v)
					local distance = getDistanceBetweenPoints3D(x, y, z, vehX, vehY, vehZ)

					if distance <= 10 then
						local x, y = getScreenFromWorldPosition(vehX, vehY, vehZ + 1.3)

						if x and y then
							dxDrawRectangle(x-180/2,y,180,30, tocolor(255,255,255,120))
							exports.sas_system:radarKeret(x-180/2, y, 180, 30, 3, 255)
							dxDrawText( getVehiclePlateText(v), x-180/2,y,180+x-180/2,30+y,tocolor(0,0,0,255), 1, seefont, "center","center",false,false,true,true )
						end
					end
				end
			end
		end
	end
end)



function onoff(key, state)
	if(key=="F10" and state=="down")then
		if bekapcs == true then
			bekapcs = false
		elseif bekapcs == false then
			bekapcs = true
		end
	end
end
bindKey("F10", "down", onoff)
