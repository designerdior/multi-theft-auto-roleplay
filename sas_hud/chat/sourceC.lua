local screenW, screenH = guiGetScreenSize()
local chatSheet = createBrowser(screenW, screenH, true, true)

local chatHistory = 55
local chatMessages = 0
local oocChatMessages = 0

local chatPosX = false
local chatPosY = false
local chatWidth = false
local chatHeight = false
local chatMove = true
local chatResize = true

local oocChatPosX = false
local oocChatPosY = false
local oocChatWidth = false
local oocChatHeight = false
local oocChatMove = true
local oocChatResize = true

local chatInputHeight = 20

local customChatEnabled = false
local activeChatType = false

local isChatInputActive = false
local canWriteToChatInput = false
local chatInputValue = ""
local sentMessages = {}
local lastSentMessage = ""
local selectedChatMessage = 0

local characterRemoveStartTimer = nil
local characterRemoveTimer = nil

local chatboxLayout = getChatboxLayout()
local moocChatLines = chatboxLayout.chat_lines
local moocChatPosX = 20
local moocChatPosY = chatboxLayout.chat_scale[2] * chatboxLayout.chat_lines
local moocChatMaxLines = 10
local moocChatMessages = {}
local moocChatState = true

chatRenderedOut = false
--showChat(false)

settingsStorage = {
	chatType = 0,
	chatFontSize = 95,
	chatBGAlpha = 0,
	chatTextShadowAlpha = 255,
	moocChatEnabled = true
}

addEventHandler("onClientBrowserCreated", getRootElement(),
	function ()
		if source == chatSheet then
			loadBrowserURL(chatSheet, "http://mta/local/files/html/chat.html")
		end
	end
)
addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(setChatFontSize, 2000, 1, settingsStorage.chatFontSize)
		setTimer(setChatBackgroundAlpha, 2000, 1, settingsStorage.chatBGAlpha)
		setTimer(setChatTextShadowAlpha, 2000, 1, settingsStorage.chatTextShadowAlpha)
	end)

addEventHandler("onClientBrowserDocumentReady", getRootElement(),
	function ()
		if source == chatSheet then
			executeBrowserJavascript(chatSheet, "document.getElementById(\"innercontents\").style.fontSize=\"" .. 97 .. "%\"; document.getElementById(\"chatinput\").style.fontSize=\"" .. 97 .. "%\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight; var element=document.getElementById(\"innercontents\"),temp=document.createElement(element.nodeName);temp.setAttribute(\"style\",\"opacity:0;margin:0px;padding:0px;font-family:\"+element.style.fontFamily+\";font-size:\"+element.style.fontSize),temp.innerHTML=\"test\",temp=element.parentNode.appendChild(temp);var ret=temp.clientHeight;temp.parentNode.removeChild(temp); document.title = ret;")
			setTimer(resizeTheChat, 500, 1)
		end
	end
)

function resizeTheChat()
	customChatEnabled = true
	chatInputHeight = tonumber(getBrowserTitle(chatSheet)) or 20
	chatMove = true
	chatResize = true
	oocChatMove = true
	oocChatResize = true

	executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").innerHTML = \"Chat: \"; document.getElementById(\"chatinput\").style.width: " .. screenW .. "px; document.getElementById(\"chatinput\").style.height: " .. chatInputHeight .. "px;")
	executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").innerHTML = \"OOC: \"; document.getElementById(\"oocchatinput\").style.width: " .. screenW .. "px; document.getElementById(\"oocchatinput\").style.height: " .. chatInputHeight .. "px;")
end

function chatInputSwitched()
	if isChatInputActive then
		if activeChatType == "radio" then
			executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").style.visibility = \"visible\"; document.getElementById(\"chatinput\").innerHTML = \"Rádió: \"; document.getElementById(\"chatinput\").style.left=\"" .. chatPosX .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. chatPosY + chatHeight - chatInputHeight .. "px\";")
		elseif activeChatType == "normal" then
			executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").style.visibility = \"visible\"; document.getElementById(\"chatinput\").innerHTML = \"Chat: \"; document.getElementById(\"chatinput\").style.left=\"" .. chatPosX .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. chatPosY + chatHeight - chatInputHeight .. "px\";")
		end
	else
		isChatInputActive = false
		executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").style.visibility = \"hidden\";")
	end
