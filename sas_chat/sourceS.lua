local abKapcsolat = exports.sas_mysql:getConnection()

function trunklateText(thePlayer, text, factor)
	if getElementData(thePlayer,"alcohollevel") and getElementData(thePlayer,"alcohollevel") > 0 then
		local level = math.ceil( getElementData(thePlayer,"alcohollevel") * #text / ( factor or 5.5 ) )
		for i = 1, level do
			x = math.random( 1, #text )
			-- dont replace spaces
			if text.sub( x, x ) == ' ' then
				i = i - 1
			else
				local a, b = text:sub( 1, x - 1 ) or "", text:sub( x + 1 ) or ""
				local c = ""
				if math.random( 1, 6 ) == 1 then
					c = string.char(math.random(65,90))
				else
					c = string.char(math.random(97,122))
				end
				text = a .. c .. b
			end
		end
	end
	return text
end

function getElementDistance( a, b )
	if not isElement(a) or not isElement(b) or getElementDimension(a) ~= getElementDimension(b) then
		return math.huge
	else
		local x, y, z = getElementPosition( a )
		return getDistanceBetweenPoints3D( x, y, z, getElementPosition( b ) )
	end
end

local gpn = getPlayerName
function getPlayerName(p)
	local name = gpn(p) or getElementData(p, "ped:name")
	return string.gsub(name, "_", " ")
end

-- /ad
function advertMessage(thePlayer, commandName, showNumber, ...)
	--local canIAD = getElementData(thePlayer, "sanAdvert") or 0
	--if (canIAD == 0) then
	---	outputChatBox("(( Parancs letitva. Keress fel egy híradóst. ))", thePlayer)
	--else
		 
		if getElementData(thePlayer, "loggedin") then
			if not (...) or not (showNumber) then
				outputChatBox("HASZNÁLD: /" .. commandName .. " [Mutassa a telefonszámom 0/1] [Üzenet]", thePlayer, 255, 194, 14)
			elseif getElementData(thePlayer, "adminjailed") then
				outputChatBox("Börtönben nem tudsz hirdetni.", thePlayer, 255, 0, 0)
			elseif getElementData(thePlayer, "alcohollevel") and getElementData(thePlayer, "alcohollevel") ~= 0 then
				outputChatBox("Túl részeg vagy a hirdetés feladásához!", thePlayer, 255, 0, 0)
			else
				if (exports.sas_global:hasItem(thePlayer, 36) or exports.sas_global:hasItem(thePlayer, 37)) then
					if (getElementData(thePlayer, "ads") or 0) >= 50 then
						outputChatBox("5 percenként maximum 2 hirdetést tudsz feladni.", thePlayer, 255, 0, 0)
						return
					end
					message = table.concat({...}, " ")
					if showNumber ~= "0" and showNumber ~= "1" then
						message = showNumber .. " " .. message
						showNumber = 0
					end
					if message:sub(-1) ~= "." then
						message = message .. "."
					end
					
					local cost = math.ceil(string.len(message)/0.004)
					if exports.sas_global:takeMoney(thePlayer, cost) then
						local name = getPlayerName(thePlayer)
						local phoneNumber = getElementData(thePlayer, "cellnumber")
						
						for key, value in ipairs(getElementsByType("player")) do
							if (getElementData(value, "loggedin") and not getElementData(value, "disableAds")) then
								outputChatBox("   HÍRDETÉS: " .. message .. " ((" .. name .. "))", value, 0, 255, 64)
								
								if (tonumber(showNumber)==1) then
									outputChatBox("   Kapcsolat: #" .. phoneNumber .. ".", value, 0, 255, 64)
								end
							end
						end
						exports.sas_global:givePlayerAchievement(player, 9)
						outputChatBox("Hirdetésed összesen:" .. cost .. "$-ba került. Köszönjük.", thePlayer)
						setElementData(thePlayer, "ads", ( getElementData(thePlayer, "ads") or 0 ) + 1)
						setElementData(thePlayer, "sanAdvert", 0)
						setTimer(
							function(p)
								if isElement(p) then
									local c =  getElementData(p, "ads") or 0
									if c > 1 then
										setElementData(p, "ads", c-1)
									else
										setElementData(p, "ads")
									end
								end
							end, 300000, 1, thePlayer
						)
					else
						outputChatBox("Ez egy kicsit drága lennne... Nincs ennyi pénz nálad", thePlayer)
					end
				else
					outputChatBox("Mobil nélkül nehéz lesz...", thePlayer, 255, 0, 0)
				end
			end
		end
	--end
end
--addCommandHandler("ad", advertMessage, false, false)

function megprobal(thePlayer, cmd, ...)
	if not(isPedDead(thePlayer) and getElementData(source, "loggedin")) then
		local message = table.concat({...}, " ")
		if not message then
			outputChatBox("HASZNÁLD: /"..cmd.." [Cselekvés]", thePlayer, 255, 194, 14)
		else
			local name = getPlayerName(thePlayer)
			local szazalek = math.random(0,100)
			if szazalek >= 40 and szazalek <= 80 then
				sendLocalTry(thePlayer, "".. name .." megpróbál " .. message .. " és sikerül neki!", 0, 255, 0)
			else
				sendLocalTry(thePlayer, "".. name .." megpróbál " .. message .. " de sajnos nem sikerül neki!", 255, 0, 0)
			end
			
		end
	end
end
addCommandHandler("megprobal", megprobal, false, false)
addCommandHandler("megpróbál", megprobal, false, false)

function megprobalja(thePlayer, cmd, ...)
	if not(isPedDead(thePlayer) and getElementData(source, "loggedin")) then
		local message = table.concat({...}, " ")
		if not message then
			outputChatBox("HASZNÁLD: /"..cmd.." [Cselekvés]", thePlayer, 255, 194, 14)
		else
			local name = getPlayerName(thePlayer)
			local szazalek = math.random(0,100)
			if szazalek >= 40 and szazalek <= 80 then
				sendLocalTry(thePlayer, "".. name .." megpróbálja " .. message .. " és sikerül neki!", 0, 255, 0)
			else
				sendLocalTry(thePlayer, "".. name .." megpróbálja " .. message .. " de sajnos nem sikerül neki!", 255, 0, 0)
			end
			
		end
	end
end
addCommandHandler("megprobalja", megprobalja, false, false)
addCommandHandler("megpróbálja", megprobalja, false, false)



-- Main chat: Local IC, Me Actions & Faction IC Radio
function localIC(source, message, language)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(source) then return end
	local x, y, z = getElementPosition(source)
	local playerName = getPlayerName(source)
	
	message = string.gsub(message, "#%x%x%x%x%x%x", "")


	local dimension = getElementDimension(source)
	local interior = getElementInterior(source)
	local shownto = 1
	
	-- Chat Commands tooltip
	local kieg = ""
	for key, nearbyPlayer in ipairs(getElementsByType( "player" )) do
		local dist = getElementDistance( source, nearbyPlayer )
		
		if dist < 20 then
			local nearbyPlayerDimension = getElementDimension(nearbyPlayer)
			local nearbyPlayerInterior = getElementInterior(nearbyPlayer)

			if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) then
				if not (isPedDead(nearbyPlayer)) and getElementData(nearbyPlayer, "loggedin") and (nearbyPlayer~=source) then
					local message2 = message
					local pveh = getPedOccupiedVehicle(source)
					local jatekos = nearbyPlayer
					--[[
					if pveh then
						if (exports['sas_vehicle']:isVehicleWindowUp(pveh)) then
							kieg = "((Kocsiban)) "
							for i = 0, getVehicleMaxPassengers(pveh) do
								local lp = getVehicleOccupant(pveh, i)
								
								if (lp) and (lp~=source) then
									jatekos = lp
								end
							end
						end
					end]]--
					outputChatBox( getChatSzin(dist).." " .. playerName .. " "..kieg.."mondja: " .. message2, jatekos, 255, 255, 255, true)
						
					shownto = shownto + 1
				end
			end
		end
	end
	outputChatBox(playerName .. " "..kieg.."mondja: " .. message, source, 255, 255, 255, true)
	exports['sas_freecamtv']:add(shownto, playerName .. " mondja: " .. message, source)
end

function getChatSzin(tavolgas)
	if tavolgas < 4 then
		return "#EEEEEE"
	elseif tavolgas < 8 then
		return "#DDDDDD"
	elseif tavolgas < 12 then
		return "#CCCCCC"
	elseif tavolgas < 16 then
		return "#BBBBBB"
	else
		return "#AAAAAA"
	end
end
--[[
for i = 1, 3 do
	addCommandHandler( tostring( i ), 
		function( thePlayer, commandName, ... )
			local lang = tonumber( getElementData( thePlayer, "languages.lang" .. i ) )
			if lang ~= 0 then
				localIC( thePlayer, table.concat({...}, " "), lang )
			end
		end
	)
end]]--

function meEmote(source, cmd, ...)
	if not(isPedDead(source) and getElementData(source, "loggedin")) then
		local message = table.concat({...}, " ")
		if not (...) then
			outputChatBox("HASZNÁLD: /me [Cselekvés]", source, 255, 194, 14)
		else
			triggerClientEvent("onMessageIncome",source,"* "..message,2)
			sendLocalMeAction(source, message)
		end
	end
end
addCommandHandler("ME", meEmote, false, true)
addCommandHandler("Me", meEmote, false, true)

function radio(source, radioID, message)
	radioID = tonumber(radioID) or 1
	local hasRadio, itemKey, pItemID, pItemValue, pItemCount = exports.sas_items:hasItem(source, 4)

	if exports.sas_items:hasItemBag(source, 4) then
		local theChannel = pItemValue
		--outputChatBox(theChannel)
		if radioID ~= 1 then
			local count = 0
			local items = exports.sas_items:getElementItems(thePlayer, thePlayer, 0)
			for k, v in ipairs(items) do
				if v[1] == 6 then
					count = count + 1
					if count == radioID then
						theChannel = v[2]
						break
					end
				end
			end
		end
		
		if theChannel == 1 then
			outputChatBox("Kérlek állítsd be a rádiódat (( /tuneradio # ))", source, 255, 194, 14)
		elseif theChannel > 1 then
			triggerClientEvent (source, "playRadioSound", getRootElement())
			local username = getPlayerName(source)
			--local languageslot = getElementData(source, "languages.current")
			--local language = getElementData(source, "languages.lang" .. languageslot)
			--local languagename = call(getResourceFromName("language-system"), "getLanguageName", language)
			
			local factionID = getElementData(source,"faction")
			if not (factionID == -1) then
				local theTeam = getPlayerTeam(source)
				local factionrank = tonumber(getElementData(source,"factionrank"))
				local ranks = getElementData(theTeam,"ranks")
				factionRankTitle = ranks[factionrank] .. " - "
			else
				factionRankTitle = ""
			end
			
			message = trunklateText( source, message )
			outputChatBox("[RADIO #" .. theChannel .. "] " .. factionRankTitle .. username .. " mondja: " .. message, source, 0, 102, 255)
			
			for key, value in ipairs(getElementsByType( "player" )) do
		
				
				if (isElement(value)) and getElementData(thePlayer, "loggedin") and (value~=source) then
					if (exports.sas_global:hasItem(value, 41, theChannel)) then
						triggerClientEvent (value, "playRadioSound", getRootElement())

						--local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, value, message, language)
						--outputChatBox(" [RADIO #" .. theChannel .. "] " .. factionRankTitle .. username .. " mondja: " .. trunklateText( value, message ), value, 0, 102, 255)
						
						
						if (exports.sas_global:hasItem(value, 41) == false) then
							-- Show it to people near who can hear his radio
							for k, v in ipairs(getNearbyElements(value, "player",7)) do
								if getElementData(v, "loggedin") then
									if (exports.sas_global:hasItem(v, 41, targetChannel) == false) then
										local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, v, message, language)
										--outputChatBox("[" .. languagename .. "] " .. getPlayerName(value) .. " rádiója: " .. trunklateText( v, message2 ), v, 255, 255, 255)
									end
								end
							end
						end
					end
				end
			end
			
			--Show the radio to nearby listening in people near the speaker
			for key, value in ipairs(getElementsByType("player")) do
				if getElementDistance(source, value) < 10 then
					if (value~=source) then
						--local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, value, message, language)
						outputChatBox(" " .. getPlayerName(source) .. " [RADIO] mondja: " .. message, value, 255, 255, 255)
					end
				end
			end
		else
			outputChatBox("A rádiód ki van kapcsolva. ((/toggleradio))", source, 255, 0, 0)
		end
	else
		outputChatBox("Nincs nálad rádió.", source, 255, 0, 0)
	end
