local connection = exports.sas_mysql:getConnection()

-- ADMIN HISTORY:
-- 0: jail
-- 1: kick
-- 2: ban
-- 3: forceapp
-- 4: warn
-- 5: auto-ban


local _getPlayerName = getPlayerName

function getPlayerName(player)
	return _getPlayerName(player):gsub("_", " ")
end

function toggleInvisibility(thePlayer)
	if (tonumber(getElementData(thePlayer, "adminlevel")) >= 1) then
		local enabled = getElementData(thePlayer, "invisible")
		if (enabled == true) then
			setElementAlpha(thePlayer, 255)
			setElementData(thePlayer, "reconx", false)
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFLátható vagy.", thePlayer, 255, 0, 0,true)
			setElementData(thePlayer, "invisible", false)
		elseif (enabled == false or enabled == nil) then
			setElementAlpha(thePlayer, 0)
			setElementData(thePlayer, "reconx", true)
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFLáthatatlan vagy.", thePlayer, 0, 255, 0,true)
			setElementData(thePlayer, "invisible", true)
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFElõbb kapcsold ki az Admin TV-t.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("disappear", toggleInvisibility)
addCommandHandler("vanish", toggleInvisibility)


function adminMessage(thePlayer, commandName, ...)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/asay [Admin Üzenet]", thePlayer, 255, 255, 255, true)
		else
			local adminrang = exports.sas_global:getPlayerAdminTitle(thePlayer)

			message = table.concat({...}, " ")
			local playerName = getPlayerName(thePlayer)
			outputChatBox(adminrang .. " " .. playerName .. ": " .. message, getRootElement(), 217, 83, 79,true)
		end
	end
end
addCommandHandler("asay", adminMessage, false, false)


function getPosition(thePlayer, commandName)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		local x, y, z = getElementPosition(thePlayer)
		local rotation = getPedRotation(thePlayer)
		local dimension = getElementDimension(thePlayer)
		local interior = getElementInterior(thePlayer)

		outputChatBox("#7cc576[SeeMTA]: #FFFFFFPozíció: #32b3ef" .. x .. ", " .. y .. ", " .. z, thePlayer, 255, 255, 255,true)
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFRotáció: #32b3ef" .. rotation, thePlayer, 255, 255, 255,true)
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFDimenzió: #32b3ef" .. dimension, thePlayer, 255, 255, 255,true)
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFInterior: #32b3ef" .. interior, thePlayer, 255, 255, 255,true)
	end
end
addCommandHandler("getpos", getPosition, false, false)


-- /MUTE
function mutePlayer(thePlayer, commandName, targetPlayer)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID / NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				else
					local muted = getElementData(targetPlayer, "muted")

					if (muted==0) then
						setElementData(targetPlayer, "muted", 1)
						outputChatBox(targetPlayerName .. " némítva lett az OOC-rõl.", thePlayer, 255, 0, 0)
						outputChatBox("Némítva lettél az OOC Chat-rõl" .. getPlayerName(thePlayer) .. "' által.", targetPlayer, 255, 0, 0)
					else
						setElementData(targetPlayer, "muted", 0)
						outputChatBox(targetPlayerName .. "-rõl levetted az OOC némítást.", thePlayer, 0, 255, 0)
						outputChatBox("'" .. getPlayerName(thePlayer) .. "' levette rólad az OOC némítást.", targetPlayer, 0, 255, 0)
					end
					dbPoll ( dbQuery( connection, "UPDATE accounts SET muted='?' WHERE id = '?'", getElementData(targetPlayer, "muted"), getElementData( targetPlayer, "dbid" )), -1 )
				end
			end
		end
	end
end
addCommandHandler("pmute", mutePlayer, false, false)

-- /RESKICK
function resKick(thePlayer, commandName, amount)
	if (exports.sas_global:isPlayerScripter(thePlayer)) then
		if not (amount) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF: /" .. commandName .. " [Játékosok száma amennyit kickelni akarsz]", thePlayer, 255, 194, 14)
		else
			amount = tonumber(amount)
			local playercount = getPlayerCount()
			if (amount>=playercount) then
				outputChatBox("Nincs elég játékos a kickeléshez. (Jelenleg " .. playercount .. " játékos online)", thePlayer, 255, 0, 0)
			else
				local players = { }
				local count = 1
				for key, value in ipairs(getElementsByType("player")) do
					if not (exports.sas_global:isPlayerAdmin(value)) and not exports.sas_global:isPlayerScripter(value) then
						players[count] = value
						count = count + 1

						if (count==amount) then
							break
						end
					end
				end
				local kickcount = 0
				for key, value in ipairs(players) do
					if (kickcount<amount) then
						local luck = math.random(0, 1)
						if (luck==1) then
							kickPlayer(value, getRootElement(), "Foglalt slot-ra csatlakoztál")
							kickcount = kickcount + 1
						end
					end
				end
				outputChatBox("" .. kickcount .. "/" .. amount .. " játékos kickelve.", thePlayer, 0, 255, 0)
			end
		end
	end
end
addCommandHandler("reskick", resKick, false, false)

-- /DISARM
function disarmPlayer(thePlayer, commandName, targetPlayer)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID / NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("A játékos nincs bejelentkezve.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					takeAllWeapons(targetPlayer)
					outputChatBox(targetPlayerName .. " lefegyverezve.", thePlayer, 255, 194, 14)
				end
			end
		end
	end
end
addCommandHandler("disarm", disarmPlayer, false, false)

-- /FRECONNECT
function forceReconnect(thePlayer, commandName, targetPlayer)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID / NévRészlet]", thePlayer, 255, 255, 255, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				elseif (logged==1) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFJátékos " .. targetPlayerName .. " újracsatlakoztatva.", thePlayer, 255, 0, 0, true)

					local port = getServerPort()
					local password = getServerPassword()

					redirectPlayer(targetPlayer, "localhost", port, password) --ezt módosítani!!!

				end
			end
		end
	end
end
addCommandHandler("freconnect", forceReconnect, false, false)

-- /SETHP
function setPlayerHealth(thePlayer, commandName, targetPlayer, health)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not tonumber(health) or not (targetPlayer) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID / NévRészlet] [Élet]", thePlayer, 255, 255, 255,true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				if tonumber( health ) < getElementHealth( targetPlayer ) and getElementData( thePlayer, "adminlevel" ) < getElementData( targetPlayer, "adminlevel" ) then
					outputChatBox("Nah.", thePlayer, 255, 0, 0)
				elseif not setElementHealth(targetPlayer, tonumber(health)) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFHelytelen élet érték.", thePlayer, 255, 0, 0, true)
				else
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFJátékos #32b3ef" .. targetPlayerName .. " #ffffffkapott " .. health .. " életet.", thePlayer, 255, 255, 255,true)
					triggerEvent("onPlayerHeal", targetPlayer, true)
				end
			end
		end
	end
end
addCommandHandler("sethp", setPlayerHealth, false, false)

-- /SETARMOR
function setPlayerArmour(thePlayer, commandName, targetPlayer, armor)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (armor) or not (targetPlayer) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID / NévRészlet] [Armor]", thePlayer, 255, 255, 255,true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("A játékos nincs bejelentkezve.", thePlayer, 255, 0, 0)
				elseif (tostring(type(tonumber(armor))) == "number") then
					setPedArmor(targetPlayer, tonumber(armor))
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFJátékos #32b3ef" .. targetPlayerName .. "#ffffff kapott  " .. armor .. " páncélt.", thePlayer, 0, 255, 0, true)
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFHelytelen páncél érték.", thePlayer, 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("setarmor", setPlayerArmour, false, false)

-- /SETPLAYERSKIN
function setPlayerSkinCmd(thePlayer, commandName, targetPlayer, skinID)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (skinID) or not (targetPlayer) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID / NévRészlet] [Skin ID]", thePlayer, 255, 255, 255,true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				elseif (tostring(type(tonumber(skinID))) == "number" and tonumber(skinID) ~= 0) then
					local fat = getPedStat(targetPlayer, 21)
					local muscle = getPedStat(targetPlayer, 23)

					setPedStat(targetPlayer, 21, 0)
					setPedStat(targetPlayer, 23, 0)
					local skin = setElementModel(targetPlayer, tonumber(skinID))

					setPedStat(targetPlayer, 21, fat)
					setPedStat(targetPlayer, 23, muscle)
					if not (skin) then
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFHelytelen skin ID.", thePlayer, 255, 0, 0, true)
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFJátékos #32b3ef" .. targetPlayerName .. " #ffffffkinézete megváltoztatva erre: #32b3ef" .. skinID .. "#ffffff.", thePlayer, 255, 255, 255,true)
					end
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFHelytelen skin ID.", thePlayer, 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("setpskin", setPlayerSkinCmd, false, false)

function setIdoJaras(thePlayer, commandName, IdoJaras)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (IdoJaras) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Időjárás]", thePlayer, 255, 194, 14, true)
		else
			setWeather (IdoJaras)
		end
	end
end
addCommandHandler("setweather", setIdoJaras, false, false)