end

function oocChatInputSwitched()
	if isChatInputActive then
		executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").style.visibility = \"visible\"; document.getElementById(\"oocchatinput\").innerHTML = \"OOC: \"; document.getElementById(\"oocchatinput\").style.left=\"" .. oocChatPosX .. "px\";document.getElementById(\"oocchatinput\").style.top=\"" .. oocChatPosY + oocChatHeight - chatInputHeight .. "px\";")
	else
		executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").style.visibility = \"hidden\";")
	end
end

function refreshChatInputText()
	if activeChatType == "ooc" then
		executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").innerHTML = \"OOC: " .. escapeHTML(chatInputValue) .. "\";")
	elseif activeChatType == "radio" then
		executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").innerHTML = \"Rádió: " .. escapeHTML(chatInputValue) .. "\";")
	else
		executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").innerHTML = \"Chat: " .. escapeHTML(chatInputValue) .. "\";")
	end
end

function toggleChatInput(state)
	canWriteToChatInput = false

	if state then
		guiSetInputEnabled(true)
		showCursor(true)

		chatInputValue = ""
		lastSentMessage = chatInputValue
		selectedChatMessage = 0
		isChatInputActive = true

		if activeChatType == "ooc" then
			oocChatInputSwitched()
		else
			chatInputSwitched()
		end
	else
		chatInputValue = ""
		lastSentMessage = chatInputValue
		isChatInputActive = false

		if activeChatType == "ooc" then
			oocChatInputSwitched()
		else
			chatInputSwitched()
		end
		activeChatType = false

		guiSetInputEnabled(false)
		showCursor(false)
	end

	setElementData(localPlayer, "typing", isChatInputActive or isChatBoxInputActive())
end

setElementData(localPlayer, "customchat", false)
showChat(true)
local showing = nil
addEventHandler("onClientRender", getRootElement(), function()
	x,y,w,h = getNode(22, "x"), getNode(22, "y"),getNode(22, "width"),getNode(22, "height")
	showing = getNode(22, "showing")
	if showing or getElementData(localPlayer, "valaszto") then
		customchatRender(x, y, w, h)
	--	oocchat(x, y, w, h)
	end
end)

function customchatRender(x, y, w, h)
	if getElementData(localPlayer, "customchat") and getElementData(localPlayer, "enableall") and getElementData(localPlayer, "loggedin") then
		if chatPosX ~= x then
			chatPosX = x
			chatMove = true
		end

		if chatPosY ~= y then
			chatPosY = y
			chatMove = true
		end

		if chatWidth ~= w then
			chatWidth = w
			chatResize = true
		end

		if chatHeight ~= h then
			chatHeight = h
			chatResize = true
		end

		if chatMove then
			executeBrowserJavascript(chatSheet, "document.getElementById(\"innercontents\").style.left=\"" .. x .. "px\";document.getElementById(\"innercontents\").style.top=\"" .. y .. "px\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight;")

			if isChatInputActive then
				executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").style.left=\"" .. x .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. y + h - chatInputHeight .. "px\";")
			end

			chatMove = false
		end

		if chatResize then
			executeBrowserJavascript(chatSheet, "document.getElementById(\"innercontents\").style.width=\"" .. w .. "px\";document.getElementById(\"innercontents\").style.height=\"" .. h - chatInputHeight .. "px\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight;")

			if isChatInputActive then
				executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").style.left=\"" .. x .. "px\";document.getElementById(\"chatinput\").style.top=\"" .. y + h - chatInputHeight .. "px\";")
			end

			chatResize = false
		end
	--	outputDebugString("chat")
	--	if not chatRenderedOut then
			dxDrawImage(0, 0, screenW, screenH, chatSheet)
			chatRenderedOut = true
			--outputDebugString("chat")
		--end
	end
end

