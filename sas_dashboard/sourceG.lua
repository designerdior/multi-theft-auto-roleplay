
------------------------Exportált funkciók------------------------

function isInGroup(element, groupId)
	if isElement(element) and getElementType(element) == "player" then
		local groupCount = getElementData(element, "groupCount")
		if groupCount > 0 then
			for key = 0, groupCount do
				if getElementData(element, "group_"..key) == tonumber(groupId) then
					return true
				end
			end
		else
			return false
		end
	else
		return false
	end
end

function isGroupLeader(element, groupId)
	if isInGroup(element, groupId) then
		local groupCount = getElementData(element, "groupCount")
		if groupCount > 0 then
			for key = 0, groupCount do
				if getElementData(element, "group_"..key) == tonumber(groupId) and getElementData(element, "group_"..key.."_leader") == 1 then
					return true
				end
			end
		else
			return false
		end
	else
		return false
	end
end