end
local hangulatjel_jelentes = 
{
	"nagyot mosolyog",
	"felnevet",
	"elpirul",
	"nyelvet ölt",
	"szomorú",
	"szomorú",
	"vidám",
	"vidám",
	"kacsint",
	"kacsint",
	"nagyon ideges",
	"nagyot kacsint",
	"nagyot kacsint"
}
local hangulatjelek = { 
	":D",
	"xD",
	":$",
	":P",
	":(",
	":-(",
	":)",
	":-)",
	";)",
	";-)",
	":@",
	";D",
	";-D"
}

function chatMain(message, messageType)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(source) then cancelEvent() return end
	
	
	if not (isPedDead(source)) and getElementData(source, "loggedin") and not (messageType==2) then -- Player cannot chat while dead or not logged in, unless its OOC
		local hangulatjelet_talaltam = -1
		for key, value in ipairs( hangulatjelek ) do
			message = tostring(message)
			local nagybetu = message:upper()
			value = tostring(value)
			value = value:upper()
			if nagybetu:find( value, 1, true ) then
				hangulatjelet_talaltam = key
				break
				--return
			end
		end
		if hangulatjelet_talaltam == -1 then
			local dimension = getElementDimension(source)
			local interior = getElementInterior(source)
			-- Local IC
			if (messageType==0) then
				localIC(source, message, 1)
				triggerClientEvent("onMessageIncome",source,message,0)
			elseif (messageType==1) then -- Local /me action
				meEmote(source, "me", message)
			end
		else
			--meEmote(source, "me", "(( Hangulatjelet használt ))")
			meEmote(source, "me", tostring(hangulatjel_jelentes[hangulatjelet_talaltam]))
			cancelEvent()
			--outputChatBox("Debug: " .. tostring(hangulatjelet_talaltam) .. " - " .. tostring(hangulatjel_jelentes[hangulatjelet_talaltam]),source, 255, 255, 255)
		end
	elseif (messageType==2) and getElementData(thePlayer, "loggedin") then -- Radio
		radio(source, 1, message)
	end
end
addEventHandler("onPlayerChat", getRootElement(), chatMain)

function msgRadio(thePlayer, commandName, ...)
	if (...) then
		local message = table.concat({...}, " ")
		radio(thePlayer, 1, message)
	else
		outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("r", msgRadio, false, false)
addCommandHandler("radio", msgRadio, false, false)

