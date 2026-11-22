local font = dxCreateFont("files/Roboto.ttf", 16)
local fontg = guiCreateFont("files/Roboto.ttf", 13)

local sx, sy = guiGetScreenSize()

local box = {500, 170}
local boxPosition = {(sx/2)-(box[1]/2), (sy/2-box[2]/2)}

local showPanel = false

local bankPeds = {
	{1468.9052734375, -1011.7841796875, 26.84375, 180},
	{1480.8447265625, -1013.09375, 26.84375, 180}
}

local invitingText = ""
local actualEditing = ""
local bankCountEdit = ""

local spamTimer

engineImportTXD(engineLoadTXD("files/atm.txd"), 2942)

addEventHandler("onClientCharacter", getRootElement(), function(character)
	if showPanel then
		if character == "." then return end
		local newText = invitingText .. character

		if tonumber(newText) then
			if tonumber(newText) >= 1 and tonumber(newText) <= 1000000000 then
				invitingText = newText
			end
		end
	end
end)

for k, v in ipairs(bankPeds) do
	local ped = createPed(121, v[1], v[2], v[3])
	setElementRotation(ped, 0,0, v[4])
	setElementData(ped, "bankThing", true)
	setElementData(ped, "tagName", "NPC")
	setElementData(ped, "visiblePedName", "Banki ügyintéző")
	setElementData(ped, "nameEnabled", true)
	setElementFrozen(ped, true)
end

local lastChangeCursorState = 0
local cursorState = false

function atmPanel()
	if showPanel then
		dxDrawRectangle(boxPosition[1], boxPosition[2], box[1], box[2], tocolor(0,0,0,180))
		exports.sas_system:radarKeret(boxPosition[1], boxPosition[2], box[1], box[2], 2, 255)
		dxDrawText("SeeMTA v3 - Bank", boxPosition[1]+1, boxPosition[2]-24, 0, 0, tocolor(0, 0, 0, 255),0.83,font,"left","top", false, false, false, true)

		dxDrawText("#7cc576SeeMTA v3 #FFFFFF- Bank", boxPosition[1], boxPosition[2]-25, 0, 0, tocolor(255, 255, 255, 255),0.83,font,"left","top", false, false, false, true)
		dxDrawText("#FFFFFFEgyenleg: #7cc576"..thousandsStepper(getElementData(localPlayer, "bankmoney")).. " $",boxPosition[1]+5, boxPosition[2]+5, 0, 0, tocolor(255, 255, 255, 255),0.8,font,"left","top", false, false, false, true)
		dxDrawRectangle(boxPosition[1]+5, boxPosition[2]+40, 490, 40, tocolor(99,99,99,180))
		dxDrawText("Összeg:", boxPosition[1]+8, boxPosition[2]+40, 0, boxPosition[2]+80, tocolor(255,255,255,255), 0.8, font, "left", "center")

		local time = getTickCount() - lastChangeCursorState

		if time >= 500 then
			cursorState = not cursorState
			lastChangeCursorState = getTickCount()
		end

		if actualEditing == "bankcounter" then
			bankCountEdit = invitingText
			local w = dxGetTextWidth(thousandsStepper(bankCountEdit), 0.8, font)
			if cursorState then
				dxDrawLine(boxPosition[1]+82+w, boxPosition[2]+40+5, boxPosition[1]+82+w,boxPosition[2]+80-5, tocolor(255, 255, 255, 255), 1)
			end
    	end
		dxDrawText(thousandsStepper(bankCountEdit), boxPosition[1]+80, boxPosition[2]+40, 0, boxPosition[2]+80, tocolor(255,255,255, 255), 0.8, font, "left", "center")

		if isInSlot(boxPosition[1]+5,boxPosition[2]+130,490,30) then
			dxDrawRectangle(boxPosition[1]+5,boxPosition[2]+130,490,30,tocolor(217, 83, 79,255))
		else
			dxDrawRectangle(boxPosition[1]+5,boxPosition[2]+130,490,30,tocolor(217, 83, 79,200))
		end
		dxDrawText("Kilépés",boxPosition[1]+5,boxPosition[2]+130, boxPosition[1]+495,boxPosition[2]+160, tocolor(255, 255, 255, 255),0.8,font,"center","center", false, false, false, true)

		if isInSlot(boxPosition[1]+5, boxPosition[2]+90,243,30) then
			dxDrawRectangle(boxPosition[1]+5, boxPosition[2]+90,243,30,tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(boxPosition[1]+5, boxPosition[2]+90,243,30,tocolor(124, 197, 118,150))
		end
		dxDrawText("#FFFFFFKivétel",boxPosition[1]+5, boxPosition[2]+90, boxPosition[1]+248, boxPosition[2]+120, tocolor(255, 255, 255, 255),0.8,font,"center","center", false, false, false, true)
		if isInSlot(boxPosition[1]+5+248, boxPosition[2]+90,243,30,243,30) then
			dxDrawRectangle(boxPosition[1]+5+248, boxPosition[2]+90,243,30,tocolor(124,197,118,200))
		else
			dxDrawRectangle(boxPosition[1]+5+248, boxPosition[2]+90,243,30,tocolor(124,197,118,150))
		end
		dxDrawText("#FFFFFFBefizetés",boxPosition[1]+5+248, boxPosition[2]+90,boxPosition[1]+5+248+243, boxPosition[2]+120, tocolor(255, 255, 255, 255),0.8,font,"center","center", false, false, false, true)
	end
end

function clickOnATM(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickElement)
	if not isElement(clickElement) then return end
	if state == "down" and button == "right" then
		if getElementData(clickElement, "bankThing") then
			local x, y, z = getElementPosition(localPlayer)
			local ex, ey, ez = getElementPosition(clickElement)
			if getDistanceBetweenPoints3D(x, y, z, ex, ey, ez) <= 3 then
				showPanel = true
				addEventHandler("onClientRender", getRootElement(), atmPanel)
				setElementData(localPlayer, "toggleInterface", true)
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickOnATM)

