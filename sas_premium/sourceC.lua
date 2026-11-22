local sx, sy = guiGetScreenSize()
local premiumShopOpened = false
local currentTab = 1
local premiumInformation = false

-- selector
local tabNames = {
	{"Fegyverek/Töltények"},
	{"Egyedi Prémium fegyverek (Skines)"},
	{"Speciális Itemek/Kártyák"},
	{"Mester könyvek"},
	{"Drogok"},
	{"Pénz vásárlás"},
	{"Blueprint"}
}

-- counter
local selectedItem = nil
local countSelector = false
local wantedCount = 1
local invitingText = ""

-- fonts
local Roboto = dxCreateFont("files/Roboto.ttf", 10)
local RobotoSized = dxCreateFont("files/Roboto.ttf", 20)
local RobotoL = dxCreateFont("files/RobotoL.ttf", 10)
local RobotoLSized = dxCreateFont("files/RobotoL.ttf", 20)

-- scroll
local maxShow = 12
local scrollData = 0
local scrollData2 = 0
local scrollDataBlueprint = 0

local weaponItems = {
	-- ItemID, ItemNév, ItemDarab, ItemÉrték, ItemLeirás, PP, Countable
	{92, "Flashbang", 1, 1, "Flashbang.", 500, false},
	{93, "Molotov koktél", 1, 1, "Molotov koktél.", 500, false},
	{94, "Füst gránát", 1, 1, "Füst gránát a tökéletes taktikai fegyver..", 500, false},
	{69, "Kés", 1, 1, "Egy fegyvernek minősülő kés.", 2500, false},
	{75, "Colt-45", 1, 1, "Egy Colt-45-ös.", 2500, false},
	{81, "Uzi", 1, 1, "Uzi géppisztoly.", 3500, false},
	{82, "MP5", 1, 1, "MP5-ös fegyver.", 3500, false},
	{77, "Desert Eagle pisztoly", 1, 1, "Nagy kaliberű Desert Eagle pisztoly.", 3500, false},
	{83, "TEC-9", 1, 1, "TEC-9-es gépfegyver", 4500, false},
	{76, "Hangtompítós Colt-45", 1, 1, "Egy Colt-45-ös hangtompítóval szerelve.", 4500, false},
	{78, "Sörétes puska", 1, 1, "Nagy kaliberű sörétes puska.", 4500, false},
	{84, "AK-47", 1, 1, "AK-47-es gépfegyver.", 5500, false},
	{85, "M4", 1, 1, "M4-es gépfegyver.", 5500, false},
	{86, "Vadász puska", 1, 1, "Vadász puska a pontos és határozott lövéshez.", 6500, false},
	{79, "Rövid csövű sörétes pusk", 1, 1, "Nagy kaliberű sörétes puska levágott csővel", 8000, false},
	{80, "SPAZ-12 taktikai sörétes puska", 1, 1, "SPAZ-12 taktikai sörétes puska elit fegyver.", 10500, false},
	{73, "Katana", 1, 1, "Ősi japán ereklye.", 15000, false},
	{87, "Mesterlövész", 1, 1, "Mesterlövész puska.", 16000, false},
	{108, "5x9mm-es töltény", 1, 1, "Colt-45, Desert Eagle 5x9mm-es töltény", 10, true},
	{109, "AK-47-es töltény", 1, 1, "AK-47-es töltény", 10, true},
	{111, "Kis gépfegyver töltények", 1, 1, "Kis gépfegyver töltények (UZI, MP5, TEC9)", 10, true},
	{112, "M4-es gépfegyver töltény", 1, 1, "M4-es gépfegyver töltény", 5, true},
	{113, "Sörétes töltény", 1, 1, "Sörétes töltény", 5, true},
	{110, "Vadászpuska lőszer", 1, 1, "Hosszú Vadászpuska töltény", 10, true}
}