function setIdo(thePlayer, commandName, Ido)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (Ido) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF: /" .. commandName .. " [Óra]", thePlayer, 255, 194, 14, true)
		else
			setTime (Ido,0)
		end
	end
end
addCommandHandler("settimes", setIdo)

-- /CHANGENAME
function asetPlayerName(thePlayer, commandName, targetPlayer, ...)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (...) or not (targetPlayer) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID / NévRészlet] [Játékos új neve]", thePlayer, 255, 255, 255,true)
		else
			local newName = table.concat({...}, "_")
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				if newName == targetPlayerName then
					outputChatBox( "#d9534f[SeeMTA]: #FFFFFFA játékos már ezt a nevet viseli.", thePlayer, 255, 0, 0, true)
				else
					local dbid = getElementData(targetPlayer, "dbid")
					if (sor>0) then
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFEz a név már használatban.", thePlayer, 255, 0, 0, true)
					else
						local name = setPlayerName(targetPlayer, tostring(newName))
						exports.sas_vehicle:changeCharacterName(dbid, tostring(newName))

						if (name) then
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (not hiddenAdmin) then
								local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
								exports.sas_global:sendMessageToAdmins("" .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " megváltoztatta " .. targetPlayerName .. " nevét erre: " .. newName .. ".")
							end
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFMegváltoztattad #32b3ef" .. targetPlayerName .. "#ffffff nevét erre: #32b3ef" .. tostring(newName) .. "#ffffff.", thePlayer, 255, 255, 255,true)
						else
							outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékosnak nem sikerült megváltoztatni a nevét.", thePlayer, 255, 0, 0, true)
						end
					end
				end
			end
		end
	end
end
addCommandHandler("changename", asetPlayerName, false, false)

-- /HIDEADMIN
function hideAdmin(thePlayer, commandName)
	if exports.sas_global:isPlayerHeadAdmin(thePlayer) or exports.sas_global:isPlayerScripter(thePlayer) then
		local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

		if (not hiddenAdmin) then
			setElementData(thePlayer, "hiddenadmin", 1)
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFRejtett Admin vagy.", thePlayer, 0, 206, 209, true)
		elseif (hiddenAdmin) then
			setElementData(thePlayer, "hiddenadmin", 0)
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFRejtett Admin mód kikapcsolva.", thePlayer, 0, 206, 209, true)
		end
	end
end
addCommandHandler("hideadmin", hideAdmin, false, false)

-- HEADS Hidden OOC
function hiddenOOC(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if (exports.sas_global:isPlayerHeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Message]", thePlayer, 255, 194, 14, true)
		else
			local players = getElementsByType("player")
			local message = table.concat({...}, " ")

			for index, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")

				if (logged==1) and getElementData(arrayPlayer, "globalooc") == 1 then
					outputChatBox("(( Rejtett Admin: " .. message .. " ))", arrayPlayer, 255, 255, 255)
				end
			end
		end
	end
end
addCommandHandler("ho", hiddenOOC, false, false)

-- RECON
function reconPlayer(thePlayer, commandName, targetPlayer)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			local rx = getElementData(thePlayer, "reconx")
			local ry = getElementData(thePlayer, "recony")
			local rz = getElementData(thePlayer, "reconz")
			local reconrot = getElementData(thePlayer, "reconrot")
			local recondimension = getElementData(thePlayer, "recondimension")
			local reconinterior = getElementData(thePlayer, "reconinterior")

			if not (rx) or not (ry) or not (rz) or not (reconrot) or not (recondimension) or not (reconinterior) then
				outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. "#ffffff [Névrészlet]", thePlayer, 255, 255, 255,true)
			else
				detachElements(thePlayer)

				setElementPosition(thePlayer, rx, ry, rz)
				setPedRotation(thePlayer, reconrot)
				setElementDimension(thePlayer, recondimension)
				setElementInterior(thePlayer, reconinterior)
				setCameraInterior(thePlayer, reconinterior)

				setElementData(thePlayer, "reconx", nil)
				setElementData(thePlayer, "recony", nil, false)
				setElementData(thePlayer, "reconz", nil, false)
				setElementData(thePlayer, "reconrot", nil, false)
				setCameraTarget(thePlayer, thePlayer)
				setElementAlpha(thePlayer, 255)
				outputChatBox("Recon kikapcsolva.", thePlayer, 255, 194, 14)
			end
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				else
					setElementAlpha(thePlayer, 0)

					if ( not getElementData(thePlayer, "reconx") or getElementData(thePlayer, "reconx") == true ) and not getElementData(thePlayer, "recony") then
						local x, y, z = getElementPosition(thePlayer)
						local rot = getPedRotation(thePlayer)
						local dimension = getElementDimension(thePlayer)
						local interior = getElementInterior(thePlayer)
						setElementData(thePlayer, "reconx", x)
						setElementData(thePlayer, "recony", y, false)
						setElementData(thePlayer, "reconz", z, false)
						setElementData(thePlayer, "reconrot", rot, false)
						setElementData(thePlayer, "recondimension", dimension, false)
						setElementData(thePlayer, "reconinterior", interior, false)
					end
					setPedWeaponSlot(thePlayer, 0)

					local playerdimension = getElementDimension(targetPlayer)
					local playerinterior = getElementInterior(targetPlayer)

					setElementDimension(thePlayer, playerdimension)
					setElementInterior(thePlayer, playerinterior)
					setCameraInterior(thePlayer, playerinterior)

					local x, y, z = getElementPosition(targetPlayer)
					setElementPosition(thePlayer, x - 10, y - 10, z - 5)
					local success = attachElements(thePlayer, targetPlayer, -10, -10, -5)
					if not (success) then
						success = attachElements(thePlayer, targetPlayer, -5, -5, -5)
						if not (success) then
							success = attachElements(thePlayer, targetPlayer, 5, 5, -5)
						end
					end

					if not (success) then
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem sikerült kapcsolódni a játékoshoz.", thePlayer, 0, 255, 0, true)
					else
						setCameraTarget(thePlayer, targetPlayer)
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin TV: Most #32b3ef" .. targetPlayerName .. "#ffffff-t figyeled.", thePlayer, 255, 255, 255,true)

						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

						if hiddenAdmin == 0 and not exports.sas_global:isPlayerLeadAdmin(thePlayer) then
							local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
							exports.sas_global:sendMessageToAdmins("" .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " Admin TV-zi " .. targetPlayerName .. "-t.")
						end
					end
				end
			end
		end
	end
end
addCommandHandler("recon", reconPlayer, false, false)

function fuckRecon(thePlayer, commandName, targetPlayer)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		local rx = getElementData(thePlayer, "reconx")
		local ry = getElementData(thePlayer, "recony")
		local rz = getElementData(thePlayer, "reconz")
		local reconrot = getElementData(thePlayer, "reconrot")
		local recondimension = getElementData(thePlayer, "recondimension")
		local reconinterior = getElementData(thePlayer, "reconinterior")

		detachElements(thePlayer)
		setCameraTarget(thePlayer, thePlayer)
		setElementAlpha(thePlayer, 255)

		if rx and ry and rz then
			setElementPosition(thePlayer, rx, ry, rz)
			if reconrot then
				setPedRotation(thePlayer, reconrot)
			end

			if recondimension then
				setElementDimension(thePlayer, recondimension)
			end

			if reconinterior then
				setElementInterior(thePlayer, reconinterior)
				setCameraInterior(thePlayer, reconinterior)
			end
		end

		outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin TV kikapcsolva.", thePlayer, 0, 206, 209, true)
	end
end
addCommandHandler("stoprecon", fuckRecon, false, false)

--pm
function PMNeki(thePlayer, commandName, targetPlayer, ...)
		if(not getElementData(thePlayer, "loggedin") or getElementData(thePlayer, "loggedin") == 0) then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem vagy bejelentkezve.", thePlayer, 255, 0, 0, true)
			return
		end
		if not (targetPlayer) or not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. "#ffffff [Névrészlet] [szöveg]", thePlayer, 255, 255, 255,true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				szoveg = table.concat({...}, " ")
				local adminszolis = getElementData(targetPlayer, "adminduty")
				if (exports.sas_global:isPlayerSeged(targetPlayer) == true and adminszolis and adminszolis > 0 or exports.sas_global:isPlayerSeged(thePlayer) == true) then
					local rejtettadmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)
					local targetName = getPlayerName(targetPlayer)
					outputChatBox("[PM neked][ID: "..getElementData(thePlayer, "playerid").."] " .. playerName .. ": " .. szoveg, targetPlayer, 255, 153, 51)
					outputChatBox("[PM tőled][ID: "..getElementData(thePlayer, "playerid").."] " .. targetName .. ": " .. szoveg, thePlayer, 255, 153, 51)
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFCsak szolgálatban levő adminnak írhatsz PM-et!", thePlayer, 255, 0, 0, true)
				end
			end
		end
end
addCommandHandler("pm", PMNeki, false, false)