for i = 1, 20 do
	addCommandHandler( "m" .. tostring( i ), 
		function( thePlayer, commandName, ... )
			if i <= exports['sas_items']:countItems(thePlayer, 6) then
				radio( thePlayer, i, table.concat({...}, " ") )
			end
		end
	)
end

function govAnnouncement(thePlayer, commandName, ...)
	local theTeam = getPlayerTeam(thePlayer)
	
	if (theTeam) then
		local teamID = tonumber(getElementData(theTeam, "id"))
		local team = getPlayerTeam(thePlayer)
		local frakcioNev = getTeamName(team)
		if (teamID==80 or teamID==16 --[[or teamID==3]] or teamID==17 or teamID==19) then
			local message = table.concat({...}, " ")
			local factionRank = tonumber(getElementData(thePlayer,"factionrank"))
			
			if (factionRank<8) then
				outputChatBox("Nincs jogosultságod a parancs használatához!", thePlayer, 255, 0, 0)
			elseif #message == 0 then
				outputChatBox("Használd: " .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
			else
				local ranks = getElementData(theTeam,"ranks")
				local factionRankTitle = ranks[factionRank]
				
				
				for key, value in ipairs(getElementsByType("player")) do
					
					if getElementData(thePlayer, "loggedin") then
						outputChatBox(">> FELHÍVÁS "..frakcioNev..", " .. factionRankTitle .. ", " .. getPlayerName(thePlayer), value, 255, 0, 0)
						outputChatBox("-- "..message, value, 0, 255, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("gov", govAnnouncement)

function playerToggleDonatorChat(thePlayer, commandName)
	
	if getElementData(thePlayer, "loggedin") then
		local enabled = getElementData(thePlayer, "donatorchat")
		
		if (enabled==1) then
			outputChatBox("VIP chat elrejtve.", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "donatorchat", 0)
		else
			outputChatBox("VIP chat megjelenítve.", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "donatorchat", 1)
		end
		dbPoll ( dbQuery( abKapcsolat, "UPDATE accounts SET donatorchat='?' WHERE id ='?'", getElementData(thePlayer, "donatorchat"), getElementData(thePlayer, "gameaccountid")), -1 )
	end
end
addCommandHandler("toggledonatorchat", playerToggleDonatorChat, false, false)
addCommandHandler("toggledon", playerToggleDonatorChat, false, false)
addCommandHandler("toggledchat", playerToggleDonatorChat, false, false)

function donatorchat(thePlayer, commandName, ...)
	if ( exports.sas_global:isPlayerBronzeDonator(thePlayer) or exports.sas_global:isPlayerAdmin(thePlayer) ) then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local title = ""
			local hidden = getElementData(thePlayer, "hiddenadmin") or 0

			if ( exports.sas_global:isPlayerAdmin(thePlayer) ) then
				if (hidden == 1) or (exports.sas_global:getPlayerAdminTitle(thePlayer) == "Player") then
					if not (exports.sas_global:isPlayerBronzeDonator(thePlayer)) then
						title = "Bronz támogató"
					else
						title = exports.sas_global:getPlayerDonatorTitle(thePlayer)
					end
				else
					title = exports.sas_global:getPlayerAdminTitle(thePlayer)
				end
			elseif ( exports.sas_global:isPlayerBronzeDonator(thePlayer) ) then
				title = exports.sas_global:getPlayerDonatorTitle(thePlayer)
			end
				
			for key, value in ipairs(getElementsByType("player")) do
				if ( exports.sas_global:isPlayerBronzeDonator(value) or exports.sas_global:isPlayerAdmin(value) ) then
					if ( getElementData(value, "donatorchat") == 1 ) then
						outputChatBox("[VIP] " .. title .. " " .. getPlayerName(thePlayer) .. ": " .. message, value, 160, 164, 104)
					end
				end
			end
		end
	end
end
addCommandHandler("donator", donatorchat, false, false)
addCommandHandler("don", donatorchat, false, false)
addCommandHandler("dchat", donatorchat, false, false)

function departmentradio(thePlayer, commandName, ...)
	local theTeam = getPlayerTeam(thePlayer)
	
	if (theTeam) then
		local teamID = tonumber(getElementData(theTeam, "id"))

		if (teamID==15 or teamID==16 or teamID==17 or teamID == 19) then
			if (...) then
				local factionRank = tonumber(getElementData(thePlayer,"factionrank"))
				local ranks = getElementData(theTeam,"ranks")
				local factionRankTitle = ranks[factionRank]
				local frackioID = getElementData(thePlayer,"faction")
				if(frackioID == 16)then
					frakcioNev = "FBI"
				elseif(frackioID == 15)then
					frakcioNev = "PD"
				else
					frakcioNev = getTeamName(theTeam)
				end
				
				local message = trunklateText( thePlayer, table.concat({...}, " ") )
				local playerName = getPlayerName(thePlayer)

				outputChatBox("[Sürgősségi Rádió] [" .. frakcioNev .. "] [" .. factionRankTitle .. "] " .. playerName .. " mondja: " .. message, value, 0, 150, 255)
			else
				outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("d", departmentradio, false, false)
addCommandHandler("department", departmentradio, false, false)

function blockChatMessage()
	cancelEvent()
end

addEventHandler("onPlayerChat", getRootElement(), blockChatMessage)
-- End of Main Chat

function globalOOC(thePlayer, commandName, ...)	
	if getElementData(thePlayer, "loggedin") then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local oocEnabled = getOOCState()
			message = table.concat({...}, " ")
			local muted = getElementData(thePlayer, "muted")
			if (oocEnabled==0) and not (exports.sas_global:isPlayerAdmin(thePlayer)) then
				outputChatBox("GLOBAL OOC tiltva.", thePlayer, 255, 0, 0)
			elseif (muted==1) then
				outputChatBox("Tiltva vagy a GLOBAL OOC chatrõl.", thePlayer, 255, 0, 0)
			else
				local players = getElementsByType("player")
				local playerName = getPlayerName(thePlayer)
				local playerID = getElementData(thePlayer, "playerid")
					
				for k, arrayPlayer in ipairs(players) do
					local targetOOCEnabled = getElementData(arrayPlayer, "globalooc")

					if getElementData(thePlayer, "loggedin") and (targetOOCEnabled==1) then
						outputChatBox("(( (" .. playerID .. ") " .. playerName .. ": " .. message .. " ))", arrayPlayer, 196, 255, 255)
					end
				end
			end
		end
	end
end
--addCommandHandler("o", globalOOC, false, false)
--addCommandHandler("GlobalOOC", globalOOC)

function playerToggleOOC(thePlayer, commandName)
	
	if getElementData(thePlayer, "loggedin") then
		local playerOOCEnabled = getElementData(thePlayer, "globalooc")
		
		if (playerOOCEnabled==1) then
			outputChatBox("GLOBAL OOC kikapcsolva.", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "globalooc", 0)
		else
			outputChatBox("GLOBAL OOC bekapcsolva.", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "globalooc", 1)
		end
		dbPoll ( dbQuery( abKapcsolat, "UPDATE accounts SET globalooc='?' WHERE id ='?'", getElementData(thePlayer, "globalooc"), getElementData(thePlayer, "gameaccountid")), -1 )
	end
end
addCommandHandler("toggleooc", playerToggleOOC, false, false)


local advertisementMessages = { "samp", "SA-MP", "Kye", "server", "sincityrp", "ls-rp", "sincity", "eg", "tri0n3", "www.", ".com", ".net", ".co.uk", ".org", "Bryan", "Danny", "everlast", "neverlast", "www.everlastgaming.com"}

function isFriendOf(thePlayer, targetPlayer)
	local friends = getElementData(targetPlayer, "friends")
	if friends then
		local targetID = tonumber( getElementData( thePlayer, "gameaccountid" ) )
		if friends[ targetID ] then
			return true
		end
	end
	return false
end

--[[function pmPlayer(thePlayer, commandName, who, ...)
	if not (who) or not (...) then
		outputChatBox("Használd: /" .. commandName .. " [NévRészlet] [üzenet]", thePlayer, 255, 194, 14)
	else
		message = table.concat({...}, " ")
		
		local loggedIn = getElementData(thePlayer, "loggedin")
		if (loggedIn==0) then
			return
		end
		
		local targetPlayer, targetPlayerName
		if (isElement(who)) then
			if (getElementType(who)=="player") then
				targetPlayer = who
				targetPlayerName = getPlayerName(who)
				message = string.gsub(message, string.gsub(targetPlayerName, " ", "_", 1) .. " ", "", 1)
			end
		else
			targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, who)
		end
		
		if (targetPlayer) then
			local logged = getElementData(targetPlayer, "loggedin")
			local pmblocked = getElementData(targetPlayer, "pmblocked")

			if not (pmblocked) then
				pmblocked = 0
				setElementData(targetPlayer, "pmblocked", 0, false)
			end
			
			if getElementData(thePlayer, "loggedin") and not getElementData(targetPlayer, "disablePMs") and (pmblocked==0 or exports.sas_global:isPlayerAdmin(thePlayer) or exports.sas_global:isPlayerScripter(thePlayer) or getElementData(thePlayer, "reportadmin") == targetPlayer or isFriendOf(thePlayer, targetPlayer)) then
				local playerName = getPlayerName(thePlayer):gsub("_", " ")
				
				if not exports.sas_global:isPlayerScripter(thePlayer) and not exports.sas_global:isPlayerScripter(targetPlayer) then
					-- Check for advertisements
					for k,v in ipairs(advertisementMessages) do
						local found = string.find(string.lower(message), "%s" .. tostring(v))
						local found2 = string.find(string.lower(message), tostring(v) .. "%s")
						if (found) or (found2) or (string.lower(message)==tostring(v)) then
							sendMessageToAdmins("AdmWrn: " .. tostring(playerName) .. " sent a possible advertisement PM to " .. tostring(targetPlayerName) .. ".")
							sendMessageToAdmins("AdmWrn: Message: " .. tostring(message))
							break
						end
					end
				end
				
				-- Send the message
				local playerid = getElementData(thePlayer, "playerid")
				local targetid = getElementData(targetPlayer, "playerid")
				outputChatBox("PM From (" .. playerid .. ") " .. playerName .. ": " .. message, targetPlayer, 255, 255, 0)
				outputChatBox("PM Sent to (" .. targetid .. ") " .. targetPlayerName .. ": " .. message, thePlayer, 255, 255, 0)
				
				exports.logs:logMessage("[PM From " ..playerName .. " TO " .. targetPlayerName .. "]" .. message, 8)
				outputDebugString("[PM From " ..playerName .. " TO " .. targetPlayerName .. "]" .. message)
				
				if not exports.sas_global:isPlayerScripter(thePlayer) and not exports.sas_global:isPlayerScripter(targetPlayer) then
					-- big ears
					local received = {}
					received[thePlayer] = true
					received[targetPlayer] = true
					for key, value in pairs( getElementsByType( "player" ) ) do
						if isElement( value ) and not received[value] then
							local listening = getElementData( value, "bigears" )
							if listening == thePlayer or listening == targetPlayer then
								received[value] = true
								outputChatBox("(" .. playerid .. ") " .. playerName .. " -> (" .. targetid .. ") " .. targetPlayerName .. ": " .. message, value, 255, 255, 0)
							end
						end
					end
				end
			elseif (logged==0) then
				outputChatBox("Player is not logged in yet.", thePlayer, 255, 255, 0)
			elseif (pmblocked==1) then
				outputChatBox("Player is ignoring whispers!", thePlayer, 255, 255, 0)
			end
		end
	end
end
addCommandHandler("pm", pmPlayer, false, false)]]--

function localOOC(thePlayer, commandName, ...)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return end
	
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)
		
	if getElementData(thePlayer, "loggedin") and not (isPedDead(thePlayer)) then
		local muted = getElementData(thePlayer, "muted")
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		elseif (muted==1) then
			outputChatBox("Tiltva vagy az OOC chatrõl.", thePlayer, 255, 0, 0)
		else
			--exports.sas_global:sendLocalText(thePlayer, getPlayerName(thePlayer) .. ": (( " .. table.concat({...}, " ") .. " ))", 196, 255, 255)
			local x, y, z = getElementPosition(thePlayer)
			for index, nearbyPlayer in ipairs(getElementsByType("player")) do
				if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < ( 20 ) then
					triggerClientEvent(nearbyPlayer, "onOOCMessageSend", nearbyPlayer, getPlayerName(thePlayer) .. ": (( " .. table.concat({...}, " ") .. " ))")
				end
			end
		end
	end
