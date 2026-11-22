local hostname = "address"
local username = "user"
local password = "pass"
local database = "sas"

addEventHandler("onResourceStart", resourceRoot, function()
	connection = dbConnect("mysql", "dbname="..database..";host="..hostname, username, password, "charset=utf8")

	if not connection then
		cancelEvent(true, "mysql: can't connect to the database")
	end
end)

function getConnection()
	return connection, {hostname, username, password, database}
end
