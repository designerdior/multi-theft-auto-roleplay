local showIcons = true
local marker = nil
local sx, sy = guiGetScreenSize()
local rel = ((sx/1920)+(sy/1080))/2

local notificationData = {}

local notificationFont = dxCreateFont('files/OpenSansB.ttf', 14*rel)
local infosFont = dxCreateFont('files/opensans.ttf', 11*rel)
local iconsFont = dxCreateFont('files/icons.ttf', 24*rel)

function renderInteriorPanel()
	--if isElement(marker) then
		for k, v in pairs(notificationData) do
			if (v.State == 'fadeIn') then
				local alphaProgress = (getTickCount() - v.AlphaTick) / 650
				local alphaAnimation = interpolateBetween(0, 0, 0, 255, 0, 0, alphaProgress, 'Linear')

				if (alphaAnimation) then
					v.Alpha = alphaAnimation
				else
					v.Alpha = 255
				end

				if (alphaProgress > 1) then
					v.Tick = getTickCount()
					v.State = 'openTile'
				end
			elseif (v.State == 'fadeOut') then
				local alphaProgress = (getTickCount() - v.AlphaTick) / 650
				local alphaAnimation = interpolateBetween(255, 0, 0, 0, 0, 0, alphaProgress, 'Linear')

				if (alphaAnimation) then
					v.Alpha = alphaAnimation
				else
					v.Alpha = 0
				end

				if (alphaProgress > 1) then
					notificationData = {}
				end
			elseif (v.State == 'openTile') then
				local tileProgress = (getTickCount() - v.Tick) / 350
				local tilePosition = interpolateBetween(v.StartX, 0, 0, v.EndX, 0, 0, tileProgress, 'Linear')
				local tileWidth = interpolateBetween(0, 0, 0, v.Width, 0, 0, tileProgress, 'Linear')

				if (tilePosition and tileWidth) then
					v.CurrentX = tilePosition
					v.CurrentWidth = tileWidth
				else
					v.CurrentX = v.EndX
					v.CurrentWidth = v.Width
				end

				if (tileProgress > 1) then
					if becsukva then
						v.State = 'fixTile'
						v.Tick = getTickCount()
						v.State = 'closeTile'
					end
				end
			elseif (v.State == 'closeTile') then
				local tileProgress = (getTickCount() - v.Tick) / 350
				local tilePosition = interpolateBetween(v.EndX, 0, 0, v.StartX, 0, 0, tileProgress, 'Linear')
				local tileWidth = interpolateBetween(v.Width, 0, 0, 0, 0, 0, tileProgress, 'Linear')

				if (tilePosition and tileWidth) then
					v.CurrentX = tilePosition
					v.CurrentWidth = tileWidth
				else
					v.CurrentX = v.StartX
					v.CurrentWidth = 0
				end

				if (tileProgress > 1) then
					v.AlphaTick = getTickCount()
					v.State = 'fadeOut'
				end
			elseif (v.State == 'fixTile') then
				v.Alpha = 255
				v.CurrentX = v.EndX
				v.CurrentWidth = v.Width
			end

			roundedRectangle(v.CurrentX - 60*rel, sy/2 + 350*rel, 65*rel + v.CurrentWidth, 65*rel, tocolor(0, 0, 0, 150 * v.Alpha / 255))
			dxDrawRectangle(v.CurrentX - 60*rel, sy/2 + 350*rel, 65*rel, 65*rel, tocolor(0, 0, 0, 255 * v.Alpha / 255))

			if (v.Alpha == 255) then
				dxDrawText(v.Text, v.CurrentX + 40*rel, sy/2 + 360*rel, v.CurrentX + v.CurrentWidth - 40*rel, sy/2 + 375*rel, tocolor(153, 255, 153, 255), 1, notificationFont, 'center', 'center', true, false, true)
				dxDrawText("Nyomj [E] gombot a belépéshez.", v.CurrentX + 25*rel, sy/2 + 385*rel, v.CurrentX + v.CurrentWidth - 20*rel, sy/2 + 410*rel, tocolor(255, 255, 255, 255), 1, infosFont, 'center', 'center', true, false, true)
			end

			if (v.Type == 0) then
				--dxDrawText('', v.CurrentX + 5, sy/2 - 50/2+325, v.CurrentX + 5 + 50 - 10, 20 + sy/2 - 50/2+300, tocolor(255, 255, 255, v.Alpha), 1, iconsFont, 'center', 'center', false, false, true)
				dxDrawImage(v.CurrentX - 60*rel, sy/2 + 350*rel, 64*rel, 64*rel, "files/icons/status.png",0,0,0,tocolor(255,255,255,255 * v.Alpha / 255),true)
			elseif (v.Type == 1) then
				dxDrawImage(v.CurrentX - 60*rel, sy/2 + 350*rel, 64*rel, 64*rel, "files/icons/elado.png",0,0,0,tocolor(255,255,255,255 * v.Alpha / 255),true)
			elseif (v.Type == 2) then
				dxDrawImage(v.CurrentX - 60*rel, sy/2 + 350*rel, 64*rel, 64*rel, "files/icons/status.png",0,0,0,tocolor(255,255,255,255 * v.Alpha / 255),true)
			elseif (v.Type == 4) then
				dxDrawImage(v.CurrentX - 60*rel, sy/2 + 350*rel, 64*rel, 64*rel, "files/icons/garazs.png",0,0,0,tocolor(255,255,255,255 * v.Alpha / 255),true)
			end
		end
	--end
