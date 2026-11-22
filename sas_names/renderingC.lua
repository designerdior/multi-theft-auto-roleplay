local playersList = {}
local vehiclesList = {}
local roadblockList = {}
local lPlayer = getLocalPlayer()
local customFont = dxCreateFont ("files/roboto_light.ttf",20)
local customFontv = dxCreateFont ("files/roboto.ttf",20)

titles = {"AdminSegéd", "Admin 1", "Admin 2", "Admin 3", "Admin 4", "Admin 5", "Főadmin", "SuperAdmin", "Tulajdonos", "Rendszergazda", "<Fejlesztő/>"}

-------------------------------------------------------------------------------------------------------------------

addEventHandler( "onClientElementStreamIn", getRootElement(),
    function ()
		local typ = getElementType (source)
		if (typ == "player" ) or (typ == "ped" and getElementData (source,"visibleName"))then
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
		if (typ == "player") or (typ == "ped" and getElementData (source,"visibleName"))then
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
			--if v ~= lPlayer then
				playersList[v] = true
				setPlayerNametagShowing (v,false)
			--end
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
	if input<curve[1][1] then
		return curve[1][2]
	end
	for idx=2,#curve do
		if input<curve[idx][1] then
			local x1 = curve[idx-1][1]
			local y1 = curve[idx-1][2]
			local x2 = curve[idx][1]
			local y2 = curve[idx][2]
			local alpha = (input - x1)/(x2 - x1);
			return math.lerp(y1,y2,alpha)
		end
	end
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
local adutyColor = "" --tocolor(255,235,180,textalpha)
addEventHandler ("onClientRender",getRootElement(),
	function ()
		if not options.disabled then
			if getElementData (getLocalPlayer(),"inBus") ~= true then
				local x,y,z = getCameraMatrix ()
				local weapon = getPedWeapon(getLocalPlayer())
				local target = false
				if weapon == 34 or weapon == 43 then
					target = getPedTarget (getLocalPlayer())
				end
				for i,v in pairs(playersList) do
					if i and isElement(i) and i ~= localPlayer then
						--if i ~= localPlayer then
							local alpha = getElementAlpha (i)
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
										local headPosX,headPosY,headPosZ = getPedBonePosition (i,4)
										if headPosX and headPosY and headPosZ then
											local clear = isLineOfSightClear (x,y,z,headPosX,headPosY,headPosZ,true,false,false,true,false,false,false)
											if clear then
												headPosZ = headPosZ+0.38
												local sx,sy = getScreenFromWorldPosition (headPosX,headPosY,headPosZ,25,false)
												if sx then
													local tag = getElementData (i,"tagName")
													local name = getAccurateName(i)
													if name then

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


														local baseColor = tocolor(255,255,255,textalpha)--RGBToHex(r,g,b,textalpha)--
														local tagColor = RGBToHex(255,255,255)--tocolor(tr,tg,tb,textalpha)
														local idColor = RGBToHex(255,255,255) --tocolor(255,235,180,textalpha)
														local teamColor = RGBToHex(49,162,228) --tocolor(255,235,180,textalpha)


														local tagText = ""
														if tag then
															tagText = " (" .. tag .. ")"
														end

														local getAccurateAdminTitle = titles[getElementData(i, "adminlevel")]
														if getElementData (i,"adminduty") then
															adutyText = " (".. getAccurateAdminTitle ..")"
														else
															adutyText = ""
														end

														local ID = getElementData (i,"playerid")
														local idText = ""
														if ID then
															idText = " (" .. ID .. ")"
															if getElementData (i,"nameMask") == true then
																idText = ""
															end
														else
														end
														local text = name .. tagText .. adutyText .. idText
														local textWithCodes = name .. tagColor .. "" .. tagText .. adutyColor .. adutyText .. idColor .. idText
														local textWithCodesh = name..""..tagText..adutyText..idText
														local font = customFont-- "default-bold"

														local textWidth = dxGetTextWidth (text,scale,font)
														local textHeight = dxGetFontHeight (scale,font)
														local posX = sx-textWidth/2
														local posY2 = sy
														local posY = sy-textHeight
														local offset = 1

													--	dxDrawText (text,posX+offset+1,posY+offset,0,0,tocolor(0,0,0,textalpha-200),scale-0.01,customFontv,"left","top")
													--	dxDrawText (textWithCodesh,posX+1,posY,0,0,tocolor(0,0,0,100),scale-0.01,customFontv,"left","top")
														--if getElementData (i,"adminduty") == 0 then
															dxDrawText (text,posX+offset,posY+offset,0,0,tocolor(0,0,0,textalpha),scale,customFontv,"left","top",false,false,false,false,true)
														--else

															dxDrawText (textWithCodes,posX,posY,0,0,baseColor,scale,customFontv,"left","top",false,false,false,true,true)
															--dxDrawText (text,posX+offset,posY+offset,0,0,tocolor(0,0,0,textalpha),scale,customFontv,"left","top",false,false,false,false,true)
														--end


														if getElementData (i,"pmTyping") then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	dxDrawImage (ix,iy,width,height,"files/pm.png",0,0,0,tocolor(255,255,255,textalpha))
																end
														elseif getElementData (i,"afk") then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	dxDrawImage (ix,iy,width,height,"files/afk.png",0,0,0,tocolor(0,0,0,textalpha))
																end
														elseif getElementData (i,"adminduty") and getElementData(i, "adminlevel") >= 10 then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	adutyColor = RGBToHex(50,179,239)
																	--outputChatBox(adutyColor)
																	dxDrawImage (ix,iy,width,height,"files/devduty.png",0,0,0,tocolor(255,255,255,textalpha))
																end
														elseif getElementData (i,"adminduty") and getElementData(i, "adminlevel") == 9 then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	adutyColor = RGBToHex(242,97,102)
																	dxDrawImage (ix,iy,width,height,"files/owner.png",0,0,0,tocolor(255,255,255,textalpha))
																end
														elseif getElementData (i,"adminduty") and tonumber(getElementData(i, "adminlevel")) == 8 then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	adutyColor = RGBToHex(226,59,20)
																	dxDrawImage (ix,iy,width,height,"files/superadmin.png",0,0,0,tocolor(255,255,255,textalpha))
																end
														elseif getElementData (i,"adminduty") and getElementData(i, "adminlevel") == 7 then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	adutyColor = RGBToHex(239,173,95)
																	dxDrawImage (ix,iy,width,height,"files/foadmin.png",0,0,0,tocolor(255,255,255,textalpha))
																end
														elseif getElementData (i,"adminduty") and getElementData(i, "adminlevel") < 7 and getElementData(i, "adminlevel") > 1 then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	adutyColor = RGBToHex(125,159,109)
																	dxDrawImage (ix,iy,width,height,"files/adminduty.png",0,0,0,tocolor(255,255,255,textalpha))
																end
														elseif getElementData (i,"adminduty") and getElementData(i, "adminlevel") == 1 then
																if progress < 1 then
																	local by = posY-5
																	local scale = interpolateBetween (
																		0.7,0,0,
																		0,0,0,
																		progress,"OutQuad"
																	)
																	local width,height = 256*scale,256*scale
																	local ix,iy = sx-width/2,by-height
																	adutyColor = RGBToHex(244,154,193)
																	dxDrawImage (ix,iy,width,height,"files/asduty.png",0,0,0,tocolor(255,255,255,textalpha))
																end
														end
														local oocText = getElementData (i,"oocMessage")
														if oocText then
															local x,y = math.floor(sx-130),math.floor(posY-60)
															local x2,y2 = math.floor(sx+130),math.floor(posY-5)

															dxDrawText (oocText,x+offset,y+offset,x2+offset,y2+offset,tocolor(0,0,0,textalpha),scale,font,"center","bottom",false,true,false)
															dxDrawText (oocText,x,y,x2,y2,tocolor(205,205,205,textalpha),scale,font,"center","bottom",false,true,false)
														end
													else
														outputDebugString ("Nick niedostępny",3)
													end
												end
											end
										end
									end
								end
							end
						--end
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