local skinnedWeapons = {
	{279, "Camo knife", 1, 1, "Terep mintás kés", 10000, false},
	{280, "Rust knife", 1, 1, "Rozsdás kés", 10000, false},
	{281, "Carbon knife", 1, 1, "Carbonból készült kés", 10000, false},
	{271, "Camo Desert Eagle", 1, 1, "Terep mintás Desert Eagle pisztoly.", 12500, false},
	{275, "Camo MP-5", 1, 1, "Camo MP-5-ös.", 12500, false},
	{278, "Winter MP-5", 1, 1, "Winter MP-5-ös.", 13000, false},
	{283, "Camo TEC-9", 1, 1, "Terep mintás TEC-9.", 13500, false},
	{272, "Gold Desert Eagle", 1, 1, "Arany Desert Eagle pisztoly", 14000, false},
	{277, "Hotline Miami MP-5", 1, 1, "Hotline Miami MP-5-ös fegyver.", 14500, false},
	{285, "Winter TEC-9", 1, 1, "Winter style TEC-9", 14500, false},
	{266, "Winter AK-47", 1, 1, "Winter Camo AK-47", 15000, false},
	{265, "Camo AK-47", 1, 1, "Terep mintás AK-47", 15000, false},
	{264, "Digit AK-47", 1, 1, "Digit camo AK-47", 15000, false},
	{276, "Gold MP-5", 1, 1, "Gold MP-5-ös fegyver.", 15000, false},
	{269, "Silver AK-47", 1, 1, "Ezüst AK-47-es", 15000, false},
	{270, "Hello AK-47", 1, 1, "Pink Camo AK-47", 15000, false},
	{282, "Bronze TEC-9", 1, 1, "Bronz TEC-9-es gépfegyver.", 15500, false},
	{284, "Gold TEC-9", 1, 1, "Arany TEC-9-es gépfegyver.", 16000, false},
	{267, "Gold AK-47", 1, 1, "Arany AK-47 ver. 1", 17000, false},
	{268, "Gold AK-47", 1, 1, "Arany AK-47 ver. 2", 17000, false},
	{274, "Camo Sniper", 1, 1, "Camo Sniper", 32000, false},
	{273, "Winter Sniper", 1, 1, "Winter Camo Sniper", 33000, false},
}

local specialItems = {
	{124, "Benzines kanna", 1, 1, "Benzines kanna", 50, false},
	{188, "Instant Üzemanyag Kártya", 1, 1, "S lőn, teli a tank ha kocsiban ülsz.", 100, false},
	{152, "Eü. doboz", 1, 1, "Egészségügyi doboz", 100, false},
	{162, "PPSnack", 1, 1, "Minden ami tápláló, ebben megtalálható", 100, false},
	{187, "Instant Fix Kártya",  1, 1, "Amikor egy isteni erő újraéleszti az autódat, amiben ülsz.", 200, true},
	{189, "Istant Gyógyítás", 1, 1, "S lőn, egy isteni csoda felsegít téged.", 200, true},
	{147, "Gyógyszer", 1, 1, "Életmentő kapszula", 300, false},
	{148, "Vitamin", 1, 1, "Fő az egészség", 300, false},
	{119, "Fegyverengedély", 1, 1, "Fegyverengedély", 4000, false},
}

local masterBooks = {
	{234, "A fegyvermester: A hangtompítós Colt-45", 1, 1, "-", 2000, false},
	{239, "A fegyvermester: M4", 1, 1, "-", 2100, false},
	{237, "A fegyvermester: MP5", 1, 1, "-", 2400, false},
	{241, "A fegyvermester: Sörétes puska", 1, 1, "-", 2500, false},
	{235, "A fegyvermester: Desert Eagle", 1, 1, "-", 2600, false},
	{238, "A fegyvermester: AK-47", 1, 1, "-", 2600, false},
	{242, "A fegyvermester: Taktikai sörétes puska", 1, 1, "-", 2700, false},
	{240, "A fegyvermester: Vadász-Mesterlövész puska", 1, 1, "-", 2800, false},
	{233, "A fegyvermester: Colt-45", 1, 1, "-", 3000, false},
	{243, "A fegyvermester: A lefűrészelt sörétes", 1, 1, "-", 4050, false},
	{236, "A fegyvermester: UZI & TEC-9", 1, 1, "-", 4100, false}
}

