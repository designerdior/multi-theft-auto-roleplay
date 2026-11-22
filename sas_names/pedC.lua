local playersList = {}
local vehiclesList = {}
local roadblockList = {}
local lPlayer = getLocalPlayer()
local customFont = dxCreateFont ("files/roboto_light.ttf",20)
local customFontv = dxCreateFont ("files/roboto.ttf",20)

-------------------------------------------------------------------------------------------------------------------

local gpn = getPlayerName
function getAccurateName(p)
	local name = gpn(p) or getElementData("ped:name")
	return string.gsub(name, "_", " ")
end

-------------------------------------------------------------------------------------------------------------------

addEventHandler( "onClientElementStreamIn", getRootElement(),
    function ()
		local typ = getElementType (source)
		if (typ == "player" and source ~= lPlayer) or (typ == "ped" and (getElementData (source,"visiblePedName") or false ~= false))then
			--table.insert (playersList,source)
			playersList[source] = true
			setPlayerNametagShowing (source,false)
		elseif typ == "vehicle" then
			vehiclesList[source] = true
		elseif typ == "object" then
			if getElementData (source,"roadblockID") then
				roadblockList[source] = true
			end
		end
	end
)

addEventHandler( "onClientElementStreamOut", getRootElement( ),
    function ()
		local typ = getElementType (source)
		if (typ == "player" and source ~= getLocalPlayer()) or (typ == "ped" and (getElementData (source,"visiblePedName") or false ~= false))then
			--[[for k,v in ipairs(playersList) do
				if v == source then
					table.remove (playersList,k)
				end
			end]]
			playersList[source] = nil
		elseif typ == "vehicle" then
			vehiclesList[source] = nil
		elseif typ == "object" then
			if roadblockList[source] then
				roadblockList[source] = nil
			end
		end
	end
)

addEventHandler ("onClientResourceStart",getResourceRootElement(getThisResource()),
	function ()
		local players = getElementsByType ("player",getRootElement(),true)
		for k,v in ipairs(players) do
			if v ~= lPlayer then
				--table.insert(playersList,v)
				playersList[v] = true
				setPlayerNametagShowing (v,false)
			end
		end
		local vehs = getElementsByType ("vehicle",getRootElement(),true)
		for k,v in ipairs(vehs) do
			vehiclesList[v] = true
		end
		local objs = getElementsByType ("object",getRootElement(),true)
		for k,v in ipairs(objs) do
			if getElementData (v,"roadblockID") then
				roadblockList[v] = true
			end
		end
	end
)

