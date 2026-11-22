local sx, sy = guiGetScreenSize ()
local font = dxCreateFont("font.ttf", 10)
local font2 = dxCreateFont("font.ttf", 16)
local seefont = dxCreateFont("FontAwesome.otf", 10)
local seefont2 = dxCreateFont("RobotoB.ttf", 12)
local seefont3 = dxCreateFont("RobotoL.ttf", 12)
local seefont4 = dxCreateFont("Roboto.ttf", 12)
local player_cache = {}
local mutat = false
local list_index = 0
local plus = 0
local plus_ertek = 0
local disabled_controls = { "next_weapon","previous_weapon","aim_weapon","radio_next","radio_previous", "fire" }
local g_oldControlStates = {}
local alpha = 0
local clickedPlayer = nil
local lastClickedPlayer = nil
local forgas = 0
local width = 0
local alphamore = 0
local csukas = true
local oX, oY = 1920, 1080



function getAlpha(a)
	if (alpha>a) then
		return a
	end
	return (a-(a-alpha))
end

function getForgas(f)
	if (forgas>f) then
		return f
	end
	return (f-(f-forgas))
end

local counter = 0
local starttick
local currenttick

local function isInBox( x, y, xmin, xmax, ymin, ymax )
	return x >= xmin and x <= xmax and y >= ymin and y <= ymax
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function loadScoreboardData ()
	data.ids = {}
	data.players = {}
	local players = getElementsByType ("player")
	for k,v in ipairs(players) do
		if v ~= getLocalPlayer() then
			local ID = getElementData (v,"playerid")
			table.insert(data.players,ID)
			data.ids[ID] = v
		end
	end
	table.sort (data.players)
	local ID = getElementData(getLocalPlayer(),"playerid")
	data.ids[ID] = getLocalPlayer()
	table.insert(data.players,1,ID)
	data.length = #data.players
	table.sort(players, function(a, b)
		if a ~= localPlayer and b ~= localPlayer and getElementData(a, "playerid") and getElementData(b, "playerid") then
			return tonumber(getElementData(a, "playerid")) < tonumber(getElementData(b, "playerid"))
		end
	end)

	--data.slots = maxP
	--data.serverName = sName

	data.maxHeight = 800
	if sy-200 <= data.maxHeight then
		data.maxHeight = sy-200
	end
end

addEventHandler ("onClientRender",root,
	function()
		if not starttick then
			starttick = getTickCount ()
		end
		counter = counter + 1
		currenttick = getTickCount ()
		if currenttick - starttick >= 1000 then
			setElementData (localPlayer, "FPS", counter)
			counter = 0
			starttick = false
		end
	end
)

fpstable = {}
function averageFPS()
	avgseconds = 10
	for i = 0, avgseconds do
		if i+1 <= avgseconds then
			fpstable[i+1] = fpstable[i]
		end
		fpstable[0] = getElementData (localPlayer, "FPS")
	end
	totalframes = 0
	for k, v in pairs(fpstable) do
		if v ~= false then
			totalframes = totalframes + v
		end
	end
	avgfps = math.round(totalframes / avgseconds, 0)
	setElementData (localPlayer, "avgfps", avgfps)
end

setTimer (averageFPS, 1000, 0)

function getOnlineAdmins()
	player_cache = getElementsByType("player")
	local count = 0
	for i, p in pairs(player_cache) do
		if((getElementData(p, "adminlevel") or 0)>0)then
			count = count + 1
		end
	end
	return count
end

