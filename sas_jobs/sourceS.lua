local con = exports.sas_mysql:getConnection()

function szerverMunkaFelvetel(munkaID)
	setElementData(client, "job", munkaID)
	dbPoll ( dbQuery( con, "UPDATE characters SET job=? WHERE id = ?", munkaID, getElementData(client, "dbid")), -1 )
end

addEvent("munkaFelvetel", true)
addEventHandler("munkaFelvetel", getRootElement(), szerverMunkaFelvetel)

function szerverMunkaFelmondas()
	triggerClientEvent ( client, "munkaKelepesKliens", getRootElement(), getElementData(client, "job") )
	setElementData(client, "job", 0)
	dbPoll ( dbQuery( con, "UPDATE characters SET job=0 WHERE id = ?", getElementData(client, "dbid")), -1 )
end

addEvent("munkaFelmondas", true)
addEventHandler("munkaFelmondas", getRootElement(), szerverMunkaFelmondas)