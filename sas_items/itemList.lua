local screenX, screenY = guiGetScreenSize()
local sxF, syF = screenX/2, screenY/2
local showList = false
local scrollNum = 0
local maxShowed = 16
local ahFont = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 13)

function showItemList()
	if showList then
			dxDrawRectangle(sxF-300, syF-300, 600, 610, tocolor(0,0,0,140))
			dxDrawRectangle(sxF-300, syF-300, 600, 30, tocolor(0,0,0,170))
			dxDrawRectangle(sxF-300+10, syF-300+40, 580, 30, tocolor(0,0,0,170)) -- magyarázat
			if isInSlot(sxF-300+10, syF-300+530+20+10, 580, 40) then
				dxDrawRectangle(sxF-300+10, syF-300+530+20+10, 580, 40, tocolor(217, 83, 79,255)) -- kilépés
			else
				dxDrawRectangle(sxF-300+10, syF-300+530+20+10, 580, 40, tocolor(217, 83, 79,200))
			end
			dxDrawText("#7cc576ID", sxF-300+15, syF-300+40, 0, syF-300+40+30, tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
			dxDrawText("#7cc576Item név", sxF-300+15+140, syF-300+40, 0, syF-300+40+30, tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
			dxDrawText("See#7cc576MTA v3 - Itemlist", sxF-300+5,syF-300, 0,syF-300+30, tocolor(255,255,255,255), 1, ahFont, "left", "center", false,false,false,true)
			dxDrawText("Kilépés", sxF-300+10, syF-300+530+20+10, sxF-300+10+580, syF-300+530+20+10+40, tocolor(0,0,0,255), 1, ahFont, "center", "center", false,false,false,true)
			--exports['sas_system']:formComboRajzolas(sxF,syF, 80, 25, letrehozasInputok)
			local itemIDS = 0
			--for k, v in pairs( items ) do
				--itemIDS = itemIDS +1
			--end

			local elem = 0
			local pngNum = 0
			for k, v in pairs( items ) do
					itemIDS = itemIDS +1
					if (k > scrollNum and elem < maxShowed) then
						--if itemIDS ~= 95 or itemIDS ~= 100 or itemIDS ~= 101 or itemIDS ~= 104 or itemIDS ~= 105 or itemIDS ~= 106 or itemIDS ~= 107 then
							elem = elem + 1
							pngNum = itemIDS
							if elem < 9 then
								dxDrawRectangle(sxF-300+10, syF-300+40+(elem*60), 580, 30, tocolor(0,0,0,170))
							end
							if v.name == "No Item" or v.name == "No item" then
								pngNum = 0
							end

							dxDrawRectangle(sxF-300+10, syF-300+40+(elem*30), 580, 30, tocolor(0,0,0,100))
							dxDrawText(itemIDS, sxF-300+15+30, syF-300+40+(elem*30), 0, syF-300+40+30+(elem*30), tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
							dxDrawText(v.name, sxF-300+15+140, syF-300+40+(elem*30), 0, syF-300+40+30+(elem*30), tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
							dxDrawImage(sxF-300+10, syF-300+40+(elem*30), 30, 30, "files/items/"..pngNum..".png")
						--end
					end
				--end
			end
			exports['sas_system']:gorgetesRajzolas(sxF-300+600, syF-300, 5, 610, #items, maxShowed, scrollNum, tocolor(0, 0, 0, 255))
	end
end
addEventHandler("onClientRender", getRootElement(), showItemList)

bindKey("mouse_wheel_down", "down",
	function()
		if showList then
			if scrollNum < #items - maxShowed then
				scrollNum = scrollNum + 1
			end
		end
	end
)

bindKey("mouse_wheel_up", "down",
	function()
		if showList then
			if scrollNum > 0 then
				scrollNum = scrollNum - 1
			end
		end
	end
)

addCommandHandler("itemlist",
    function(cmd)
        if tonumber(getElementData(localPlayer, "adminlevel")) < 7 then return end

        if not showList then
            showList = true
        else
            showList = false
        end
    end
)

function exitClick(button, state)
	if button == "left" and state == "down" then
		if showList then
			if isInSlot(sxF-300+10, syF-300+530+20+10, 580, 40) then
				showList = false
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), exitClick)
