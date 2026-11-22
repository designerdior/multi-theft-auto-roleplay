local sx,sy = guiGetScreenSize ()
local chatData = getChatboxLayout()
local x, y = sx/2-50, sy-180
local oocState = true
local maxLines = 9
local oocMessages = {}
local font = "default-bold"
local _,scale = chatData["chat_scale"]
local bg = {chatData["chat_color"]}
local lines = chatData["chat_lines"]
-- local chatX,chatY = x,y
local chatX,chatY = 0.015625*sx,16 + 15*lines + 25

addEventHandler ("onClientRender",getRootElement(),
	function ()
		if getElementData(localPlayer, "loggedin") then
			if oocState and getElementData(localPlayer, "enableall") then
				chatX, chatY = exports.sas_hud:getNode(11, "x"), exports.sas_hud:getNode(11, "y")
				dxDrawText("OOC Chat (Kikapcsoláshoz /togooc | Takarítás: /co)",chatX+1,chatY+1,0,0,tocolor(0,0,0),1,font)
				dxDrawText("OOC Chat (Kikapcsoláshoz /togooc | Takarítás: /co)",chatX,chatY,0,0,tocolor(205,205,205),1,font)
				for k,v in ipairs(oocMessages) do
					local tx,ty = chatX,chatY + (maxLines+2)*15 - k*15
					dxDrawText(v,tx+1,ty+1,0,0,tocolor(0,0,0),1,font)
					dxDrawText(v,tx,ty,0,0,tocolor(205,205,205),1,font)
				end
			end
		end
	end
)

addEvent ("onOOCMessageSend",true)
addEventHandler ("onOOCMessageSend",getRootElement(),
	function (message)
		local player = source
		local int,dim = getElementInterior (player),getElementDimension(player)
		if int == getElementInterior(localPlayer) and dim == getElementDimension(localPlayer) then
			local length = #oocMessages
			if #oocMessages >= maxLines then
				table.remove (oocMessages,maxLines)
			end
			local text = message
			table.insert (oocMessages,1,text)
			outputConsole ("[OOC]"..text)
		end
	end
)

function isOOCChatToggled ()
	return oocState
end

function toggleOOCChat (state)
	if state ~= oocState then
		oocState = state
	end
end

function togOOCCMD (cname,arg)
	toggleOOCChat (not oocState)
end
addCommandHandler ("togooc",togOOCCMD)

function co ()
	for k in pairs (oocMessages) do
    oocMessages[k] = nil
end
end
addCommandHandler ("co",co)


local oldRand = 1

local info = {
	"Weboldalunk: www.see-game.com",
	"Weboldalunk: www.see-game.com"
}
