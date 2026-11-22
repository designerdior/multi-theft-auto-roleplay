local screen = {guiGetScreenSize()}
local pTimer = {}
local toltve = 0
local showloading = false
local betoltendoObjektek = {
	{"wheel_gn1",1082},
	{"wheel_gn2",1085},
	{"wheel_gn3",1096},
	{"wheel_gn4",1097},
	{"wheel_gn5",1098},
	{"wheel_lr1",1077},
	{"wheel_lr2",1083},
	{"wheel_lr3",1078},
	{"wheel_lr4",1076},
	{"wheel_lr5",1084},
	{"wheel_sr1",1079},
	{"wheel_sr2",1075},
	{"wheel_sr3",1074},
	{"wheel_sr4",1081},
	{"wheel_sr5",1080},
	{"wheel_sr6",1073},
	{"wheel1",1025},
}

function startLoading(s)
	if s then
	--	showloading = true
	--	pTimer[getLocalPlayer()] = setTimer(function()
		--	toltve = toltve + 1
		--	--if toltve == #betoltendoObjektek then
			--	killTimer(pTimer[getLocalPlayer()])
				--showloading = false
				for i,c in ipairs(betoltendoObjektek) do
					if tostring(i) ~= tostring(c) then
						ChangeObjectModel(c[1],c[2],c[3])
					end
				end
		--	end
		--end--,#betoltendoObjektek * 20,#betoltendoObjektek)
	end
end

function load()
	startLoading(true)
end
addEventHandler("onClientResourceStart",getResourceRootElement(),load)

function ChangeObjectModel (filename,id)
	if id and filename then
		--if fileExists("files/wheels.txd") then
			txd = engineLoadTXD( "files/wheels.txd", true)
			engineImportTXD( txd, 1082 )
		--end
		if fileExists("files/"..filename..".dff") then
			dff = engineLoadDFF("files/"..filename..".dff", 0 )
			engineReplaceModel( dff, id )
		end
	end
end