function tax(amount)
	local tax = 0

	if amount > 10 then
		tax = math.ceil(amount/100)
	end

	return tax
end

function clickOnButtons(button, state, x,y)
    if showPanel then
		if button == "left" and state == "down" then
			if showPanel and isInSlot(boxPosition[1]+5,boxPosition[2]+130,490,30) then
				showPanel = false
				removeEventHandler("onClientRender", getRootElement(), atmPanel)
			elseif showPanel and isInSlot(boxPosition[1]+5+248, boxPosition[2]+90,243,30) and not isSpam() then
				if bankCountEdit ~= "" then
					local amount = tonumber(bankCountEdit)
					if getElementData(localPlayer, "money") >= amount then
						triggerServerEvent("server->takeMoney", localPlayer, amount, tax(amount))
						bankCountEdit = ""
					else
						exports.sas_hud:addNotification("Nincs elég pénz nálad!", "error")
					end
				end
			elseif showPanel and isInSlot(boxPosition[1]+5, boxPosition[2]+90,243,30) and not isSpam() then
				if bankCountEdit ~= "" then
					local amount = tonumber(bankCountEdit)
					if getElementData(localPlayer, "bankmoney") >= amount then
						triggerServerEvent("server->giveMoney", localPlayer, amount, tax(amount))
						bankCountEdit = ""
					else
						exports.sas_hud:addNotification("Nincs elég pénz a bankszámládon!", "error")
					end
				end
			end
    	end
	end
end
addEventHandler("onClientClick", getRootElement(), clickOnButtons)

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

function isSpam()
    if isTimer(spamTimer) then
        return true
    end
    spamTimer = setTimer(function() end, 5000, 1)
    return false
end

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
    if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
        return true
    else
        return false
    end
end

function clickOnEdits(button, state, x,y)
    if button == "left" and state == "down" then
      if showPanel then
        if isInSlot(boxPosition[1]+5, boxPosition[2]+40, 490, 40) then
           actualEditing = "bankcounter"
           invitingText = bankCountEdit
           alphaAnim = true
			else
				actualEditing = ""
			end
		end
    end