function oocchat(x, y, w, h)
	if getElementData(localPlayer, "customchat") then
		if not chatRenderedOut then
			dxDrawImage(0, 0, screenW, screenH, chatSheet)
			chatRenderedOut = true
		end

		if oocChatPosX ~= x then
			oocChatPosX = x
			oocChatMove = true
		end

		if oocChatPosY ~= y then
			oocChatPosY = y
			oocChatMove = true
		end

		if oocChatWidth ~= w then
			oocChatWidth = w
			oocChatResize = true
		end

		if oocChatHeight ~= h then
			oocChatHeight = h
			oocChatResize = true
		end

		if oocChatMove then
			executeBrowserJavascript(chatSheet, "document.getElementById(\"oocinnercontents\").style.left=\"" .. x .. "px\";document.getElementById(\"oocinnercontents\").style.top=\"" .. y .. "px\"; document.getElementById(\"oocinnercontents\").scrollTop = document.getElementById(\"oocinnercontents\").scrollHeight;")

			if isChatInputActive then
				executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").style.left=\"" .. x .. "px\";document.getElementById(\"oocchatinput\").style.top=\"" .. y + h - chatInputHeight .. "px\";")
			end

			oocChatMove = false
		end

		if oocChatResize then
			executeBrowserJavascript(chatSheet, "document.getElementById(\"oocinnercontents\").style.width=\"" .. w .. "px\";document.getElementById(\"oocinnercontents\").style.height=\"" .. h - chatInputHeight .. "px\"; document.getElementById(\"oocinnercontents\").scrollTop = document.getElementById(\"oocinnercontents\").scrollHeight;")

			if isChatInputActive then
				executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").style.left=\"" .. x .. "px\";document.getElementById(\"oocchatinput\").style.top=\"" .. y + h - chatInputHeight .. "px\";")
			end

			oocChatResize = false
		end
	end
end

function setChatFontSize(size)
	if tonumber(size) then
		size = math.floor(tonumber(size))

		if size >= 50 and size <= 200 then
			settingsStorage.chatFontSize = size
			executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").style.fontSize=\"" .. size .. "%\";")
			executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").style.fontSize=\"" .. size .. "%\";")
			executeBrowserJavascript(chatSheet, "document.getElementById(\"innercontents\").style.fontSize=\"" .. size .. "%\";")
			executeBrowserJavascript(chatSheet, "document.getElementById(\"oocinnercontents\").style.fontSize=\"" .. size .. "%\";")
			setTimer(resizeTheChat, 500, 1)
		end
	end
end

