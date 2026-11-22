local carNamesTable = {
	{585, "Audi 80", "emperor"},
	{526, "Audi A3", "fortune"},
	{533, "Audi R8 Spyder", "feltzer"},
	{580, "Audi RS4 avant", "stafford"},
	{596, "Audi RS6 Police", "police ls"},
	{602, "Audi Sport Quattro '83", "alpha"},
	{483, "Barkas B1000-1", "camper"},
	{433, "Barracks", "barracks"},
	{492, "BMW 5 Series F10", "greenwood"},
	{421, "BMW 7 Series F01", "washington"},
	{551, "BMW 750i e38", "merit"},
	{420, "BMW M5 e34", "taxi"},
	{598, "BMW M5 e39 Police", "police lv"},
	{445, "BMW M5 e60", "admiral"},
	{491, "BMW M635 CSi e24", "virgo"},
	{522, "BMW S1000", "nrg-500"},
	{481, "BMX", "bmx"},
	{498, "Boxville", "boxville"},
	{494, "Bugatti Chiron", "hotring racer"},
	{415, "Bugatti Veyron SS", "cheetah"},
	{548, "Cargobob", "cargobob"},
	{544, "Chevrolet Camaro ZL1", "bullet"},
	{467, "Chevrolet Caprice '87", "oceanic"},
	{542, "Chevrolet Chevelle '71", "clover"},
	{517, "Chevrolet Chevelle SS '67", "majestic"},
	{490, "Chevrolet Suburban NNI", "fbi rancher"},
	{426, "Dodge Challenger SRT 8", "premier"},
	{439, "Dodge Charger '69 R/T", "stallion"},
	{603, "Dodge Coronet 440", "phoenix"},
	{554, "Dodge RAM 3500 HD.", "yosemite"},
	{521, "Ducati Desmosedici RR", "fcr-900"},
	{555, "Ferrari 250 GTO", "windsor"},
	{411, "Ferrari 430 Scuderia", "Infernus"},
	{407, "Fire Truck", "fire truck"},
	{413, "Ford Econoline", "pony"},
	{479, "Ford Explorer NAV", "regina"},
	{543, "Ford F-150", "sadler"},
	{528, "Ford F-150 NNI", "fbi truck"},
	{401, "Ford Focus SVT", "bravura"},
	{527, "Ford Mustang GT 2014", "cadrona"},
	{601, "Ford Taurus SHO NAV", "glendale damaged"},
	{586, "Harley Davidson Fat Boy", "wayfarer"},
	{463, "Harley Davidson Knucklehead", "freeway"},
	{462, "Honda Click", "faggio"},
	{470, "Hummer H1", "patriot"},
	{500, "Jeep Wrangler", "mesa"},
	{508, "Journey", "journey"},
	{458, "Lada 2102", "solair"},
	{546, "Lada 2107", "intruder"},
	{451, "Lamborghini Huracan", "turismo"},
	{446, "Lampadati Toro", "squalo"},
	{429, "Lexus LFA", "banshee"},
	{409, "Lincoln Town Car", "stretch"},
	{477, "Mazda RX-7", "zr-350"},
	{506, "McLaren P1", "super gt"},
	{516, "Mercedes-Benz 300 SEL", "nebula"},
	{438, "Mercedes-Benz E250 Estate", "cabbie"},
	{550, "Mercedes-Benz e420 w210", "sunrise"},
	{507, "Mercedes-Benz e500 w124", "elegant"},
	{489, "Mercedes-Benz G65 AMG", "rancher"},
	{503, "Mercedes-Benz SLS AMG", "Hotring Racer 3"},
	{510, "Mountain Bike", "mountain bike"},
	{488, "News Chopper", "News Chopper"},
	{587, "Nissan GT-R", "euros"},
	{562, "Nissan Skyline R34 GT-R", "Hotring Racer 2"},
	{597, "Opel Astra H Police", "police sf"},
	{566, "Peugeot 406", "tahoma"},
	{475, "Plymouth Hemi 'Cuda '70", "sabre"},
	{497, "Police Maverick", "police maverick"},
	{402, "Pontiac Firebird", "buffalo"},
	{480, "Porsche 918 Spyder", "comet"},
	{505, "Rancher Lure", "rancher lure"},
	{579, "Range Rover Sport SC.", "huntley"},
	{453, "Reefer", "reefer"},
	{468, "Sanchez", "sanchez"},
	{529, "Seat Leon", "willard"},
	{540, "Subaru Impreza WRX STI", "vincent"},
	{531, "Tractor", "tractor"},
	{408, "Trashmaster", "trashmaster"},
	{454, "Tropic", "tropic"},
	{456, "Vapid Benson", "yankee"},
	{474, "Volkswagen Beetle 1973", "hermes"},
	{547, "Volkswagen Bora", "primo"},
	{410, "Volkswagen Golf I", "manana"},
	{547, "Volkswagen Golf II", "Club"},
	{496, "Volkswagen Scirocco TSI", "blista compact"},
	{452, "Wellcraft 38 Scarab KV", "Speeder"},
	{502, "Wiesmann GT MF4-CS", "Hotring Racer 2"},
}


function getVehicleNames(id)
	if id then
		if tonumber(id) >= 400 and tonumber(id) <= 611 then
			for k,v in ipairs(carNamesTable) do
				if tonumber(id) == carNamesTable[k][1] then
					return carNamesTable[k][2]
				end
			end
		else
			outputChatBox("Kocsi IDk csak 400-tól 600-ig elérhetőek.")
		end
	end
end

function getVehicleNamesByString(defaultName)
	if defaultName then
		for k,v in ipairs(carNamesTable) do
			if defaultName == carNamesTable[k][3] then
				return carNamesTable[k][2]
			end
		end
	end
end


function getCarNameByCommand(_,_, id)
	--getVehicleNames(tonumber(id))
	outputChatBox(getVehicleNames(tonumber(id)))
end
addCommandHandler("getcarname", getCarNameByCommand)