local drugs = {
	{64, "Szárított marihuána", 1, 1, "Szárított marihuána", 500, false},
  {16, "Kokain", 1, 1, "Tiszta kokain por.", 500, false},
	{17, "Heroin", 1, 1, "Heroin por.", 600, false},
}

local moneyTable = {
	{1, "10 000 $", 1, 1, "", 3000, false, 10000},
  {2, "100 000 $", 1, 1, "", 15000, false, 100000},
	{3, "500 000 $", 1, 1, "", 30000, false, 500000},
	{4, "1 000 000 $", 1, 1, "", 50000, false, 1000000},
}

local bluePrints = {
	{298, "Blueprint: Cserepes növény: Mák", 1, 1, "", 2000, false},
  {298, "Blueprint: Cserepes növény: Kokacserje", 2, 1, "", 2000, false},
	{298, "Blueprint: Cserepes növény: Kender", 3, 1, "", 2000, false},
	{298, "Blueprint: Szárított marihuána", 4, 1, "", 2000, false},
	{298, "Blueprint: Füves cigi", 5, 1, "", 2000, false},
  {298, "Blueprint: Kokain", 6, 1, "", 2000, false},
	{298, "Blueprint: Heroin por", 7, 1, "", 2000, false},
	{298, "Blueprint: Heroinos fecskendő", 8, 1, "", 2000, false},
	{298, "Blueprint: Colt-45", 9, 1, "", 2000, false},
	{298, "Blueprint: AK-47", 10, 1, "", 2000, false},
	{298, "Blueprint: Sörétes puska", 11, 1, "", 2000, false},
	{298, "Blueprint: Vadászpuska", 12, 1, "", 2000, false},
	{298, "Blueprint: UZI", 13, 1, "", 2000, false},
	{298, "Blueprint: TEC-9", 14, 1, "", 2000, false},
	{298, "Blueprint: Kés", 15, 1, "", 2000, false},
}

function premiumShopOpen()
	if not premiumInformation and not countSelector then
		if not premiumShopOpened then
			premiumShopOpened = true
		else
			premiumShopOpened = false
			currentTab = 1
			scrollData = 0
			scrollData2 = 0
		end
	end
end
bindKey("F7", "down", premiumShopOpen)