--vá
function ValaszNeki(thePlayer, commandName, targetPlayer, ...)
	if (exports.sas_global:isPlayerSeged(thePlayer)) then
		if not (targetPlayer) or not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Névrészlet] [szöveg]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				szoveg = table.concat({...}, " ")

				if (exports.sas_global:isPlayerAdmin(targetPlayer) ~= true) then
					local rejtettadmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)

					if (rejtettadmin==0) then
						local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
						--outputChatBox("Válaszod neki: " .. targetPlayerName .. ": " .. szoveg, thePlayer, 255, 255, 0)
						outputChatBox(adminTitle .. playerName .. ": " .. szoveg, targetPlayer, 255, 153, 51)
					else
						local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
						--outputChatBox("Válaszod neki: " .. targetPlayerName .. ": " .. szoveg, thePlayer, 255, 255, 0)
						outputChatBox(adminTitle .. ": " .. szoveg, targetPlayer, 255, 153, 51)
					end
					exports.sas_global:sendMessageToAdmins(playerName .. " válaszolt neki: " .. targetPlayerName, 255, 255, 0)
					exports.sas_global:sendMessageToAdmins("Szöveg: " .. szoveg, 255, 255, 0)
				else
					outputChatBox("(( Másik adminnak akarsz válaszolni?! ))", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("vá", ValaszNeki, false, false)
addCommandHandler("válasz", ValaszNeki, false, false)


-- Kick
function kickAPlayer(thePlayer, commandName, targetPlayer, ...)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) or not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Névrészlet] [Indok]", thePlayer, 255, 255, 255,true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local thePlayerPower = exports.sas_global:getPlayerAdminLevel(thePlayer)
				local targetPlayerPower = exports.sas_global:getPlayerAdminLevel(targetPlayer)
				reason = table.concat({...}, " ")

				if (targetPlayerPower <= thePlayerPower) then
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)

					dbPoll ( dbQuery( connection, "INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES (?, ?, ?, ?, ?, 1, 0, ?)", getPlayerName(targetPlayer), tostring(getElementData(targetPlayer, "gameaccountid") or 0), getPlayerName(thePlayer), tostring(getElementData(thePlayer, "accountid") or 0), hiddenAdmin, reason), -1 )

					if (not hiddenAdmin) then
						if commandName ~= "skick" then
							local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
							exports.sas_hud:addKickban(getRootElement(), playerName.." kickelte: "..targetPlayerName, "kick", "Indok: "..reason)
						end
						kickPlayer(targetPlayer, thePlayer, reason)
					else
						if commandName ~= "skick" then
							exports.sas_hud:addKickban(getRootElement(), playerName.." kickelte: "..targetPlayerName, "kick", "Indok: "..reason)
						end
						kickPlayer(targetPlayer, getRootElement(), reason)
					end
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFEz a játékos magasabb szintű admin, mint te.", thePlayer, 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("pkick", kickAPlayer, false, false)


-- BAN
function obanAPlayer(thePlayer, commandName, targetPlayer, hours, ...)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) or not (hours) or (tonumber(hours)<0) or not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Teljes név] [Idõ órában, 0 = Örök] [Indok]", thePlayer, 255, 194, 14, true)
		else
			local eredmeny, sorszam = dbPoll ( dbQuery( connection, "SELECT account, accounts.id as accid FROM characters INNER JOIN accounts ON characters.account=accounts.id WHERE charactername LIKE ?", targetPlayer), -1 )

			hours = tonumber(hours)
			if not (sorszam == 1) then
			elseif (hours>168) then
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem bannolhatsz többet mint 7 nap (168 Óra).", thePlayer, 255, 194, 14, true)
			else
				reason = table.concat({...}, " ")

					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)
					local accountID = eredmeny[1]["accid"]

					local seconds = ((hours*60)*60)
					local rhours = hours
					-- text value
					if (hours==0) then
						hours = "örökre"
					elseif (hours==1) then
						hours = "1 Órára"
					else
						hours = hours .. " Órára"
					end

					reason = reason .. " (" .. hours .. ")"

					--dbPoll ( dbQuery( connection, "INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES (?, ?, ?, ?, ?, 2, ?, ?)", getPlayerName(targetPlayer), tostring(getElementData(targetPlayer, "gameaccountid") or 0), getPlayerName(thePlayer), tostring(getElementData(thePlayer, "gameaccountid") or 0), hiddenAdmin, rhours, reason), -1 )

					if (not hiddenAdmin) then
						local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
						exports.sas_hud:addKickban(getRootElement(), playerName.." bannolta: "..targetPlayerName, "ban", "Indok: "..reason)
						dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='1', banned_reason=?, banned_by=? WHERE id='?'", reason, playerName, accountID), -1 )
					elseif (hiddenAdmin) then
						exports.sas_hud:addKickban(getRootElement(), playerName.." bannolta: "..targetPlayerName, "ban", "Indok: "..reason)
						dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='1', banned_reason='?', banned_by=? WHERE id='?'", reason, playerName, accountID), -1 )
					end
			end
		end
	end
end
addCommandHandler("offban", obanAPlayer, false, false)

function banAPlayer(thePlayer, commandName, targetPlayer, hours, ...)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) or not (hours) or (tonumber(hours)<0) or not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFHasználat: /" .. commandName .. "[Játékosnév/ID] [Idő(Órában), 0 = Örök] [Oka]", thePlayer, 255, 194, 14,true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			hours = tonumber(hours)

			if not (targetPlayer) then
			elseif (hours>168) then
				outputChatBox("Nem bannolhatsz többet mint 7 nap (168 Óra).", thePlayer, 255, 194, 14)
			else
				local thePlayerPower = exports.sas_global:getPlayerAdminLevel(thePlayer)
				local targetPlayerPower = exports.sas_global:getPlayerAdminLevel(targetPlayer)
				reason = table.concat({...}, " ")

				if (targetPlayerPower <= thePlayerPower) then -- Check the admin isn't banning someone higher rank them him
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)
					local accountID = getElementData(targetPlayer, "account:id")

					local seconds = ((hours*60)*60)
					local rhours = hours
					-- text value
					if (hours==0) then
						hours = "Örökre"
					else
						hours = hours .. " órára"
					end

					reason = reason .. " (" .. hours .. ")"

					dbPoll ( dbQuery( connection, "INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES (?, ?, ?, ?, ?, 2, ?, ?)", getPlayerName(targetPlayer), tostring(getElementData(targetPlayer, "gameaccountid") or 0), getPlayerName(thePlayer), tostring(getElementData(thePlayer, "gameaccountid") or 0), hiddenAdmin, rhours, reason), -1 )

					local showingPlayer = nil
					if (not hiddenAdmin) then
						local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
						exports.sas_hud:addKickban(getRootElement(), playerName.." bannolta: "..targetPlayerName, "ban", "Indok: "..reason)
						showingPlayer = thePlayer

						local ban = addBan(nil, nil, getPlayerSerial(targetPlayer), thePlayer, reason, seconds)
						--local ban = banPlayer(targetPlayer, false, false, true, thePlayer, reason, seconds)

						if (seconds == 0) then
							dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='1', banned_reason=?, banned_by=? WHERE id='?'", reason, playerName, accountID), -1 )
						end
					elseif (hiddenAdmin) then
						exports.sas_hud:addKickban(getRootElement(), playerName.." bannolta: "..targetPlayerName, "ban", "Indok: "..reason)
						showingPlayer = getRootElement()

						local ban = addBan(nil, nil, getPlayerSerial(targetPlayer), thePlayer, reason, seconds)
						--local ban = banPlayer(targetPlayer, false, false, true, getRootElement(), reason, seconds)

						if (seconds == 0) then
							dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='1', banned_reason='?', banned_by=? WHERE id='?'", reason, playerName, accountID), -1 )
						end
					end

					local serial = getPlayerSerial(targetPlayer)
					for key, value in ipairs(getElementsByType("player")) do
						if getPlayerSerial(value) == serial then
							kickPlayer(value, showingPlayer, reason)
						end
					end
				end
			end
		end
	end
end
addCommandHandler("pban", banAPlayer, false, false)

function unbanAccount(theBan)
	local ip = getBanIP(theBan)
	dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='0', banned_by=NULL WHERE ip='??'", ip), -1 )
end
addEventHandler("onUnban", getRootElement(), unbanAccount)



-- /UNBAN
function unbanPlayer(thePlayer, commandName, nickName)
	if (exports.sas_global:isPlayerSuperAdmin(thePlayer)) then
		if not (nickName) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Játékos teljes neve]", thePlayer, 255, 194, 14, true)
		else
			local bans = getBans()
			local found = false

			local result1, sor = dbPoll ( dbQuery( connection, "SELECT account FROM characters WHERE charactername=? LIMIT 1", tostring(nickName)), -1 )

		--	if (result1 and sor>0) then
				local row = result1[1]
				local accountid = tonumber(row["account"])

				local result, sor = dbPoll ( dbQuery( connection, "SELECT ip, banned FROM accounts WHERE id='??'", accountid), -1 )

				if (result) then
					if (sor>0) then
						local row = result[1]
						local ip = tostring(row["ip"])
						local banned = tonumber(row["banned"])

						if not found and banned == 1 then
							exports.sas_global:sendMessageToAdmins(tostring(nickName) .. " unbannolva lett " .. getPlayerName(thePlayer) .. " által.")
							dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='0', banned_by=NULL WHERE id='??'", accountid), -1 )
							found = true
						end

						if not (found) then
							outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem találtam BAN-t erre a névre: '" .. nickName .. "'", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem találtam BAN-t erre a névre: '" .. nickName .. "'", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem találtam BAN-t erre a névre: '" .. nickName .. "'", thePlayer, 255, 0, 0, true)
				end
			end
	--	end
	end
