local factor = 1.5

function relateVelocity(speed)
	return factor * speed
end

function getVehicleVelocity(vehicle)
	speedx, speedy, speedz = getElementVelocity (vehicle)
	return relateVelocity((speedx^2 + speedy^2 + speedz^2)^(0.5)*100)
end

function interior ( commandName, interior )
  --Let's see if they gave a interior ID
  if ( interior ) then
    --They did, so let's assign them to that interior and teleport them there (all in 1 function call!)
    setElementInterior ( getLocalPlayer(), interior)
  else
    --They didn't give one, so set them to the interior they wanted, but don't teleport them.
    setElementInterior ( getLocalPlayer(), 0 )
  end
end
--addCommandHandler ( "interior", interior )

function dym ( commandName, dim )
  --Let's see if they gave a interior ID
  if ( dim ) then
    --They did, so let's assign them to that interior and teleport them there (all in 1 function call!)
    setElementDimension ( getLocalPlayer(), dim)
  else
    --They didn't give one, so set them to the interior they wanted, but don't teleport them.
    setElementDimension ( getLocalPlayer(), 0 )
  end
end
--addCommandHandler ( "dim", dym )

function findPlayerByPartialNick(thePlayer, nick, msg, tipus)
  if not tipus then tipus = 1 end

  if nick == "*" then
    return thePlayer, getPlayerName(thePlayer):gsub("_", " ")
  end

  local byID = false
  if not nick and not isElement(thePlayer) and type( thePlayer ) == "string" then
    outputDebugString( "Hibás paraméterek lettek megadva." )
    return
  end
  
  if tonumber(nick) ~= nil then
    byID = true
  else
    byID = false
  end
  
  local tempTable = {}
  if not byID then
    nick = string.gsub(nick, " ", "_")
    nick = string.lower(nick)
    for key, value in ipairs(getElementsByType("player")) do
      local playerName = string.lower(getPlayerName(value))
      local playerName2 = getPlayerName(value)
      if string.find(playerName, tostring(nick)) then
        local stringStart, stringEnd = string.find(playerName, tostring(nick))
        if tonumber(stringStart) > 0 and tonumber(stringEnd) > 0 then
          tempTable[#tempTable + 1] = {value, playerName2}
        end
      end
    end
  else
    nick = tonumber(nick) or 0
    for key, value in ipairs(getElementsByType("player")) do
      local playerID = tonumber(getElementData(value, "playerid")) or 0
      local playerName2 = getPlayerName(value)
      if playerID == nick then
        tempTable[#tempTable + 1] = {value, playerName2}
      end
    end
  end
  
  if #tempTable == 1 then
    return tempTable[#tempTable][1], tempTable[#tempTable][2]:gsub("_", " ")
  elseif #tempTable == 0 then
    return false
  else
    if tipus == 1 then
      for k,v in ipairs(tempTable) do
        local vid = tonumber(getElementData(v[1], "playerid")) or 0
        outputChatBox(v[2] .. " - [" .. vid .. "]", thePlayer, 255, 0, 0)
      end
    else
      outputChatBox("[SeeMTA] #ffffffTöbb találat.", 124, 197, 118, true)
      for k,v in ipairs(tempTable) do
        local vid = tonumber(getElementData(v[1], "playerid")) or 0
        outputChatBox(v[2] .. " - [" .. vid .. "]", 255, 255, 255, true)
      end
    end
    return false
  end
  return false
end