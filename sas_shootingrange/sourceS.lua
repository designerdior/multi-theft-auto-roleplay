local uSound = {}
local weapons = {}
local randomTable = 0
--1586, 1585, 1584, 1583

addEventHandler("onResourceStart", getResourceRootElement(),function()

	local skillPed = createPed(299,296.8115234375, -75.41796875, 1001.515625)
	setElementInterior(skillPed, weapInt)
	setElementDimension(skillPed, weapDim)
	setElementData(skillPed, "npcType", true)
	setElementData ( skillPed, "visiblePedName", "Benjamin")
	setElementData ( skillPed,"tagName","NPC")
	setElementData ( skillPed,"nameEnabled",true)
	setElementFrozen(skillPed, true)
	setElementRotation(skillPed,0,0,0)
	setElementData(skillPed,"weapSkillPed", true)
end)

addCommandHandler("addskill",
	function(playerSource,commandName,targetPlayer,skill)
		if getElementData(playerSource, "adminlevel") >= 8 then
			if not tonumber(skill) or not (targetPlayer) then
				outputChatBox("Használat: #ffffff/"..commandName.." [ID/Név] [skillID]", playerSource,61,122,188,true)
				outputChatBox("AK-47:#ffffff 77, #3d7abcM4:#ffffff 78", playerSource,61,122,188,true)
				outputChatBox("Deagle:#ffffff 71, #3d7abcShotgun:#ffffff 72", playerSource,61,122,188,true)
				outputChatBox("Sawed-off:#ffffff 73, #3d7abcColt-45:#ffffff 69", playerSource,61,122,188,true)
				outputChatBox("Sniper:#ffffff 79, #3d7abcMP5:#ffffff 76", playerSource,61,122,188,true)
				outputChatBox("UZI:#ffffff 75", playerSource,61,122,188,true)
			else
				local targetPlayer, targetPlayerName = exports['global']:findPlayerByPartialNick(playerSource, targetPlayer)
				if targetPlayer then
					setPedStat(targetPlayer, tonumber(skill), 999)
					outputChatBox("Adtál " .. targetPlayerName .. " -nak/nek fegyverskillt. ("..skill ..")", playerSource)
				end
			end
		end
	end
)

addCommandHandler("delskill",
	function(playerSource,commandName,targetPlayer,skill)
		if getElementData(playerSource, "adminlevel") >= 8 then
			if not tonumber(skill) or not (targetPlayer) then
				outputChatBox("Használat: #ffffff/"..commandName.." [ID/Név] [skillID]", playerSource,61,122,188,true)
				outputChatBox("AK-47:#ffffff 77, #3d7abcM4:#ffffff 78", playerSource,61,122,188,true)
				outputChatBox("Deagle:#ffffff 71, #3d7abcShotgun:#ffffff 72", playerSource,61,122,188,true)
				outputChatBox("Sawed-off:#ffffff 73, #3d7abcColt-45:#ffffff 69", playerSource,61,122,188,true)
				outputChatBox("Sniper:#ffffff 79, #3d7abcMP5:#ffffff 76", playerSource,61,122,188,true)
				outputChatBox("UZI:#ffffff 75", playerSource,61,122,188,true)
			else
				local targetPlayer, targetPlayerName = exports['global']:findPlayerByPartialNick(playerSource, targetPlayer)
				if targetPlayer then
					setPedStat(targetPlayer, tonumber(skill), 0)
					outputChatBox("Adtál " .. targetPlayerName .. " -nak/nek fegyverskillt. ("..skill ..")", playerSource)
				end
			end
		end
	end
)

function addSkillToClient(skillID,num)
	local skillID = tonumber(skillID)
	local num = tonumber(num)
	setPedStat(client, skillID, getPedStat(client, skillID) + num)
end
addEvent("addSkillToClient",true)
addEventHandler("addSkillToClient",root,addSkillToClient)

addCommandHandler("nullskills",function(playerSource)
	if getElementData(playerSource,"adminlevel") == 12 then
		for k,v in ipairs(getElementsByType("player")) do
			setPedStat(v, 70, 0)
			setPedStat(v, 71, 0)
			setPedStat(v, 72, 0)
			setPedStat(v, 74, 0)
			setPedStat(v, 76, 0)
			setPedStat(v, 77, 0)
			setPedStat(v, 78, 0)
			setPedStat(v, 79, 0)
		end
	end
end)