end
addCommandHandler("b", localOOC, false, false)
addCommandHandler("LocalOOC", localOOC)

--[[function districtIC(thePlayer, commandName, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end
	
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)
	
	if getElementData(thePlayer, "loggedin") and not (isPedDead(thePlayer)) then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local playerName = getPlayerName(thePlayer)
			local message = table.concat({...}, " ")
			local zonename = exports.sas_global:getElementZoneName(thePlayer)
			
			for key, value in ipairs(getElementsByType("player")) do
				local playerzone = exports.sas_global:getElementZoneName(value)
				local playerdimension = getElementDimension(value)
				local playerinterior = getElementInterior(value)
				
				if (zonename==playerzone) and (dimension==playerdimension) and (interior==playerinterior) then
					if getElementData(thePlayer, "loggedin") then
						outputChatBox("District IC: " .. message .. " ((".. playerName .."))", value, 255, 255, 255)
					end
				end
			end
		end
	end
end
addCommandHandler("district", districtIC, false, false)]]--

function localDo(thePlayer, commandName, ...)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return end
	
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)
		
	if not (isPedDead(thePlayer)) and getElementData(thePlayer, "loggedin") then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [Nem látható cselekvés]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			triggerClientEvent("onMessageIncome",thePlayer,"* "..message,1)
			sendLocalDoAction(thePlayer, message)
		end
	end
end
addCommandHandler("do", localDo, false, false)


function localShout(thePlayer, commandName, ...)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return end
	
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)
		
	if not (isPedDead(thePlayer)) and getElementData(thePlayer, "loggedin") then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local playerName = getPlayerName(thePlayer)
			

			local message = trunklateText(thePlayer, table.concat({...}, " "))
			outputChatBox(" " .. playerName .. " kiáltja: " .. message .. "!!", thePlayer, 255, 255, 255)
			triggerClientEvent("onMessageIncome",thePlayer, message,3)
			for index, nearbyPlayer in ipairs(getElementsByType("player")) do
				if getElementDistance( thePlayer, nearbyPlayer ) < 40 then
					local nearbyPlayerDimension = getElementDimension(nearbyPlayer)
					local nearbyPlayerInterior = getElementInterior(nearbyPlayer)
					
					if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) and (nearbyPlayer~=thePlayer) then
						if getElementData(thePlayer, "loggedin") and not (isPedDead(nearbyPlayer)) then

							outputChatBox("" .. playerName .. " kiáltja: " .. message .. "!", nearbyPlayer, 255, 255, 255)
						end
					end
				end
			end
		end
	end
end
addCommandHandler("s", localShout, false, false)

