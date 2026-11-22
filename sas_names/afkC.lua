--[[local afkCount = 0
local lx,ly,lz = 0,0,0

setTimer (
	function ()
		if getElementData(getLocalPlayer(),"afk") == false then
			local hp = getElementHealth (getLocalPlayer())
			if hp > 0 then
				if isPedOnGround (getLocalPlayer()) then
					local cx,cy,cz = getCameraMatrix ()
					if cx == lx and cy == ly and cz == lz then
						afkCount = afkCount+1
						if afkCount >= 12 then
							setElementData (getLocalPlayer(),"afk",true)
							afkCount = 0
						end
					else
						afkCount = 0
					end
					lx,ly,lz = cx,cy,cz
				end
			end
		else
			local cx,cy,cz = getCameraMatrix ()
			if cx ~= lx or cy ~= ly or cz ~= lz then
				setElementData (getLocalPlayer(),"afk",false)
				afkCount = 0
				lx,ly,lz = cx,cy,cz
			end
		end
	end
,2500,0)]]

local lastClick = getTickCount()

addEventHandler ("onClientRender",getRootElement(),
	function ()
		local cTick = getTickCount ()
		if cTick-lastClick >= 600000 then
			if getElementData(getLocalPlayer(),"afk") == false then
				local hp = getElementHealth (getLocalPlayer())
				if hp > 0 then
					setElementData (getLocalPlayer(),"afk",true)
				end
			end
		end
	end
)

addEventHandler( "onClientRestore", getLocalPlayer(),
	function ()
		lastClick = getTickCount ()
		setElementData (getLocalPlayer(),"afk",false)
	end
)

addEventHandler( "onClientMinimize", getRootElement(),
	function ()
		--[[local cx,cy,cz = getCameraMatrix ()
		lx,ly,lz = cx,cy,cz
		afkCount = 0]]
		setElementData (getLocalPlayer(),"afk",true)
	end
)

addEventHandler( "onClientCursorMove", getRootElement( ),
    function ( x, y )
		lastClick = getTickCount ()
		if getElementData(getLocalPlayer(),"afk") == true then
			setElementData (getLocalPlayer(),"afk",false)
		end
    end
)

addEventHandler("onClientKey", getRootElement(), 
	function ()
		
		lastClick = getTickCount ()
		if getElementData(getLocalPlayer(),"afk") == true then
			--[[local cx,cy,cz = getCameraMatrix ()
			lx,ly,lz = cx,cy,cz
			afkCount = 0]]
			setElementData (getLocalPlayer(),"afk",false)
		end
	end
)