local lastTick2 = 0
local alpha1 = 0
local alpha2 = 0
local alphaSz = 0
local nyitas = false
function scoreBoard()
 --for k,v in ipairs(data.players) do
  local ID = v
  local player = localPlayer
  local onlineTime = getElementData ( player, "orafent" ) or 0
  local masodperc = math.fmod(math.floor(onlineTime), 60)
  local perc = math.fmod(math.floor(onlineTime/60), 60)
  local ora = math.floor(tonumber(((onlineTime / 60) / 60)))
  local currPlayers = getCurrentPlayers()
  local CurrPlayer = 76 / 100 * currPlayers
  if masodperc < 10 then
     masodperc = "0"..masodperc
  end
  if perc < 10 then
	perc = "0"..perc
  end
  if ora < 10 then
	ora = "0"..ora
  end
	if csukas == true and alpha1 > 0 then
		alpha1 = alpha1 - 5
	end
	if not csukas and alpha1 ~= 100 then
		alpha1 = alpha1 + 5
	end
	if csukas == true and alphaSz > 0 then
		alphaSz = alphaSz - 8.5
	end
	if not csukas and alphaSz ~= 255 then
		alphaSz = alphaSz + 8.5
	end
	if csukas == true and alpha2 > 0 then
		alpha2 = alpha2 - 6.5
	end
	if not csukas and alpha2 ~= 130 then
		alpha2 = alpha2 + 6.5
	end
	if csukas == true and alphamore > 0 then
		alphamore = alphamore - 7.5
	end
	if not csukas and alphamore ~= 210 then
		alphamore = alphamore + 7.5
	end
  if not mutat then return end
  --outputChatBox(width)
  player_cache = getElementsByType("player")
  if(alpha<255)then
	alpha=alpha + (255/100)
  end
  if(forgas<360)then
	forgas=forgas + (360/40)
  end
  if alphamore == 0 then
	mutat = false
  end
  if (getElementData(getLocalPlayer(), "coremode") == true) then return end
	dxDrawRectangle(sx/2-250-30-490+3+512, sy/2-300-19, 512, 32,tocolor(0,0,0,alphamore))
	dxDrawRectangle(sx/2-250-30-490+3+512, sy/2-300-19+32, 512, 2,tocolor(111,164,99,alphamore))
	dxDrawText ("#7cc576Online: #ffffff 810/".. getCurrentPlayers ( ) .."", sx/2-250-30-490+3+512+300-2, sy/2-300-19,sx/2-250-30-490+3+512+200-2+300, sy/2-300-19+32+2, tocolor ( 255, 255, 255, alphaSz ), 0.75, seefont2, "right", "center" ,false,false,false,true)

	for c = 1, 17 do
		if c %2 == 0 then
			dxDrawRectangle(sx/2-250-30-490+3+512, sy/2-300-19+32+2+(c*35)-35, 507, 35, tocolor(0,0,0,alpha1))
		else
			dxDrawRectangle(sx/2-250-30-490+3+512, sy/2-300-19+32+2+(c*35)-35, 507, 35, tocolor(0,0,0,alpha2))
		end
	end

	dxDrawText ( "See#7cc576MTA v3 scoreboard", sx/2-250-30-490+3+512+300-2, sy/2-300-19,sx/2-250-30-490+3+512+200-2, sy/2-300-19+32+2, tocolor ( 255, 255, 255, alphaSz ), 1, seefont2, "right", "center" ,false,false,false,true)


	local cTick = getTickCount ()
	local progress = (cTick - lastTick2)/300
	exports.sas_system:addV3logo(sx/2-128/2, sy/2-440, nyitas, progress)


  local szin = tocolor(255,255,255,alphaSz)
  local sor = 0
  local elem = 0
  lastClickedPlayer = nil
	 for i, p in pairs(player_cache) do
			if(not getPlayerName(p)) then break end
			if(list_index<i and elem<17)then
			  local onlineTime = getElementData ( p, "orafent" ) or 0
		      local masodperc = math.fmod(math.floor(onlineTime), 60)
		      local perc = math.fmod(math.floor(onlineTime/60), 60)
		      local ora = math.floor(tonumber(((onlineTime / 60) / 60)))
			  local playerid = getElementData(p, "playerid")
			  if masodperc < 10 then
		        masodperc = "0"..masodperc
		      end
		      if perc < 10 then
			    perc = "0"..perc
		      end
		      if ora < 10 then
			    ora = "0"..ora
		      end
				--playerid = 100
				local pingHEX = "#7cc576"
				local ping = getPlayerPing(p)

				if ping > 80 and ping < 200 then
					pingHEX = "#ff9900"
				end
				if ping > 200 then
					pingHEX = "#db3232"
				end
				dxDrawText("ID: "..getElementData(p, "playerid").."", sx/2-280+15-500+500+18, sy/2-300-19+32+2+(elem*35), 0, sy/2-300-19+32+2+35+(elem*35), szin,0.87, seefont4, "left", "center")
				dxDrawText("" ..getPlayerName(p):gsub("_"," "), sx/2 - 500/2 + 69+500-500-9, sy/2 - (82 + plus)/2-2-28-80+1-111+37+2 + sor, 0, 0, szin, 0.87, seefont4, "left", "top" ) -- + 46
			  if not getElementData(p, "loggedin") then
				--dxDrawText(""..ora..":"..perc..":"..masodperc, sx/2 - 500/2 + 254 - 10+width-500, sy/2 - (82 + plus)/2-2-28-80+4 + sor, 0, 0, szin, 0.5, seefont2, "left", "top")
				dxDrawText("LVL: "..math.round(getElementData(p, "hoursplayed")/60), sx/2 - 500/2 + 373 +7 - 10+500-500, sy/2 - (82 + plus)/2-2-28-80+1-111+37+2 + sor, sx/2 - 500/2 + 373 - 10+500-500+55, sy/2 - (82 + plus)/2-2-28-80+1-111+37+2 + sor, szin, 0.87, seefont4, "right", "top"  )
				dxDrawText ("Ping:     "..pingHEX..""..ping, sx/2 - 500/2 + 456 - 10+10+500-500-30, sy/2 - (82 + plus)/2-2-28-80+1-111+37+2 + sor, 0, 0, szin, 0.87, seefont4, "left", "top" ,false,false,false,true)
			  else
				dxDrawText("Nincs bejelentkezve", sx/2 - 500/2 + 250+4 - 10+50+10+500-500+50, sy/2 - (82 + plus)/2-2-28-80+1-111+37+2 + sor, 0, 0, szin, 0.87, seefont4)
			  end
			end
			  exports['sas_system']:gorgetesRajzolas(sx/2-250-30-490+3+512+512-5, sy/2-300-19+34, 5, 595, 50, 1, list_index, tocolor(0,0,0,alphaSz))
			  elem = elem + 1
			  sor = sor + 35
		--	outputChatBox(elem)
	end
