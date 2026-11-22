bindKey("b", "down", "chatbox", "LocalOOC")
bindKey( "m", "down", "togglecursor" )

-- Local OOC bind
bindKey( "b", "down", "chatbox", "LocalOOC" )

data = { }
function datachange(value)
	if (data[value] == nil) then
		data[value] = 1
	else
		data[value] = data[value] + 1
	end
end
addEventHandler("onClientElementDataChange", getRootElement(), datachange)

function playRadioSound()
	playSoundFrontEnd(47)
	setTimer(playSoundFrontEnd, 700, 1, 48)
	setTimer(playSoundFrontEnd, 800, 1, 48)
end
addEvent( "playRadioSound", true )
addEventHandler( "playRadioSound", getRootElement(), playRadioSound )


local tick = getTickCount()
function showdata()
	local tick2 = getTickCount()
	local time = (tick2 - tick) / 1000
	outputChatBox("Sync for " .. time .. " seconds.")

	local largest = 0
	local largestname = "none"
	for key, value in pairs(data) do
		if (value>=5) then
			if (value>largest) and (value~="scoreboard:reload") then
				largest = value
				largestname = key
			end
			outputChatBox(tostring(key) .. ": ".. value)
		end
	end

	outputChatBox("Largest was: ".. largestname .. ": " .. largest)
end
addCommandHandler("showdata", showdata)



local textcolor = tocolor(255,255,255,255)
local textsToDraw = {}

local showtime = 10000
local characteraddition = 50

function income(text, r, g, b)
	--if r == 133 and g == 44 and b == 89 then
		local newtext = text:gsub("#%x+ %[%w+%] (%w+) (%w+) %w+: ","%1_%2|")
		if newtext then
			local pos = newtext:find("|")
			if pos then
				local name = newtext:sub( 0, pos - 1 )
				local newtext = newtext:sub( pos + 1 )

				local player = getPlayerFromName( name )
				if (isElement(player)) then
					addText(player, newtext)
				end
			end
		end
	--end
end