end
addCommandHandler("punban", unbanPlayer)

-- /UNBANIP
function unbanPlayerIP(thePlayer, commandName, ip)
	if (exports.sas_global:isPlayerSuperAdmin(thePlayer)) then
		if not (ip) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [IP]", thePlayer, 255, 194, 14, true)
		else
			local bans = getBans()
			local found = false

			for key, value in ipairs(bans) do
				if (ip==getBanIP(value)) then
					exports.sas_global:sendMessageToAdmins(tostring(ip) .. " unbannolta " .. getPlayerName(thePlayer) .. ".")
					removeBan(value, thePlayer)
					dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='0', banned_by=NULL WHERE WHERE ip='??'", ip), -1 )
					found = true
					break
				end
			end

			dbPoll ( dbQuery( connection, "SELECT COUNT(*) as number FROM accounts WHERE ip = '??' AND banned = 1", ip), -1 )
			if eredmeny and tonumber(eredmeny[1]["number"]) > 0 then
				dbPoll ( dbQuery( connection, "UPDATE accounts SET banned='0', banned_by=NULL WHERE WHERE ip='??'", ip), -1 )
			end

			if not (found) then
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem találtam BAN-t erre a névre: '" .. ip .. "'", thePlayer, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("unbanip", unbanPlayerIP, false, false)

local teleportLocations = {
	-- 			x					y					z			int dim	rot
	ls = { 		1520.0029296875, 	-1701.2425537109, 	13.546875, 	0, 	0,	275	},
	sf = { 		-1689.0689697266, 	-536.7919921875, 	18.854997, 	0, 	0,	252	},
	lv = { 		1691.6801757813, 	1449.1293945313, 	12.765375,	0, 	0,	268	},
	pc = { 		2253.66796875, 		-85.0478515625, 	28.086093,	0, 	0,	180	},
	bank = { 	593.32421875, 		-1245.466796875, 	18.083688,	0, 	0,	198	},
	cityhall = {1484.369140625, 	-1763.861328125, 	18.795755,	0, 	0,	180	},
	igs = {		1970.248046875, 	-1778.4609375, 		13.546875,	0, 	0,	90	},
	btr = {		2729.5419921875,	-1457.904296875, 	30.453125,	0, 	0,	250	},
	ash = {		1212.8564453125, 	-1327.5771484375, 	13.567770,	0, 	0,	90	},
	rakasz = {		138.798828125, -1916.4794921875, -0.55000001192093,	0, 	0,	90	}

}

function teleportToPresetPoint(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Hely]", thePlayer, 255, 194, 14, true)
		else
			local target = string.lower(tostring(target))

			if (teleportLocations[target] ~= nil) then
				if (isPedInVehicle(thePlayer)) then
					local veh = getPedOccupiedVehicle(thePlayer)
					setElementAngularVelocity(veh, 0, 0, 0)
					setElementPosition(veh, teleportLocations[target][1], teleportLocations[target][2], teleportLocations[target][3])
					setVehicleRotation(veh, 0, 0, teleportLocations[target][6])
					setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)

					setElementDimension(veh, teleportLocations[target][5])
					setElementInterior(veh, teleportLocations[target][4])

					setElementDimension(thePlayer, teleportLocations[target][5])
					setElementInterior(thePlayer, teleportLocations[target][4])
					setCameraInterior(thePlayer, teleportLocations[target][4])
				else
					setElementPosition(thePlayer, teleportLocations[target][1], teleportLocations[target][2], teleportLocations[target][3])
					setPedRotation(thePlayer, teleportLocations[target][6])
					setElementDimension(thePlayer, teleportLocations[target][5])
					setCameraInterior(thePlayer, teleportLocations[target][4])
					setElementInterior(thePlayer, teleportLocations[target][4])
				end
			else
				outputChatBox("Ismeretlen hely!", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("gotoplace", teleportToPresetPoint, false, false)
addCommandHandler("tele", teleportToPresetPoint, false, false)
addCommandHandler("teleport", teleportToPresetPoint, false, false)

function setPos(player, cmd, x,y,z)
	if x and y and z then
		setElementPosition(player,x,y,z)
	else
		outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. cmd .. " [x], [y], [z]", thePlayer, 255, 194, 14, true)
	end
end
addCommandHandler("setposition", setPos)

function makePlayerAdmin(thePlayer, commandName, who, rank)
	if (exports.sas_global:isPlayerHeadAdmin(thePlayer)) then
		if not (who) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID/NévRészlet] [Rang]", thePlayer, 255, 255, 255, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, who)

			if (targetPlayer) then
				local username = getPlayerName(thePlayer)
				local accountID = getElementData(targetPlayer, "gameaccountid")

				setElementData(targetPlayer, "adminlevel", tonumber(rank))

				dbExec(connection, "UPDATE accounts SET admin=? WHERE id=?", tonumber(rank), accountID)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFBeállítottad #32b3ef" .. targetPlayerName .. " #ffffffAdmin rangját erre: #32b3ef" .. rank .. ".", thePlayer, 255, 255, 255,true)

				if tonumber(rank) <= 0 then
					setElementData(targetPlayer, "adminduty", false)
					setPlayerName(targetPlayer, getElementData(targetPlayer, "charname"))
				end
				
				if (getElementData(thePlayer, "hiddenadmin") == 0) then
					local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF".. adminTitle .. " " .. username .. " #ffffffbeállította az Admin rangodat erre: #32b3ef" .. rank .. "#ffffff.", targetPlayer, 0, 206, 209, true)
					exports.sas_global:sendMessageToAdmins(tostring(adminTitle) .. " " .. username .. " beállította " .. targetPlayerName .. " Admin szintjét erre: " .. rank .. ".", 255, 0, 0, true)
				else
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFEgy rejtett Admin beállította az Admin rangodat erre: " .. rank .. ".", targetPlayer, 255, 194, 14,true)
				end
			end
		end
	end
end
addCommandHandler("makeadmin", makePlayerAdmin, false, false)


