function buyItemOnServer(player, price)
	setElementData(player, "pp", getElementData(player, "pp")-price)
end
addEvent("buyItemOnServer", true)
addEventHandler("buyItemOnServer", getRootElement(), buyItemOnServer)

function buyMoneyOnServer(player, price, money)
	setElementData(player, "pp", getElementData(player, "pp")-price)
	setElementData(player, "money", getElementData(player, "money")+money)
end
addEvent("buyMoneyOnServer", true)
addEventHandler("buyMoneyOnServer", getRootElement(), buyMoneyOnServer)
