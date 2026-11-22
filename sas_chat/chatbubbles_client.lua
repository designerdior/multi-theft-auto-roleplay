local textsToDraw = {}

local hideown
local showtime
local characteraddition
local maxbubbles

local font = dxCreateFont( ":sas_hud/files/fonts/RobotoL.ttf", 16 )

local showthebubbles = true

function income(message,messagetype)
	if source ~= getLocalPlayer() or not hideown then
		addText(source,message,messagetype)
	end
end

function addText(source,message,messagetype)
	local notfirst = false
	for i,v in ipairs(textsToDraw) do
		if v[1] == source then
			v[4] = v[4] + 1
			--if(v[4] > maxbubbles) then
			--	removeText(v)
			--end
			notfirst = true
		end
	end
	local infotable = {source,message,messagetype,0}
	table.insert(textsToDraw,infotable)
	if not notfirst then
		setTimer(removeText,showtime + (#message * characteraddition),1,infotable)
	end
end

function removeText(sinfotable)
	for i,v in ipairs(textsToDraw) do
		if v[1] == sinfotable[1] and v[2] == sinfotable[2] then
			for i2,v2 in ipairs(textsToDraw) do
				if v2[1] == v[1] and v[4] - v2[4] == 1 then
					if(v[4] > maxbubbles) then -- Régieket töröljük amit nem látunk
						setTimer(removeText,50,1,v2)
					else
						setTimer(removeText,showtime + (#v2[2] * characteraddition),1,v2)
					end
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
	if showthebubbles then
		for i,v in ipairs(textsToDraw) do
			if isElement(v[1]) then
				if getElementHealth(v[1]) > 0 then
					local camPosXl, camPosYl, camPosZl = getPedBonePosition (v[1], 6)
					local camPosXr, camPosYr, camPosZr = getPedBonePosition (v[1], 7)
					local x,y,z = (camPosXl + camPosXr) / 2, (camPosYl + camPosYr) / 2, (camPosZl + camPosZr) / 2
					--local posx,posy = getScreenFromWorldPosition(x,y,z+0.25)
					local cx,cy,cz = getCameraMatrix()
					local px,py,pz = getElementPosition(v[1])
					local distance = getDistanceBetweenPoints3D(cx,cy,cz,px,py,pz)
					local posx,posy = getScreenFromWorldPosition(x,y,z+0.07*distance+0.10)
					local elementtoignore1 = getPedOccupiedVehicle(getLocalPlayer()) or getLocalPlayer()
					local elementtoignore2 = getPedOccupiedVehicle(v[1]) or v[1]
					if posx and distance <= 20 and ( isLineOfSightClear(cx,cy,cz,px,py,pz,true,true,false,true,false,true,true,elementtoignore1) or isLineOfSightClear(cx,cy,cz,px,py,pz,true,true,false,true,false,true,true,elementtoignore2) ) and ( not maxbubbles or  v[4] < maxbubbles ) then -- change this when multiple ignored elements can be specified
						local width = dxGetTextWidth(v[2],0.9,font)
						local kozep = posx - (22 + (0.5 * width))
						
						local r,g,b = 255,255,255
						local kieg = ""
						-- Do
						if v[3] == 1 then
							r,g,b = 255, 51, 102
						-- Me
						elseif v[3] == 2 then
							r,g,b = 194, 162, 218
						elseif v[3] == 3 then
							kieg = "_s"
						end
						
						dxDrawRectangle(posx - (12 + (0.5 * width)),posy - (v[4] * 35),width + 23,30,tocolor(0,0,0,150))
						--dxDrawImage ( math.floor(posx - (12 + (0.5 * width))),posy - (v[4] * 25),width + 23,30, 'chatbuborek/b_kozep'..kieg..'.png', 0, 0, 0 )
						--dxDrawImage ( math.floor(kozep),posy - (v[4] * 25),10,30, 'chatbuborek/b_bal'..kieg..'.png', 0, 0, 0 )
						--dxDrawImage ( math.floor(kozep)+ round((width + 33), 0),posy - (v[4] * 25),10,30, 'chatbuborek/b_jobb'..kieg..'.png', 0, 0, 0 )
						
						dxDrawText(v[2],posx - (0.5 * width),posy - (v[4] * 35)+2,posx - (0.5 * width),posy - (v[4] * 25),tocolor(r,g,b,255),0.9,font,"left","top",false,false,false)
					end
				end
			end
		end
	end
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.4)
end


function getServerSettings()
    triggerServerEvent("onAskForBubbleSettings",getLocalPlayer())
end

function saveSettings(settings)
	showtime = settings[1]
	characteraddition = settings[2]
	maxbubbles = settings[3]
	hideown = settings[4]
	addEvent("onMessageIncome",true)
	addEventHandler("onMessageIncome",getRootElement(),income)
end

function toggleBubblesOnOff()
	showthebubbles = not showthebubbles
	outputChatBox("Chat buborékok " ..( not showthebubbles and "#FF0000kikapcsolva#FFFFFF." or "#00FF00bekapcsolva#FFFFFF." ),255,255,255,true)
end

addEventHandler("onClientPlayerQuit",getRootElement(),getTextsToRemove)
addEventHandler("onClientRender",getRootElement(),handleDisplay)
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),getServerSettings)
addEvent("onBubbleSettingsReturn",true)
addEventHandler("onBubbleSettingsReturn",getRootElement(),saveSettings)
addCommandHandler("chatbubbles",toggleBubblesOnOff)