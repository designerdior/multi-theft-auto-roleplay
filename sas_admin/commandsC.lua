commands =
			{
				-- level 1: Kezdő Admin
					{ "/auncuff", "/auncuff [Játékos]", "Leveszi a Játékosrol a bilincset" },
					{ "/pmute", "/pmute [Játékos]", "Játékos elnemitasa" },
				--	{ "/togooc", "/togooc", "OOC chat ki/be kapcsolasa" },
					--{ "/stogooc", "/stogooc", "OOC chat ki/be kapcsolasa csendben" },
					--{ "/disarm", "/disarm [Játékos]", "Elveszi az osszes fegyvert a Játékostol" },
					--{ "/freconnect", "/freconnect [Játékos]", "Ujracsatlakoztatja a Játékost" },
					{ "/sethp", "/sethp [Játékos] [Érték]", "beállítja a játékos életerejét." },
					{ "/setarmor", "/setarmor [Játékos] [uj armor]", "Pajzs beállítása a játékosnak" },
					{ "/setpskin", "/setpskin [Játékos] [skin id]", "Beallitja a Játékos kinezetet" },
					--{ "/slap", "/slap [Játékos]", " -15 eletel 'felpofozni egy Játékost'" },
					--{ "/hugeslap", "/hugeslap [Játékos]", "-50 elet 'felpofozni egy Játékost'" },
					{ "/recon", "/recon [Játékos]", "Játékos TV-zese" },
					{ "/stoprecon", "/stoprecon", "Admin TV kikapcsolasa" },
					{ "/pkick", "/pkick [Játékos] [indok]", "Játékos kickelese" },
					{ "/pban", "/pban [Játékos] [ora] [indok]", "Játékos bannolasa idore/vegtelenre" },
					{ "/unban", "/unban [karakter teljes neve]", "Unban karakter nev alapjan" },
					--{ "/unbanip", "/unbanip [ip]", "Unban IP alapjan" },
					--{ "/gotoplace", "/gotoplace [ls/sf/lv/pc]", "Teleport 4 helyhez" },
					{ "/jail", "/jail [Játékos] [perc] [indok]", "Admin Jail. Ha a perc tobb mint 999 akkor az vegtelen." },
					{ "/unjail", "/unjail [Játékos]", "Játékos kiszedese a bortonbol" },
					{ "/jailed", "/jailed", "Admin Jail-ben lévő játékosok listája" },
					{ "/goto", "/goto [Játékos]", "Teleportálás másik játékoshoz" },
					{ "/gethere", "/gethere [Játékos]", "Játékos magadhoz teleportálása" },
					{ "/sendto", "/gethere [Játékos] [dest. player]", "Játékos teleportálása egy másik játékoshoz" },
					{ "/freeze", "/freeze [Játékos]", "Játékos megfagyasztása" },
					{ "/unfreeze", "/unfreeze [Játékos]", "Játékos kiolvasztása" },
					{ "/mark", "/mark [név]", "Lementi az aktuális pozíciód" },
					{ "/gotomark", "/gotomark [név]", "teleportálás az adott helyre /mark [név]" },
					--{ "/makedonator", "/makedonator [Játékos] [level]", "A játékos kinevezése 'Támogató'-vá" },
					{ "/adminduty", "/adminduty", "Adminszolgálatba lépés, vagy kilépés" },
					--{ "/setmotd", "/setmotd [üzenet]", "Napi üzenet" },
					--{ "/setamotd", "/setamotd [Üzenet]", "Admin üzenet(Napi)" },
					--{ "/warn", "/warn [Játékos]", "3 figyelmeztettés utána  játékos bannolva lesz" },
					{ "/showinv", "/showinv [Játékos]", "A játékos táskájának ellenőrzése" },
					{ "/togmytag", "/togmytag", "Neved elrejtése, megjelenítése" },
					{ "/dropme", "/dropme", "Elrak téged a jelenlegi FREECAM pozicóira" },
					{ "/disappear", "/disappear", "Láthatattlanság ki/be kapcsolása" },
					--{ "/findalts", "/findalts [Játékos]", "A felhasználó karakterjei" },
				--	{ "/setlanguage", "/setlanguage [Játékos] [nyelv] [szintl]", "Nyelv beállítása a játékos számára. Tanulás" },
				--	{ "/dellanguage", "/dellanguage [Játékos] [nyelv]", "Nyelv törlése a játékos karakterjéből" },
				--	{ "/aunblindfold", "/aunblindfold [Játékos]", "unblindfold the player" },
					-- vehicle/*
				--	{ "/carlist", "/carlist", "Jármű nevek, színek mutattása" },
					{ "/unflip", "/unflip", "Kocsi talpra állítása" },
					--{ "/unlockcivcars", "/unlockcivcars", "Összes civil kocsi kinyitása" },
					{ "/oldcar", "/oldcar", "Az útolsó vezett jármű ID-je" },
					{ "/thiscar", "/thiscar", "Jelenleg vezett jármű ID-je" },
					{ "/gotocar", "/gotocar [id]", "Teleportálás az adott járműhöz" },
					{ "/getcar", "/getcar [id]", "Magadhoz teleportálod az adott kocsit" },
					{ "/nearbyvehicles", "/nearbyvehicles", "Összes jármű kijelzése 20-as körzetben" },
					{ "/respawnveh", "/respawnveh [id]", "Az adott jármű respawnolása" },
					{ "/respawnall", "/respawnall", "Összes jármű respawnolása" },
					{ "/respawnciv", "/respawnciv", "Összes civil(és munka) jármű respawnolása" },
					--{ "/findveh", "/findveh [név]", "retrieves the model for that vehicle name" },
					{ "/fixveh", "/fixveh [Játékos]", "Játékos járművének megjavítása" },
					--{ "/fixvehs", "/fixvehs", "Összes jármű megjavítása" },
					--{ "/fixvehis", "/fixvehis [Játékos]", "Járművek KÜLSÖ kinézetének javítása. Motor nem biztos hogy megjavul" },
					{ "/blowveh", "/blowveh [Játékos]", "Járékos kocsijának felrobbantása" },
				--	{ "/setcarhp", "/setcarhp [Játékos] [Érték]", "Jármű 'életét' átállítja 1000-re." },
					{ "/fuelveh", "/fuelveh [Játékos]", "Járékos kocsijának újra töltése" },
					{ "/fuelvehs", "/fuelvehs", "Összes kocsi megtankolása" },
					--{ "/setcolor", "/setcolor [Játékos] [szín 1] [szín 2]", "Játékos kocsijának szín váltása" },
					{ "/getcolor", "/getcolor [jármű]", "Jármű színének lekérdezése" },

					-- interior/*
					{ "/getpos", "/getpos", "Megtudhatod a jelenlegi helyzetted, interrior és dimenzió helyedet" },
					--{ "/x", "/x [érték]", "Növeli az X kordinátad az adott értékkel" },
				--	{ "/y", "/y [érték]", "Növeli az Y kordinátad az adott értékke" },
				--	{ "/z", "/z [érték]", "Növeli az Z kordinátad az adott értékke" },
					--{ "/set*", "/set[bármely kombináció] [kordináták]", "Kordiánták beállítása - Lehetséges kombinációk: x, y, z, xyz, xy, xz, yz" },
					{ "/nearbyinteriors", "/nearbyinteriors","Közeledben lévő interrior-ok" },
					{ "/getinteriorid", "/getinteriorid","Interrior ID lekérdezése"},

					-- election/*
				--	{ "/addcandidate", "/addcandidate", "Játékos hozzáadása a választási listához" },
				--	{ "/delcandidate", "/delcandidate", "Játékos törlése a választási listáról" },
					--{ "/showresults", "/showresults", "Választási eredmények mutattása" },

					-- factions/*


				--	{ "/resetbackup", "/resetbackup", "Rendőrségi erősítéskérő rendszer újraindítása" },
				--	{ "/resetassist", "/resetassist", "Sürgösségi asszisztens kérő rendszer újraindítása" },
				--	{ "/resettowbackup", "/resettowbackup", "Vontattó kérő rendszer újraindítása" },
				--	{ "/aremovespikes", "/aremovespikes", "Összes Stop'n'Stick rendszer 'felszedése'" },
				--	{ "/clearnearbytag", "/clearnearbytag", "Clears nearby tag" },

					{ "/changelock", "/changelock", "Jármű/interrior kulcs váltás" },
				--	{ "/restartgatekeepers", "/restartgatekeepers", "Gatekeepers resource újraindítása" },
				-- level 2: Admin
				--	{ "/superman", "/superman", "Superman aktiválása(KISZÉVE)" },
					{ "/gotohouse", "/gotohouse [id]", "Házhoz teleportálás" },
					-- vehicles
			--		{ "/createtext", "/createtext [szöveg]", "3D szöveg készítése" },
			--		{ "/nearbytexts", "/nearbytexts", "3D szövegek a közeledben" },
			--		{ "/deletetext", "/deletetext [ID]", "3D szöveg törlése" },

				-- level 3: Haladó Admin
				--	{ "/setweather", "/setweather", "Időjárás megváltoztattása" },
					--{ "/findip", "/findip [játékos/felhasználónév/ip]", "A játékos összes karakterjének mutattása" },

					-- vehicles

				--	{ "/addupgrade", "/addupgrade [Játékos] [fejlesztés ID]", "Játékos kocsijának fejlesztéser" },
				--	{ "/addpaintjob", "/addpaintjob [Játékos] [fejlesztés ID]", "Jármű átmatricizása" },
				--	{ "/resetupgrades", "/resetupgrades [Játékos]", "Összes tuning leszedése a járműről" },
					{ "/aunimpound", "/aunimpound [jármű id]", "Jármű kihozása a lefoglalt jármvek közül" },
				---	{ "/setvehtint", "/setvehtint [Játékos] [0- Leszed, 1- Hozzáad]", "Színárnyalat fel/le szerelése" },

					-- elevators
					{ "/addelevator", "/addelevator [interior] [dimenzió] [x] [y] [z]", "Lift készítése" },
					{ "/delelevator", "/delelevator [id]", "Lift törlése" },
					{ "/nearbyelevators", "/nearbyelevators", "Közelben lévő liftek mutattása" },
					{ "/toggleelevator", "/toggleelevator [id]", "Lift engedélyezése, tiltása" },



				-- level 4: Haladó Admin

					{ "/addatm", "/addatm", "ATM létrehozzása" },
					{ "/delatm", "/delatm [id]", "ATM törlése" },
					{ "/nearbyatms", "/nearbyatms", "Közeledben lévő ATM-ek" },
				--	{ "/bigears", "/bigears [Játékos]", "Nagy fülek ;>)" },
					--{ "/bigearsf", "/bigearsf [factionid]", "Nagy füle :>)" },

					-- paynspray/*
				--	{ "/addpaynspray", "/addpaynspray", "Új pay n spray készítése" },
				--	{ "/nearbypaynsprays", "/nearbypaynsprays", "Közledben lévő pay n sprays" },
				--	{ "/delpaynspray", "/delpaynspray [id]", "Adott pay n spray törlése" },

					-- phone/*
				--	{ "/addphone", "/addphone", "Köztelefon készítése" },
				--	{ "/nearbyphones", "/nearbyphones", "Köztelefonok a közeledben" },
				--	{ "/delphone", "/delphone [id]", "Köztelefon törlése" },

					-- interiors/*
				--	{ "/enableallelevators", "/enableallelevators", "Összes list engedélyezése" },

					{ "/addinterior", "/addinterior  [Interior ID] [TÍPUS] [ÁR] [NÉV]","Interrior készítése" },
					{ "/sellproperty", "/sellproperty","Interrior eladása" },
					{ "/delinterior", "/delproperty","Interrior törlése" },
					{ "/getinteriorid", "/getinteriorid [id]","Jelenlegi interrior mutatása" },
					{ "/setinteriorid", "/setinteriorid [id]","Interrior megváltozatatása" },
					{ "/getinteriorprice", "/getinteriorprice","Interrior árának megnézése" },
					{ "/setinteriorprice", "/setinteriorprice [ár]","Interrior árának megváltoztatása" },
				--	{ "/toggleinterior", "/toggleinterior [id]","Interrior engedélyezése, tiltása" },
				--	{ "/enableallinteriors", "/enableallinteriors","Összes interrior engedélyezése" },
					{ "/setinteriorexit", "/setinteriorexit","changes an interior exit marker" },
					{ "/setinteriorentrance", "/setinteriorentrance  [Interior ID]","Interrior bejárat megváltoztattása" },

					-- factions/*
					{ "/setfactionleader", "/setfactionleader [Játékos] [frakció id]", "játékos frakció leader-é való kinevezése" },
					{ "/setvehfaction", "/setfactionveh [jármű id] [frakció id]", "Frakció jármű beállítása" },
					{ "/setfactionrank", "/setfactionrank [Játékos] [rang]", "Játékos rangjának megváltoztattása" },

					-- fuelpoints/*
				--	{ "/addfuelpoint", "/addfuelpoint", "Új benzinkút készítése" },
			--		{ "/nearbyfuelpoints", "/nearbyfuelpoints", "Közeledben lévő bezinkútak" },
				--	{ "/delfuelpoint", "/delfuelpoint [id]", "Benzinkút törlése" },

					-- player/*
				--	{ "/reskick", "/reskick [szám]", "Kickeli a megadott számú játékosokat a szerverről" },
					--{ "/ck", "/ck [Játékos] [Halál indoka]", "állandóan megöli a karaktert, spawnol egy hullát a játékos helyén" },
				--	{ "/unck", "/unck [Játékos]", "'Állandó ölés' kikapcsolása" },
				--	{ "/bury", "/bury [Játékos]", "Eltemeti a játékost;Eltünik a hulla" },
					--{ "/givegun", "/givegun [Játékos] [fegyver id] [lőszer]", "fegyver adása a játékos részére" },
					{ "/setmoney", "/setmoney [Játékos] [összeg]", "Játékosnak való pénz beállítása az adott összegre" },
					{ "/givemoney", "/givemoney [Játékos] [összeg]", "Játékosnak való pénz adása" },
					{ "/resetcharacter", "/resetcharacter [Keresztnév_Vezetéknév]", "Karakter nullázása" },
					{ "/setvehlimit", "/setvehlimit [Játékos] [limit]", "Játékos kocsijának max sebessége." },
				-- level 5: Fő Admin
					-- player/*
					{ "/hideadmin", "/hideadmin", "Látható, nem látható admin státusz" },
				--	{ "/ho", "/ho [szöveg]", "Global OOC küldése ismeretlen adminként" },
			--		{ "/hw", "/hw [Játékos] [szöveg]", "Ismeretlenkéne való PM küldése" },
					{ "/makeadmin", "/makeadmin [Játékos] [rang]", "Játkéos kinevezése adminná" },
					{ "/giveitem", "/giveitem [Játékos] [targy id] [targy ertek]", "targy adasa, /itemlist a targy ID megtekintesehez" },
					{ "/changename", "/changename [Játékos] [uj karakter nev]", "megvaltoztatja a karakter nevet" },

					--faction

					{ "/makefaction", "/makefaction [típus] [név]", "Frakció készítése" },
					{ "/renamefaction", "/renamefaction [id] [új név]", "Frackió átnevezése" },
					{ "/setfaction", "/setfaction [id] [frackió ID]", "játékos frakcióba rakása" },
					{ "/delfaction", "/delfaction [id]", "Frakció törlése" },
					{ "/showfactions", "/showfactions", "Frakciók listája" },

					-- interior
					{ "/reloadinterior", "/reloadinterior [id]","Interrior újratöltése az adatbázisból" },
					{ "/setinteriorname", "/setinteriorname [newname]","Interriornév át állítása" },
					{ "/setfee", "/setfee [összeg]","Interrior belépési díjjának beállítása" },

					-- resource/*
					{ "/startres", "/startres [resource neve]", "Resource elindítása" },
					{ "/stopres", "/stopres [resource neve]", "Resource leállítása" },
					{ "/restartres", "/restartres [resource neve]", "Resource újraindítása" },
					{ "/rescheck", "/rescheck", "Ellenőrzi a jelenleg nem futó Resource-okat, és elindítja őket" },
				--	{ "/rcs", "/rcs", "check if the resource \"Resource-Keeper\" is running" },
					{ "/givelicense", "/givelicense [Játékos] [típús]", "Játékos számára engedély adás" },

					--vehicle
					{ "/veh", "/veh [model] [szín 1] [szín 2]", "Ideiglenes jármű készítése" },
					{ "/delveh", "/delveh [id]", "Jármű törlése(IDEIGLENES)" },
					{ "/delthisveh", "/delthisveh", "Az összes IDEIGLENES jármű törlése" },
					{ "/makeveh", "/makeveh", "Új 'állandó' jármű készítése" },
					{ "/makecivveh", "/makecivveh", "Új civil jármű készítése" },
}

local sx,sy = guiGetScreenSize()
local sxF, syF = sx/2, sy/2
local ahFont = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 13) or "default-bold"
local scrollNum = 0
local maxShowed = 16
local showAH = false

--letrehozasInputok = {"karakterszulinap", 1, -- Kombó azonosító, Jelenleg kiválasztott
	--{"Január", "Február", "Március", "Április", "Május", "Június", "Július", "Augusztus", "Szeptember", "Október", "November", "December"}
--}

bindKey ("m", "down",
function()
    showCursor( not isCursorShowing() )
end)

function showAdminHelpPanel()
	if showAH then
			dxDrawRectangle(sxF-300, syF-300, 600, 610, tocolor(0,0,0,140))
			dxDrawRectangle(sxF-300, syF-300, 600, 30, tocolor(0,0,0,170))
			dxDrawRectangle(sxF-300+10, syF-300+40, 580, 30, tocolor(0,0,0,170)) -- magyarázat
			if isInSlot(sxF-300+10, syF-300+530+20+10, 580, 40) then
				dxDrawRectangle(sxF-300+10, syF-300+530+20+10, 580, 40, tocolor(217, 83, 79,255)) -- kilépés
			else
				dxDrawRectangle(sxF-300+10, syF-300+530+20+10, 580, 40, tocolor(217, 83, 79,200))
			end
			dxDrawText("#7cc576Parancs", sxF-300+15, syF-300+40, 0, syF-300+40+30, tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
			dxDrawText("#7cc576Leírás", sxF-300+15+140, syF-300+40, 0, syF-300+40+30, tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
			dxDrawText("See#7cc576MTA v3 - Admin Commands", sxF-300+5,syF-300, 0,syF-300+30, tocolor(255,255,255,255), 1, ahFont, "left", "center", false,false,false,true)
			dxDrawText("Kilépés", sxF-300+10, syF-300+530+20+10, sxF-300+10+580, syF-300+530+20+10+40, tocolor(0,0,0,255), 1, ahFont, "center", "center", false,false,false,true)
			--exports['sas_system']:formComboRajzolas(sxF,syF, 80, 25, letrehozasInputok)
			local elem = 0
			for level, levelcmds in pairs( commands ) do
				if (level > scrollNum and elem < maxShowed) then
						elem = elem + 1
						if elem < 9 then
							dxDrawRectangle(sxF-300+10, syF-300+40+(elem*60), 580, 30, tocolor(0,0,0,170))
						end
						dxDrawRectangle(sxF-300+10, syF-300+40+(elem*30), 580, 30, tocolor(0,0,0,100))
						dxDrawText(commands[level][1], sxF-300+15, syF-300+40+(elem*30), 0, syF-300+40+30+(elem*30), tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
						dxDrawText(commands[level][3], sxF-300+15+140, syF-300+40+(elem*30), 0, syF-300+40+30+(elem*30), tocolor(255,255,255,255), 0.8, ahFont, "left", "center", false,false,false,true)
				end
			end
			exports['sas_system']:gorgetesRajzolas(sxF-300+600, syF-300, 5, 610, #commands, maxShowed, scrollNum, tocolor(0, 0, 0, 255))
	end
end
addEventHandler("onClientRender", getRootElement(), showAdminHelpPanel)

function ahPanelOpen()
	if not showAH then
		showAH = true
	elseif showAH then
		showAH = false
	end
end
addCommandHandler("ah", ahPanelOpen)

function exitClick(button, state)
	if button == "left" and state == "down" then
		if showAH then
			if isInSlot(sxF-300+10, syF-300+530+20+10, 580, 40) then
				showAH = false
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), exitClick)


bindKey("mouse_wheel_down", "down",
	function()
		if showAH then
			if scrollNum < #commands - maxShowed then
				scrollNum = scrollNum + 1
			end
		end
	end
)

bindKey("mouse_wheel_up", "down",
	function()
		if showAH then
			if scrollNum > 0 then
				scrollNum = scrollNum - 1
			end
		end
	end
)

function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(isInBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function fadeOff ()
	fadeCamera(true)
end
addCommandHandler("fadeoff", fadeOff)
