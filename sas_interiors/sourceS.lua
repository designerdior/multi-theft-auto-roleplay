local connection = exports.sas_mysql:getConnection()

local loadedMarkers = {}

addCommandHandler("addinterior",
	function(playerSource, commandName, intid, inttype, cost, ...)
		if getElementData(playerSource, "adminlevel") >= 8 then
			if intid and inttype and cost and (...) then
				name = table.concat({...}, " ")
				x,y,z = getElementPosition(playerSource)
				intbel = interiorok[tonumber(intid)]
				if intbel then
					local interiorid = intbel[1]
					local ix = intbel[2]
					local iy = intbel[3]
					local iz = intbel[4]
					local marker_int = getElementInterior(playerSource)
					local marker_dim = getElementDimension(playerSource)
					
					dbExec(connection, "INSERT INTO interiors SET x = ?, y = ?, z = ?, interiorx = ?, interiory = ?, interiorz = ?, name = ?, type = ?, cost = ?, interior = ?, interiorwithin = ?, dimensionwithin = ?, owner = ?",x, y, z, ix, iy, iz, name, inttype, cost, interiorid, marker_int, marker_dim, 0)

					dbQuery(function(qh)
						local result, rows = dbPoll(qh, 0)
						if rows > 0 then
							loadOneInterior(result[1])
							outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Interior sikeresen létrehozva, ID: #32b3ef"..result[1]["id"], playerSource,124, 197, 118,true)
						end
					end, connection, "SELECT * FROM interiors WHERE id=LAST_INSERT_ID()")
				end
			else
				outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff /" .. commandName .. " [InteriorBelsőID] [tipus] [ár] [név]", playerSource,124, 197, 118,true)
				outputChatBox("#7cc576[Típusok]:#ffffff [0 - Ház] [1 - Biznisz] [2 - Önkormányzati] [3 - Bérház] [4 - Garázs]", playerSource,124, 197, 118,true)
			end
		end
	end
)

addCommandHandler("delinterior", function (playerSource, cmd, id)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if not id then outputChatBox("#7cc576[SeeMTA - Interior]#ffffff /".. cmd .." [ID]",playerSource, 124, 197, 118, true) return end
		local id = tonumber(id)
		if loadedMarkers[id] then
			for k, v in pairs(loadedMarkers[id]) do
				destroyElement(v)
				v = nil
			end
			dbExec(connection,"DELETE FROM interiors WHERE id=?",id)
			outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen törölted az interiort! #32b3ef("..id..")",playerSource,124, 197, 118,true)
		else
			outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Nincs ilyen interior!",playerSource,124, 197, 118,true)
		end
	end
end)

addEventHandler("onResourceStart",resourceRoot,function()
	dbQuery(function(qh)
		local result, rows = dbPoll(qh, 0)
		if rows > 0 then
			for k, v in ipairs(result) do
				loadOneInterior(v)
			end
		end
	end, connection, "SELECT * FROM interiors")
end)