end
addEventHandler("onClientClick", getRootElement(), clickOnEdits)


addEventHandler("onClientKey",getRootElement(),function(button,state)
	if button == "backspace" and state then
		if showPanel then
			if string.len(invitingText) >= 1 then
				invitingText = string.sub(invitingText, 1, string.len(invitingText)-1)
			end
		end
	elseif button == "1" or button == "2" or button == "3" or button == "4" or button == "5" or button == "6" or button == "m" then
		if state then
			if showPanel then
				cancelEvent()
			end
		end
	end
end)

addCommandHandler("nearbyatms", function()
	if getElementData(localPlayer, "adminlevel") >= 8 then
		local van = false
		local px, py, pz = getElementPosition(localPlayer)
		outputChatBox("#7cc576[SeeMTA]: #ffffffKözeledben lévő ATMek:", 25, 152, 139, true)
		for k, v in ipairs(getElementsByType("object"), getRootElement(), true) do
			if getElementData(v, "bankThing") then
				local x, y, z = getElementPosition(v)
				if getDistanceBetweenPoints3D(px, py, pz, x, y, z) <= 10 then
					van = true
					outputChatBox("#7cc576[SeeMTA]: #ffffffID: "..getElementData(v, "bankID"), 25, 152, 139, true)
				end
			end
		end
		if not van then
			outputChatBox("#7cc576[SeeMTA]: #ffffffNincs a közeledben ATM", 25, 152, 139, true)
		end
	end
end)

addCommandHandler("pay", function(commandName, targetPlayerNick, amount)
	if getElementData(localPlayer, "loggedin") then
		if not (targetPlayerNick) or not tonumber(amount) then
			outputChatBox("Használd: /" .. commandName .. " [NévRészlet] [Összeg]", 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(localPlayer, targetPlayerNick)
			
			if targetPlayer then
				local x, y, z = getElementPosition(localPlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)
				local amount = math.abs(math.floor((tonumber(amount))))
				local tax = tax(amount)
				
				if localPlayer == targetPlayer then
					outputChatBox("#d75959[SeeMTA]: #ffffffMagadnak nem tudsz pénzt utalni.", 255, 255, 255, true)
					return
				elseif getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) > 10 then
					outputChatBox("#d75959[SeeMTA]: #ffffffTúl messze van a játékos.", 255, 255, 255, true)
					return
				elseif amount <= 0 then
					outputChatBox("#d75959[SeeMTA]: #ffffffNullánál nagyobb egész számot írj be!", 255, 255, 255, true)
					return
				elseif amount > getElementData(localPlayer, "money") then
					outputChatBox("#d75959[SeeMTA]: #ffffffNincs ennyi pénzed.", 255, 255, 255, true)
					return
				elseif isTimer(payTimer) then
					outputChatBox("#d75959[SeeMTA]: #ffffffMár van egy átadás folyamatban.", 255, 255, 255, true)
					return
				end

				outputChatBox("#7cc576[SeeMTA]: #ffffffHamarosan elindul a pénz átadása.", 255, 255, 255, true)

				payTimer = setTimer(function()
					local x, y, z = getElementPosition(localPlayer)
					local tx, ty, tz = getElementPosition(targetPlayer)

					if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) > 10 then
						outputChatBox("#d75959[SeeMTA]: #ffffffTúl messze kerültetek egymástól.", 255, 255, 255, true)
						return
					elseif amount > getElementData(localPlayer, "money") then
						outputChatBox("#d75959[SeeMTA]: #ffffffIdő közben elfogyott a pénzed.", 255, 255, 255, true)
						return
					end

					outputChatBox("#7cc576[SeeMTA]: #ffffffAdtál #2ab8e8"..targetPlayerName.."#ffffff-nak/nek #7cc576"..(amount - tax).." #ffffffdollárt. (Adó: #d75959"..tax.."#ffffff$)", 255, 255, 255, true)
					triggerServerEvent("server->payMoney", localPlayer, targetPlayer, amount, tax)
				end, 5000, 1)
			end
		end
	end
end)