function setChatBackgroundAlpha(alpha)
	if tonumber(alpha) and alpha >= 0 and alpha <= 255 then
		settingsStorage.chatBGAlpha = alpha
		executeBrowserJavascript(chatSheet, "document.getElementById(\"oocchatinput\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
		executeBrowserJavascript(chatSheet, "document.getElementById(\"chatinput\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
		executeBrowserJavascript(chatSheet, "document.getElementById(\"innercontents\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
		executeBrowserJavascript(chatSheet, "document.getElementById(\"oocinnercontents\").style.backgroundColor=\"rgba(0,0,0," .. alpha / 255 .. ")\";")
	end
end

function setChatTextShadowAlpha(alpha)
	if tonumber(alpha) and alpha >= 0 and alpha <= 255 then
		settingsStorage.chatTextShadowAlpha = alpha
		executeBrowserJavascript(chatSheet, "document.getElementById(\"shadow\").innerHTML = \"* { text-shadow: 1px 1px rgba(0, 0, 0, " .. alpha / 255 .. "); }\";")
	end
end

function escapeHTML(html)
	html = utf8.gsub(html, "&", "&amp;")
	html = utf8.gsub(html, "<", "&lt;")
	html = utf8.gsub(html, ">", "&gt;")
	html = utf8.gsub(html, "\"", "&quot;")
	html = utf8.gsub(html, "'", "&#39;")
	html = utf8.gsub(html, "/", "&#x2F;")
	return html
end

function processMessage(message)
	if utf8.len(message) >= 1 then
		if utf8.find(utf8.sub(message, 1, 1), "/") then
			local messageSplit = split(message, " ")
			local command = utf8.gsub(messageSplit[1], "/", "")

			table.remove(messageSplit, 1)
			executeCommandHandler(command, table.concat(messageSplit, " "))
			triggerServerEvent("executeCommand", localPlayer, command, table.concat(messageSplit, " "))
		else
			if activeChatType == "radio" then
				triggerServerEvent("executeCommand", localPlayer, "r", message)
			elseif activeChatType == "ooc" then
				executeCommandHandler("b", message)
			else
				if not executeCommandHandler("say", message) then
					triggerServerEvent("executeCommand", localPlayer, "say", message)
				end
					--outputChatBox(chatInputValue)
			--	outputChatBox(getPlayerName(localPlayer)" mondja: "..chatInputValue)
			end
		end

		table.insert(sentMessages, 1, message)
		selectedChatMessage = 0
	end

	toggleChatInput(false)
end

function processCharacterRemove()
	chatInputValue = utf8.sub(chatInputValue, 1, utf8.len(chatInputValue) - 1)
	refreshChatInputText()
end

bindKey("t", "down",
	function ()
		if getElementData(localPlayer, "enableall") and getElementData(localPlayer, "customchat") then
			if showing or getElementData(localPlayer, "valaszto") then
				if not isBrowserLoading(chatSheet) and not isChatInputActive then
					activeChatType = "normal"
					toggleChatInput(true)
				end
			end
		end

		setElementData(localPlayer, "typing", isChatInputActive or isChatBoxInputActive())
	end
)

bindKey("y", "down", "chatbox", "Rádió")
bindKey("y", "down",
	function ()
		if getElementData(localPlayer, "enableall") and getElementData(localPlayer, "customchat") then
			if showing or getElementData(localPlayer, "valaszto") then
				if not isBrowserLoading(chatSheet) and not isChatInputActive then
					activeChatType = "radio"
					toggleChatInput(true)
				end
			end
		end

		setElementData(localPlayer, "typing", isChatInputActive or isChatBoxInputActive())
	end
)
addCommandHandler("Rádió",
	function(_, ...)
		if getElementData(localPlayer, "loggedin") and isChatVisible() then
			local message = table.concat({...}, " ")

			if utf8.len(message) > 0 then
				local textWithoutSpaces = utf8.gsub(message, " ", "")

				if (textWithoutSpaces and utf8.len(textWithoutSpaces) > 0) or not textWithoutSpaces then
					triggerServerEvent("executeCommand", localPlayer, "r", message)
				end
			end
		end
	end
)

bindKey("b", "down",
	function ()
		if getElementData(localPlayer, "enableall") and getElementData(localPlayer, "customchat") then
			--if isHudElementVisible("oocchat") then
				if not isBrowserLoading(chatSheet) and not isChatInputActive then
					activeChatType = "ooc"
					toggleChatInput(true)
				end
			--end
		end

		setElementData(localPlayer, "typing", isChatInputActive or isChatBoxInputActive())
	end
)

function clearChat()
	for i = 1, getChatboxLayout()["chat_lines"] do
		outputChatBox("")
	end

	executeBrowserJavascript(chatSheet, "document.getElementById(\"innercontents\").innerHTML = \"<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>\"")
	chatMessages = 0
end
addCommandHandler("clearchat", clearChat)
addCommandHandler("cc", clearChat)

function clearOOC()
	executeBrowserJavascript(chatSheet, "document.getElementById(\"oocinnercontents\").innerHTML = \"<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>\"")
	oocChatMessages = 0
	moocChatMessages = {}
end
addCommandHandler("clearooc", clearOOC)
addCommandHandler("co", clearOOC)

addEventHandler("onClientCharacter", getRootElement(),
	function (character)
		if getElementData(localPlayer, "customchat") and isChatInputActive and utf8.len(chatInputValue) < 100 then
			if canWriteToChatInput then

				chatInputValue = chatInputValue .. character

				refreshChatInputText()
				outputDebugString(chatInputValue)
			end

			canWriteToChatInput = true
		end
	end
)

addEventHandler("onClientKey", getRootElement(),
	function (key, pressDown)
		if getElementData(localPlayer, "customchat") then
			if isChatInputActive then
				if pressDown then
					if key == "enter" or key == "num_enter" then
						cancelEvent()
						processMessage(chatInputValue)
					elseif key == "backspace" then
						if utf8.len(chatInputValue) ~= 0 then
							chatInputValue = utf8.sub(chatInputValue, 1, utf8.len(chatInputValue) - 1)
							refreshChatInputText()

							characterRemoveStartTimer = setTimer(function()
								processCharacterRemove()
								characterRemoveTimer = setTimer(processCharacterRemove, 50, 0)
							end, 500, 1)
						end
					elseif key == "escape" then
						cancelEvent()
						toggleChatInput(false)
					elseif key == "arrow_u" and (sentMessages[selectedChatMessage + 1] or selectedChatMessage + 1 == 0) then
						selectedChatMessage = selectedChatMessage + 1

						if selectedChatMessage == 0 then
							chatInputValue = lastSentMessage
							refreshChatInputText()
						else
							chatInputValue = sentMessages[selectedChatMessage]
							refreshChatInputText()
						end
					elseif key == "arrow_d" and (sentMessages[selectedChatMessage - 1] or selectedChatMessage - 1 == 0) then
						selectedChatMessage = selectedChatMessage - 1

						if selectedChatMessage == 0 then
							chatInputValue = lastSentMessage
							refreshChatInputText()
						else
							chatInputValue = sentMessages[selectedChatMessage]
							refreshChatInputText()
						end
					end
				else
					if key == "backspace" then
						if isTimer(characterRemoveStartTimer) then
							killTimer(characterRemoveStartTimer)
						end

						if characterRemoveTimer and isTimer(characterRemoveTimer) then
							killTimer(characterRemoveTimer)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientChatMessage", getRootElement(),
	function (message, r, g, b)
		if r == 255 and g == 150 and b == 255 then
			return
		end

		local isFormattedMessage = false

		if utf8.sub(message, 1, 8) == "[format]" then
			message = utf8.gsub(message, "%[format]", "")
			isFormattedMessage = true
			cancelEvent()
		end

		local messageMainColor = string.format("#%02x%02x%02x", r, g, b)
		local escapedMessage = escapeHTML(message)

		if utf8.find(utf8.sub(messageMainColor .. escapedMessage, 8, 16), "#%x%x%x%x%x%x%[") and utf8.find(messageMainColor .. escapedMessage, "%]:") then
			local formattedMessage = utf8.sub(message, 1, #messageMainColor) .. "<b style='color: inherit;'>" .. utf8.sub(message, #messageMainColor + 1, utf8.find(escapedMessage, "%]:") + 1) .. "</b>"
			formattedMessage = formattedMessage .. utf8.sub(message, utf8.find(escapedMessage, "%]:") + 2, #escapedMessage)
			escapedMessage = utf8.gsub(formattedMessage, "#%x%x%x%x%x%x", "</font><font style='color: %1;'>")
		else
			escapedMessage = messageMainColor .. escapedMessage
			escapedMessage = utf8.gsub(escapedMessage, "#%x%x%x%x%x%x", "</font><font style='color: %1;'>")
		end

		escapedMessage = utf8.gsub(escapedMessage, "&#47;", "/")

		if isFormattedMessage then
			message = utf8.gsub(message, "%[(fa%-(.-))%]", "")
			message = utf8.gsub(message, "%[b%]", "")
			message = utf8.gsub(message, "%[/b%]", "")
			message = utf8.gsub(message, "%[i%]", "")
			message = utf8.gsub(message, "%[/i%]", "")
			message = utf8.gsub(message, "%[u%]", "")
			message = utf8.gsub(message, "%[/u%]", "")

			escapedMessage = utf8.gsub(escapedMessage, "%[(fa%-(.-))%]", "<i class='fa %1' style='color: inherit; vertical-align: middle;'></i>")
			escapedMessage = utf8.gsub(escapedMessage, "%[b%]", "<b style='color: inherit;'>")
			escapedMessage = utf8.gsub(escapedMessage, "%[/b%]", "</b>")
			escapedMessage = utf8.gsub(escapedMessage, "%[i%]", "<i style='color: inherit;'>")
			escapedMessage = utf8.gsub(escapedMessage, "%[/i%]", "</i>")
			escapedMessage = utf8.gsub(escapedMessage, "%[u%]", "<ins style='color: inherit;'>")
			escapedMessage = utf8.gsub(escapedMessage, "%[/u%]", "</ins>")

			outputChatBox(messageMainColor .. message, 255, 150, 255, true)
		end

		chatMessages = chatMessages + 1
		executeBrowserJavascript(chatSheet, "document.getElementById(\"innercontents\").innerHTML=document.getElementById(\"innercontents\").innerHTML+\"" .. escapedMessage .. "<br />\"; document.getElementById(\"innercontents\").scrollTop = document.getElementById(\"innercontents\").scrollHeight;")

		if chatMessages > chatHistory then
			chatMessages = chatHistory
			executeBrowserJavascript(chatSheet, "var lines=document.getElementById(\"innercontents\").innerHTML.split(\"<br>\");lines.splice(0,1);document.getElementById(\"innercontents\").innerHTML = lines.join(\"<br />\");")
		end
	end, true, "high+99999"
)

addEvent("onClientRecieveOOCMessage", true)
addEventHandler("onClientRecieveOOCMessage", getRootElement(),
	function (message, playerName)
		executeBrowserJavascript(chatSheet, "document.getElementById(\"oocinnercontents\").innerHTML=document.getElementById(\"oocinnercontents\").innerHTML+\"" .. escapeHTML(playerName .. ": (( " .. message .. " ))") .. "<br />\"; document.getElementById(\"oocinnercontents\").scrollTop = document.getElementById(\"oocinnercontents\").scrollHeight;")

		oocChatMessages = oocChatMessages + 1

		if oocChatMessages > chatHistory then
			oocChatMessages = chatHistory
			executeBrowserJavascript(chatSheet, "var lines=document.getElementById(\"oocinnercontents\").innerHTML.split(\"<br>\");lines.splice(0,1);document.getElementById(\"oocinnercontents\").innerHTML = lines.join(\"<br />\");")
		end

		if #moocChatMessages >= moocChatMaxLines then
			table.remove(moocChatMessages, moocChatMaxLines)
		end

		table.insert(moocChatMessages, 1, playerName .. ": (( " .. message .. " ))")
		outputConsole(playerName .. ": (( " .. message .. " ))")
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if isChatVisible() and moocChatState then
			chatboxLayout = getChatboxLayout()
			moocChatLines = chatboxLayout.chat_lines
			moocChatPosY = (chatboxLayout.chat_scale[2] * chatboxLayout.chat_lines) + 16 + 15 * moocChatLines + 25

		--	dxDrawText("OOC Chat (eltüntetéshez /tog ooc)", moocChatPosX + 1, moocChatPosY + 1, 0, 0, tocolor(0, 0, 0), 1, "default-bold", "left", "top", false, false, false)
		--	dxDrawText("OOC Chat (eltüntetéshez /tog ooc)", moocChatPosX, moocChatPosY, 0, 0, tocolor(205, 205, 205), 1, "default-bold", "left", "top", false, false, false)

			for k, v in ipairs(moocChatMessages) do
				dxDrawText(v, moocChatPosX + 1, moocChatPosY + (moocChatMaxLines + 1) * 15 - k * 15 + 1, 0, 0, tocolor(0, 0, 0), 1, "default-bold", "left", "top", false, false, false)
				dxDrawText(v, moocChatPosX, moocChatPosY + (moocChatMaxLines + 1) * 15 - k * 15, 0, 0, tocolor(205, 205, 205), 1, "default-bold", "left", "top", false, false, false)
			end
		end
	end
)

addCommandHandler("tog",
	function (_, text)
		if text == "ooc" or text == "OOC" then
			moocChatState = not moocChatState
		end
	end
)
