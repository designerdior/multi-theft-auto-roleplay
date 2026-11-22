function getAdmins()
	local players = getElementsByType("player")

	local admins = { }
	local count = 1

	for key, value in ipairs(players) do
		if isPlayerSeged(value) and getPlayerAdminLevel(value) <= 6 then
			admins[count] = value
			count = count + 1
		end
	end
	return admins
end

function isPlayerSeged(thePlayer)
	return getPlayerAdminLevel(thePlayer) >= 1
end

function isPlayerAdmin(thePlayer)
	return getPlayerAdminLevel(thePlayer) >= 2
end

function isPlayerFullAdmin(thePlayer)
	return getPlayerAdminLevel(thePlayer) >= 3
end

function isPlayerSuperAdmin(thePlayer)
	return getPlayerAdminLevel(thePlayer) >= 4
end

function isPlayerLeadAdmin(thePlayer)
	return getPlayerAdminLevel(thePlayer) >= 5
end

function isPlayerHeadAdmin(thePlayer)
	return getPlayerAdminLevel(thePlayer) >= 6
end

function getPlayerAdminLevel(thePlayer)
	return isElement( thePlayer ) and tonumber(getElementData(thePlayer, "adminlevel")) or 0
end

local titles = {"AdminSegéd", "Admin[1]", "Admin[2]", "Admin[3]", "Admin[4]", "Admin[5]", "Főadmin", "SuperAdmin", "Tulajdonos", "Rendszergazda", "Fejlesztő"}

function getPlayerAdminTitle(thePlayer)
	local text = titles[getPlayerAdminLevel(thePlayer)] or "Player"

	local hiddenAdmin = getElementData(thePlayer, "hiddenadmin") or 0
	if (hiddenAdmin==1) then
		text = text .. " (Rejtett)"
	end

	return text
end

function getAccurateAdminTitle(thePlayer)
	return titles[getPlayerAdminLevel(thePlayer)] or " "
end