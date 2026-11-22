addEvent("anim - give", true)
addEventHandler("anim - give", root,
    function(ped, anim)
        setElementData(ped, "forceAnimation", anim)
        setTimer(setPedAnimation, 50, 2, ped, anim[1], anim[2], -1, false, true, false)
    end
)

addEvent("health - give", true)
addEventHandler("health - give", root,
    function(ped)
        setElementHealth(ped, 100)
    end
)

addEvent("GoServerToBackClient", true)
addEventHandler("GoServerToBackClient", root,
    function(veh, attacker, weapon)
        triggerClientEvent(attacker, "onClientVehicleDamageCopy", attacker, veh, attacker, weapon)
    end
)


addCommandHandler("agyogyit",
	function(thePlayer, cmd, who, targetPlayer)
		if (exports.sas_global:isPlayerAdmin(thePlayer)) then
			if not (who) then
				outputChatBox("#7cc576[SeeMTA]: #ffffff/" .. cmd .. " [Játékos neve]", thePlayer,0,0,0,true)
			else
                local targetPlayer, targetPlayerName = exports['sas_global']:findPlayerByPartialNick(thePlayer, who)
                if (targetPlayer) then
                    setElementData(targetPlayer, "bone", {true, true, true, true, true})
                    setElementData(targetPlayer, "attackOnHand", 0)
                    setElementData(targetPlayer, "torsoAmmo", 0)
                    toggleMoveControls(targetPlayer,true)
                    setElementData(targetPlayer, "forceAnimation", "")
                    setTimer(setPedAnimation, 50, 2, targetPlayer, "", "", -1, false, true, false)
                    outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen meggyógyítottad #32b3ef"..targetPlayerName.."#ffffff-t.",thePlayer,0,0,0,true)
                    local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
                    exports.sas_global:sendMessageToAdmins("" .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer):gsub("_", " ") .. " meggyógyította #32b3ef"..targetPlayerName.."#ffffff-t.")
                    outputChatBox("#7cc576[SeeMTA]: #ffffff"..tostring(adminTitle).." "..getPlayerName(thePlayer):gsub("_", " ").." megyógyított téged.",targetPlayer,0,0,0,true)
                end
			end
		end
	end
)


function toggleMoveControls(player, value)
    toggleControl(player, "forwards", value)
    toggleControl(player, "backwards", value)
    toggleControl(player, "left", value)
    toggleControl(player, "right", value)
    toggleControl(player, "jump", value)
    toggleControl(player, "fire", value)
    toggleControl(player, "aim_weapon", value)
    toggleControl(player, "enter_exit", value)
end