end
addEventHandler("onClientRender", getRootElement(), renderInteriorPanel)

function clientMarkerHit(thePlayer, matchingDimension)
	cancelEvent()
	if thePlayer == localPlayer then
		if getElementDimension(source) == getElementDimension(thePlayer) then
			if getElementData(source,"isIntMarker") == true or getElementData(source,"isIntOutMarker") == true then
				marker = nil
				bindKey("e", "down", bindKeyInteriorFunctions)
				bindKey("k", "down", lockInteriorFunctions)
				setElementData(thePlayer, "isInIntMarker",true)
				setElementData(thePlayer, "int:Marker", source)
				marker = source
				local inttype = getElementData(marker,"inttype")
				local owner = getElementData(marker,"owner")
				local ownerName = getElementData(marker,"ownerName") or "Senki"
				local intCost = getElementData(marker,"cost")
				if (inttype==4) then
					text = "["..tonumber(getElementData(marker,"dbid")).."] Garázs"
				else
					text = "["..tonumber(getElementData(marker,"dbid")).."] "..tostring(getElementData(marker,"name"))..""
				end

				-- sima
				if inttype == 0 and owner <= 0 then
					infoText = "Ára: " .. tostring(getElementData(marker,"cost")) .. " $."
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF A vásárláshoz nyomd meg az [E] gombot! #32b3ef("..intCost.."$)",153, 255, 153,true)
				elseif inttype == 0 and owner >= 1 then
					infoText = "Tulaj: " ..string.gsub(ownerName, "_", " ") .. ""
				-- biznisz
				elseif inttype == 1 and owner <= 0 then
					infoText = "Ára: " .. tostring(getElementData(marker,"cost")) .. " $."
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF A vásárláshoz nyomd meg az [E] gombot! #32b3ef("..intCost.."$)",153, 255, 153,true)
				elseif inttype == 1 and owner >= 1 then
					infoText = "Tulaj: " ..string.gsub(ownerName, "_", " ") .. ""
				-- önkoris(bolt, stb...)
				elseif inttype == 2 then
					infoText = "Állami épület."
				-- garázs
				elseif inttype == 4 and owner <= 0 then
					infoText = "Ára: " .. tostring(getElementData(marker,"cost")) .. " $."
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF A vásárláshoz nyomd meg az [E] gombot! #32b3ef("..intCost.."$)", 153, 255, 153,true)
				elseif inttype == 4 and owner >= 1 then
					infoText = "Tulaj: " ..string.gsub(ownerName, "_", " ") .. ""
				else
					infoText = "Hibás interior"
				end

				if (notificationData ~= nil) then
					table.remove(notificationData, #notificationData)
				end

				table.insert(notificationData,
					{
						StartX = (sx / 2) - 12*rel,
						EndX = (sx / 2) - 115*rel,
						Text = text,
						Width = 280*rel,
						Alpha = 0,
						State = 'fadeIn',
						Tick = 0,
						AlphaTick = getTickCount(),
						CurrentX = (sx / 2) - 12*rel,
						CurrentWidth = 0,
						Type = inttype
					}
				)
				if getElementData(localPlayer, "adminduty") then
					if inttype == 0 and owner >= 1 or inttype == 1 and owner >= 1 or inttype == 4 and owner >= 1 then
						outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFFInterior tulaja: #32b3ef"..(ownerName:gsub("_", " ")), 153, 255, 153, true)
					end
				end
			end
		end
	end
end
addEventHandler("onClientMarkerHit", resourceRoot, clientMarkerHit)

addEventHandler("onClientMarkerLeave", resourceRoot, function(thePlayer, matchingDimension)
	if thePlayer == localPlayer then
		marker = nil
		unbindKey("e", "down", bindKeyInteriorFunctions)
		unbindKey("k", "down", lockInteriorFunctions)
		setElementData(thePlayer, "isInIntMarker",false)
		setElementData(thePlayer, "int:Marker", nil)
		for k, v in pairs(notificationData) do
			v.State = 'fixTile'
			v.Tick = getTickCount()
			v.State = 'closeTile'
		end
	end
end)

function bindKeyInteriorFunctions()
	if isElement(marker) then
		local theElement = getElementData(marker, "other")
		if theElement then
			local intID = getElementData(marker,"dbid")
			local intLocked = getElementData(marker,"locked")
			local intType = getElementData(marker,"inttype")
			local intOwner = getElementData(marker,"owner")
			local intCost = getElementData(marker,"cost")
			if intType == 0 and intOwner <= 0 then

				local count = 0
				for k, v in ipairs(getElementsByType("marker")) do
					if getElementData(v, "owner") == getElementData(localPlayer, "dbid") and getElementData(v, "dbid") and not getElementData(v,"isIntOutMarker") then
						count = count + 1
					end
				end

				--if count >= getElementData(localPlayer, "char:houseSlot") then
				--	outputChatBox(count)
				--	outputChatBox(getElementData(localPlayer, "char:houseSlot"))
				--	outputChatBox("#7cc576#7cc576[SeeMTA]: #FFFFFF Nincs elég interior slotod!", 255, 255, 255, true)
				--	return
				--end

				if getElementData(localPlayer,"money") >= intCost then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFSikeresen vettél egy házat. #7cc576("..intCost.." $.)",124, 197, 118,true)
					triggerServerEvent("updateInteriorOwner", localPlayer, intID, intCost)
				else
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFNincs nálad elég pénz, hogy megvehesd ezt az ingatlant.",124, 197, 118,true)
				end
			elseif intType == 1 and intOwner <= 0 then

				local count = 0
				for k, v in ipairs(getElementsByType("marker")) do
					if getElementData(v, "owner") == getElementData(localPlayer, "dbid") and getElementData(v, "dbid") and not getElementData(v,"isIntOutMarker") then
						count = count + 1
					end
				end

				--if count >= getElementData(localPlayer, "char:houseSlot") then
				--	outputChatBox(count)
				--	outputChatBox(getElementData(localPlayer, "char:houseSlot"))
				--	outputChatBox("#7cc576#7cc576[SeeMTA]: #FFFFFF Nincs elég interior slotod!", 255, 255, 255, true)
				--	return
				--end


				if getElementData(localPlayer,"money") >= intCost then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen vettél egy bizniszt. #7cc576("..intCost.." $.)",124, 197, 118,true)
					triggerServerEvent("updateInteriorOwner", localPlayer, intID, intCost)
				else
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF Nincs nálad elég pénz, hogy megvehesd ezt az ingatlant.",124, 197, 118,true)
				end
			elseif intType == 4 and intOwner <= 0 then

				local count = 0
				for k, v in ipairs(getElementsByType("marker")) do
					if getElementData(v, "owner") == getElementData(localPlayer, "dbid") and getElementData(v, "dbid") and not getElementData(v,"isIntOutMarker") then
						count = count + 1
					end
				end

				--if count >= getElementData(localPlayer, "char:houseSlot") then
				--	outputChatBox(count)
				--	outputChatBox(getElementData(localPlayer, "char:houseSlot"))
				--	outputChatBox("#7cc576#7cc576[SeeMTA]: #FFFFFF Nincs elég interior slotod!", 255, 255, 255, true)
				--	return
				--end

				if getElementData(localPlayer,"money") >= intCost then

					triggerServerEvent("updateInteriorOwner", localPlayer, intID, intCost)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen vettél egy garázst. #7cc576("..intCost.." $.)",124, 197, 118,true)


				else
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF Nincs nálad elég pénz, hogy megvehesd ezt az ingatlant.",124, 197, 118,true)
				end
			else
				if intLocked == 0 then
					if isPedInVehicle(localPlayer) and intType == 4 then
						local x,y,z = getElementData(theElement,"x"),getElementData(theElement,"y"),getElementData(theElement,"z")
						local veh = getPedOccupiedVehicle(localPlayer)
						setElementPosition(veh, x, y, z)
						setElementDimension(veh, getElementDimension(theElement))
						setElementInterior(veh, getElementInterior(theElement))

						setElementDimension(localPlayer, getElementDimension(theElement))
						setElementInterior(localPlayer, getElementInterior(theElement))
						lockedSound = playSound("files/sounds/intenter.mp3")
					else
						if not isPedInVehicle(localPlayer) then
							local x,y,z = getElementData(theElement,"x"),getElementData(theElement,"y"),getElementData(theElement,"z")
							setElementPosition(localPlayer, x, y, z)
							setElementDimension(localPlayer, getElementDimension(theElement))
							setElementInterior(localPlayer, getElementInterior(theElement))
							lockedSound = playSound("files/sounds/intenter.mp3")
						else
							outputChatBox("#7cc576[SeeMTA]: #FFFFFF Ez nem egy garázs.",124, 197, 118,true)
						end
					end
				else
					if isElement(lockedSound) then
						destroyElement(lockedSound)
					end
					lockedSound = playSound("files/sounds/locked.mp3")
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF A kiválasztott ingatlan zárva van.",124, 197, 118,true)
				end
			end
		end
	end
end

function lockInteriorFunctions()
	if isElement(marker) then
		local markID = tonumber(getElementData(marker, "dbid")) or 0
		local markType = tostring(getElementData(marker, "inttype")) or nil
		local markLocked = tonumber(getElementData(marker, "locked")) or 0
		if markID then
			if getElementData(localPlayer, "adminduty") or exports.sas_items:hasItem(localPlayer, 12, markID) then
				local theElement = getElementData(marker, "other")
				if theElement then
					if markLocked == 0 then
						if isElement(openCloseSound) then
							destroyElement(openCloseSound)
						end
						openCloseSound = playSound("files/sounds/openclose.mp3")
						setElementData(marker, "locked", 1)
						setElementData(theElement, "locked", 1)
						exports["sas_global"]:sendLocalMeMessage(localPlayer,"bezárja az ingatlant. ("..string.gsub(getElementData(marker, "name") or getElementData(theElement, "name"), "_", " ")..")")
						triggerServerEvent("lockIntToClient",localPlayer,tonumber(markID),1)
						return
					else
						if isElement(openCloseSound) then
							destroyElement(openCloseSound)
						end
						openCloseSound = playSound("files/sounds/openclose.mp3")
						setElementData(marker, "locked", 0)
						setElementData(theElement, "locked", 0)
						exports["sas_global"]:sendLocalMeMessage(localPlayer,"kinyitja az ingatlant. ("..string.gsub(getElementData(marker, "name") or getElementData(theElement, "name"), "_", " ")..")")
						triggerServerEvent("lockIntToClient",localPlayer,tonumber(markID),0)
						return
					end
				end
			else
				outputChatBox("#7cc576[SeeMTA]: #FFFFFF A kiválasztott ingatlanhoz nincs kulcsod.",124, 197, 118,true)
			end
		end
	end
end


local png = tag1
local scale = 0
local tag1 = dxCreateTexture("files/icons/elado.png")
local tag2 = dxCreateTexture("files/icons/haz.png")
local tag3 = dxCreateTexture("files/icons/allami.png")
local tag4 = dxCreateTexture("files/icons/garazs.png")
addEventHandler("onClientRender", getRootElement(),function()
	if showIcons == true then
		for k,v in pairs(getElementsByType("marker")) do
			if isElement(v) and v then
				if getElementType(v) == "marker" and isElementStreamedIn(v) and getElementData(v, "dbid") then
					local Marker = v
					local markType = getElementData(v,"inttype")
					local markOwner = getElementData(v,"owner")
					if markType == 0 and markOwner <= 0 then
						png = tag1
						ic1,ic2,ic3 = 124, 197, 118
					elseif markType == 0 and markOwner >= 1 then
						png = tag2
						ic1,ic2,ic3 = 66, 150, 245
					elseif markType == 1 then
						png = tag3
						ic1,ic2,ic3 = 221, 118, 0
					elseif markType == 2 then
						png = tag3
						ic1,ic2,ic3 = 221, 118, 0
					elseif markType == 4 then
						png = tag4
						ic1,ic2,ic3 = 66, 150, 245
					end
					local px,py,pz = getElementPosition(localPlayer)
					local x, y, z = getElementPosition(v)
					dxDrawImageOnElement(Marker, png,1000,1,0.4, ic1, ic2, ic3, 200)
				end
			end
		end
	end
end)

function dxDrawImageOnElement(TheElement,Image,distance,height,width,R,G,B,alpha)
	local x, y, z = getElementPosition(TheElement)
	local x2, y2, z2 = getElementPosition(localPlayer)
	local distance = distance or 20
	local height = height or 1
	local width = width or 1
	local checkBuildings = checkBuildings or true
	local checkVehicles = checkVehicles or false
	local checkPeds = checkPeds or false
	local checkObjects = checkObjects or true
	local checkDummies = checkDummies or true
	local seeThroughStuff = seeThroughStuff or false
	local ignoreSomeObjectsForCamera = ignoreSomeObjectsForCamera or false
	local ignoredElement = ignoredElement or nil
	local sx, sy = getScreenFromWorldPosition(x, y, z+height)
	if(sx) and (sy) then
		local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
		if(distanceBetweenPoints < distance) then
			dxDrawMaterialLine3D(x, y, z+0.4+height-(distanceBetweenPoints/distance)-0.3, x, y, z+height-0.3, Image, width-(distanceBetweenPoints/distance), tocolor(R or 255, G or 255, B or 255, alpha or 255))
		end
	end
end

addCommandHandler("togicons",function()
	showIcons = not showIcons
	if showIcons == true then
		outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen bekapcsoltad az interior-ok ikonjait.",124, 197, 118,true)
	else
		outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen kikapcsoltad az interior-ok ikonjait.",124, 197, 118,true)
	end
end)

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200)
		end

		if (not bgColor) then
			bgColor = borderColor
		end

		--> Background
		dxDrawRectangle(x, y, w, h, bgColor, postGUI)

		--> Border
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI) -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI) -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI) -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI) -- right
	end
end


function getCursorPositionAdded()
    return cursorX, cursorY
end