function megaphoneShout(thePlayer, commandName, ...)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return end
	
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)
		
	if not (isPedDead(thePlayer)) and getElementData(thePlayer, "loggedin") then
		local faction = getPlayerTeam(thePlayer)
		local factiontype = getElementData(faction, "type")
		
		if (factiontype==2) or (factiontype==3) or (factiontype==4) then
			if not (...) then
				outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
			else
				local playerName = getPlayerName(thePlayer)
				local message = trunklateText(thePlayer, table.concat({...}, " "))
				

				for index, nearbyPlayer in ipairs(getElementsByType("player")) do
					if getElementDistance( thePlayer, nearbyPlayer ) < 40 then
						local nearbyPlayerDimension = getElementDimension(nearbyPlayer)
						local nearbyPlayerInterior = getElementInterior(nearbyPlayer)
						
						if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) then
							if getElementData(nearbyPlayer, "loggedin") and not (isPedDead(nearbyPlayer)) then
								local message2 = message
								outputChatBox(" ((" .. playerName .. ")) Megaphone <O: " .. trunklateText(nearbyPlayer, message2), nearbyPlayer, 255, 255, 0)
							end
						end
					end
				end
			end
		else
			outputChatBox("Nincs megaphon-ed!", thePlayer, 255, 0 , 0)
		end
	end
end
addCommandHandler("m", megaphoneShout, false, false)

local togState = { }
function toggleFaction(thePlayer, commandName, State)
	local pF = getElementData(thePlayer, "faction")
	local fL = getElementData(thePlayer, "factionleader")
	local theTeam = getPlayerTeam(thePlayer)

	if fL == 1 then
		if togState[pF] == false or not togState[pF] then
			togState[pF] = true
			outputChatBox("Frakció chat tiltva.", thePlayer)
			for index, arrayPlayer in ipairs( getElementsByType( "player" ) ) do
				if isElement( arrayPlayer ) then
					if getPlayerTeam( arrayPlayer ) == theTeam and getElementData(arrayPlayer, "loggedin") then
						outputChatBox("Frakció chat tiltva.", arrayPlayer, 255, 0, 0)
					end
				end
			end
		else
			togState[pF] = false
			outputChatBox("Frakció chat endegélyezve.", thePlayer)
			for index, arrayPlayer in ipairs( getElementsByType( "player" ) ) do
				if isElement( arrayPlayer ) then
					if getPlayerTeam( arrayPlayer ) == theTeam and getElementData(arrayPlayer, "loggedin") then
						outputChatBox("Frakció chat engedélyezve.", arrayPlayer, 0, 255, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("togglef", toggleFaction)
addCommandHandler("togf", toggleFaction)

function factionOOC(thePlayer, commandName, ...)

	if getElementData(thePlayer, "loggedin") then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local theTeam = getPlayerTeam(thePlayer)
			local theTeamName = getTeamName(theTeam)
			local playerName = getPlayerName(thePlayer)
			local playerFaction = getElementData(thePlayer, "faction")
			
			if not(theTeam) or (theTeamName=="Citizen") then
				outputChatBox("Nem vagy frakcióban.", thePlayer)
			else
				local message = table.concat({...}, " ")
				
				if (togState[playerFaction]) == true then
					return
				end
			
				for index, arrayPlayer in ipairs( getElementsByType( "player" ) ) do
					if isElement( arrayPlayer ) then
						if getElementData( arrayPlayer, "bigearsfaction" ) == theTeam then
							outputChatBox("((" .. theTeamName .. ")) " .. playerName .. ": " .. message, arrayPlayer, 3, 157, 157)
						elseif getPlayerTeam( arrayPlayer ) == theTeam and getElementData(thePlayer, "loggedin") then
							outputChatBox("((OOC Frakció Chat)) " .. playerName .. ": " .. message, arrayPlayer, 3, 237, 237)
						end
					end
				end
			end
		end
	end
end
--addCommandHandler("f", factionOOC, false, false)

function setRadioChannel(thePlayer, commandName,slot, channel)
	channel = tonumber( channel )
	
	if not (channel) then
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFHasználd: /" .. commandName .. "[Item Slot] [Frekvencia]", thePlayer, 255, 194, 14, true)
	else
		--if (exports.sas_items:hasItem(thePlayer, 4)) then
			local items = exports.sas_items:getElementItems(thePlayer, thePlayer, 0)
			for k, v in pairs( items["bag"] ) do
				--outputDebugString("szar")
				if channel > 0 and channel < 1000000000 then
					if v["id"] == 4 then
						if v["slot"] == tonumber(slot) then
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFBeállítottad a rádiódat a #32b3ef#" .. channel .. " #FFFFFFfrekvenciára.", thePlayer,0,0,255,true)
							exports.sas_items:updateItemValue(thePlayer, thePlayer, v["slot"], channel, v["dbid"])
							outputDebugString(v["slot"])
							--outputChatBox("#7cc576[SeeMTA]: #FFFFFFBeállítottad a rádiódat a #32b3ef#" .. channel .. " #FFFFFFfrekvenciára.", thePlayer,0,0,255,true)
							sendLocalMeAction(thePlayer, "átálítja a rádiója frekvenciáját.")
						else
							outputChatBox("#d9534f[SeeMTA]: #FFFFFFEzen a sloton nem található rádió.", thePlayer, 255, 0, 0,true)
						end
					end
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFTiltott frekvencia.", thePlayer, 255, 0, 0,true)
				end
			end
		--else
			--outputChatBox("#d9534f[SeeMTA]: #FFFFFFNincs rádiód!", thePlayer, 255, 0, 0, true)
		--end
	end
end
addCommandHandler("tuneradio", setRadioChannel, false, false)

function toggleRadio(thePlayer, commandName, slot)
	if (exports.sas_global:hasItem(thePlayer, 41)) then
		local slot = tonumber( slot )
		local items = exports.sas_global:getItems(thePlayer)
		local titemValue = false
		local count = 0
		for k, v in ipairs( items ) do
			if v[1] == 6 then
				if slot then
					count = count + 1
					if count == slot then
						titemValue = v[2]
						break
					end
				else
					titemValue = v[2]
					break
				end
			end
		end
		
		-- gender switch for /me
		local genderm = getElementData(thePlayer, "gender") == 1 and "a" or "a"
		
		if titemValue < 0 then
			outputChatBox("Bekapcsoltad a rádiód.", thePlayer, 255, 194, 14)
			sendLocalMeAction(thePlayer, "bekapcsolta " .. genderm .. " rádióját.")
		else
			outputChatBox("Kikapcsoltad a rádiód.", thePlayer, 255, 194, 14)
			sendLocalMeAction(thePlayer, "kikapcsolta " .. genderm .. " rádióját.")
		end
		--setElementData(thePlayer, "radiochannel", channel, false)
		
		local count = 0
		for k, v in ipairs( items ) do
			if v[1] == 6 then
				if slot then
					count = count + 1
					if count == slot then
						exports.sas_global:updateItemValue(thePlayer, v[3], ( titemValue < 0 and 1 or -1 ) * math.abs( v[2] or 1))
						break
					end
				else
					exports.sas_global:updateItemValue(thePlayer, k, ( titemValue < 0 and 1 or -1 ) * math.abs( v[2] or 1))
				end
			end
		end
	else
		outputChatBox("Nincs rádiód!", thePlayer, 255, 0, 0)
	end
end
--addCommandHandler("toggleradio", toggleRadio, false, false)

-- Admin chat
function adminChat(thePlayer, commandName, ...)
	
	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerAdmin(thePlayer))  then
		if not (...) then
			outputChatBox("Használd: /a [üzenet]", thePlayer, 204, 0, 255,true)
		else
			local message = table.concat({...}, " ")
			local players = getElementsByType("player")
			local username = getPlayerName(thePlayer)
			local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
			for k, arrayPlayer in ipairs(players) do				
				if(exports.sas_global:isPlayerAdmin(arrayPlayer)) and getElementData(arrayPlayer, "loggedin") then
					outputChatBox(adminTitle .. " " .. username .. ": " .. message, arrayPlayer, 204, 0, 255,true)
				end
			end
			
		end
	end