function addText(source,message)
	local notfirst = false
	for i,v in ipairs(textsToDraw) do
		if v[1] == source then
			v[3] = v[3] + 1
			notfirst = true
		end
	end
	local infotable = {source,message,0}
	table.insert(textsToDraw,infotable)
	if not notfirst then
		setTimer(removeText,showtime + (#message * characteraddition),1,infotable)
	end
end

function removeText(infotable)
	for i,v in ipairs(textsToDraw) do
		if v[1] == infotable[1] and v[2] == infotable[2] then
			for i2,v2 in ipairs(textsToDraw) do
				if v2[1] == v[1] and v[3] - v2[3] == 1 then
					setTimer(removeText,showtime + (#v[2] * characteraddition),1,v2)
				end
			end
			table.remove(textsToDraw,i)
			break
		end
	end
end

function getTextsToRemove()
	for i,v in ipairs(textsToDraw) do
		if v[1] == source then
			removeText(v)
		end
	end
end

function handleDisplay()
	for i,v in ipairs(textsToDraw) do
		local camPosXl, camPosYl, camPosZl = getPedBonePosition (v[1], 6)
		local camPosXr, camPosYr, camPosZr = getPedBonePosition (v[1], 7)
		local x,y,z = (camPosXl + camPosXr) / 2, (camPosYl + camPosYr) / 2, (camPosZl + camPosZr) / 2
		--local posx,posy = getScreenFromWorldPosition(x,y,z+0.25)
		local cx,cy,cz = getCameraMatrix()
		local px,py,pz = getElementPosition(v[1])
		local distance = getDistanceBetweenPoints3D(cx,cy,cz,px,py,pz)
		local posx,posy = getScreenFromWorldPosition(x,y,z+0.020*distance+0.10)
		if posx and distance <= 45 and ( isLineOfSightClear(cx,cy,cz,px,py,pz,true,true,false,true,false,true,true,getPedOccupiedVehicle(getLocalPlayer())) or isLineOfSightClear(cx,cy,cz,px,py,pz,true,false,false,true,false,true,true,getPedOccupiedVehicle(v[1])) ) then -- change this when multiple ignored elements can be specified
			local width = dxGetTextWidth(v[2],1,"default")

			dxDrawRectangle(posx - (3 + (0.5 * width)),posy - (2 + (v[3] * 20)),width + 5,19,tocolor(0,0,0,255))
			dxDrawRectangle(posx - (6 + (0.5 * width)),posy - (2 + (v[3] * 20)),width + 11,19,tocolor(0,0,0,40))
			dxDrawRectangle(posx - (8 + (0.5 * width)),posy - (1 + (v[3] * 20)),width + 15,17,tocolor(0,0,0,255))
			dxDrawRectangle(posx - (10 + (0.5 * width)),posy - (1 + (v[3] * 20)),width + 19,17,tocolor(0,0,0,40))
			dxDrawRectangle(posx - (10 + (0.5 * width)),posy - (v[3] * 20) + 1,width + 19,13,tocolor(0,0,0,255))
			dxDrawRectangle(posx - (12 + (0.5 * width)),posy - (v[3] * 20) + 1,width + 23,13,tocolor(0,0,0,40))
			dxDrawRectangle(posx - (12 + (0.5 * width)),posy - (v[3] * 20) + 4,width + 23,7,tocolor(0,0,0,255))

			-- dxDrawText("This is a message! font:default",400,100,400,100,tocolor(255,255,255,255),1,"default")
			-- dxDrawText("This is a message! font:default-bold",400,130,400,130,tocolor(255,255,255,255),1,"default-bold")
			-- dxDrawText("This is a message! font:clear",400,160,400,160,tocolor(255,255,255,255),1,"clear")
			-- dxDrawText("This is a message! font:arial",400,190,400,190,tocolor(255,255,255,255),1,"arial")
			-- dxDrawText("This is a message! font:pricedown",400,220,400,220,tocolor(255,255,255,255),1,"pricedown")
			-- dxDrawText("This is a message! font:bankgothic",400,250,400,250,tocolor(255,255,255,255),1,"bankgothic")
			-- dxDrawText("This is a message! font:diploma",400,280,400,280,tocolor(255,255,255,255),1,"diploma")
			-- dxDrawText("This is a message! font:beckett",400,310,400,310,tocolor(255,255,255,255),1,"beckett")
			-- dxDrawText("This is a message! font:sans",400,340,400,340,tocolor(255,255,255,255),1,"sans")

			dxDrawText(v[2],posx - (0.5 * width),posy - (v[3] * 20),posx - (0.5 * width),posy - (v[3] * 20),textcolor,1,"default","left","top",false,false,false)
		end
	end
end

addEventHandler("onClientPlayerQuit",getRootElement(),getTextsToRemove)
addEventHandler("onClientRender",getRootElement(),handleDisplay)
addEventHandler("onClientChatMessage",getRootElement(),income)


local chatting = 0
local chatters = { }

function checkForChat()
	local recon = getElementData(getLocalPlayer(), "reconx")

	if not (reconx) then
		if (isChatBoxInputActive() and chatting==0) then
			chatting = 1
			triggerServerEvent("chat1", getLocalPlayer())
		elseif (not isChatBoxInputActive() and chatting==1) then
			chatting = 0
			triggerServerEvent("chat0", getLocalPlayer())
		end
	end
end
setTimer(checkForChat, 100, 0)



function addChatter()
	for key, value in ipairs(chatters) do
		if ( value == source ) then
			return
		end
	end
	table.insert(chatters, source)
end
addEvent("addChatter", true)
addEventHandler("addChatter", getRootElement(), addChatter)

function delChatter()
	for key, value in ipairs(chatters) do
		if ( value == source ) then
			table.remove(chatters, key)
		end
	end
end
addEvent("delChatter", true)
addEventHandler("delChatter", getRootElement(), delChatter)
addEventHandler("onClientPlayerQuit", getRootElement(), delChatter)

function render()
	local x, y, z = getElementPosition(getLocalPlayer())
	local reconx = getElementData(getLocalPlayer(), "reconx")
	for key, value in ipairs(chatters) do
		if (isElement(value)) then
			if getElementType(value) == "player" then
				local px, py, pz = getPedBonePosition(value, 6)

				local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
				if isElementOnScreen(value) and not getElementData(value, "reconx") and not getElementData(value, "freecam:state") then
					if (dist>25) then
						chatters[value] = nil
						return
					end

					local lx, ly, lz = getCameraMatrix()
					local vehicle = getPedOccupiedVehicle(value)
					if (vehicle) then
						local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, px, py, pz+1.5, true, true, true, true, false, false, true, false, vehicle)
					else
						local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, px, py, pz+1.5, true, true, true, true, false, false, true, false)
					end
					if not (collision) or (reconx) then
						local screenX, screenY = getScreenFromWorldPosition(px, py, pz+1)
						if (screenX and screenY) then
							dist = dist / 5

							if (dist<1) then dist = 1 end
							if (dist>4 and reconx) then dist = 4 end


							local offset = 70 / dist

							local draw = dxDrawImage(screenX, screenY, (256*0.7) / dist, (256*0.7) / dist, "typing.png")
						end
					end
				end
			else
				chatters[key] = nil
			end
		else
			chatters[key] = nil
		end
	end
end
addEventHandler("onClientRender", getRootElement(), render)

chaticon = true
function toggleChatIcon()
	if (chaticon) then
		triggerServerEvent("chaticon0", getLocalPlayer())
		outputChatBox("Chat ikonok kikapcsolva.", 255, 0, 0)
		chaticon = false
		removeEventHandler("onClientRender", getRootElement(), render)
	else
		triggerServerEvent("chaticon1", getLocalPlayer())
		outputChatBox("Chat ikonok bekapcsolva.", 0, 255, 0)
		chaticon = true
		addEventHandler("onClientRender", getRootElement(), render)
	end
end
addCommandHandler("togglechaticons", toggleChatIcon, false)
addCommandHandler("togchaticons", toggleChatIcon, false)

function sendLocalDoAction(thePlayer, message)
	triggerServerEvent("sendLocalDoAction", localPlayer, localPlayer, message)
end

function sendLocalMeAction(thePlayer, message)
	triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, message)
end