local panelWidth = respc(512)
local panelHeight = respc(640)
local panelPosX = (screenW - panelWidth) / 2
local panelPosY = (screenH - panelHeight) / 2
local panelTitleHeight = respc(32)

local contentPosY = panelPosY + (panelTitleHeight + respc(2))
local contentHeight = panelHeight - (panelTitleHeight + respc(2))
local rowWidth = panelWidth
local rowHeight = respc(contentHeight / 17)

local onlinePlayers = {}
local panelPage = 0

local logoAnimStart = false
local logoAnimEnd = false
local fadeStart = false
local fadeEnd = false

local fadeAmount = 0

local logoSize = respc(128)
local logoPosX = (screenW - logoSize) / 2
local logoPosY = panelPosY - logoSize
local logoOffsetX = respc(27)
local logoOffsetY = respc(13)


addEventHandler("onClientKey", getRootElement(),
	function (key, pressDown)
		if not getElementData(localPlayer, "loggedin") then return end
		if logoAnimStart or logoAnimEnd then
			if key == "mouse_wheel_up" and panelPage > 0 then
				panelPage = panelPage - 1
			end

			if key == "mouse_wheel_down" and panelPage < #onlinePlayers - 17 then
				panelPage = panelPage + 1
			end
		end

		if key == "tab" and not pressDown then
			logoAnimStart = false
			fadeStart = false
			logoAnimEnd = getTickCount()
			fadeEnd = logoAnimEnd + 400
			logoOffsetX = 0
			logoOffsetY = 0
			fadeAmount = 1
		end

		if key == "tab" and pressDown then
			onlinePlayers = {}
			logoAnimStart = getTickCount() + 400
			fadeStart = logoAnimStart - 400
			logoAnimEnd = false
			fadeEnd = false
			logoOffsetX = respc(27)
			logoOffsetY = respc(13)

			local localPlayerNameColor = "#FFFFFF"
			if getElementData(localPlayer, "adminduty") then
				local playerAdminLevel = getElementData(localPlayer, "adminlevel") or 0

				if playerAdminLevel ~= 0 then
					if playerAdminLevel == 8 or playerAdminLevel == 11 then
						localPlayerNameColor = "#32b3ef"
					elseif playerAdminLevel == 9 then
						localPlayerNameColor = "#d75959"
					elseif playerAdminLevel == 7 then
						localPlayerNameColor = "#7a2978"
					elseif playerAdminLevel == 6 then
						localPlayerNameColor = "#dfb551"
					else
						localPlayerNameColor = "#7cc576"
					end
				end
			end

			onlinePlayers[1] = {
				localPlayer,
				localPlayerNameColor .. string.gsub(getPlayerName(localPlayer), "_", " "),
				getElementData(localPlayer, "playerid"),
			}

			local prePlayersTable = {}
			local players = getElementsByType("player")
			local lastPlayer = localPlayer

			for i = 1, #players do
				if players[i] ~= localPlayer and isElement(players[i]) then
					local playerID = getElementData(players[i], "playerid") or 0

					if getElementData(players[i], "loggedin") then
						local playerNameColor = "#FFFFFF"
						if getElementData(players[i], "adminduty") then
							local playerAdminLevel = getElementData(players[i], "adminlevel") or 0

							if playerAdminLevel ~= 0 then
								if playerAdminLevel == 8 or playerAdminLevel == 11 then
									playerNameColor = "#32b3ef"
								elseif playerAdminLevel == 9 then
									playerNameColor = "#d75959"
								elseif playerAdminLevel == 7 then
									playerNameColor = "#7a2978"
								elseif playerAdminLevel == 6 then
									playerNameColor = "#dfb551"
								else
									playerNameColor = "#7cc576"
								end
							end
						end
						
						prePlayersTable[playerID] = {
							players[i],
							playerNameColor .. string.gsub(getPlayerName(players[i]), "_", " "),
							playerID,
						}
					else
						prePlayersTable[playerID] = {
							players[i],
							"#949494" .. string.gsub(getPlayerName(players[i]), "_", " "),
							playerID
						}
					end

					lastPlayer = players[i]
				end
			end

			for i = 1, (getElementData(lastPlayer, "playerid") or 0) do
				if prePlayersTable[i] then
					table.insert(onlinePlayers, prePlayersTable[i])
				end
			end
		end
	end
)