end

addCommandHandler("a", adminChat, false, false)


-- Scripter Chat
function scripterChat(thePlayer, commandName, ...)
	
	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerScripter(thePlayer))  then
		if not (...) then
			outputChatBox("Használd: /s [üzenet]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local players = getElementsByType("player")
			local username = getPlayerName(thePlayer)
			
			for k, arrayPlayer in ipairs(players) do
				if(exports.sas_global:isPlayerScripter(arrayPlayer)) and getElementData(arrayPlayer, "loggedin") then
					outputChatBox("~" .. username .. "~ " .. message, arrayPlayer, 255, 255, 128)
				end
			end
		end
	end
end
addCommandHandler("ss", scripterChat, false, false)
addCommandHandler("sc", scripterChat, false, false)

-- Admin announcement
--[[function adminAnnouncement(thePlayer, commandName, ...)
	
	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerAdmin(thePlayer))  then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local players = getElementsByType("player")
			local username = getPlayerName(thePlayer)

			for k, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
				
				if (logged) then
					if exports.sas_global:isPlayerAdmin(arrayPlayer) then
						outputChatBox( "Admin Announcement by " .. getPlayerName(thePlayer) .. ":", arrayPlayer, 255, 194, 14)
					end
					outputChatBox("   *** " .. message .. " ***", arrayPlayer, 255, 194, 14)
				end
			end
		end
	end
end
addCommandHandler("ann", adminAnnouncement, false, false)]]--

function leadAdminChat(thePlayer, commandName, ...)
	
	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local players = getElementsByType("player")
			local username = getPlayerName(thePlayer)
			local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)

			for k, arrayPlayer in ipairs(players) do				
				if (exports.sas_global:isPlayerLeadAdmin(arrayPlayer)) and getElementData(arrayPlayer, "loggedin") then
					outputChatBox("*4+* " ..adminTitle .. " " .. username .. ": " .. message, arrayPlayer, 204, 102, 255)
				end
			end
		end
	end
end
addCommandHandler("l", leadAdminChat, false, false)

function headAdminChat(thePlayer, commandName, ...)
	
	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerHeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local players = getElementsByType("player")
			local username = getPlayerName(thePlayer)
			local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)

			for k, arrayPlayer in ipairs(players) do				
				if(exports.sas_global:isPlayerHeadAdmin(arrayPlayer)) and getElementData(arrayPlayer, "loggedin") then
					outputChatBox("*5+* " ..adminTitle .. " " .. username .. ": " .. message, arrayPlayer, 255, 204, 51)
				end
			end
		end
	end
end
addCommandHandler("h", headAdminChat, false, false)

-- Misc
local function sortTable( a, b )
	if b[2] < a[2] then
		return true
	end
	
	if b[2] == a[2] and b[4] > a[4] then
		return true
	end
	
	return false
end


function playerChangeChatbubbleMode(thePlayer, commandName, mode)
	if getElementData(thePlayer, "loggedin") then
		mode = tonumber(mode)
		if not mode or mode < 0 or mode > 2 then
			outputChatBox("Használd: /" .. commandName .. " [1-3]", thePlayer, 255, 194, 14)
			outputChatBox("0 = összes elrejtése  1 = saját elrejtése  2 = az összes megjelenítése", thePlayer, 255, 194, 14)
		else
			if (mode == 0) then
				outputChatBox("Az összes chatbuborék elrejtve.", thePlayer, 255, 194, 14)
			elseif (mode == 1) then
				outputChatBox("Csak a saját chatbuborékot van elrejtve a többit látni fogod.", thePlayer, 255, 194, 14)
			elseif (mode == 2) then
				outputChatBox("Az összes chatbuborék látható.", thePlayer, 255, 194, 14)
			end
			setElementData(thePlayer, "chatbubbles", mode)
			dbPoll ( dbQuery( abKapcsolat, "UPDATE accounts SET chatbubbles='?' WHERE id ='?'", mode, getElementData(thePlayer, "gameaccountid")), -1 )
		end
	end
end
addCommandHandler("changecbmode", playerChangeChatbubbleMode, false, false)

function toggleOOC(thePlayer, commandName)

	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerAdmin(thePlayer)) then
		local players = getElementsByType("player")
		local oocEnabled = getOOCState()
		if (commandName == "togooc") then
			if (oocEnabled==1) then
				setOOCState(0)

				for k, arrayPlayer in ipairs(players) do
					if	getElementData(arrayPlayer, "loggedin") then
						outputChatBox("OOC Chat engedélyzeve lett egy Admin által.", arrayPlayer, 0, 255, 0)
					end
				end
			elseif (oocEnabled==0) then
				setOOCState(1)

				for k, arrayPlayer in ipairs(players) do
					if	getElementData(arrayPlayer, "loggedin") then
						outputChatBox("OOC Chat tiltva lett egy Admin által.", arrayPlayer, 255, 0, 0)
					end
				end
			end
		elseif (commandName == "stogooc") then
			if (oocEnabled==1) then
				setOOCState(0)
				
				for k, arrayPlayer in ipairs(players) do
					local admin = getElementData(arrayPlayer, "adminlevel")
					
					if getElementData(arrayPlayer, "loggedin") and (tonumber(admin)>0)then
						outputChatBox("OOC Chat engedélyezve lett Admin " .. getPlayerName(thePlayer) .. " által.", arrayPlayer, 0, 255, 0)
					end
				end
			elseif (oocEnabled==0) then
				setOOCState(1)
				
				for k, arrayPlayer in ipairs(players) do
					local admin = getElementData(arrayPlayer, "adminlevel")
					
					if	getElementData(arrayPlayer, "loggedin") and (tonumber(admin)>0)then
						outputChatBox("OOC Chat tiltva lett Admin " .. getPlayerName(thePlayer) .. " által.", arrayPlayer, 255, 0, 0)
					end
				end
			end
		end
	end
end

addCommandHandler("togooc", toggleOOC, false, false)
addCommandHandler("stogooc", toggleOOC, false, false)
		
--[[function togglePM(thePlayer, commandName)
	
	if getElementData(thePlayer, "loggedin") and ((exports.sas_global:isPlayerAdmin(thePlayer)) or (exports.sas_global:isPlayerBronzeDonator(thePlayer)))then
		local pmenabled = getElementData(thePlayer, "pmblocked")
		
		if (pmenabled==1) then
			setElementData(thePlayer, "pmblocked", 0, false)
			outputChatBox("PM's are now enabled.", thePlayer, 0, 255, 0)
		else
			setElementData(thePlayer, "pmblocked", 1, false)
			outputChatBox("PM's are now disabled.", thePlayer, 255, 0, 0)
		end
		mysql:query_free("UPDATE accounts SET pmblocked=" .. mysql:escape_string(getElementData(thePlayer, "pmblocked")) .. " WHERE id = " .. mysql:escape_string(getElementData(thePlayer, "gameaccountid")))
	end
end
addCommandHandler("togpm", togglePM)
addCommandHandler("togglepm", togglePM)

function toggleAds(thePlayer, commandName)
	
	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerGoldDonator(thePlayer))then
		local adblocked = getElementData(thePlayer, "disableAds")
		if (adblocked) then -- enable the ads again
			setElementData(thePlayer, "disableAds", false, false)
			outputChatBox("Ads are now enabled.", thePlayer, 0, 255, 0)
			mysql:query_free("UPDATE accounts SET adblocked=0 WHERE id = " .. mysql:escape_string(getElementData(thePlayer, "gameaccountid")) )
		else -- disable them D:
			setElementData(thePlayer, "disableAds", true, false)
			outputChatBox("Ads are now disabled.", thePlayer, 255, 0, 0)
			mysql:query_free("UPDATE accounts SET adblocked=1 WHERE id = " .. mysql:escape_string(getElementData(thePlayer, "gameaccountid")) )
		end
	end
end
addCommandHandler("togad", toggleAds)
addCommandHandler("togglead", toggleAds)]]--