function loadOneInterior(row)
	loadedMarkers[row["id"]] = {}
	if row["owner"] <= 0 and row["type"] == 0 then
		loadedMarkers[row["id"]][1] = createMarker( row["x"], row["y"], row["z"]-1, "cylinder", 0.7, 124, 197, 118, 100)
		loadedMarkers[row["id"]][2] = createMarker( row["interiorx"], row["interiory"], row["interiorz"]-1, "cylinder", 0.7, 124, 197, 118, 100)
	elseif row["type"] == 1 then
		loadedMarkers[row["id"]][1] = createMarker( row["x"], row["y"], row["z"]-1, "cylinder", 0.7, 221, 118, 0, 100)
		loadedMarkers[row["id"]][2] = createMarker( row["interiorx"], row["interiory"], row["interiorz"]-1, "cylinder", 0.7, 221, 118, 0, 100)
	elseif row["type"] == 2 then
		loadedMarkers[row["id"]][1] = createMarker( row["x"], row["y"], row["z"]-1, "cylinder", 0.7, 221, 118, 0, 100)
		loadedMarkers[row["id"]][2] = createMarker( row["interiorx"], row["interiory"], row["interiorz"]-1, "cylinder", 0.7, 221, 118, 0, 100)
	elseif row["type"] == 4 then
		loadedMarkers[row["id"]][1] = createMarker( row["x"], row["y"], row["z"]-1, "cylinder", 0.7, 66, 150, 245, 100)
		loadedMarkers[row["id"]][2] = createMarker( row["interiorx"], row["interiory"], row["interiorz"]-1, "cylinder", 0.7, 66, 150, 245, 100)
	else
		loadedMarkers[row["id"]][1] = createMarker( row["x"], row["y"], row["z"]-1, "cylinder", 0.7, 66, 150, 245, 100)
		loadedMarkers[row["id"]][2] = createMarker( row["interiorx"], row["interiory"], row["interiorz"]-1, "cylinder", 0.7, 66, 150, 245, 100)
	end
	setElementData(loadedMarkers[row["id"]][1],"isIntMarker",true)
	setElementData(loadedMarkers[row["id"]][2],"isIntOutMarker",true)
	setElementData(loadedMarkers[row["id"]][1],"other",loadedMarkers[row["id"]][2])
	setElementData(loadedMarkers[row["id"]][2],"other",loadedMarkers[row["id"]][1])
	setElementData(loadedMarkers[row["id"]][1],"dbid",row["id"])
	setElementData(loadedMarkers[row["id"]][2],"dbid",row["id"])
	setElementData(loadedMarkers[row["id"]][1],"inttype",row["type"])
	setElementData(loadedMarkers[row["id"]][2],"inttype",row["type"])
	setElementData(loadedMarkers[row["id"]][1],"owner",row["owner"])
	setElementData(loadedMarkers[row["id"]][2],"owner",row["owner"])

	setElementData(loadedMarkers[row["id"]][1],"x",row["x"])
	setElementData(loadedMarkers[row["id"]][2],"x",row["interiorx"])
	setElementData(loadedMarkers[row["id"]][1],"y",row["y"])
	setElementData(loadedMarkers[row["id"]][2],"y",row["interiory"])
	setElementData(loadedMarkers[row["id"]][1],"z",row["z"])
	setElementData(loadedMarkers[row["id"]][2],"z",row["interiorz"])

	setElementData(loadedMarkers[row["id"]][1], "angle", row["angle"])
	setElementData(loadedMarkers[row["id"]][1], "locked", row["locked"])
	setElementData(loadedMarkers[row["id"]][1], "cost", row["cost"])
	setElementData(loadedMarkers[row["id"]][1], "name", row["name"])
	setElementData(loadedMarkers[row["id"]][1], "fee", row["fee"])
	setElementDimension(loadedMarkers[row["id"]][1], row["dimensionwithin"])
	setElementInterior(loadedMarkers[row["id"]][1], row["interiorwithin"])

	setElementData(loadedMarkers[row["id"]][2], "angle", row["angleexit"])
	setElementData(loadedMarkers[row["id"]][2], "locked", row["locked"])
	setElementData(loadedMarkers[row["id"]][2], "cost", row["cost"])
	setElementData(loadedMarkers[row["id"]][2], "name", row["name"])
	setElementData(loadedMarkers[row["id"]][2], "fee", row["fee"])
	setElementInterior(loadedMarkers[row["id"]][2], row["interior"])
	setElementDimension(loadedMarkers[row["id"]][2], row["id"])
end

addEvent("lockIntToClient",true)
addEventHandler("lockIntToClient",getRootElement(),function(id,lock)
	dbExec(connection, "UPDATE interiors SET locked = ? WHERE id = ?",lock,id)
end)

function updateInteriorOwner(intID,intCost)
	if exports.sas_items:giveItem(client, 12, intID, 1,0) then
		local owner = getElementData(client, "dbid")
		dbExec(connection, "UPDATE interiors SET owner=? WHERE id = ?", owner, intID)
		for k, v in pairs(loadedMarkers[intID]) do
			setElementData(v, "owner", owner)
			setMarkerColor(v, 66, 150, 245, 100)
		end
		setElementData(client,"money",getElementData(client,"money")-intCost)
	else
		return false
	end
end
addEvent("updateInteriorOwner", true)
addEventHandler("updateInteriorOwner", getRootElement(), updateInteriorOwner)

addCommandHandler("setinteriorname",function(playerSource,cmd,id,...)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if id and (...) then
			id = tonumber(id)
			reName = table.concat({...}, " ")
			for k,v in ipairs(getElementsByType("marker")) do
				if getElementData(v,"dbid") == id then
					outputChatBox("#7cc576[SeeMTA]:#ffffff Sikeresen megváltoztattad az interior #32b3ef("..getElementData(v,"name")..")#ffffff nevét #32b3ef"..reName.."#ffffff névre.",playerSource,124, 197, 118,true)
					setElementData(v,"name",reName)
					dbExec(connection, "UPDATE interiors SET name = ? WHERE id = ?",reName,id)
				end
			end
		else
			outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff /"..cmd.." [interiorID] [Név]",playerSource,124, 197, 118,true)
		end
	end
end)