function premiumShop()
	if premiumShopOpened and not countSelector then
		if not premiumInformation then
			-- basic things
			exports.sas_system:addV3logo(sx/2-128/2, sy/2-530/2-128, true, 0)
			dxDrawRectangle(sx/2-825/2, sy/2-506/2, 830, 515, tocolor(0,0,0,200))
			dxDrawRectangle(sx/2-825/2, sy/2-506/2, 830, 35, tocolor(0,0,0,255))
			drawTextWithBorder(formatNumber(getElementData(localPlayer, "pp"), " ").." #32b3efPP", 1, sx/2-825/2, sy/2+530/2,0,0, tocolor(0, 0, 0, 255), tocolor(255, 255, 255, 255), 1, 1, Roboto, "left", "top", false, false,false, true)

			if isInSlot(sx/2-825/2+825-65, sy/2-506/2+520,65,25) then
				dxDrawRectangle(sx/2-825/2+825-65, sy/2-506/2+520,65,25, tocolor(217, 83, 79, 200))
			else
				dxDrawRectangle(sx/2-825/2+825-65, sy/2-506/2+520,65,25, tocolor(217, 83, 79, 150))
			end
			dxDrawText("Kilépés", sx/2-825/2+825-65, sy/2-506/2+520, sx/2-825/2+825, sy/2-506/2+545 ,tocolor(0,0,0,200), 0.55, RobotoSized, "center", "center")

			-- select tab buttons
			if isInSlot(sx/2-825/2+550, sy/2-515/2+5,275 ,35) then
				if currentTab < 7 then
					dxDrawRectangle(sx/2-825/2+550, sy/2-515/2+5,275 ,35, tocolor(124, 197, 118, 200))
				end
			elseif isInSlot(sx/2-825/2, sy/2-515/2+5,275 ,35) then
				if currentTab > 1 then
					dxDrawRectangle(sx/2-825/2, sy/2-515/2+5,275 ,35, tocolor(124, 197, 118, 200))
				end
			end

			dxDrawText(tabNames[currentTab][1], sx/2-825/2+275, sy/2-515/2+5,sx/2-825/2+550, sy/2-515/2+35 ,tocolor(255,255,255,255), 0.55, RobotoLSized, "center", "center")
			if currentTab <= 6 then
				dxDrawText(tabNames[currentTab+1][1], sx/2-825/2+550, sy/2-515/2+5,sx/2-825/2+825, sy/2-515/2+35 ,tocolor(255,255,255,255), 0.55, RobotoLSized, "center", "center")
			end
			if currentTab > 1 then
				dxDrawText(tabNames[currentTab-1][1], sx/2-825/2, sy/2-515/2+5,sx/2-825/2+275, sy/2-515/2+35 ,tocolor(255,255,255,255), 0.55, RobotoLSized, "center", "center")
			end



			-- pp information
			if isInSlot(sx/2+825/2-170+5, sy/2-530/2-20,170,25) then
				dxDrawRectangle(sx/2+825/2-170+5, sy/2-530/2-20,170,25, tocolor(124, 197, 118, 200))
			else
				dxDrawRectangle(sx/2+825/2-170+5, sy/2-530/2-20,170,25, tocolor(124, 197, 118, 150))
			end
			dxDrawText("Prémium információ", sx/2+825/2-170+5, sy/2-530/2-20, sx/2+825/2-170+5+170, sy/2-530/2-20+25, tocolor(0,0,0,200), 0.55, RobotoSized, "center", "center")
			-- panels
			if currentTab == 1 then
				local counter = 0
			  for k , v in ipairs(weaponItems) do
			   	if (k > scrollData and counter < maxShow) then
			    	counter = counter + 1
						if counter %2 == 0 then
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,220))
						else
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,100))
						end
						dxDrawImage(sx/2-825/2+5,sy/2-515/2+(counter*40)+2, 36, 36, ":sas_items/files/items/"..v[1]..".png")
						dxDrawText(v[2].. " #598ED7("..v[5]..")", sx/2-825/2+5+41,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)
						dxDrawText("Ár: "..formatNumber(v[6], " ").. " #598ED7PP", sx/2+250-10,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)

						-- button
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 200))
						else
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 150))
						end
						dxDrawText("Vásárlás", sx/2+330, sy/2-515/2+(counter*40)+7, sx/2+330+65, sy/2-515/2+(counter*40)+7+25, tocolor(0,0,0,200), 1, Roboto, "center", "center")
					end
				end
				-- scrollbar
				exports.sas_system:gorgetesRajzolas(sx/2+825/2, sy/2-505/2, 5, 515, #weaponItems, maxShow, scrollData, tocolor(0, 0, 0, 255))
			elseif currentTab == 2 then
				local counter = 0
			  for k , v in ipairs(skinnedWeapons) do
			   	if (k > scrollData2 and counter < maxShow) then
			    	counter = counter + 1
						if counter %2 == 0 then
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,220))
						else
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,100))
						end
						dxDrawImage(sx/2-825/2+5,sy/2-515/2+(counter*40)+2, 36, 36, ":sas_items/files/items/"..v[1]..".png")
						local leiras = " #598ED7("..v[5]..")"

						dxDrawText(v[2].. " #598ED7("..v[5]..")", sx/2-825/2+5+41,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)
						dxDrawText("Ár: "..formatNumber(v[6], " ").. " #598ED7PP", sx/2+250-10,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)

						-- button
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 200))
						else
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 150))
						end
						dxDrawText("Vásárlás", sx/2+330, sy/2-515/2+(counter*40)+7, sx/2+330+65, sy/2-515/2+(counter*40)+7+25, tocolor(0,0,0,200), 1, Roboto, "center", "center")
					end
				end
				-- scrollbar
				exports.sas_system:gorgetesRajzolas(sx/2+825/2, sy/2-505/2, 5, 515, #skinnedWeapons, maxShow, scrollData2, tocolor(0, 0, 0, 255))
			elseif currentTab == 3 then
				local counter = 0
			  for k , v in ipairs(specialItems) do
			   --	if (k > scrollData and counter < maxShow) then
			    	counter = counter + 1
						if counter %2 == 0 then
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,220))
						else
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,100))
						end
						dxDrawImage(sx/2-825/2+5,sy/2-515/2+(counter*40)+2, 36, 36, ":sas_items/files/items/"..v[1]..".png")
						dxDrawText(v[2].. " #598ED7("..v[5]..")", sx/2-825/2+5+41,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)
						dxDrawText("Ár: "..formatNumber(v[6], " ").. " #598ED7PP", sx/2+250-10,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)

						-- button
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 200))
						else
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 150))
						end
						dxDrawText("Vásárlás", sx/2+330, sy/2-515/2+(counter*40)+7, sx/2+330+65, sy/2-515/2+(counter*40)+7+25, tocolor(0,0,0,200), 1, Roboto, "center", "center")
					--end
				end
				-- scrollbar
				exports.sas_system:gorgetesRajzolas(sx/2+825/2, sy/2-505/2, 5, 515, #specialItems, maxShow, scrollData, tocolor(0, 0, 0, 255))
			elseif currentTab == 4 then
				local counter = 0
				for k , v in ipairs(masterBooks) do
					--if (k > scrollData and counter < maxShow) then
						counter = counter + 1
						if counter %2 == 0 then
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,220))
						else
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,100))
						end

						local leiras = " #598ED7("..v[5]..")"
						if string.len(v[5]) < 3 then
							leiras = ""
						end

						dxDrawImage(sx/2-825/2+5,sy/2-515/2+(counter*40)+2, 36, 36, ":sas_items/files/items/"..v[1]..".png")
						dxDrawText(v[2]..""..leiras, sx/2-825/2+5+41,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)
						dxDrawText("Ár: "..formatNumber(v[6], " ").. " #598ED7PP", sx/2+250-10,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)

						-- button
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 200))
						else
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 150))
						end
						dxDrawText("Vásárlás", sx/2+330, sy/2-515/2+(counter*40)+7, sx/2+330+65, sy/2-515/2+(counter*40)+7+25, tocolor(0,0,0,200), 1, Roboto, "center", "center")
					--end
				end
				-- scrollbar
				exports.sas_system:gorgetesRajzolas(sx/2+825/2, sy/2-505/2, 5, 515, #masterBooks, maxShow, scrollData, tocolor(0, 0, 0, 255))
			elseif currentTab == 5 then
				local counter = 0
				for k , v in ipairs(drugs) do
					--if (k > scrollData and counter < maxShow) then
						counter = counter + 1
						if counter %2 == 0 then
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,220))
						else
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,100))
						end

						local leiras = " #598ED7("..v[5]..")"
						if string.len(v[5]) < 3 then
							leiras = ""
						end

						dxDrawImage(sx/2-825/2+5,sy/2-515/2+(counter*40)+2, 36, 36, ":sas_items/files/items/"..v[1]..".png")
						dxDrawText(v[2]..""..leiras, sx/2-825/2+5+41,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)
						dxDrawText("Ár: "..formatNumber(v[6], " ").. " #598ED7PP", sx/2+250-10,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)

						-- button
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 200))
						else
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 150))
						end
						dxDrawText("Vásárlás", sx/2+330, sy/2-515/2+(counter*40)+7, sx/2+330+65, sy/2-515/2+(counter*40)+7+25, tocolor(0,0,0,200), 1, Roboto, "center", "center")
				--end
				end
				-- scrollbar
				exports.sas_system:gorgetesRajzolas(sx/2+825/2, sy/2-505/2, 5, 515, #drugs, maxShow, scrollData, tocolor(0, 0, 0, 255))
			elseif currentTab == 6 then
				local counter = 0
				for k , v in ipairs(moneyTable) do
				--	if (k > scrollData and counter < maxShow) then
						counter = counter + 1
						if counter %2 == 0 then
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,220))
						else
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,100))
						end

						local leiras = " #598ED7("..v[5]..")"
						if string.len(v[5]) < 3 then
							leiras = ""
						end

						dxDrawImage(sx/2-825/2+5,sy/2-515/2+(counter*40)+2, 36, 36, "files/items/money"..v[1]..".png")
						dxDrawText(v[2], sx/2-825/2+5+41,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)
						dxDrawText("Ár: "..formatNumber(v[6], " ").. " #598ED7PP", sx/2+250-10,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)

						-- button
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 200))
						else
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 150))
						end
						dxDrawText("Vásárlás", sx/2+330, sy/2-515/2+(counter*40)+7, sx/2+330+65, sy/2-515/2+(counter*40)+7+25, tocolor(0,0,0,200), 1, Roboto, "center", "center")
					--end
				end
				-- scrollbar
				exports.sas_system:gorgetesRajzolas(sx/2+825/2, sy/2-505/2, 5, 515, #drugs, maxShow, scrollData, tocolor(0, 0, 0, 255))
			elseif currentTab == 7 then
				local counter = 0
				for k , v in ipairs(bluePrints) do
					if (k > scrollDataBlueprint and counter < maxShow) then
						counter = counter + 1
						if counter %2 == 0 then
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,220))
						else
							dxDrawRectangle(sx/2-825/2,sy/2-515/2+(counter*40), 825, 40, tocolor(0,0,0,100))
						end


						dxDrawImage(sx/2-825/2+5,sy/2-515/2+(counter*40)+2, 36, 36, ":sas_items/files/items/"..v[1]..".png")
						dxDrawText(""..v[2], sx/2-825/2+5+41,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)
						dxDrawText("Ár: "..formatNumber(v[6], " ").. " #598ED7PP", sx/2+250-10,sy/2-515/2+(counter*40)+2, 0, sy/2-515/2+(counter*40)+2+36, tocolor(255,255,255,255), 1, Roboto, "left", "center",false,false,false,true)

						-- button
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 200))
						else
							dxDrawRectangle(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25, tocolor(124, 197, 118, 150))
						end
						dxDrawText("Vásárlás", sx/2+330, sy/2-515/2+(counter*40)+7, sx/2+330+65, sy/2-515/2+(counter*40)+7+25, tocolor(0,0,0,200), 1, Roboto, "center", "center")
					end
				end
				-- scrollbar
				exports.sas_system:gorgetesRajzolas(sx/2+825/2, sy/2-505/2, 5, 515, #bluePrints, maxShow, scrollDataBlueprint, tocolor(0, 0, 0, 255))
			end
		else
			-- premium information panel
			dxDrawImage(sx/2-623/2,sy/2-479/2, 623, 479, "files/ppinfo.png")
			if isInSlot(sx/2+623/2-65, sy/2+479/2+5,65,25) then
				dxDrawRectangle(sx/2+623/2-65, sy/2+479/2+5,65,25, tocolor(217, 83, 79, 200))
			else
				dxDrawRectangle(sx/2+623/2-65, sy/2+479/2+5,65,25, tocolor(217, 83, 79, 150))
			end
			dxDrawText("Kilépés", sx/2+623/2-65, sy/2+479/2+5,sx/2+623/2, sy/2+479/2+30 ,tocolor(0,0,0,200), 0.55, RobotoSized, "center", "center")
		end
	end
	if countSelector then
		--wantedCount = invitingText
		if string.len(invitingText) >= 1 then
			wantedCount = invitingText
		end
		local priceOfItem = tonumber(wantedCount)*selectedItem[6]
		dxDrawRectangle(sx/2-365/2,sy/2-90,365, 180, tocolor(0,0,0,200))
		dxDrawText("Vásárlás: "..selectedItem[2], sx/2-365/2, sy/2-115, sx/2-365/2+365, 0, tocolor(255,255,255,255), 0.7, RobotoSized, "center", "top")
		dxDrawText("Mennyiség: "..tonumber(wantedCount).. " db\nEgységár: "..selectedItem[6].."\nÖsszesen: "..priceOfItem.."\n#7cc576Add meg a mennyiséget a billentyűzeteddel!", sx/2-365/2, sy/2-120, sx/2-365/2+365, sy/2-90+180, tocolor(255,255,255,255), 0.55, RobotoLSized, "center", "center",false,false,false,true)

		if isInSlot(sx/2-365/2+75,sy/2-90+135,205,35) then
			dxDrawRectangle(sx/2-365/2+75,sy/2-90+135,205,35, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(sx/2-365/2+75,sy/2-90+135,205,35, tocolor(124, 197, 118,150))
		end
		dxDrawText("Vásárlás", sx/2-365/2+75,sy/2-90+135, sx/2-365/2+280,sy/2-90+170, tocolor(255,255,255,255), 0.6, RobotoSized, "center", "center",false,false,false,true)
	end
end
addEventHandler("onClientRender", getRootElement(), premiumShop)

function buttonClicks(button, state)
	if premiumShopOpened then
		if button == "left" and state == "down" then
			if not countSelector and not premiumInformation then
				if isInSlot(sx/2-825/2+825-65, sy/2-506/2+520,65,25) then
					premiumShopOpened = false
					currentTab = 1
					scrollData = 0
					scrollData2 = 0
				end
			end
			if not countSelector then
				if isInSlot(sx/2+825/2-170+5, sy/2-530/2-20,170,25) then
					if not premiumInformation then
						premiumInformation = true
					end
				elseif isInSlot(sx/2+623/2-65, sy/2+479/2-20+25,65,25) then
					if premiumInformation then
						premiumInformation = false
					end
				-- select Tabs
				elseif isInSlot(sx/2-825/2+550, sy/2-515/2+5,275 ,35) then
					if currentTab < 7 then
						currentTab = currentTab + 1
						playSound("files/switchoption.mp3")
					end
				elseif isInSlot(sx/2-825/2, sy/2-515/2+5,275 ,35) then
					if currentTab > 1 then
						currentTab = currentTab - 1
						playSound("files/switchoption.mp3")
					end
				end
				-- buy buttons

				if currentTab == 1 then -- weapons
					local counter = 0
					for k , v in ipairs(weaponItems) do
					  if (k > scrollData and counter < maxShow) then
					   	counter = counter + 1
							if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
								selectedItem = v
								countSelector = true
								playSound("files/prompt.mp3")
							end
						end
					end
				elseif currentTab == 2 then
					local counter = 0
					for k , v in ipairs(skinnedWeapons) do
					  if (k > scrollData2 and counter < maxShow) then
					   	counter = counter + 1
							if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
								selectedItem = v
								countSelector = true
								playSound("files/prompt.mp3")
							end
						end
					end
				elseif currentTab == 3 then
					local counter = 0
					for k , v in ipairs(specialItems) do
					  counter = counter + 1
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							selectedItem = v
							countSelector = true
							playSound("files/prompt.mp3")
						end
					end
				elseif currentTab == 4 then
					local counter = 0
					for k , v in ipairs(masterBooks) do
					  counter = counter + 1
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							selectedItem = v
							countSelector = true
							playSound("files/prompt.mp3")
						end
					end
				elseif currentTab == 5 then
					local counter = 0
					for k , v in ipairs(drugs) do
					  counter = counter + 1
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							selectedItem = v
							countSelector = true
							playSound("files/prompt.mp3")
						end
					end
				elseif currentTab == 6 then
					local counter = 0
					for k , v in ipairs(moneyTable) do
					  counter = counter + 1
						if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
							selectedItem = v
							countSelector = true
							playSound("files/prompt.mp3")
						end
					end
				elseif currentTab == 7 then
					local counter = 0
					for k , v in ipairs(bluePrints) do
						if (k > scrollDataBlueprint and counter < maxShow) then
						  counter = counter + 1
							if isInSlot(sx/2+330, sy/2-515/2+(counter*40)+7, 65,25) then
								selectedItem = v
								countSelector = true
								playSound("files/prompt.mp3")
							end
						end
					end
				end
			end

			if countSelector then
				local priceOfItem = tonumber(wantedCount)*selectedItem[6]
				if isInSlot(sx/2-365/2+75,sy/2-90+135,205,35) then
					if getElementData(localPlayer, "pp") >= priceOfItem then
						if not selectedItem[8] then
							if not selectedItem[7] and tonumber(wantedCount) > 1 then
								return exports.sas_hud:addNotification("Ebből az itemből egyszerre csak egyet vehetsz!", "error")
							end
							triggerServerEvent("giveItem", localPlayer, localPlayer, selectedItem[1], selectedItem[3], wantedCount, 0)
							triggerServerEvent("buyItemOnServer", localPlayer, localPlayer, priceOfItem)
							exports.sas_hud:addNotification("Sikeres vásárlás!", "success")
							playSound("files/promptaccept.mp3")
							countSelector = false
							selectedItem = nil
							premiumShopOpened = false
							invitingText = ""
							wantedCount = 1
						else
							if not selectedItem[7] and tonumber(wantedCount) > 1 then
								return exports.sas_hud:addNotification("Ebből az itemből egyszerre csak egyet vehetsz!", "error")
							end
							triggerServerEvent("buyMoneyOnServer", localPlayer, localPlayer, priceOfItem, selectedItem[8])
							exports.sas_hud:addNotification("Sikeres vásárlás!", "success")
							playSound("files/promptaccept.mp3")
							countSelector = false
							selectedItem = nil
							premiumShopOpened = false
							invitingText = ""
							wantedCount = 1
						end
					else
						exports.sas_hud:addNotification("Nincs elég prémiumpontod!", "error")
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), buttonClicks)