----------------------[JAIL]--------------------
function ojailPlayer(thePlayer, commandName, who, minutes, ...)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		local minutes = tonumber(minutes)
		if not (who) or not (minutes) or not (...) or (minutes<1) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Játékos Teljes neve] [Perc(>=1) 999=Végtelen] [Indok]", thePlayer, 255, 194, 14, true)
		else
			local reason = table.concat({...}, " ")
			local eredmeny, sorszam = dbPoll ( dbQuery( connection, "SELECT account, accounts.id as accid FROM characters INNER JOIN accounts ON characters.account=accounts.id WHERE charactername LIKE ?", who), -1 )

			if (sorszam == 1) then
				local playerName = getPlayerName(thePlayer)

				if (minutes>=999) then
					dbPoll ( dbQuery( connection, "UPDATE accounts SET adminjail='1', adminjail_time='?', adminjail_permanent='1', adminjail_by=?, adminjail_reason=? WHERE id='?'", minutes, playerName, reason, accountID), -1 )
					minutes = "Végtelen"
					setElementData(targetPlayer, "jailtimer", true, false)
				else
					dbPoll ( dbQuery( connection, "UPDATE accounts SET adminjail='1', adminjail_time='?', adminjail_permanent='0', adminjail_by=?, adminjail_reason=? WHERE id='?'", minutes, playerName, reason, accountID), -1 )
					local theTimer = setTimer(timerUnjailPlayer, 60000, minutes, targetPlayer)
				end

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFBebörtönözted " .. who .. "-t " .. minutes .. " percre.", thePlayer, 255, 0, 0, true)

				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				--dbPoll ( dbQuery( connection, "INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES (?, ?, ?, ?, ?, 0, ?, ?)", getPlayerName(targetPlayer), tostring(getElementData(targetPlayer, "gameaccountid") or 0), getPlayerName(thePlayer), tostring(getElementData(thePlayer, "gameaccountid") or 0), hiddenAdmin, ( minutes == 999 and 0 or minutes ), reason), -1 )

				if (not hiddenAdmin) then
					local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
					outputChatBox("#cb1919[AdminJail]: " .. adminTitle .. " " .. playerName .. " bebörtönözte " .. who .. "-t " .. minutes .. " percre. (Offline)", getRootElement(), 255, 0, 0, true)
					outputChatBox("#cb1919[AdminJail]: Indok: " .. reason, getRootElement(), 255, 0, 0, true)
				else
					outputChatBox("#cb1919[AdminJail]: Rejtett Admin bebörtönözte " .. who .. "-t " .. minutes .. " percre. (Offline)", getRootElement(), 255, 0, 0, true)
					outputChatBox("#cb1919[AdminJail]: Indok: " .. reason, getRootElement(), 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("offjail", ojailPlayer, false, false)

function jailPlayer(thePlayer, commandName, who, minutes, ...)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		local minutes = tonumber(minutes)
		if not (who) or not (minutes) or not (...) or (minutes<1) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID/NévRészlet] [Perc(>=1) 999=Végtelen] [Indok]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, who)
			local reason = table.concat({...}, " ")

			if (targetPlayer) then
				local playerName = getPlayerName(thePlayer)
				local jailTimer = getElementData(targetPlayer, "jailtimer")
				local accountID = getElementData(targetPlayer, "gameaccountid")

				if isTimer(jailTimer) then
					killTimer(jailTimer)
				end

				if (isPedInVehicle(targetPlayer)) then
					setElementData(targetPlayer, "realinvehicle", 0, false)
					removePedFromVehicle(targetPlayer)
				end

				if (minutes>=999) then
					dbPoll ( dbQuery( connection, "UPDATE accounts SET adminjail='1', adminjail_time='?', adminjail_permanent='1', adminjail_by=?, adminjail_reason=? WHERE id='?'", minutes, playerName, reason, accountID), -1 )
					minutes = "Végtelen"
					setElementData(targetPlayer, "jailtimer", true, false)
				else
					dbPoll ( dbQuery( connection, "UPDATE accounts SET adminjail='1', adminjail_time='?', adminjail_permanent='0', adminjail_by=?, adminjail_reason=? WHERE id='?'", minutes, playerName, reason, accountID), -1 )
					local theTimer = setTimer(timerUnjailPlayer, 60000, minutes, targetPlayer)
					setElementData(targetPlayer, "jailserved", 0, false)
					setElementData(targetPlayer, "jailtimer", theTimer, false)
				end
				setElementData(targetPlayer, "adminjailed", true)
				setElementData(targetPlayer, "jailreason", reason, false)
				setElementData(targetPlayer, "jailtime", minutes, false)
				setElementData(targetPlayer, "jailadmin", getPlayerName(thePlayer), false)

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFBebörtönözted " .. targetPlayerName .. "-t " .. minutes .. " percre.", thePlayer, 255, 0, 0, true)

				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				dbPoll ( dbQuery( connection, "INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES (?, ?, ?, ?, ?, 0, ?, ?)", getPlayerName(targetPlayer), tostring(getElementData(targetPlayer, "gameaccountid") or 0), getPlayerName(thePlayer), tostring(getElementData(thePlayer, "gameaccountid") or 0), hiddenAdmin, ( minutes == 999 and 0 or minutes ), reason), -1 )

				if (not hiddenAdmin) then
					local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
					outputChatBox("#cb1919[AdminJail]: " .. adminTitle .. " " .. playerName .. " bebörtönözte " .. targetPlayerName .. "-t " .. minutes .. " percre.", getRootElement(), 255, 0, 0, true)
					outputChatBox("#cb1919[AdminJail]: Indok: " .. reason, getRootElement(), 255, 0, 0, true)
				else
					outputChatBox("#cb1919[AdminJail]: Rejtett Admin bebörtönözte " .. targetPlayerName .. "-t " .. minutes .. " percre.", getRootElement(), 255, 0, 0, true)
					outputChatBox("#cb1919[AdminJail]: Indok: " .. reason, getRootElement(), 255, 0, 0, true)
				end
				setElementDimension(targetPlayer, 65400+getElementData(targetPlayer, "playerid"))
				setElementInterior(targetPlayer, 6)
				setCameraInterior(targetPlayer, 6)
				setElementPosition(targetPlayer, 263.821807, 77.848365, 1001.0390625)
				setPedRotation(targetPlayer, 267.438446)

				toggleControl(targetPlayer,'next_weapon',false)
				toggleControl(targetPlayer,'previous_weapon',false)
				toggleControl(targetPlayer,'fire',false)
				toggleControl(targetPlayer,'aim_weapon',false)
				setPedWeaponSlot(targetPlayer,0)
			end
		end
	end
end
addCommandHandler("jail", jailPlayer, false, false)

function timerUnjailPlayer(jailedPlayer)
	if(isElement(jailedPlayer)) then
		local timeServed = getElementData(jailedPlayer, "jailserved")
		local timeLeft = getElementData(jailedPlayer, "jailtime")
		local accountID = getElementData(jailedPlayer, "gameaccountid")
		if (timeServed) then
			setElementData(jailedPlayer, "jailserved", timeServed+1, false)
			local timeLeft = timeLeft - 1
			setElementData(jailedPlayer, "jailtime", timeLeft, false)

			if (timeLeft<=0) then
				dbPoll ( dbQuery( connection, "UPDATE accounts SET adminjail_time='0', adminjail='0' WHERE id='?'", accountID), -1 )
				setElementData(jailedPlayer, "jailtimer")
				setElementData(jailedPlayer, "adminjailed")
				setElementData(jailedPlayer, "jailreason")
				setElementData(jailedPlayer, "jailtime")
				setElementData(jailedPlayer, "jailadmin")
				setElementPosition(jailedPlayer, 1519.97265625, -1698.21875, 13.546875)
				setPedRotation(jailedPlayer, 272.18768310547)
				setElementDimension(jailedPlayer, 0)
				setElementInterior(jailedPlayer, 0)
				setCameraInterior(jailedPlayer, 0)
				toggleControl(jailedPlayer,'next_weapon',true)
				toggleControl(jailedPlayer,'previous_weapon',true)
				toggleControl(jailedPlayer,'fire',true)
				toggleControl(jailedPlayer,'aim_weapon',true)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFKiszabadítottak a börtönbõl!", jailedPlayer, 0, 255, 0, true)

				local gender = getElementData(jailedPlayer, "gender")
				local genderm = "his"
				if (gender == 1) then
					genderm = "her"
				end

				exports.sas_global:sendMessageToAdmins("AdmJail: " .. getPlayerName(jailedPlayer) .. " Admin börtön ideje lenullázva.")
			else
				dbPoll ( dbQuery( connection, "UPDATE accounts SET adminjail_time='?' WHERE id='?'", timeLeft, accountID), -1 )
			end
		end
	end
end

function unjailPlayer(thePlayer, commandName, who)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (who) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID/NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, who)

			if (targetPlayer) then
				local jailed = getElementData(targetPlayer, "jailtimer", nil)
				local username = getPlayerName(thePlayer)
				local accountID = getElementData(targetPlayer, "gameaccountid")

				if not (jailed) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFF".. targetPlayerName .. " nincs bebörtönözve.", thePlayer, 255, 0, 0, true)
				else
					dbPoll ( dbQuery( connection, "UPDATE accounts SET adminjail_time='0', adminjail='0' WHERE id='?'", accountID), -1 )

					if isTimer(jailed) then
						killTimer(jailed)
					end
					setElementData(targetPlayer, "jailtimer")
					setElementData(targetPlayer, "adminjailed")
					setElementData(targetPlayer, "jailreason")
					setElementData(targetPlayer, "jailtime")
					setElementData(targetPlayer, "jailadmin")
					setElementPosition(targetPlayer, 1519.97265625, -1698.21875, 13.546875)
					setPedRotation(targetPlayer, 272.18768310547)
					setElementDimension(targetPlayer, 0)
					setCameraInterior(targetPlayer, 0)
					setElementInterior(targetPlayer, 0)
					toggleControl(targetPlayer,'next_weapon',true)
					toggleControl(targetPlayer,'previous_weapon',true)
					toggleControl(targetPlayer,'fire',true)
					toggleControl(targetPlayer,'aim_weapon',true)
					outputChatBox(" #32b3ef" .. username .. " kivett a börtönbõl.", targetPlayer, 0, 255, 0, true)
					exports.sas_global:sendMessageToAdmins(targetPlayerName .. "-t kivette a börtöbõl: " .. username .. ".")
				end
			end
		end
	end
end
addCommandHandler("unjail", unjailPlayer, false, false)

function jailedPlayers(thePlayer, commandName)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then

		local players = getElementsByType("player")
		local count = 0
		for key, value in ipairs(players) do
			if getElementData(value, "adminjailed") then
				outputChatBox("#7cc576[SeeMTA]: #FFFFFF" .. getPlayerName(value) .. ", bebörtönözve " .. tostring(getElementData(value, "jailadmin")) .. " által, ült " .. tostring(getElementData(value, "jailserved")) .. " percet és " .. tostring(getElementData(value,"jailtime")) .. " perc van hátra", thePlayer, 0, 206, 209, true)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFIndok: " .. tostring(getElementData(value, "jailreason")), thePlayer, 0, 206, 209)
				count = count + 1
			elseif getElementData(value, "pd.jailtimer") then
				outputChatBox("[LETARTÓZTATVA] " .. getPlayerName(value) .. ", ült " .. tostring(getElementData(value, "pd.jailserved")) .. " percet és " .. tostring(getElementData(value, "pd.jailtime")) .. " perc van még hátra", thePlayer, 0, 102, 255, true)
				count = count + 1
			end
		end

		if count == 0 then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFSenki sincs bebörtönözve.", thePlayer, 0, 206, 209,true)
		end
	end
end

addCommandHandler("jailed", jailedPlayers, false, false)