function renderTheScoreboard()
	if logoAnimStart or logoAnimEnd then
		local currentTickCount = getTickCount()

		if fadeStart and currentTickCount >= fadeStart then
			fadeAmount = interpolateBetween(0, 0, 0, 1, 0, 0, (currentTickCount - fadeStart) / 400, "OutQuad")
		elseif fadeEnd and currentTickCount >= fadeEnd then
			local fadeProgress = (currentTickCount - fadeEnd) / 400
			fadeAmount = interpolateBetween(1, 0, 0, 0, 0, 0, fadeProgress, "OutQuad")

			if fadeProgress > 1 then
				onlinePlayers = {}
				logoAnimEnd = false
				fadeEnd = false
			end
		end

		if logoAnimStart and currentTickCount >= logoAnimStart then
			logoOffsetX, logoOffsetY = interpolateBetween(respc(27), respc(13), 0, 0, 0, 0, (currentTickCount - logoAnimStart) / 400, "OutQuad")
		elseif logoAnimEnd and currentTickCount >= logoAnimEnd then
			logoOffsetX, logoOffsetY = interpolateBetween(0, 0, 0, respc(27), respc(13), 0, (currentTickCount - logoAnimEnd) / 400, "OutQuad")
		end
		dxDrawImage(logoPosX + logoOffsetX, logoPosY + logoOffsetY, logoSize, logoSize, "files/logo2.png", 0, 0, 0, tocolor(255, 255, 255, 255 * fadeAmount))
		dxDrawImage(logoPosX - logoOffsetX, logoPosY + logoOffsetY, logoSize, logoSize, "files/logo3.png", 0, 0, 0, tocolor(255, 255, 255, 255 * fadeAmount))
		dxDrawImage(logoPosX, logoPosY, logoSize, logoSize, "files/logo1.png", 0, 0, 0, tocolor(255, 255, 255, 255 * fadeAmount))

		dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 150 * fadeAmount))
		dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelTitleHeight, tocolor(0, 0, 0, 150 * fadeAmount))
		dxDrawText("See#7cc576MTA v3 scoreboard", panelPosX + respc(8), panelPosY, panelPosX + panelWidth, panelPosY + panelTitleHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.5, getFont("RobotoB"), "left", "center", false, false, false, true)
		dxDrawText("#7cc576Online: #ffffff" .. #onlinePlayers .. "/750", panelPosX, panelPosY, panelPosX + panelWidth - respc(8), panelPosY + panelTitleHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.375, getFont("RobotoB"), "right", "center", false, false, false, true)
		dxDrawRectangle(panelPosX, panelPosY + panelTitleHeight, panelWidth, respc(2), tocolor(124, 197, 118, 200 * fadeAmount))

		if #onlinePlayers > 17 then
			rowWidth = panelWidth - respc(5)
		end

		for i = 1, 17 do
			local rowY = contentPosY + contentHeight / 17 * (i - 1)

			if i % 2 == 0 then
				dxDrawRectangle(panelPosX, rowY, rowWidth, rowHeight, tocolor(0, 0, 0, 50 * fadeAmount))
			end

			local playerData = onlinePlayers[i + panelPage]

			if playerData and isElement(playerData[1]) then
				dxDrawText("ID: " .. playerData[3], panelPosX + respc(8), rowY, panelPosX + panelWidth, rowY + rowHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.85, getFont("Roboto"), "left", "center", false, false, false, true)
				dxDrawText("                 " .. playerData[2], panelPosX + respc(8), rowY, panelPosX + panelWidth, rowY + rowHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.85, getFont("Roboto"), "left", "center", false, false, false, true)

				if getElementData(playerData[1], "loggedin") then
					dxDrawText("    LVL " .. 0 .. "    Ping:          ", panelPosX, rowY, panelPosX + rowWidth - respc(8), rowY + rowHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.85, getFont("Roboto"), "right", "center", false, false, false, true)

					local playerPing = getPlayerPing(playerData[1])
					if 150 >= playerPing and playerPing > 100 then
						dxDrawText("#dfb551" .. playerPing, panelPosX, rowY, panelPosX + rowWidth - respc(8), rowY + rowHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.85, getFont("Roboto"), "right", "center", false, false, false, true)
					elseif playerPing <= 100 then
						dxDrawText("#7cc576" .. playerPing, panelPosX, rowY, panelPosX + rowWidth - respc(8), rowY + rowHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.85, getFont("Roboto"), "right", "center", false, false, false, true)
					else
						dxDrawText("#d75959" .. playerPing, panelPosX, rowY, panelPosX + rowWidth - respc(8), rowY + rowHeight, tocolor(255, 255, 255, 255 * fadeAmount), 0.85, getFont("Roboto"), "right", "center", false, false, false, true)
					end
				else
					dxDrawText("Nincs bejelentkezve! ", panelPosX, rowY, panelPosX + rowWidth - respc(8), rowY + rowHeight, tocolor(200, 200, 200, 255 * fadeAmount), 0.85, getFont("Roboto"), "right", "center", false, false, false, true)
				end
			end
		end

		if #onlinePlayers > 17 then
			dxDrawRectangle(panelPosX - respc(5), contentPosY, respc(5), contentHeight, tocolor(0, 0, 0, 100 * fadeAmount))
			dxDrawRectangle(panelPosX - respc(5), contentPosY + (contentHeight / #onlinePlayers) * panelPage, 5, (contentHeight / #onlinePlayers) * 16, tocolor(124, 197, 118, 150 * fadeAmount))
		end
	end
end
addEventHandler("onClientRender", getRootElement(), renderTheScoreboard)

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end