function removeAnimation(thePlayer)
	exports.sas_global:removeAnimation(thePlayer)
end

-- /w(hisper)
function localWhisper(thePlayer, commandName, targetPlayerNick, ...)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return end
	 
	if getElementData(thePlayer, "loggedin") then
		if not (targetPlayerNick) or not (...) then
			outputChatBox("Használd: /" .. commandName .. " [ID/NévRészlet] [üzenet]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayerNick)
			
			if targetPlayer then
				local x, y, z = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)
				
				if (getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)<3) then
					local name = getPlayerName(thePlayer)
					local message = table.concat({...}, " ")
					message = trunklateText( thePlayer, message )
					

					
					sendLocalMeAction(thePlayer, "súg valamit neki " .. targetPlayerName .. ".")
					outputChatBox(" " .. name .. " suttogva: " .. message, thePlayer, 255, 255, 255)
					outputChatBox(" " .. name .. " suttogva: " .. message, targetPlayer, 255, 255, 255)
					for i,p in ipairs(getElementsByType( "player" )) do
						if (getElementData(p, "adminduty")) then
							if p ~= targetPlayer and p ~= thePlayer then
								local ax, ay, az = getElementPosition(p)
								if (getDistanceBetweenPoints3D(x, y, z, ax, ay, az)<4) then
									outputChatBox("[" .. languagename .. "] " .. name .. " suttogja neki " .. getPlayerName(targetPlayer):gsub("_"," ") .. ": " .. message, p, 255, 255, 255)
								end
							end
						end
					end
				else
					outputChatBox("Túl messze vagy tõle " .. targetPlayerName .. ".", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("w", localWhisper, false, false)

-- /c(lose)
function localClose(thePlayer, commandName, ...)
	if exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return end
	 
	if getElementData(thePlayer, "loggedin") then
		if not (...) then
			outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
		else
			local name = getPlayerName(thePlayer)
			local message = table.concat({...}, " ")
			message = trunklateText( thePlayer, message )

			for index, targetPlayers in ipairs( getElementsByType( "player" ) ) do
				if getElementDistance( thePlayer, targetPlayers ) < 5 then
					local message2 = message
					if targetPlayers ~= thePlayer then
						message2 = trunklateText( targetPlayers, message2 )
					end
					local pveh = getPedOccupiedVehicle(targetPlayers)
					if pveh then
						if (exports['sas_vehicle']:isVehicleWindowUp(pveh)) then			
							outputChatBox( " " .. name .. " súgja: " .. message2, targetPlayers, 255, 255, 255)
						end
					else
						outputChatBox( " " .. name .. " súgja: " .. message2, targetPlayers, 255, 255, 255)
					end
				end
			end
		end
	end
end
addCommandHandler("c", localClose, false, false)

------------------
-- News Faction --
------------------
-- /n(ews)
function newsMessage(thePlayer, commandName, ...)
	if getElementData(thePlayer, "loggedin") then
		local theTeam = getPlayerTeam(thePlayer)
		local factionType = getElementData(theTeam, "type")
		
		if(factionType==6)then -- news faction
			
			if not(...)then
				outputChatBox("Használd: /" .. commandName .. " [üzenet]", thePlayer, 255, 194, 14)
			else
				local message = table.concat({...}, " ")
				local name = getPlayerName(thePlayer)
				
				local abuse = true
				if (getElementDimension(thePlayer) == 9902) then
					abuse = false
				end
				for index, nearbyVehicle in ipairs( getNearbyElements(thePlayer, "vehicle", 25) ) do
					if (getElementModel(nearbyVehicle) == 582) then
					 abuse = false
					end
				end
				
				for key, value in ipairs(getElementsByType("player")) do
						
					if getElementData(value, "loggedin") then
							
						if not(getElementData(value, "tognews")==1) then
							outputChatBox("[Hírek] ".. name .." mondja: ".. message, value, 200, 100, 200)
						end
					end
				end
				
				exports.sas_global:giveMoney(theTeam, 200)
			end
		end
	end
end
addCommandHandler("n", newsMessage, false, false)

-- /tognews
function togNews(thePlayer, commandName)	
	if getElementData(thePlayer, "loggedin") and (exports.sas_global:isPlayerGoldDonator(thePlayer)) then
		local newsTog = getElementData(thePlayer, "tognews")
		
		if (newsTog~=1) then
			outputChatBox("/news tiltva.", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "tognews", 1, false)
		else
			outputChatBox("/news engedélyezve.", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "tognews", 0, false)
		end
		dbPoll ( dbQuery( abKapcsolat, "UPDATE accounts SET newsblocked='?' WHERE id ='?'", getElementData(thePlayer, "tognews"), getElementData(thePlayer, "gameaccountid")), -1 )
	end
end
addCommandHandler("tognews", togNews, false, false)
addCommandHandler("togglenews", togNews, false, false)


-- /startinterview
function StartInterview(thePlayer, commandName, targetPartialPlayer)
	if getElementData(thePlayer, "loggedin") then
		local theTeam = getPlayerTeam(thePlayer)
		local factionType = getElementData(theTeam, "type")
		if(factionType==6)then -- news faction
			if not (targetPartialPlayer) then
				outputChatBox("Használd: /" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14)
			else
				local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPartialPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "loggedin") then
						if(getElementData(targetPlayer,"interview"))then
							outputChatBox("Ez a játékos már interjúban van.", thePlayer, 255, 0, 0)
						else
							setElementData(targetPlayer, "interview", true, false)
							local playerName = getPlayerName(thePlayer)
							outputChatBox(playerName .." felkért egy interjúra.", targetPlayer, 0, 255, 0)
							outputChatBox("((Használd /i hogy beszélj az interjúba.))", targetPlayer, 0, 255, 0)
							local NewsFaction = getPlayersInTeam(getPlayerTeam(thePlayer))
							for key, value in ipairs(NewsFaction) do
								outputChatBox("((".. playerName .." meghívta " .. targetPlayerName .. " egy interjúra.))", value, 0, 255, 0)
							end
						end
					end
				end
			end
		end
	end
end
addCommandHandler("interview", StartInterview, false, false)

-- /endinterview
function endInterview(thePlayer, commandName, targetPartialPlayer)
	if getElementData(thePlayer, "loggedin") then
		local theTeam = getPlayerTeam(thePlayer)
		local factionType = getElementData(theTeam, "type")
		if(factionType==6)then -- news faction
			if not (targetPartialPlayer) then
				outputChatBox("Használd: /" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14)
			else
				local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPartialPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "loggedin") then
						if not(getElementData(targetPlayer,"interview"))then
							outputChatBox("Ez a játékos nincs meghívva az interjúba.", thePlayer, 255, 0, 0)
						else
							setElementData(targetPlayer, "interview")
							local playerName = getPlayerName(thePlayer)
							outputChatBox(playerName .." befejezte az interjút.", targetPlayer, 255, 0, 0)
						
							local NewsFaction = getPlayersInTeam(getPlayerTeam(thePlayer))
							for key, value in ipairs(NewsFaction) do
								outputChatBox("((".. playerName .." befejezte az interjút vele " .. targetPlayerName .. ".))", value, 255, 0, 0)
							end
						end
					end
				end
			end
		end
	end