----------------------------[GO TO PLAYER]---------------------------------------
function gotoPlayer(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerSeged(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0 , 0, true)
				else
					local x, y, z = getElementPosition(targetPlayer)
					local interior = getElementInterior(targetPlayer)
					local dimension = getElementDimension(targetPlayer)
					local r = getPedRotation(targetPlayer)

					-- Maths calculations to stop the player being stuck in the target
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

					setCameraInterior(thePlayer, interior)

					if (isPedInVehicle(thePlayer)) then
						local veh = getPedOccupiedVehicle(thePlayer)
						setElementAngularVelocity(veh, 0, 0, 0)
						setElementInterior(thePlayer, interior)
						setElementDimension(thePlayer, dimension)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)
						setElementPosition(veh, x, y, z + 1)
						warpPedIntoVehicle ( thePlayer, veh )
						setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
					else
						setElementPosition(thePlayer, x, y, z)
						setElementInterior(thePlayer, interior)
						setElementDimension(thePlayer, dimension)
					end
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFTeleportáltál hozzá: #32b3ef" .. targetPlayerName .. "#ffffff.", thePlayer,255,255,255,true)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin #32b3ef" .. username .. "#ffffff teleportált hozzád. ", targetPlayer,255,255,255,true)
				end
			end
		end
	end
end
addCommandHandler("goto", gotoPlayer, false, false)

function getPlayer(thePlayer, commandName, from, to)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if(not from or not to) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF: /" .. commandName .. " [ForrásJátékos] [CélJátékos]", thePlayer, 255, 194, 14)
		else
			local admin = getPlayerName(thePlayer)
			local fromplayer, targetPlayerName1 = exports.sas_global:findPlayerByPartialNick(thePlayer, from)
			local toplayer, targetPlayerName2 = exports.sas_global:findPlayerByPartialNick(thePlayer, to)

			if(fromplayer and toplayer) then
				local logged1 = getElementData(fromplayer, "loggedin")
				local logged2 = getElementData(toplayer, "loggedin")

				if(not logged1 or not logged2) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFValamelyik játékos nincs bejelentkezve.", thePlayer, 255, 0 , 0, true)
				else
					local x, y, z = getElementPosition(toplayer)
					local interior = getElementInterior(toplayer)
					local dimension = getElementDimension(toplayer)
					local r = getPedRotation(toplayer)

					-- Maths calculations to stop the target being stuck in the player
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

					if (isPedInVehicle(fromplayer)) then
						local veh = getPedOccupiedVehicle(fromplayer)
						setElementAngularVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)

					else
						setElementPosition(fromplayer, x, y, z)
						setElementInterior(fromplayer, interior)
						setElementDimension(fromplayer, dimension)
					end

					outputChatBox("#7cc576[SeeMTA]: #FFFFFF Teleportáltad " .. targetPlayerName1 .. "-t " .. targetPlayerName2 .. "-hoz.", thePlayer,0,0,0,true)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF Admin " .. admin .. " teleportált hozzá: " .. targetPlayerName2 .. ". ", fromplayer,0,0,0,true)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF Admin " .. admin .. " teleportálta " .. targetPlayerName1 .. "-t hozzád.", toplayer,0,0,0,true)
				end
			end
		end
	end
end
addCommandHandler("sendto", getPlayer, false, false)

function gotoxyz_func ( player, cmd, dim )
	if (exports.sas_global:isPlayerAdmin(player)) then
		setElementDimension ( player, dim )
	end
end
addCommandHandler( "setdim", gotoxyz_func, false, false )


function gotoPosition ( player, cmd, x,y,z )
		if (exports.sas_global:isPlayerAdmin(player)) then
			if x and y and z then
				setElementPosition(player, x, y, z)
			else
				outputChatBox("[Gotopos]: x, y, z")
			end
		end
end
addCommandHandler( "gotopos", gotoPosition, false, false )

----------------------------[GET PLAYER HERE]---------------------------------------
function getPlayer(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then

		if not (target) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0 , 0, true)
				else
					local x, y, z = getElementPosition(thePlayer)
					local interior = getElementInterior(thePlayer)
					local dimension = getElementDimension(thePlayer)
					local r = getPedRotation(thePlayer)
					setCameraInterior(targetPlayer, interior)

					-- Maths calculations to stop the target being stuck in the player
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

					if (isPedInVehicle(targetPlayer)) then
						local veh = getPedOccupiedVehicle(targetPlayer)
						setElementAngularVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)

					else
						setElementPosition(targetPlayer, x, y, z)
						setElementInterior(targetPlayer, interior)
						setElementDimension(targetPlayer, dimension)
					end
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFTeleportáltad #32b3ef" .. targetPlayerName .. "#ffffff -t magadhoz.", thePlayer,255,255,255,true)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin " .. username .. " magához teleportált. ", targetPlayer,255,255,255,true)
				end
			end
		end
	end
end
addCommandHandler("gethere", getPlayer, false, false)

function setInt(thePlayer, commandName, target, int)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet] [Összeg]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				setElementInterior(targetPlayer,int)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFF".. targetPlayerName .. " interiorja átírva: " .. int .. "", thePlayer,200,200,200,true)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin " .. username .. " átállította az interiorod: " .. int .. ".", targetPlayer,200,200,200,true)
			end
		end
	end
end
addCommandHandler("setint", setInt, false, false)

function giveMoney(thePlayer, commandName, target, money)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (target) or not tonumber(money) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet] [Összeg]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				setElementData(targetPlayer, "money", getElementData(targetPlayer, "money") + tonumber(money))

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdtál neki: #32b3ef" .. targetPlayerName .. " #7cc576" .. money .. " #FFFFFFdollárt.", thePlayer,200,200,200,true)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin " .. username .. " adott neked #7cc576" .. money .. " #FFFFFFdollárt.", targetPlayer,200,200,200,true)
			end
		end
	end
end
addCommandHandler("givemoney", giveMoney, false, false)

function setMoney(thePlayer, commandName, target, money)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (target) or not tonumber(money) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet] [Összeg]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				setElementData(targetPlayer, "money", tonumber(money))

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFBeállítottad neki: #32b3ef" .. targetPlayerName .. " #7cc576" .. money .. " #FFFFFFdollárra.", thePlayer,200,200,200,true)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin " .. username .. " beállította a pénzed #7cc576" .. money .. " #FFFFFFdollárra.", targetPlayer,200,200,200,true)
			end
		end
	end
end
addCommandHandler("setmoney", setMoney, false, false)

function givePP(thePlayer, commandName, target, pp)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (target) or not tonumber(pp) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet] [PP]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				setElementData(targetPlayer, "pp", getElementData(targetPlayer, "pp") + tonumber(pp))

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdtál neki: #32b3ef" .. targetPlayerName .. " #7cc576" .. pp .. " #ffffffPP-t.", thePlayer,200,200,200,true)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin " .. username .. " adott neked #7cc576" .. pp .. " #ffffffPP-t.", targetPlayer,200,200,200,true)
			end
		end
	end
end
addCommandHandler("givepp", givePP, false, false)

function setPP(thePlayer, commandName, target, pp)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not (target) or not tonumber(pp) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet] [PP]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				setElementData(targetPlayer, "pp", tonumber(pp))

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFBeállítottad neki: #32b3ef" .. targetPlayerName .. " #7cc576" .. pp .. " #ffffffPP-re.", thePlayer,200,200,200,true)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin " .. username .. " adott neked #7cc576" .. pp .. " #ffffffPP-re.", targetPlayer,200,200,200,true)
			end
		end
	end
end
addCommandHandler("setpp", setPP, false, false)

-----------------------------------[FREEZE]----------------------------------
function freezePlayer(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)
			if targetPlayer then
				local veh = getPedOccupiedVehicle( targetPlayer )
				if (veh) then
					setElementFrozen(veh, true)
					toggleAllControls(targetPlayer, false, true, false)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFFagyasztva lettél egy Admin által. Kövesd az általa adott instrukciókat!", targetPlayer,0,0,0,true)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFLefagyasztottad " ..targetPlayerName.. "-t.", thePlayer,0,0,0,true)
				else
					toggleAllControls(targetPlayer, false, true, false)
					setPedWeaponSlot(targetPlayer, 0)
					setElementData(targetPlayer, "freeze", 1)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFFagyasztva lettél egy Admin által. Kövesd az általa adott instrukciókat!", targetPlayer,0,0,0,true)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFLefagyasztottad " ..targetPlayerName.. "-t.", thePlayer,0,0,0,true)
				end
				local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
				local username = getPlayerName(thePlayer)
				exports.sas_global:sendMessageToAdmins("#32b3ef " .. tostring(adminTitle) .. " " .. username .. " #FFFFFFlefagyasztotta #32b3ef" .. targetPlayerName .. "#FFFFFF-t.")
			end
		end
	end
end
addCommandHandler("freeze", freezePlayer, false, false)

