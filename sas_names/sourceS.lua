
function setPlayerVisibleName (player,name)
	if isElement(player) and name then
		local name = string.gsub(name,"_"," ")
		setElementData (player,"visibleName",name)
		return true
	end
end

function getPlayerVisibleName (player)
	if isElement(player) then
		return getElementData (player,"visibleName",name)
	end
end

function setPlayerTag (player,tag)
	if isElement(player) then
		setElementData (player,"tagName",tag)
		if tag == false or tag == nil then
			setPlayerTagColor (player,"standard")
		end
		return true
	end
end

function getPlayerTag (player)
	if isElement(player) then
		return getElementData (player,"tagName")
	end
end

function getPlayerVisibleNameState (player)
	if isElement(player) then
		local name = getElementData (player,"visibleName")
		return name
	end
end

function setPlayerNameVisibleState (player,state)
	if isElement(player) then
		if state == true or state == false then
			setElementData (player,"nameEnabled",state)
		end
	end
end

function setPlayerMaskState (player,state)
	if player and isElement(player) then
		if state == true or state == false then
			setElementData (player,"nameMask",state)
			if state == true then
				if charUID then
					setElementData (player,"nameMask",true)
				end
			elseif state == false then
				local name = getPlayerName(player)
				if name then
					local name = string.gsub(name,"_"," ")
					if name then
						setPlayerVisibleName (player,name)
						setElementData (player,"nameMask",false)
					end
				end
			end
		end
	end
end

function getPlayerMaskState (player)
	if isElement(player) then
		return getElementData (player,"nameMask")
	end
end

function setPlayerNicknameColor (player,r,g,b)
	if isElement(player) then
		if r == "standard" or r == "normal" then
			local r,g,b = 255,235,180
			local gametime = getElementData(player, "hoursplayed")
			if gametime < 5 then
				r,g,b = 91,255,78
			end
			setElementData (player,"nametagColorR",r)
			setElementData (player,"nametagColorG",g)
			setElementData (player,"nametagColorB",b)
		elseif type(r) == "number" and type(g) == "number" and type(b) == "number" then
			setElementData (player,"nametagColorR",r)
			setElementData (player,"nametagColorG",g)
			setElementData (player,"nametagColorB",b)
		end
	end
end

function getPlayerNicknameColor (player)
	if isElement(player) then
		local r,g,b = getElementData (player,"nametagColorR"),getElementData (player,"nametagColorG"),getElementData (player,"nametagColorB")
		if r == false or g == false or b == false then
			r,g,b = 255,235,180
		end
		return r,g,b
	end
end

function setPlayerTagColor (player,r,g,b)
	if isElement(player) then
		if r == "standard" or r == "normal" then
			setElementData (player,"tagNameColorR",255)
			setElementData (player,"tagNameColorG",235)
			setElementData (player,"tagNameColorB",180)
		elseif type(r) == "number" and type(g) == "number" and type(b) == "number" then
			setElementData (player,"tagNameColorR",r)
			setElementData (player,"tagNameColorG",g)
			setElementData (player,"tagNameColorB",b)
		end
	end
end

function getPlayerTagColor (player)
	if isElement(player) then
		local r,g,b = getElementData (player,"tagNameColorR"),getElementData (player,"tagNameColorG"),getElementData (player,"tagNameColorB")
		if r == false or g == false or b == false then
			r,g,b = 255,235,180
		end
		return r,g,b
	end
end

function setPlayerDescription (player,desc)
	if isElement(player) then
		setElementData (player,"description",desc)
		return true
	end
end

function getPlayerDescription (player)
	if isElement(player) then
		return getElementData (player,"description")
	end
end

addEventHandler ("onResourceStart",getResourceRootElement(getThisResource()),
	function ()
		local players = getElementsByType ("player")
		for k,v in ipairs(players) do
			setPlayerNameVisibleState (v,true)
			setPlayerVisibleName (v,string.gsub(getPlayerName(v),"_"," "))
			setPlayerMaskState (v,false)
			setPlayerTag (v,false)
		end
	end
)

addEventHandler ("onPlayerJoin",getRootElement(),
	function ()
		setElementData (source,"nameMask",false)
		setElementData (source,"nameEnabled",true)
		setPlayerNameVisibleState (source,true)
		setPlayerVisibleName (source,string.gsub(getPlayerName(source),"_"," "))
	end
)

addEventHandler ("onPlayerChangeNick",getRootElement(),
	function (old,new)
		--setPlayerNameVisibleState (source,true)
		--setPlayerVisibleName (source,string.gsub(new,"_"," "))
		cancelEvent ()
	end
)