end
addCommandHandler("endinterview", endInterview, false, false)

-- /i
function interviewChat(thePlayer, commandName, ...)
	if getElementData(thePlayer, "loggedin") then
		if(getElementData(thePlayer, "interview"))then
			if not(...)then
				outputChatBox("Használd: /" .. commandName .. "[üzenet]", thePlayer, 255, 194, 14)
			else
				local message = table.concat({...}, " ")
				local name = getPlayerName(thePlayer)
				
				
				for key, value in ipairs(getElementsByType("player")) do
					if getElementData(value, "loggedin") then
						if not (getElementData(value, "tognews")==1) then
							outputChatBox("[Hírek] Interjú vendég " .. name .." mondja: ".. message, value, 200, 100, 200)
						end
					end
				end
				
				exports.sas_global:giveMoney(getTeamFromName("Riporter"), 200)
			end
		end
	end
end
addCommandHandler("i", interviewChat, false, false)

-- /bigears
function bigEars(thePlayer, commandName, targetPlayerNick)
	if exports.sas_global:isPlayerLeadAdmin(thePlayer) then
		local current = getElementData(thePlayer, "bigears")
		if not current and not targetPlayerNick then
			outputChatBox("Használd: /" .. commandName .. " [játékos]", thePlayer, 255, 194, 14)
		elseif current and not targetPlayerNick then
			setElementData(thePlayer, "bigears", false)
			outputChatBox("Megnõttek a füleid.", thePlayer, 255, 0, 0)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayerNick)
			
			if targetPlayer then
				outputChatBox("Most " .. targetPlayerName .. "-t halgatod.", thePlayer, 0, 255, 0)
				setElementData(thePlayer, "bigears", targetPlayer)
			end
		end
	end
end
addCommandHandler("bigears", bigEars)

function removeBigEars()
	for key, value in pairs( getElementsByType( "player" ) ) do
		if isElement( value ) and getElementData( value, "bigears" ) == source then
			setElementData( value, "bigears", false )
			outputChatBox("Össze mentek a füleid (Játékos lecsatlakozott).", value, 255, 0, 0)
		end
	end
end
addEventHandler( "onPlayerQuit", getRootElement(), removeBigEars)

function bigEarsFaction(thePlayer, commandName, factionID)
	if exports.sas_global:isPlayerLeadAdmin(thePlayer) then
		factionID = tonumber( factionID )
		local current = getElementData(thePlayer, "bigearsfaction")
		if not current and not factionID then
			outputChatBox("Használd: /" .. commandName .. " [faction id]", thePlayer, 255, 194, 14)
		elseif current and not factionID then
			setElementData(thePlayer, "bigearsfaction", false)
			outputChatBox("Össze mentek a füleid.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("bigearsf", bigEarsFaction)

function disableMsg(message, player)
	cancelEvent()

	-- send it using our own PM etiquette instead
	pmPlayer(source, "pm", player, message)
end
addEventHandler("onPlayerPrivateMessage", getRootElement(), disableMsg)


local chaticonsHidden = { }

function sendChatIconShown()
	local px, py, pz = getElementPosition(client)

	for key, value in ipairs(getElementsByType("player")) do
		local vx, vy, vz = getElementPosition(value)
			
		if ( getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) <= 25 ) and not (value==client) and chaticonsHidden[value]==nil then -- only send if they can see it and have chaticons enabled
			triggerClientEvent(value, "addChatter", client)
		end
	end
end
addEvent("chat1", true)
addEventHandler("chat1", getRootElement(), sendChatIconShown)

function sendChatIconHidden()
	local px, py, pz = getElementPosition(client)
	for key, value in ipairs(getElementsByType("player")) do
		local vx, vy, vz = getElementPosition(value)
		
		if ( getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) <= 25 ) and not (value==client) and chaticonsHidden[value]==nil then -- only send if they can see it and have chaticons enabled, persons out of range who COULD see it before, are handled clientside
			triggerClientEvent(value, "delChatter", client)
		end
	end
end
addEvent("chat0", true)
addEventHandler("chat0", getRootElement(), sendChatIconHidden)

function storeChatIconShown()
	chaticonsHidden[client] = nil
end
addEvent("chaticon1", true)
addEventHandler("chaticon1", getRootElement(), storeChatIconShown)

function storeChatIconHidden()
	chaticonsHidden[client] = true
end
addEvent("chaticon0", true)
addEventHandler("chaticon0", getRootElement(), storeChatIconHidden)

oocState = getElementData(getRootElement(),"globalooc:state") or 0

function getOOCState()
	return oocState
end

function setOOCState(state)
	oocState = state
	setElementData(getRootElement(),"globalooc:state", state)
end

function getNearbyElements(thePlayer, type, distance)
	local x, y, z = getElementPosition(thePlayer)
	local elements = {}

	if getElementType(thePlayer) == "player" and exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return elements end

	for index, nearbyElement in ipairs(getElementsByType(type)) do
		if isElement(nearbyElement) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyElement)) < ( distance or 20 ) then
			if getElementDimension(thePlayer) == getElementDimension(nearbyElement) then
				table.insert( elements, nearbyElement )
			end
		end
	end
	return elements
end

function sendLocalText(thePlayer, message, r, g, b, distance, exclude)
	exclude = exclude or {}
	local x, y, z = getElementPosition(thePlayer)

	if getElementType(thePlayer) == "player" and exports['sas_freecamtv']:isPlayerFreecamEnabled(thePlayer) then return end

	local shownto = 0
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < ( distance or 20 ) then
			if not exclude[nearbyPlayer] and not isPedDead(nearbyPlayer) and getElementData(nearbyPlayer, "loggedin")and getElementDimension(thePlayer) == getElementDimension(nearbyPlayer) then
				outputChatBox(message, nearbyPlayer, r, g, b)
				shownto = shownto + 1
			end
		end
	end

	if getElementType(thePlayer) == "player" and shownto > 0 and getElementDimension(thePlayer) == 127 then -- TV SHOW!
		exports['sas_freecamtv']:add(shownto, message)
	end
end
addEvent("sendLocalText", true)
addEventHandler("sendLocalText", getRootElement(), sendLocalText)

function sendLocalMeAction(thePlayer, message)
	sendLocalText(thePlayer, " *" .. getPlayerName(thePlayer):gsub("_", " ") .. ( message:sub( 1, 1 ) == "'" and "" or " " ) .. message, 194, 162, 218)
end
addEvent("sendLocalMeAction", true)
addEventHandler("sendLocalMeAction", getRootElement(), sendLocalMeAction)

function sendLocalTry(thePlayer, uzenet, r, g, b)
	local x, y, z = getElementPosition(thePlayer)
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < ( distance or 20 ) then
			outputChatBox(uzenet, nearbyPlayer, r, g, b)
		end
	end
end
addEvent("sendLocalTry", true)
addEventHandler("sendLocalTry", getRootElement(), sendLocalTry)

function sendLocalDoAction(thePlayer, message)
	sendLocalText(thePlayer, " * " .. message .. " * ((" .. getPlayerName(thePlayer):gsub("_", " ") .. "))", 255, 51, 102)
end
addEvent("sendLocalDoAction", true)
addEventHandler("sendLocalDoAction", getRootElement(), sendLocalDoAction)