addCommandHandler("setinteriorcost",function(playerSource,cmd,markerID,newCost)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if markerID and newCost then
			markerID = tonumber(markerID)
			newCost = tonumber(newCost)
			for k,v in ipairs(getElementsByType("marker")) do
				if getElementData(v,"dbid") == markerID then
					setElementData(v,"cost",newCost)
					dbExec(connection, "UPDATE interiors SET cost = ? WHERE id = ?",newCost,markerID)
				end
			end
			outputChatBox("#7cc576[SeeMTA]:#ffffff Sikeresen megváltoztattad az interior-nak az alapárát #32b3ef"..newCost.."#ffffff dollárra.",playerSource,124, 197, 118,true)
		else
			outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff /"..cmd.." [interiorID] [Összeg]",playerSource,124, 197, 118,true)
		end
	end
end)

addCommandHandler("getinteriorcost",function(playerSource)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if getElementData(playerSource, "isInIntMarker") then
			local theIntElement = getElementData(playerSource,"int:Marker")
			if getElementData(theIntElement,"isIntMarker") then
				local defaultCost = getElementData(theIntElement,"cost")
				outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Ennek az interior-nak az alapára #32b3ef"..defaultCost.."#ffffff $.",playerSource,124, 197, 118,true)
			end
		else
			outputChatBox("#d9534f[SeeMTA - Interior]:#ffffff Nem állsz interior marker-ben.",playerSource,124, 197, 118,true)
		end
	end
end)

addCommandHandler("sellinterior",function(playerSource)
	if getElementData(playerSource, "isInIntMarker") then
		local theMarkElement = getElementData(playerSource,"int:Marker")
		local theMarkOwner = getElementData(theMarkElement,"owner")
		if getElementData(theMarkElement,"isIntMarker") then
			if tonumber(getElementData(playerSource,"dbid")) == tonumber(theMarkOwner) then
				local theMarkCost = getElementData(theMarkElement,"cost")
				local theMarkID = getElementData(theMarkElement,"dbid")
				setElementData(playerSource,"money",getElementData(playerSource,"money")-(theMarkCost/2))
				outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen eladtad az ingatlanodat #32b3ef"..(theMarkCost/2).."#ffffff dollárért.",playerSource,124, 197, 118,true)
				dbExec(connection, "UPDATE interiors SET owner = ? WHERE id = ?", 0, theMarkID)
				for k, v in pairs(loadedMarkers[theMarkID]) do
					setElementData(v, "owner", 0)
					setMarkerColor(v, 124, 197, 118, 100)
				end
				setElementData(playerSource,"isInIntMarker",false)
				setElementData(playerSource,"int:Marker",nil)
			else
				outputChatBox("#d9534f[SeeMTA]:#ffffff Ennek az interior-nak nem te vagy a tulajdonosa.",playerSource,124, 197, 118,true)
			end
		end
	else
		outputChatBox("#d9534f[SeeMTA]:#ffffff Nem állsz interior marker-ben.",playerSource,124, 197, 118,true)
	end
end)

addCommandHandler("asell",function(playerSource)
	if getElementData(playerSource, "adminlevel") >= 10 then
		if getElementData(playerSource, "isInIntMarker") then
			local theMarkElement = getElementData(playerSource,"int:Marker")
			local theMarkOwner = getElementData(theMarkElement,"owner")
			if getElementData(theMarkElement,"isIntMarker") then
				local theMarkCost = getElementData(theMarkElement,"cost")
				local theMarkID = getElementData(theMarkElement,"dbid")
				outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen eladtad az ingatlanodat #32b3ef"..(theMarkCost/2).."#ffffff dollárért.",playerSource,124, 197, 118,true)
				dbExec(connection, "UPDATE interiors SET owner = ? WHERE id = ?", 0, theMarkID)
				for k, v in pairs(loadedMarkers[theMarkID]) do
					setElementData(v, "owner", 0)
					setMarkerColor(v, 124, 197, 118, 100)
				end
				setElementData(playerSource,"isInIntMarker",false)
				setElementData(playerSource,"int:Marker",nil)
			end
		else
			outputChatBox("#d9534f[SeeMTA]:#ffffff Nem állsz interior marker-ben.",playerSource,124, 197, 118,true)
		end
	end
end)

local selltable = {}