function countModification(character)
	if countSelector then
		local newText = invitingText .. character

		if tonumber(newText) then
			if tonumber(newText) >= 1 and not string.find(newText, "e") and tonumber(newText) <= 1000 then
				invitingText = newText
			end
		end

	end
end
addEventHandler("onClientCharacter", getRootElement(), countModification)

function leaveFromCountSelector(button, state)
	if button == "backspace" and state then
		if countSelector then
			if tonumber(wantedCount) <= 9 then
				countSelector = false
				selectedItem = nil
				premiumShopOpened = true
				invitingText = ""
				wantedCount = 1
			else
				if string.len(invitingText) >= 1 then
					invitingText = string.sub(invitingText, 1, string.len(invitingText)-1)
				end
			end
		end
	end
end
addEventHandler("onClientKey", getRootElement(), leaveFromCountSelector)

bindKey("mouse_wheel_down", "down",
    function()
        if premiumShopOpened then
					if currentTab == 1 then
	            if scrollData < #weaponItems - maxShow then
	                scrollData = scrollData + 1
	            end
					elseif currentTab == 2 then
							if scrollData2 < #skinnedWeapons - maxShow then
									scrollData2 = scrollData2 + 1
							end
					elseif currentTab == 7 then
							if scrollDataBlueprint < #bluePrints - maxShow then
									scrollDataBlueprint = scrollDataBlueprint + 1
							end
					end
        end
    end
)