function math.evalCurve( curve, input )
	-- First value
	if input<curve[1][1] then
		return curve[1][2]
	end
	-- Interp value
	for idx=2,#curve do
		if input<curve[idx][1] then
			local x1 = curve[idx-1][1]
			local y1 = curve[idx-1][2]
			local x2 = curve[idx][1]
			local y2 = curve[idx][2]
			-- Find pos between input points
			local alpha = (input - x1)/(x2 - x1);
			-- Map to output points
			return math.lerp(y1,y2,alpha)
		end
	end
	-- Last value
	return curve[#curve][2]
end

function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end

local sx,sy = guiGetScreenSize ()
local options = {}
options.scaleMultiplier = (sx+1920)/(1920*2)
options.scale = 1
options.scalemin = 0.17
options.descscale = 0.64
options.descscalemin = 0.1
options.distance = 35
options.aimdistance = options.distance-options.distance*0.15
options.descdistance = 17
options.alpha = 255
options.alphamin = 0
options.alphadistance = 5
options.alphadiff = options.distance - options.alphadistance
options.disabled = false

local optionsVeh = {}
optionsVeh.scaleMultiplier = (sx+1920)/(1920*2)
optionsVeh.scale = 0.64
optionsVeh.scalemin = 0.1
optionsVeh.distance = 35
optionsVeh.alpha = 255
optionsVeh.alphamin = 0
optionsVeh.alphadistance = 5
optionsVeh.alphadiff = optionsVeh.distance - optionsVeh.alphadistance

local optionsRB = {}
optionsRB.scaleMultiplier = (sx+1920)/(1920*2)
optionsRB.scale = 1
optionsRB.scalemin = 0.17
optionsRB.distance = 20
optionsRB.alpha = 255
optionsRB.alphamin = 0
optionsRB.alphadistance = 5
optionsRB.alphadiff = optionsRB.distance - optionsRB.alphadistance

local maxScaleCurve = { {0, 0}, {1.8,1.8}, {2,2} }
local textScaleCurve = { {0, 0.8}, {0.8, 1.2}, {99, 99} }
local textAlphaCurve = { {0, 0}, {25, 100}, {120, 190}, {255, 190} }

local hudX,hudY = sx*0.781,sy*0.227


addEventHandler ("onClientRender",getRootElement(),
	function ()
		local duty = getElementData (getLocalPlayer(),"tagName")
		if duty then
		--	if isPlayerHudComponentVisible ("radar") then
				local tr,tg,tb = getElementData (getLocalPlayer(),"tagNameColorR"),getElementData (getLocalPlayer(),"tagNameColorG"),getElementData (getLocalPlayer(),"tagNameColorB")
				if tr == nil or tb == nil or tg == nil or tr == false or tb == false or tg == false then
					tr,tg,tb = 255,235,180
				end
				dxDrawText ("Duty: " .. duty,hudX+1,hudY+1,0,0,tocolor(0,0,0,220),0.8,customFont,"left","top",false,false,false)
				dxDrawText ("Duty: " .. RGBToHex(tr,tg,tb) .. duty,hudX,hudY,0,0,tocolor(255,235,180,220),0.8,customFont,"left","top",false,false,false,true,true)
		--	end
		end
		local afk = getElementData (getLocalPlayer(),"afk")
		if afk then
			--dxDrawRectangle (0,0,sx,sy,tocolor(0,0,0,225),true)
			local width,height = 512,256
			--dxDrawImage (sx/2-width/2,sy/2-height/2,width,height,"afk2.png",0,0,0,tocolor(255,255,255,255),true)
		end
	end
)

addEventHandler ("onClientRender",getRootElement(),
	function ()
		if not options.disabled then
			if getElementData (getLocalPlayer(),"inBus") ~= true then
				local x,y,z = getCameraMatrix ()
				local weapon = getPedWeapon(getLocalPlayer())
				local target = false--getPedTarget (getLocalPlayer())
				if weapon == 34 or weapon == 43 then
					target = getPedTarget (getLocalPlayer())
				end
				for i,v in pairs(playersList) do
					if i and isElement(i) then
						local alpha = getElementAlpha (i)
						--outputDebugString ("Alpha: " .. tostring(alpha))
						if alpha > 0 then
							local enabled = getElementData (i,"nameEnabled")
							if enabled then
								local px,py,pz = getElementPosition (i)
								local dist = getDistanceBetweenPoints3D (x,y,z,px,py,pz)
								if target and target == i and dist > options.aimdistance then
									dist = options.distance*0.2
								end
								local notModifitedDist = dist
								if notModifitedDist < options.distance then
									local headPosX,headPosY,headPosZ = getPedBonePosition (i,4) -- pozycja glowy
									if headPosX and headPosY and headPosZ then
										local clear = isLineOfSightClear (x,y,z,headPosX,headPosY,headPosZ,true,false,false,true,false,false,false)
										if clear then
											headPosZ = headPosZ+0.38
											local sx,sy = getScreenFromWorldPosition (headPosX,headPosY,headPosZ,25,false)
											if sx then
												--local sx,sy = math.floor(sx),math.floor(sy)
												local name = getElementData (i,"visiblePedName") or false--getPlayerName (i)
												local tag = getElementData (i,"tagName")
												local petTag = getElementData (i,"petTag")
												if name ~= false then

													--local scale = 1/(options.scale * (dist / options.distance))
													local progress = dist/options.distance
													local scale = interpolateBetween (
														options.scale,0,0,
														options.scalemin,0,0,
														progress,"OutQuad"
													)
													local scale = scale * options.scaleMultiplier
													local dist = dist-(options.distance/3)
													local opdist = options.distance-(options.distance/3)
													if dist < 0 then
														dist = 0
													end
													local progress2 = dist/opdist
													local textalpha = interpolateBetween (
														options.alpha,0,0,
														options.alphamin,0,0,
														progress2,"Linear"
													)

													local r,g,b = getElementData (i,"nametagColorR"),getElementData (i,"nametagColorG"),getElementData (i,"nametagColorB")
													if r == nil or b == nil or g == nil or r == false or b == false or g == false then
														r,g,b = 255,255,255
													end
													if hitPlayers[i] then
														r,g,b = 220,20,0
													elseif getElementHealth (i) <= 0 then
														r,g,b = 20,20,20
													end
													local tr,tg,tb = getElementData (i,"tagNameColorR"),getElementData (i,"tagNameColorG"),getElementData (i,"tagNameColorB")
													if tr == nil or tb == nil or tg == nil or tr == false or tb == false or tg == false then
														tr,tg,tb = 255,255,255
													end
													local baseColor = tocolor(r,g,b,textalpha)--RGBToHex(r,g,b,textalpha)--
													local tagColor = RGBToHex(tr,tg,tb)--tocolor(tr,tg,tb,textalpha)
													local idColor = RGBToHex(255,235,180) --tocolor(255,235,180,textalpha)
													local teamColor = RGBToHex(49,162,228) --tocolor(255,235,180,textalpha)
													local adutyColor = RGBToHex(49,162,228) --tocolor(255,235,180,textalpha)

													local tagText = ""
													if tag then
														tagText = " [" .. tag .. "]"
													end

													local petTagText = ""
													if petTag then
														petTagText = " [".. petTag .. "]"
													end

													local adutyText = getElementData(i,"adminduty")
													local adminrang = titles[getElementData(i, "adminlevel")]
													if adutyText == 1 then
														adutyText = " (".. adminrang .. ")"
														else
														adutyText = ""
													end

													--local team = getTeamName(getPlayerTeam(getLocalPlayer()))
													--local teamText = ""
													----if team then
													--	teamText = " (" .. team .. ")"
													--end
													local ID = getElementData (i,"playerid")
													local idText = ""
													if ID then
														idText = " (" .. ID .. ")"
														if getElementData (i,"nameMask") == true then
															idText = ""
															--outputDebugString ("Maska ID dla " .. tostring(name) .. " = " .. tostring(ID),3)
														end
													else
														--outputDebugString ("ID dla " .. tostring(name) .. " = " .. tostring(ID),3)
													end
													local text = name .. petTagText.. "" .. tagText
													--outputChatBox ("col: '" .. tagColor .. "'")
													local textWithCodes = name .. "#32b3ef" .. petTagText .. "#ff9933" .. tagText
													--local textWithCodes = "#FFFFFF".. name .. "#000000" .. tagText .. "#555555" .. idText
													local font = customFont-- "default-bold"

													local textWidth = dxGetTextWidth (text,scale,font)
													--local textNameWidth = dxGetTextWidth(name,scale,font)
													--local textIDWidth = dxGetTextWidth (idText,scale,font)
													--local textTagWidth = dxGetTextWidth (tagText,scale,font)
													local textHeight = dxGetFontHeight (scale,font)
													local posX = sx-textWidth/2
													--local posX2 = posX+textNameWidth -- tag
													--local posX3 = posX2+textTagWidth -- id
													--local posTagX,posTagX2 = posX2,posX2+textTagWidth
													--local posIDX,posIDX2 = posX3,posX3+textIDWidth
													local posY2 = sy
													local posY = sy-textHeight
													local offset = 1

												--	drawTextWithBorder(text, 1, posX+offset,posY+offset, 0,0, tocolor(0,0,0,textalpha), tocolor(255,255,255,textalpha), scale, scale, customFontv, "left", "top", false, false,false,true)
													--drawTextWithBorder(textWithCodes, 1, posX,posY, 0,0, tocolor(0,0,0,textalpha), baseColor, scale, scale, customFontv, "left", "top", false, false,false,true)
												--	dxDrawText (text,posX+offset,posY+offset,0,0,tocolor(0,0,0,textalpha),scale,customFontv,"left","top",false,false,false,false,true)
												dxDrawText (text,posX+offset,posY+offset,0,0,tocolor(0,0,0,textalpha),scale,customFontv,"left","top",false,false,false,false,true)
												dxDrawText (textWithCodes,posX,posY,0,0,baseColor,scale,customFontv,"left","top",false,false,false,true,true)

													if getElementData (i,"pmTyping") then
															if progress < 1 then
																local by = posY-5
																local scale = interpolateBetween (
																	0.7,0,0,
																	0,0,0,
																	progress,"OutQuad"
																)
																local width,height = 256*scale,128*scale
																local ix,iy = sx-width/2,by-height
																dxDrawImage (ix,iy,width,height,"files/typing.png",0,0,0,tocolor(255,255,255,textalpha))
															end
													elseif getElementData (i,"afk") then
														if isPlayerHudComponentVisible ("radar") then
															if progress < 1 then
																local by = posY-5
																local scale = interpolateBetween (
																	0.7,0,0,
																	0,0,0,
																	progress,"OutQuad"
																)
																local width,height = 256*scale,128*scale
																local ix,iy = sx-width/2,by-height
																--dxDrawImage (ix,iy,width,height,"afk.png",0,0,0,tocolor(255,255,255,textalpha))
															end
														end
													end

													--dxDrawText (name,posX+offset,posY+offset,posX2+offset,posY2+offset,tocolor(0,0,0,textalpha),scale,font,"center","center",false,false,false)
													--dxDrawText (name,posX,posY,posX2,posY2,baseColor,scale,font,"center","center",false,false,false)

													--dxDrawText (tagText,posTagX+offset,posY+offset,posTagX2+offset,posY2+offset,tocolor(0,0,0,textalpha),scale,font,"center","center",false,false,false)
													--dxDrawText (tagText,posTagX,posY,posTagX2,posY2,tagColor,scale,font,"center","center",false,false,false)

													--dxDrawText (idText,posIDX+offset,posY+offset,posIDX2+offset,posY2+offset,tocolor(0,0,0,textalpha),scale,font,"center","center",false,false,false)
													--dxDrawText (idText,posIDX,posY,posIDX2,posY2,idColor,scale,font,"center","center",false,false,false)



													local descText = getElementData (i,"description")
													if descText then
														local descX,descY,descZ = getPedBonePosition (i,3)
														if descX and descY and descZ then
															local sx,sy = getScreenFromWorldPosition (descX,descY,descZ,25,false)
															if sx and sy then
																local dist = notModifitedDist
																local progress = dist/options.descdistance
																scale = interpolateBetween (
																	options.descscale,0,0,
																	options.descscalemin,0,0,
																	progress,"Linear"
																)
																local dist = dist-(options.descdistance/3)
																local opdist = options.descdistance-(options.descdistance/3)
																if dist < 0 then
																	dist = 0
																end
																local progress2 = dist/opdist
																textalpha = interpolateBetween (
																	options.alpha,0,0,
																	options.alphamin,0,0,
																	progress2,"Linear"
																)
																local descMainColor = tocolor(220,162,244,textalpha)
																local x,y = sx-100,sy
																local x2,y2 = sx+100,sy+150
																dxDrawText (descText,x+1,y+1,x2+1,y2+1,tocolor(0,0,0,textalpha),scale,font,"center","top",false,true,false)
																dxDrawText (descText,x,y,x2,y2,descMainColor,scale,font,"center","top",false,true,false)
															end
														end
													end
													local oocText = getElementData (i,"onOOCMessageSend")
													if oocText then
														local x,y = math.floor(sx-130),math.floor(posY-60)
														local x2,y2 = math.floor(sx+130),math.floor(posY-5)

														dxDrawText (oocText,x+offset,y+offset,x2+offset,y2+offset,tocolor(0,0,0,textalpha),scale,font,"center","bottom",false,true,false)
														dxDrawText (oocText,x,y,x2,y2,tocolor(205,205,205,textalpha),scale,font,"center","bottom",false,true,false)
													end
												else
													--outputDebugString ("Nick niedostępny",3)
												end
											end
										end
									end
								end
							end
						end
					else
						playersList[i] = nil
					end
				end
			end
		end
	end
)

addEventHandler ("onClientRender",getRootElement(),
	function ()
		if not options.disabled then
			if getElementData (getLocalPlayer(),"inBus") ~= true then
				local x,y,z = getCameraMatrix ()
				for i,v in pairs(vehiclesList) do
					if i and isElement(i) then
						local desc = getElementData (i,"vehicleDescription")
						if desc then
							local px,py,pz = getElementPosition (i)
							local dist = getDistanceBetweenPoints3D (x,y,z,px,py,pz)

							local notModifitedDist = dist

							if notModifitedDist < optionsVeh.distance then
								local clear = isLineOfSightClear (x,y,z,px,py,pz,true,false,false,true,false,false,false)
								if clear then
									local sx,sy = getScreenFromWorldPosition (px,py,pz,25,false)
									if sx then
										local dist = notModifitedDist
										local progress = dist/optionsVeh.distance
										local scale = interpolateBetween (
											optionsVeh.scale,0,0,
											optionsVeh.scalemin,0,0,
											progress,"Linear"
										)

										local dist = dist-(optionsVeh.distance/3)
										local opdist = optionsVeh.distance-(optionsVeh.distance/3)
										if dist < 0 then
											dist = 0
										end
										local progress2 = dist/opdist
										local textalpha = interpolateBetween (
											optionsVeh.alpha,0,0,
											optionsVeh.alphamin,0,0,
											progress2,"Linear"
										)

										local descMainColor = tocolor(220,162,244,textalpha)
										local x,y = sx-100,sy
										local x2,y2 = sx+100,sy+150
										dxDrawText (desc,x+1,y+1,x2+1,y2+1,tocolor(0,0,0,textalpha),scale,customFont,"center","top",false,true,false)
										dxDrawText (desc,x,y,x2,y2,descMainColor,scale,customFont,"center","top",false,true,false)
									end
								end
							end
						end
					else
						vehiclesList[i] = nil
					end
				end
			end
		end
	end
)

addEventHandler ("onClientRender",getRootElement(),
	function ()
		if not options.disabled then
			if getElementData (getLocalPlayer(),"inBus") ~= true then
				local x,y,z = getCameraMatrix ()
				for i,v in pairs(roadblockList) do
					if i and isElement(i) then
						local desc = getElementData (i,"roadblockID")
						if desc then
							local desc = "Blokada (" .. desc .. ")"

							local px,py,pz = getElementPosition (i)
							local dist = getDistanceBetweenPoints3D (x,y,z,px,py,pz)

							local notModifitedDist = dist

							if notModifitedDist < optionsVeh.distance then
								local clear = isLineOfSightClear (x,y,z,px,py,pz,true,true,false,true,false,false,false,i)
								if clear then
									local sx,sy = getScreenFromWorldPosition (px,py,pz,25,false)
									if sx then
										local dist = notModifitedDist
										local progress = dist/optionsVeh.distance
										local scale = interpolateBetween (
											optionsVeh.scale,0,0,
											optionsVeh.scalemin,0,0,
											progress,"Linear"
										)

										local dist = dist-(optionsVeh.distance/3)
										local opdist = optionsVeh.distance-(optionsVeh.distance/3)
										if dist < 0 then
											dist = 0
										end
										local progress2 = dist/opdist
										local textalpha = interpolateBetween (
											optionsVeh.alpha,0,0,
											optionsVeh.alphamin,0,0,
											progress2,"Linear"
										)

										local descMainColor = tocolor(255,235,180,textalpha)
										local x,y = sx-100,sy
										local x2,y2 = sx+100,sy+150
										dxDrawText (desc,x+1,y+1,x2+1,y2+1,tocolor(0,0,0,textalpha),scale,customFont,"center","top",false,true,false)
										dxDrawText (desc,x,y,x2,y2,descMainColor,scale,customFont,"center","top",false,true,false)
									end
								end
							end
						end
					else
						vehiclesList[i] = nil
					end
				end
			end
		end
	end
)

function togNames (state)
	outputChatBox (tostring(state) .. ", " .. tostring(options.disabled))
	if state == options.disabled then
		options.disabled = not state
	end
end

addCommandHandler ("tognames",
	function ()
		options.disabled = not options.disabled
	end
)


hitTimers = {}
hitPlayers = {}

addEventHandler ("onClientPlayerDamage",getRootElement(),
	function (att,weapon,part,loss)
		local player = source
		hitPlayers[player] = true
		if hitTimers[player] and isTimer(hitTimers[player]) then
			killTimer(hitTimers[player])
		end
		hitTimers[player] = setTimer (
			function ()
				hitPlayers[player] = false
			end
		,3000,1)
	end
)

function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end

function drawTextWithBorder(text, offset, x, y, w, h, borderColor, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
	for offsetX = -offset, offset do
		for offsetY = -offset, offset do
			dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), x + offsetX, y + offsetY, w + offsetX, h + offsetY, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
		end
	end

	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end