addCommandHandler("adásvételi",
function(playerSource,cmd,player,price)
	if getElementData(playerSource,"loggedin") then
		if player and price then
			if getElementData(playerSource, "isInIntMarker") then
				local targetPlayer,targetPlayerName = exports["sas_global"]:findPlayerByPartialNick(playerSource, player, nil, 1)
				if targetPlayer then
					if playerSource ~= targetPlayer then
						local theMarkElement = getElementData(playerSource,"int:Marker")
						if getElementData(theMarkElement,"isIntMarker") then
							local playerID = tonumber(getElementData(playerSource,"dbid") or 0)
							local intID = tonumber(getElementData(theMarkElement,"dbid") or 0)
							local intOwnerID = tonumber(getElementData(theMarkElement,"owner"))
							local intName = string.gsub(getElementData(theMarkElement,"name"), "_", " ")
							local money = tonumber(getElementData(playerSource,"money") or 0)

							if playerID == intOwnerID then
								local playerX,playerY,playerZ = getElementPosition(playerSource)
								local targetX,targetY,targetZ = getElementPosition(targetPlayer)
								if getDistanceBetweenPoints3D(playerX,playerY,playerZ,targetX,targetY,targetZ) <= 3 then
									if (tonumber(getElementData(targetPlayer,"money") or 0) >= tonumber(price)) then
										if not selltable[targetPlayer] then
											selltable[targetPlayer] = {}
										end
										selltable[targetPlayer][(#selltable[targetPlayer]) + 1] = {intID, price, true, playerSource, theMarkElement}
										outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Adásvételi ajánlatot küldött neked "..string.gsub(getPlayerName(playerSource), "_", " ").." #7cc576" .. price .. "#ffffff dollárért elad neked egy ".. intName .. " nevű ingatlant. Elfogadáshoz /elfogad " .. #selltable[targetPlayer] .. " elutasításhoz /elutasít " .. #selltable[targetPlayer], targetPlayer,124, 197, 118,true)
										outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen felnyújtottál egy adásvételi szerződést #7cc576"..string.gsub(getPlayerName(targetPlayer), "_", " ").."#ffffff -nak/nek.",playerSource,124, 197, 118,true)
									else
										outputChatBox("#d9534f[SeeMTA]:#ffffff A kiválasztott játékosnak nincs elég pénze. #7cc576("..price.." $.)", playerSource,124, 197, 118,true)
									end
								else
									outputChatBox("#d9534f[SeeMTA]:#ffffff A kiválasztott játékos #7cc576"..string.gsub(getPlayerName(targetPlayer), "_", " ").."#ffffff nincs a közeledben.",playerSource,124, 197, 118,true)
								end
							else
								outputChatBox("#d9534f[SeeMTA]:#ffffff Ennek az ingatlannak nem te vagy a tulaja.",playerSource,124, 197, 118,true)
							end
						end
					else
						outputChatBox("#d9534f[SeeMTA]:#ffffff Saját magadnak nem adhatod el.",playerSource,124, 197, 118,true)
					end
				end
			else
				outputChatBox("#d9534f[SeeMTA]:#ffffff Nem állsz interior marker-ben.",playerSource,124, 197, 118,true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]:#ffffff /" ..cmd .. " [id] [ár]" ,playerSource,124, 197, 118,true)
		end
	end
end)

addCommandHandler("elfogad",
	function(playerSource, cmd, number)
		if number then
			number = tonumber(number)
			if selltable[playerSource][number][3] then
				selltable[playerSource][number][3] = false
				outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen elfogadtad az adásvételi szerződést.", playerSource,124, 197, 118,true)
				outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Másik fél #32b3ef"..string.gsub(getPlayerName(playerSource), "_", " ").."#ffffff elfogadta az adásvételi szerződést.", selltable[playerSource][number][4],124, 197, 118,true)
				setElementData(playerSource, "char:money", getElementData(playerSource, "char:money") - selltable[playerSource][number][2])
				setElementData(selltable[playerSource][number][4], "money", getElementData(selltable[playerSource][number][4], "money") + selltable[playerSource][number][2])
				setElementData(selltable[playerSource][number][5], "owner", getElementData(playerSource, "dbid"))
				dbExec(connection, "UPDATE interiors SET owner = ? WHERE id = ?", getElementData(playerSource, "dbid"), selltable[playerSource][number][1])
				for k, v in ipairs(loadedMarkers[selltable[playerSource][number][1]]) do
					setElementData(v, "owner", getElementData(playerSource, "dbid"))
				end
			else
				outputChatBox("#d9534f[SeeMTA]:#ffffff Ezzel egy id-vel nem rendelkezik adásvételi szerződés. #7cc576("..number..")", playerSource,124, 197, 118,true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]:#ffffff /"..cmd.." [ID]", playerSource,124, 197, 118,true)
		end
	end
)

addCommandHandler("elutasít",
	function(playerSource, cmd, number)
		if getElementData(playerSource,"loggedin") then
			if number then
				number = tonumber(number)
				if selltable[playerSource][number][3] then
					selltable[playerSource][number][3] = false
					outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen elutasítottad az adásvételi szerződést.", playerSource,124, 197, 118,true)
					outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Másik a fél #32b3ef"..string.gsub(getPlayerName(playerSource), "_", " ").."#ffffff elutasította az adásvételi szerződést.", selltable[playerSource][number][4],124, 197, 118,true)
				else
					outputChatBox("#d9534f[SeeMTA]:#ffffff Ezzel egy id-vel nem rendelkezik adásvételi szerződés. ("..number..")", playerSource,124, 197, 118,true)
				end
			else
				outputChatBox("#7cc576[SeeMTA]:#ffffff /"..cmd.." [ID]", playerSource,124, 197, 118,true)
			end
		end
	end
)

addCommandHandler("gotohouse",function(playerSource,cmd,number)
	if getElementData(playerSource,"adminlevel") >= 2 then
		number = tonumber(number)
		if number then
			for k,v in ipairs(getElementsByType("marker")) do
				if getElementData(v,"isIntMarker") then
					if getElementData(v,"dbid") == number then
						local markX,markY,markZ = getElementPosition(v)
						local markInt = getElementInterior(v)
						local markDim = getElementDimension(v)
						setElementPosition(playerSource,markX,markY,markZ+1)
						setElementInterior(playerSource,markInt)
						setElementDimension(playerSource,markDim)
						outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen elteleportáltál az interior-hoz. #32b3ef("..number..")", playerSource,124, 197, 118,true)
					end
				end
			end
		else
			outputChatBox("#7cc576[SeeMTA]:#ffffff /"..cmd.." [interiorID]", playerSource,124, 197, 118,true)
		end
	end
end)

addCommandHandler("setinteriorid",function(playerSource,cmd,reID)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if reID then
			reID = tonumber(reID)
			if getElementData(playerSource, "isInIntMarker") then
				local theInteriorElement = getElementData(playerSource,"int:Marker")
				if getElementData(theInteriorElement,"isIntOutMarker") then
					intOut = interiorok[tonumber(reID)]
					if intOut then
						local interiorid = intOut[1]
						local ix = intOut[2]
						local iy = intOut[3]
						local iz = intOut[4]
						setElementPosition(playerSource,ix,iy,iz)
						setElementInterior(playerSource,interiorid)
						setElementPosition(theInteriorElement,ix,iy,iz-1)
						setElementInterior(theInteriorElement,interiorid)
						setElementData(theInteriorElement,"x",ix)
						setElementData(theInteriorElement,"y",iy)
						setElementData(theInteriorElement,"z",iz)
						dbExec(connection, "UPDATE interiors SET interiorx = ?, interiory = ?, interiorz = ?, interior = ? WHERE id = ?",ix,iy,iz,interiorid,getElementData(theInteriorElement,"dbid"))
						outputChatBox("#7cc576[SeeMTA]:#ffffff Interior ID megváltoztatva.",playerSource,124, 197, 118,true)
					end
				end
			else
				outputChatBox("#d9534f[SeeMTA]:#ffffff Nem állsz interior marker-ben.",playerSource,124, 197, 118,true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]:#ffffff /"..cmd.." [interiorBelsőID]",playerSource,124, 197, 118,true)
		end
	end
end)

addCommandHandler("setinteriorexit",function(playerSource,cmd,number)
	if getElementData(playerSource,"adminlevel") >= 8 then
		number = tonumber(number)
		if number then
			for k,v in ipairs(getElementsByType("marker")) do
				if getElementData(v,"isIntOutMarker") then
					if getElementData(v,"dbid") == number then
						local newX,newY,newZ = getElementPosition(playerSource)
						local newInt = getElementInterior(playerSource)
						setElementPosition(v,newX,newY,newZ-1)
						setElementInterior(v,newInt)
						setElementData(v,"x",newX)
						setElementData(v,"y",newY)
						setElementData(v,"z",newZ)
						dbExec(connection, "UPDATE interiors SET interiorx = ?, interiory = ?, interiorz = ?, interior = ? WHERE id = ?",newX,newY,newZ,newInt,getElementData(v,"dbid"))
						outputChatBox("#7cc576[SeeMTA - Interior]:#ffffff Sikeresen áthelyezted az interior belépő marker-ját. #32b3ef("..number..")", playerSource,124, 197, 118,true)
					end
				end
			end
		else
			outputChatBox("#7cc576[SeeMTA]:#ffffff /"..cmd.." [interiorID]", playerSource,124, 197, 118,true)
		end
	end
end)