bindKey("mouse_wheel_up", "down",
    function()
        if premiumShopOpened then
					if currentTab == 1 then
						if scrollData then
	            if scrollData > 0 then
	                scrollData = scrollData - 1
	            end
						end
					elseif currentTab == 2 then
						if scrollData2 then
	            if scrollData2 > 0 then
	                scrollData2 = scrollData2 - 1
	            end
						end
					elseif currentTab == 7 then
						if scrollDataBlueprint then
	            if scrollDataBlueprint > 0 then
	                scrollDataBlueprint = scrollDataBlueprint - 1
	            end
						end
					end
        end
    end
)

------------
-- assets --
------------

function isInSlot(xS,yS,wS,hS)
    if(isCursorShowing()) then
        XY = {guiGetScreenSize()}
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
        if(dobozbaVan(xS,yS,wS,hS, cursorX, cursorY)) then
            return true
        else
            return false
        end
    end
end


function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
    if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
        return true
    else
        return false
    end
end

function formatNumber(amount, spacer)
	if not spacer then
		spacer = ","
	end

	amount = math.floor(amount)

	local left, num, right = string.match(tostring(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. (num:reverse():gsub("(%d%d%d)", "%1" .. spacer):reverse()) .. right
end

function drawTextWithBorder(text, offset, x, y, w, h, borderColor, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
	for offsetX = -offset, offset do
		for offsetY = -offset, offset do
			dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), x + offsetX, y + offsetY, w + offsetX, h + offsetY, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
		end
	end

	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end
