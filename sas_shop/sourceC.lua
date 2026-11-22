
local sx,sy = guiGetScreenSize()

local boltShowing = false

local boltClickedItem = {}
local boltAdatok = {}
local shopguis = {}
local DB = 1
local state = 0
local tranzakcio = 0
local Scrolling = 0

local OpenSansSBL = dxCreateFont("files/OpenSansL.ttf",16)
local OpenSansSB = dxCreateFont("files/OpenSansSB.ttf",16)
local Roboto = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf",16)


local maxShowed = 12
local elem = 0

if isElement(shopgui) then
	destroyElement(shopgui)
end

function lekeres()
	for k,v in pairs(getElementsByType("ped")) do
		local pedName = getElementData(v, "visiblePedName")
		outputChatBox(pedName)
	end
end
addCommandHandler("lekernevek", lekeres)

function PedClick(button, state, absX, absY, wx, wy, wz, element)
	if element and getElementData(element, "shop:NPC") then
		if state == "down" and button == "right" then
			local x, y, z = getElementPosition(getLocalPlayer())
			if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz) <= 5 then
				boltMegjelenites(element)
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), PedClick, true)

function boltMegjelenites(boltos)
	if boltShowing then return end
	boltShowing = true
	removeEventHandler("onClientRender", getRootElement(), renderShop)
	addEventHandler("onClientRender", getRootElement(), renderShop)
	removeEventHandler("onClientClick", getRootElement(), boltKattintas)
	addEventHandler("onClientClick", getRootElement(), boltKattintas)
	boltAdatok = {getElementData(boltos, "Bolt:Tipus"), 1, 1, boltos}
	state = 1
end

function boltElrejtes()
	if not boltShowing then return end
	boltShowing = false
	state = 0
end

