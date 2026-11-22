local connection = exports.sas_mysql:getConnection()

function inzerToSQLTable ()
	if not client then return end
	local name = getPlayerName(client):gsub("_"," ")
	local cardID = generateKey(client:getData("dbid"))
	local SkinId = getPedSkin(client)
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minut
	date = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 1, time.monthday )
	lejaratdate = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 2, time.monthday )
	local CreateSQL = dbExec(connection, "INSERT INTO identity SET cardID = ?, Skin = ?, Lejarat =?, keszitett =?, Name =?, Owner =?", tonumber(cardID), SkinId, lejaratdate, date, name, getElementData(client,"dbid"))
	if CreateSQL then
		setElementData(client,"money",getElementData(client,"money")-100)
		triggerEvent("giveItem", client, client, 206, cardID, 1,0)
	end
end
addEvent("InzertSQL", true)
addEventHandler("InzertSQL", root, inzerToSQLTable)

function adasveteliIgenyles ()
	triggerEvent("giveItem", client, client, 310, 1, 1,0)
end
addEvent("adasveteliIgenyles", true)
addEventHandler("adasveteliIgenyles", root, adasveteliIgenyles)

function inzerToSQLTableUtlevel()
	if not client then return end
	local name = getPlayerName(client):gsub("_"," ")
	local cardID = generateKey(getElementData(client, "dbid"))
	local SkinId = getPedSkin(client)
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minut
	date = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 1, time.monthday )
	lejaratdate = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 2, time.monthday )
	local CreateSQL = dbExec(connection, "INSERT INTO utlevelek SET cardID = ?, Skin = ?, Lejarat =?, keszitett =?, Name =?, Owner =?", tonumber(cardID), SkinId, lejaratdate, date, name, getElementData(client,"dbid"))
	if CreateSQL then
		triggerEvent("giveItem", client, client, 263, cardID, 1,0)
		setElementData(client,"money",getElementData(client,"money")-350)
	end
end
addEvent("InzertSQLUtlevel", true)
addEventHandler("InzertSQLUtlevel", root, inzerToSQLTableUtlevel)

function InzertSQLJogsi (player)
	if not client then client = player return end
	local name = getPlayerName(client):gsub("_"," ")
	local cardID = generateKey(client:getData("dbid"))
	local SkinId = getPedSkin(client)
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minut
	lejaratdate = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 2, time.monthday )
	local CreateSQL = dbExec(connection, "INSERT INTO drivinglicenses SET cardID = ?, Skin = ?, Lejarat =?, Name =?, Owner =?", tonumber(cardID), SkinId, lejaratdate, name, getElementData(client,"dbid"))
	if CreateSQL then
		--setElementData(client,"money",getElementData(client,"money")-100)
		triggerEvent("giveItem", client, client, 207, cardID, 1,0)
	end
end
addEvent("InzertSQLJogsi", true)
addEventHandler("InzertSQLJogsi", root, InzertSQLJogsi)

function InzertSQLHorgasz (type)
	if not client then return end
	local name = getPlayerName(client):gsub("_"," ")
	local cardID = generateKey(client:getData("dbid"))
	local SkinId = getPedSkin(client)
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minut
	date = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 1, time.monthday )
	lejaratdate = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 2, time.monthday )
	local CreateSQL = dbExec(connection, "INSERT INTO horgaszengedelyek SET cardID = ?, Type = ?, Lejarat =?, keszitett =?, Name =?, Owner =?", tonumber(cardID), type, lejaratdate, date, name, getElementData(client,"dbid"))
	if CreateSQL then
		setElementData(client,"money",getElementData(client,"money")-200)
		triggerEvent("giveItem", client, client, 309, cardID, 1,0)
	end
end
addEvent("InzertSQLHorgasz", true)
addEventHandler("InzertSQLHorgasz", root, InzertSQLHorgasz)

function getPlayerToIdentity(ItemValue)
	local getPool = dbPoll (dbQuery(connection,"SELECT * FROM identity WHERE cardID=?",tonumber(ItemValue)),-1)
	if getPool then
		for i,v in ipairs(getPool) do
			triggerClientEvent(client,"ReceiveIdentity",client,v)
		end
	end
end
addEvent("getPlayerToIdentity", true)
addEventHandler("getPlayerToIdentity", root, getPlayerToIdentity)

function getPlayerToJogsi(ItemValue)
	local getPool = dbPoll (dbQuery(connection,"SELECT * FROM drivinglicenses WHERE cardID=?",tonumber(ItemValue)),-1)
	if getPool then
		for i,v in ipairs(getPool) do
			triggerClientEvent(client,"ReceiveJogsi",client,v)
		end
	end
end
addEvent("getPlayerToJogsi", true)
addEventHandler("getPlayerToJogsi", root, getPlayerToJogsi)

function getPlayerToUtlevel(ItemValue)
	local getPool = dbPoll (dbQuery(connection,"SELECT * FROM utlevelek WHERE cardID=?",tonumber(ItemValue)),-1)
	if getPool then
		for i,v in ipairs(getPool) do
			triggerClientEvent(client,"ReceiveUtlevel",client,v)
		end
	end
end
addEvent("getPlayerToUtlevel", true)
addEventHandler("getPlayerToUtlevel", root, getPlayerToUtlevel)

function getPlayerToHorgasz(ItemValue)
	local getPool = dbPoll (dbQuery(connection,"SELECT * FROM horgaszengedelyek WHERE cardID=?",tonumber(ItemValue)),-1)
	if getPool then
		for i,v in ipairs(getPool) do
			triggerClientEvent(client,"ReceiveHorgasz",client,v)
		end
	end
end
addEvent("getPlayerToHorgasz", true)
addEventHandler("getPlayerToHorgasz", root, getPlayerToHorgasz)


function refreshLicense(ItemValue, type)
	if type == "driving" then

		local time = getRealTime()
		local hours = time.hour
		local minutes = time.minut

		lejaratdate = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 2, time.monthday )
		dbExec(connection, "UPDATE drivinglicenses SET Lejarat = ? WHERE cardID = ?", lejaratdate, tonumber(ItemValue))
		setElementData(client, "money", getElementData(client, "money")-75)

	elseif type == "identity" then

		local time = getRealTime()
		local hours = time.hour
		local minutes = time.minut

		lejaratdate = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 2, time.monthday )
		dbExec(connection, "UPDATE identity SET Lejarat = ? WHERE cardID = ?", lejaratdate, tonumber(ItemValue))
		setElementData(client, "money", getElementData(client, "money")-75)
		--outputChatBox("sikeres")

	elseif type == "horgasz" then

		local time = getRealTime()
		local hours = time.hour
		local minutes = time.minut

		lejaratdate = string.format("%04d/%02d/%02d", time.year + 1900, time.month + 2, time.monthday )
		dbExec(connection, "UPDATE horgaszengedelyek SET Lejarat = ? WHERE cardID = ?", lejaratdate, tonumber(ItemValue))
		setElementData(client, "money", getElementData(client, "money")-150)
		--outputChatBox("sikeres")

	end
end
addEvent("refreshLicense", true)
addEventHandler("refreshLicense", getRootElement(), refreshLicense)

function generateKey(id)
	if (tonumber(id)) then
		if (tonumber(id) > -1) then
			return id .. math.random(111111,999999)
		else
			return false
		end
	else
		return false
	end
end