-----------------------------------[UNFREEZE]----------------------------------
function unfreezePlayer(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID/Névrészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)
			if targetPlayer then
				local veh = getPedOccupiedVehicle( targetPlayer )
				if (veh) then
					setElementFrozen(veh, false)
					--toggleAllControls(targetPlayer, true, true, true)
				end
				--else
					toggleAllControls(targetPlayer, true, true, true)
					setElementFrozen(targetPlayer, false)
					-- Disable weapon scrolling if restrained
					if getElementData(targetPlayer, "restrain") == 1 then
						setPedWeaponSlot(targetPlayer, 0)
						toggleControl(targetPlayer, "next_weapon", false)
						toggleControl(targetPlayer, "previous_weapon", false)
					end
					setElementData(targetPlayer, "freeze")
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFKi lettél fagyasztva egy Admin által.", targetPlayer,200,200,200,true)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFKifagyasztottad #32b3ef" ..targetPlayerName.. "#FFFFFF.", thePlayer,200,200,200,true)
			--	end
				local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
				local username = getPlayerName(thePlayer)
				exports.sas_global:sendMessageToAdmins(" #32b3ef" .. tostring(adminTitle) .. " " .. username .. " #FFFFFFkifagyasztotta #32b3ef" .. targetPlayerName .. "#FFFFFF-t.")
			end
		end
	end
end
addCommandHandler("unfreeze", unfreezePlayer, false, false)

------------- [gotoMark]
addEvent( "gotoMark", true )
addEventHandler( "gotoMark", getRootElement( ),
	function( x, y, z, interior, dimension, name )
		if type( x ) == "number" and type( y ) == "number" and type( z ) == "number" and type( interior ) == "number" and type( dimension ) == "number" then
			if getElementData ( client, "loggedin" ) == 1 and exports.sas_global:isPlayerAdmin(client) then
				fadeCamera ( client, false, 1,0,0,0 )

				setTimer(function(client)

					local vehicle = nil
					local seat = nil

					if(isPedInVehicle ( client )) then
						 vehicle =  getPedOccupiedVehicle ( client )
						seat = getPedOccupiedVehicleSeat ( client )
					end

					if(vehicle and (seat ~= 0)) then
						removePedFromVehicle (client )
						setElementData(client, "realinvehicle", 0, false)
						setElementPosition(client, x, y, z)
						setElementInterior(client, interior)
						setElementDimension(client, dimension)
					elseif(vehicle and seat == 0) then
						removePedFromVehicle (client )
						setElementData(client, "realinvehicle", 0, false)
						setElementPosition(vehicle, x, y, z)
						setElementInterior(vehicle, interior)
						setElementDimension(vehicle, dimension)
						warpPedIntoVehicle ( client, vehicle, 0)
					else
						setElementPosition(client, x, y, z)
						setElementInterior(client, interior)
						setElementDimension(client, dimension)
					end

					outputChatBox( "#7cc576[SeeMTA]: #FFFFFFTeleportálva lettél" .. ( name and " '" .. name .. "'" or "" ) .. ".", client, 0, 255, 0 ,true)
					setTimer(fadeCamera, 1000, 1, client, true, 1)
				end, 1000, 1, client)

			end
		end
	end
)

function changeAdminname(thePlayer, commandName, target, aName)
	if getElementData(thePlayer, "adminlevel") >= 8 then
		if not target or not aName then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [ID/Névrészlet] [Adminname]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)
			if targetPlayer then
				local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
				local username = getPlayerName(thePlayer)

				setElementData(targetPlayer, "adminnick", aName)
				if getElementData(targetPlayer, "adminduty") then
					setPlayerName(targetPlayer, tostring(aName))
				end

				dbExec(connection, "UPDATE accounts SET adminnick=? WHERE id=?", aName, getElementData(targetPlayer, "gameaccountid"))
				outputChatBox("#7cc576[SeeMTA]: #32b3ef"..adminTitle.." "..username.." #ffffffmegváltoztatta #32b3ef"..targetPlayerName.. " #ffffffadminnevét -> #32b3ef"..aName, getRootElement(), 255,255,255, true)
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem található ilyen névvel/IDvel játékos.",thePlayer, 255,255,255, true)
			end
		end
	end
end
addCommandHandler("changeadminname", changeAdminname)

function adminDuty(thePlayer, commandName)
	if exports.sas_global:isPlayerSeged(thePlayer) then
		local username = getElementData(thePlayer, "adminnick")

		if not getElementData(thePlayer, "adminduty") then
			setElementData(thePlayer, "adminduty", true)
			triggerClientEvent("sendMessageToAdmins", getRootElement(), "#7cc576[AdminDuty]: #32b3ef"..username.." #ffffffadminszolgálatba lépett.")
			exports.sas_hud:addNotification(getRootElement(), username.. " adminszolgálatba lépett.", "info")
			setPlayerName(thePlayer, getElementData(thePlayer, "adminnick"))
		else
			setElementData(thePlayer, "adminduty", false)
			triggerClientEvent("sendMessageToAdmins", getRootElement(), "#7cc576[AdminDuty]: #32b3ef"..username.." #ffffffkilépett az adminszolgálatból.")
			exports.sas_hud:addNotification(getRootElement(), username.. " kilépett az adminszolgálatból.", "info")
			setPlayerName(thePlayer, getElementData(thePlayer, "charname"))
		end
	end
end
addCommandHandler("adminduty", adminDuty, false, false)
addCommandHandler("aduty", adminDuty, false, false)
addCommandHandler("ad", adminDuty, false, false)

-- GET PLAYER ID
function getPlayerID(thePlayer, commandName, target)
	if not (target) then
		outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Névrészlet]", thePlayer, 255, 194, 14, true)
	else
		local username = getPlayerName(thePlayer)
		local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

		if targetPlayer then
			local logged = getElementData(targetPlayer, "loggedin")
			if (logged==1) then
				local id = getElementData(targetPlayer, "playerid")
				outputChatBox("#7cc576[SeeMTA]: #32b3ef" .. targetPlayerName .. " #FFFFFFID-je: #32b3ef" .. id .. "#FFFFFF.", thePlayer, 255, 194, 14, true)
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("getid", getPlayerID, false, false)
addCommandHandler("id", getPlayerID, false, false)

-- EJECT
function ejectPlayer(thePlayer, commandName, target)
	if not (target) then
		outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [NévRészlet]", thePlayer, 255, 255, 255, true)
	else
		if not (isPedInVehicle(thePlayer)) then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem vagy kocsiban.", thePlayer, 255, 0, 0, true)
		else
			local vehicle = getPedOccupiedVehicle(thePlayer)
			local seat = getPedOccupiedVehicleSeat(thePlayer)

			if (seat~=0) then
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFCsak vezetõ tud kidobni embereket a jármûbõl.", thePlayer, 255, 255, 255, true)
			else
				local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

				if not (targetPlayer) then
				elseif (targetPlayer==thePlayer) then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem dobhatod ki magadat.", thePlayer, 255, 255, 255, true)
				else
					local targetvehicle = getPedOccupiedVehicle(targetPlayer)

					if targetvehicle~=vehicle and not exports.sas_global:isPlayerAdmin(thePlayer) then
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFEz a játékos nincs a jármûben.", thePlayer, 255, 255, 255, true)
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFKidobtad " .. targetPlayerName .. "-t a jármûbõl.", thePlayer, 255, 255, 255, true)
						removePedFromVehicle(targetPlayer)
						setElementData(targetPlayer, "realinvehicle", 0, false)
						triggerEvent("removeTintName", targetPlayer)
					end
				end
			end
		end
	end
end
--addCommandHandler("eject", ejectPlayer, false, false)


-- recon fix for interior changing
function interiorChanged()
	for key, value in ipairs(getElementsByType("player")) do
		if isElement(value) then
			local cameraTarget = getCameraTarget(value)
			if (cameraTarget) then
				if (cameraTarget==source) then
					local interior = getElementInterior(source)
					local dimension = getElementDimension(source)
					setCameraInterior(value, interior)
					setElementInterior(value, interior)
					setElementDimension(value, dimension)
				end
			end
		end
	end
end
addEventHandler("onPlayerInteriorChange", getRootElement(), interiorChanged)

-- FREECAM
function toggleFreecam(thePlayer)
	if exports.sas_global:isPlayerAdmin(thePlayer) then
		local enabled = exports.sas_freecam:isPlayerFreecamEnabled (thePlayer)

		if (enabled) then
			setElementData(thePlayer, "reconx")
			setElementAlpha(thePlayer, 255)
			setElementFrozen(thePlayer, false)
			exports.sas_freecam:setPlayerFreecamDisabled (thePlayer)
		else
			removePedFromVehicle(thePlayer)
			setElementData(thePlayer, "reconx", 0)
			setElementAlpha(thePlayer, 0)
			setElementFrozen(thePlayer, true)
			exports.sas_freecam:setPlayerFreecamEnabled (thePlayer)
		end
	end
end
addCommandHandler("freecam", toggleFreecam)

-- DROP ME

function dropOffFreecam(thePlayer)
	if exports.sas_global:isPlayerAdmin(thePlayer) then
		local enabled = exports.sas_freecam:isPlayerFreecamEnabled (thePlayer)
		if (enabled) then
			local x, y, z = getElementPosition(thePlayer)
			setElementData(thePlayer, "reconx")
			setElementAlpha(thePlayer, 255)
			setElementFrozen(thePlayer, false)
			exports.sas_freecam:setPlayerFreecamDisabled (thePlayer)
			setElementPosition(thePlayer, x, y, z)
		else
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFCsak akkor mûködik ha a FREECAM be van kapcsolva.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("dropme", dropOffFreecam)