function renderShop ()
	if not boltShowing then return end
	local jX, jY, jZ = getElementPosition(getLocalPlayer())
	local bX, bY, bZ = getElementPosition(boltAdatok[4])
	if (getDistanceBetweenPoints3D(jX, jY, jZ, bX, bY, bZ) > 5 ) then
		boltElrejtes()
		boltShowing = false
		return
	end
	if state == 1 then

		exports.sas_system:addV3logo(sx/2-50,sy/2-350, true, 0, 100, 100)
		for i=1, maxShowed do
			if i %2 == 0 then
				dxDrawRectangle(sx/2-200,sy/2-200+(40*i)-38, 405, 40, tocolor(0,0,0,200))
			else
				dxDrawRectangle(sx/2-200,sy/2-200+(40*i)-38, 405, 40, tocolor(0,0,0,210))
			end
		end
		dxDrawText("Bolt",0,sy/2-230,sx,sy,tocolor(255,255,255,255),1,OpenSansSBL,"center")
		if isInSlot(sx/2+200-60,sy/2-225,60,20) then
			dxDrawRectangle(sx/2+200-60,sy/2-225,60,20,tocolor(205,92,92,255))
		else
			dxDrawRectangle(sx/2+200-60,sy/2-225,60,20,tocolor(205,92,92,200))
		end
		dxDrawText("Kilépés",sx/2+200-60,sy/2-225,sx/2+200,sy/2-205,tocolor(0,0,0,255),0.65,Roboto,"center", "center")

		local elem = 0
		for itemID=1,#ShopTipus[boltAdatok[1]][boltAdatok[2]] do
			if (itemID > Scrolling and elem < maxShowed) then
				elem = elem + 1
				if isInSlot(sx/2+200-80, sy/2-235+elem*(40)+7, 70, 20) then
					dxDrawRectangle(sx/2+200-80, sy/2-235+elem*(40)+7, 70, 20, tocolor(124, 197, 118, 255))
				else
					dxDrawRectangle(sx/2+200-80, sy/2-235+elem*(40)+7, 70, 20, tocolor(124, 197, 118, 200))
				end
				dxDrawImage(sx/2-195,sy/2-235+elem*40,36,36,":sas_items/files/items/"..getItemID(boltAdatok[1],boltAdatok[2],itemID)..".png")
				dxDrawText(exports.sas_items:getItemName(getItemID(boltAdatok[1],boltAdatok[2],itemID)),sx/2-153,sy/2-233+elem*40,sx,sy,tocolor(255,255,255,255),0.58,OpenSansSB)
				dxDrawText(" Ár: "..ShopTipus[boltAdatok[1]][boltAdatok[2]][itemID][5].." $",sx/2-150,sy/2-215+elem*40-2,sx,sy,tocolor(255,255,255,200),0.58,OpenSansSB)
				dxDrawText("Vásárlás",sx/2+200-80, sy/2-235+elem*(40)+7,sx/2+200-80+70, sy/2-235+elem*(40)+27,tocolor(0,0,0,200),0.63,Roboto,"center","center",false,false,false,true)
			end
		end
		--dxDrawRectangle(sx/2+200, sy/2+300-500, 5, 500)
		exports['sas_system']:gorgetesRajzolas(sx/2+200, sy/2+300-500+2, 5, 480, #ShopTipus[boltAdatok[1]][boltAdatok[2]], maxShowed, Scrolling, tocolor(0, 0, 0, 255))
	elseif state == 2 then
		DB  = tonumber(guiGetText(shopgui)) or 1
		dxDrawText("Vásárlás: "..boltClickedItem[2],0,sy/2-110,sx,sy,tocolor(255,255,255,255),1,OpenSansSBL,"center")
		dxDrawRectangle(sx/2-200,sy/2-75,400,150,tocolor(0,0,0,200))
		dxDrawText("Mennyiség: "..DB.." db\nEgységár: "..boltClickedItem[4].." $\nÖsszesen: "..boltClickedItem[4]*math.floor(DB).." $\n#7cc576Add meg a mennyiséget a billentyűzeteddel!",0,sy/2-70,sx,sy,tocolor(255,255,255,255),0.72,OpenSansSB,"center","top",false,false,false,true)

		if isInSlot(sx/2-100,sy/2+20,200,35) then
			dxDrawRectangle(sx/2-100,sy/2+20,200,35,tocolor(124, 197, 118,255))
		else
			dxDrawRectangle(sx/2-100,sy/2+20,200,35,tocolor(124, 197, 118,200))
		end
		dxDrawText("Vásárlás",0,sy/2+25,sx,sy,tocolor(255,255,255,255),1,OpenSansSB,"center")
	end
end


addEventHandler("onClientKey", root, function(k,v)
	if not boltShowing then return end
	if k == "backspace" and v then
		--boltElrejtes()
		state = 1
	elseif k == "enter" and v and state == 2 then
		vasarlas()
	end
end)

function boltKattintas(gomb, statusz, x, y)
	if not boltShowing then return end
	if(gomb == "left" and statusz == "down") then
		local elem = 0
		for itemID=1,#ShopTipus[boltAdatok[1]][boltAdatok[2]] do
			if (itemID > Scrolling and elem < maxShowed) then
				elem = elem + 1
				if isInSlot(sx/2+200-80, sy/2-235+elem*(41), 70, 20) and state == 1 then
					boltClickedItem = {getItemID(boltAdatok[1],boltAdatok[2],itemID),exports.sas_items:getItemName(getItemID(boltAdatok[1],boltAdatok[2],itemID)),ShopTipus[boltAdatok[1]][boltAdatok[2]][itemID][4],ShopTipus[boltAdatok[1]][boltAdatok[2]][itemID][5]}
					state = 2
					if isElement(shopgui) then
						destroyElement(shopgui)
					end
					shopgui = guiCreateEdit(-1000, -1000, 0, 0, "", false)
					if guiEditSetCaretIndex(shopgui, string.len(guiGetText(shopgui))) then
						guiBringToFront(shopgui)
					end
				end
			end
		end
		if isInSlot(sx/2+200-60,sy/2-230,60,20) and state == 1 then --Kilépés gomb
			boltElrejtes()
		end
		if isInSlot(sx/2-100,sy/2+20,200,35) and state == 2 then --Vásárlás gomb
			vasarlas()
		end
	end
end

function vasarlas()
	if DB > 0 and DB < 51 then
		if tonumber(getElementData(localPlayer, "money")) >= tonumber(boltClickedItem[4]*math.floor(DB)) then
			triggerServerEvent("Vasarlas", localPlayer, boltClickedItem[1], 1, math.floor(DB), boltClickedItem[4])
			boltElrejtes()
			boltShowing = false
			if isElement(shopgui) then
				destroyElement(shopgui)
			end
		else
			exports.sas_hud:addNotification("Nincs elég pénzed a vásárláshoz!","warning")
		end
	else
		exports.sas_hud:addNotification("Nem vehetsz 50db-nál többet!","warning")
	end
end

function getItemID(Tipus,Tabla,SorErtek)
	return ShopTipus[Tipus][Tabla][SorErtek][1] or false
end


function moneySplit(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
    if (k==0) then
      break
    end
  end
  return formatted
end


function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(isInBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end


addEventHandler("onClientPedDamage",  getRootElement(), function()
	if(getElementData(source, "shop:NPC")) then
		cancelEvent()
	end
end)

bindKey("mouse_wheel_down", "down",
	function()
		if boltShowing then
			if Scrolling < #ShopTipus[boltAdatok[1]][boltAdatok[2]] - maxShowed then
				Scrolling = Scrolling + 1
			end
		end
	end
)

bindKey("mouse_wheel_up", "down",
	function()
		if boltShowing then
			if Scrolling > 0 then
				Scrolling = Scrolling - 1
			end
		end
	end
)