end
addEventHandler("onClientRender", getRootElement(), scoreBoard)




function keys(key, state)
	if(key=="tab" and state=="down")then
		if not getElementData(getLocalPlayer(), "loggedin") then return end
		if (getElementData(getLocalPlayer(), "coremode") == true) then return end
		mutat = true
		list_index = 0
		plus = 110
		alpha = 0
		forgas = 0
		plus_ertek= 381/10
		csukas = false
		nyitas = false
		lastTick2 =getTickCount()
		for k, control in ipairs ( disabled_controls ) do
			g_oldControlStates[k] = isControlEnabled ( control )
			toggleControl ( control, false )
		end
	elseif(key=="tab" and state=="up")then
		csukas = true
		nyitas = true
		lastTick2 =getTickCount()
		for k, control in ipairs ( disabled_controls ) do
			toggleControl ( control, g_oldControlStates[k] )
		end
		g_oldControlStates = {}
	elseif(key=="mouse_wheel_down")then
		if not mutat then return end
		if list_index < #player_cache - 1 then
			list_index = list_index + 1
		end
	elseif(key=="mouse_wheel_up")then
		if not mutat then return end
		if(list_index>0)then
			list_index = list_index - 1
		end
	end
end
bindKey("tab", "both", keys)
bindKey("mouse_wheel_up", "both", keys)
bindKey("mouse_wheel_down", "both", keys)

function dxDrawColorText(str, ax, ay, bx, by, color, scale, font, alignX, alignY)
  bx, by, color, scale, font = bx or ax, by or ay, color or tocolor(255,255,255,255), scale or 1, font or "default"
  if alignX then
    if alignX == "center" then
      ax = ax + (bx - ax - dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font))/2
    elseif alignX == "right" then
      ax = bx - dxGetTextWidth(str:gsub("#%x%x%x%x%x%x",""), scale, font)
    end
  end
  if alignY then
    if alignY == "center" then
      ay = ay + (by - ay - dxGetFontHeight(scale, font))/2
    elseif alignY == "bottom" then
      ay = by - dxGetFontHeight(scale, font)
    end
  end
   local clip = false
   if dxGetTextWidth(str:gsub("#%x%x%x%x%x%x","")) > bx then clip = true end
  local alpha = string.format("%08X", color):sub(1,2)
  local pat = "(.-)#(%x%x%x%x%x%x)"
  local s, e, cap, col = str:find(pat, 1)
  local last = 1
  local text = ""
  local broke = false
  while s do
    if cap == "" and col then color = tocolor(getColorFromString("#"..col..alpha)) end
    if s ~= 1 or cap ~= "" then
      local w = dxGetTextWidth(cap, scale, font)
           if clip then
                local text_ = ""
                 for i = 1,string.len(cap) do
                  if dxGetTextWidth(text,scale,font) < bx then
                  text = text..""..string.sub(cap,i,i)
                  text_ = text_..""..string.sub(cap,i,i)
                  else
                  broke = true
                   break
                  end
                 end
                 cap = text_
                end
      dxDrawText(cap, ax, ay, ax + w, by, color, scale, font)
      ax = ax + w
      color = tocolor(getColorFromString("#"..col..alpha))
    end
    last = e + 1
    s, e, cap, col = str:find(pat, last)
  end
  if last <= #str and not broke then
    cap = str:sub(last)
                   if clip then
                local text_ = ""
                 for i = 1,string.len(cap) do
                  if dxGetTextWidth(text,scale,font) < bx then
                  text = text..""..string.sub(cap,i,i)
                  text_ = text_..""..string.sub(cap,i,i)
                  else
                  broke = true
                   break
                  end
                 end
                 cap = text_
                end
    dxDrawText(cap, ax, ay, ax + dxGetTextWidth(cap, scale, font), by, color, scale, font)
  end
end

function setTimeInServer()
	local oldTime = tonumber(getElementData(getLocalPlayer(), "orafent")) or 0
	setElementData(getLocalPlayer(), "orafent", oldTime + 1)
end
setTimer(setTimeInServer, 1000, 0)


function getCurrentPlayers()
	local counter = 0

	for k, v in pairs(getElementsByType("player")) do
		counter = counter + 1
	end

	return counter
end
