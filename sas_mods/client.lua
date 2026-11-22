local screen = {guiGetScreenSize()}
local pTimer = {}
local toltve = 0
local showloading = false
local betoltendoObjektek = {
	{"objs/bank",4600},
	{"objs/statue_v3",1337},
	{"objs/statue_v3stair",1339},
	{"objs/benzinkut_alap",5489},
	{"objs/benzinkut_alap",5489},
	{"objs/benzinkut_alap",5489},
	{"objs/benzinkut",5409},
	{"objs/vh",4101},
	{"objs/vh2",4103},
	{"objs/mall_base",3997},
	{"objs/plaza",3980},
	{"objs/club",6404},
	{"objs/showroom",16642},
	{"objs/eszaki",5853},
	{"objs/uszo",1974},
	{"objs/temple",5999},
	{"objs/emelo_block",2061},
	{"objs/emelo_kar",1277},
	{"objs/kanna",1329},
	{"objs/small",7588},
	{"objs/seec",13722},
	{"objs/seec",13831},
	{"objs/mci",5418},
	{"objs/cellphone",7079},
	{"objs/auto",6369},
	{"objs/phouse",13756},
	{"objs/cine",16010},
	-- lods
	{"objs/plazalod",4044},
	{"objs/mci_lod",5531},
	{"objs/seeclod",13759},
	{"objs/clublod",6410},
	{"objs/vh_lod1",4105},
	{"objs/vh_lod2",4104},
	{"objs/templelod",6000},
	{"objs/phouse_lod",13879},
	-- vehs
	{"vehs/infernus",411},
	{"vehs/supergt",506},
	{"vehs/admiral",445},
	{"vehs/alpha",602},
	{"vehs/ambulan",416},
	--{"vehs/banshee",429},
	{"vehs/barracks",433},
	{"vehs/blistac",496},
	{"vehs/bmx",481},
	{"vehs/boxville",498},
	{"vehs/bravura",401},
	{"vehs/buffalo",402},
	{"vehs/bullet",541},
	{"vehs/bus",431},
	{"vehs/cabbie",438},
	{"vehs/cadrona",527},
	{"vehs/camper",483},
	{"vehs/cargobob",548},
	{"vehs/cheetah",415},
	{"vehs/clover",542},
	{"vehs/club",589},
	{"vehs/comet",480},
	{"vehs/copcarsf",597},
	{"vehs/copcarvg",598},
	{"vehs/copmitsu",596},
	{"vehs/elegant",507},
	{"vehs/euros",587},
	--{"vehs/emperor",585}, -- offos
	{"vehs/faggio",462},
	{"vehs/fbiranch",490},
	{"vehs/fbitruck",528},
	{"vehs/fcr900",521},
	{"vehs/feltzer",533},
	{"vehs/fire",407},
	{"vehs/fortune",526}, -- offos
	{"vehs/freeway",463},
	{"vehs/turismo",451},
	--{"vehs/greenwood",492},
	{"vehs/heli",497},
	{"vehs/hermes",474},
	{"vehs/hotrina",494},
	{"vehs/hotrinb",502},
	{"vehs/hotring",503},
	{"vehs/huntley",579},
	{"vehs/intruder",546},
	{"vehs/landstal",400},
	{"vehs/majestic",517},
	{"vehs/manana",410},
	{"vehs/merit",551},
	{"vehs/mesa",500},
	{"vehs/moonbeam",418},
	{"vehs/mtbike",510},
	--navevo
	{"vehs/nebula",516},
	{"vehs/nrg500",522},
	{"vehs/oceanic",467},
	{"vehs/patriot",470},
	{"vehs/phoenix",603},
	{"vehs/pony",413},
	{"vehs/premier",426},
	--{"vehs/primo",547}, -- offos
	{"vehs/rancher",489},
	{"vehs/rancher2",490},
	{"vehs/reefer",453},
	{"vehs/rustler",476},
	{"vehs/sabre",475},
	{"vehs/sadlshit",605},
	{"vehs/sanchez",468},
	{"vehs/sentinel",405},
	{"vehs/solair",458},
	{"vehs/speeder",452},
	{"vehs/stafford",580},
	{"vehs/stallion",439},
	{"vehs/stretch",409},--offos
	--{"vehs/sunrise",550},
	{"vehs/tahoma",566},
	{"vehs/taxi",420},
	{"vehs/towtruck",525},
	{"vehs/trash",408},
	--tropic
	--vcnmav
	{"vehs/vincent",540},
	{"vehs/yankee",456},
}


function startLoading(s)
	if s then
		for i,c in ipairs(betoltendoObjektek) do
			if tostring(i) ~= tostring(c) then
				ChangeObjectModel(c[1],c[2],c[3])
			end
		end
	end
end

function ChangeObjectModel (filename,id)
	if id and filename then
		if fileExists(filename..".txd") then
			txd = engineLoadTXD( filename..".txd", true)
			engineImportTXD( txd, id )
		end
		if fileExists(filename..".dff") then
			dff = engineLoadDFF( filename..".dff", 0)
			engineReplaceModel( dff, id )
		end
		if fileExists(filename..".col") then
			col = engineLoadCOL( filename..".col" )
			engineReplaceCOL( col, id )
		end
	end
end

--4044
function load()
	startLoading(true)
	removeWorldModel(7448,999999,0,0,0) --lod
	removeWorldModel(1522,999999,0,0,0) --lod
	removeWorldModel(4003,999999,0,0,0) --lod
	removeWorldModel(4002,999999,0,0,0) --lod
	removeWorldModel(4102,999999,0,0,0) --lod
	removeWorldModel(5681,999999,0,0,0) --lod
end
addEventHandler("onClientResourceStart",getResourceRootElement(),load)