-- DISAPPEAR

function toggleInvisibility(thePlayer)
	if exports.sas_global:isPlayerAdmin(thePlayer) then
		local enabled = getElementData(thePlayer, "invisible")
		if (enabled == true) then
			setElementAlpha(thePlayer, 255)
			setElementData(thePlayer, "reconx", false)
			outputChatBox("Látható vagy.", thePlayer, 255, 0, 0)
			setElementData(thePlayer, "invisible", false)
		elseif (enabled == false or enabled == nil) then
			setElementAlpha(thePlayer, 0)
			setElementData(thePlayer, "reconx", true)
			outputChatBox("Láthatattlan vagy.", thePlayer, 0, 255, 0)
			setElementData(thePlayer, "invisible", true)
		else
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFElõbb kapcsold ki az Admin TV-t.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("disappear", toggleInvisibility)


-- TOGGLE NAMETAG

function toggleMyNametag(thePlayer)
	local visible = getElementData(thePlayer, "reconx")
	if exports.sas_global:isPlayerAdmin(thePlayer) then
		if (visible == true) then
			setPlayerNametagShowing(thePlayer, false)
			setElementData(thePlayer, "reconx", false)
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFA neved mostantól látható.", thePlayer, 255, 0, 0, true)
		elseif (visible == false or visible == nil) then
			setPlayerNametagShowing(thePlayer, false)
			setElementData(thePlayer, "reconx", true)
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFA neved elrejtve.", thePlayer, 0, 255, 0, true)
		else
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFElõbb kapcsold ki az Admin TV-t.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("togmytag", toggleMyNametag)

-- RESET CHARACTER
function resetCharacter(thePlayer, commandName, ...)
	if exports.sas_global:isPlayerHeadAdmin(thePlayer) then
		if not (...) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [Karakter pontos neve]", thePlayer, 255, 255, 255, true)
		else
			local character = table.concat({...}, "_")
			if getPlayerFromName(character) then
				kickPlayer(getPlayerFromName(character), "Karakter viszaállítás")
			end

			local result = dbPoll ( dbQuery( connection, "SELECT id, account FROM characters WHERE charactername='??' LIMIT 1", character), -1 )

			local charid = tonumber(result[1]["id"])
			local account = tonumber(result[1]["account"])

			if charid then
				-- delete all in-game vehicles
				for key, value in pairs( getElementsByType( "vehicle" ) ) do
					if isElement( value ) then
						if getElementData( value, "owner" ) == charid then
							destroyElement( value )
						end
					end
				end
				dbPoll ( dbQuery( connection, "DELETE FROM vehicles WHERE owner = '?'", charid), -1 )
				-- un-rent all interiors
				local old = getElementData( thePlayer, "dbid" )
				setElementData( thePlayer, "dbid", charid )
				local result, sorszam = dbPoll ( dbQuery( connection, "SELECT id FROM interiors WHERE owner = '?' AND type != 2", charid), -1 )
				if result and sorszam > 0 then
					for _, row in ipairs(result) do
						local id = tonumber(row["id"])
					end
				end
				setElementData( thePlayer, "dbid", old )

				-- get rid of all items, give him default items back
				dbPoll ( dbQuery( connection, "DELETE FROM itemek WHERE tipus = 1 AND tulaj = '?'", charid), -1 )

				-- delete wiretransfers
				dbPoll ( dbQuery( connection, "DELETE FROM wiretransfers WHERE `from` = '?' OR `to` = '?'", charid, charid), -1 )

				-- set spawn at unity, strip off money etc
				dbPoll ( dbQuery( connection, "UPDATE characters SET x=1742.1884765625, y=-1861.3564453125, z=13.577615737915, rotation=0, faction_id=-1, faction_rank=0, faction_leader=0, weapons='', ammo='', car_license=0, gun_license=0, hoursplayed=0, timeinserver=0, transport=1, lastarea='El Corona', money=250, bankmoney=500, interior_id=0, dimension_id=0, health=100, armor=0, radiochannel=100, fightstyle=0, pdjail=0, pdjail_time=0, restrainedobj=0, restrainedby=0, hunter=0, stevie=0, tyrese=0, rook=0, fish=0, truckingruns=0, truckingwage=0, blindfold=0, phoneoff=0 WHERE id = '?'", charid), -1 )

				outputChatBox("Lenulláztad " .. character .. " vagyonát.", thePlayer, 0, 255, 0)
				if (getElementData(thePlayer, "hiddenadmin")==0) then
					local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
					exports.sas_global:sendMessageToAdmins("" .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " visszaállította " .. character .. " karaktert.")
				end


			else
				outputChatBox("Nem találom: " .. character, thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("resetcharacter", resetCharacter)

--give player license
function givePlayerLicense(thePlayer, commandName, targetPlayerName, licenseType)
	if exports.sas_global:isPlayerAdmin(thePlayer) then
		if not targetPlayerName or not (licenseType and (licenseType == "1" or licenseType == "2")) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " #ffffff[NévRészlet] [Típus]", thePlayer, 255, 255, 255, true)
			outputChatBox("#ffffffTípus 1 = #32b3efSofõr", thePlayer, 255, 255, 255, true)
			outputChatBox("#ffffffTípus 2 = #32b3efFegyver", thePlayer, 255, 255, 255, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayerName)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("A játékos nincs bejelentkezve.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					local licenseTypeOutput = licenseType == "1" and "vezetői" or "fegyver"
					licenseType = licenseType == "1" and "car" or "gun"
					if getElementData(targetPlayer, "license."..licenseType) == 1 then
						outputChatBox(getPlayerName(thePlayer).."-nak már van "..licenseTypeOutput.." engedélye.", thePlayer, 255, 255, 255)
					else
						if (licenseType == "gun") then
							if exports.sas_global:isPlayerSuperAdmin(thePlayer) then
								setElementData(targetPlayer, "license."..licenseType, 1)
								dbPoll ( dbQuery( connection, "UPDATE characters SET "..licenseType.."_license='1' WHERE id = '?' LIMIT 1", getElementData(targetPlayer, "dbid")), -1 )
								outputChatBox("Játékos #32b3ef"..targetPlayerName.." kapott egy #32b3ef"..licenseTypeOutput.." engedélyt.", thePlayer, 255, 255, 255, true)
								outputChatBox("Admin #32b3ef"..getPlayerName(thePlayer).." #ffffffadott neked #32b3ef"..licenseTypeOutput.." #ffffffengedélyt.", targetPlayer, 255, 255, 255, true)
							else
								outputChatBox("Nem.", thePlayer, 255, 0, 0)
							end
						else
							setElementData(targetPlayer, "license."..licenseType, 1)
							dbPoll ( dbQuery( connection, "UPDATE characters SET "..licenseType.."_license='1' WHERE id = '?' LIMIT 1", getElementData(targetPlayer, "dbid")), -1 )
							outputChatBox("Játékos #32b3ef"..targetPlayerName.." kapott egy #32b3ef"..licenseTypeOutput.." engedélyt.", thePlayer, 255, 255, 255, true)
							outputChatBox("Admin #32b3ef"..getPlayerName(thePlayer).." adott neked #32b3ef"..licenseTypeOutput.." engedélyt.", targetPlayer, 255, 255, 255, true)
						end
					end
				end
			end
		end
	end
end
addCommandHandler("givelicense", givePlayerLicense)

function vehicleLimit(admin, command, player, limit)
	if exports.sas_global:isPlayerLeadAdmin(admin) then
		if (not player and not limit) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF /" .. command .. " [Játékos] [Limit]", admin, 255, 194, 14, true)
		else
			local tplayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(admin, player)
			if (tplayer) then
				local query, sor = dbPoll ( dbQuery( connection, "SELECT maxvehicles FROM characters WHERE id = '?' LIMIT 1", getElementData(tplayer, "dbid")), -1 )
				if (query and sor > 0) then
					local oldvl = query[1]["maxvehicles"]
					local newl = tonumber(limit)
					if (newl) then
						if (newl>0) then
							dbPoll ( dbQuery( connection, "UPDATE characters SET maxvehicles = '?' WHERE id = '?'", newl, getElementData(tplayer, "dbid")), -1 )

							setElementData(tplayer, "maxvehicles", newl)

							outputChatBox("#7cc576[SeeMTA]: #FFFFFFBeállítottad #32b3ef" .. targetPlayerName .. " #FFFFFFjármű limitjét erre: #32b3ef" .. newl .. "#FFFFFF.", admin, 255, 194, 14, true)
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFAdmin #32b3ef" .. getPlayerName(admin) .. " #FFFFFFbeállította a jármû limitedet erre: #32b3ef" .. newl .. "#FFFFFF.", tplayer, 255, 194, 14, true)

						else
							outputChatBox("#d9534f[SeeMTA]: #FFFFFFA limit nem lehet kevesebb mint 1!", admin, 255, 194, 14, true)
						end
					end
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFProbléma lépett fel a játékos keresése közben.", admin,0,0,0,true)
			end
		end
	end
end
addCommandHandler("setvehlimit", vehicleLimit)