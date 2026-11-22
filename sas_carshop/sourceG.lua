sellVehicle = {
	-- ID, NÉV,Pénz,PP,limit if limit set to -1 if the car is limitless , logo or default

	{585,"Audi 80",12500,5000, -1, "audi"},
	{526, "Audi A3", 32500,10000, -1,"audi"},
	--{526, "Audi A8", 85000,11000, -1,"audi"},
	{533, "Audi R8 Spyder",1500000,28000, 0, "audi"},
	{580, "Audi RS4 Avant", 110000,18000, 25,"audi"},
	{602, "Audi Sport Quattro '83", 2550000,28500, 0,"audi"},
	{483, "Barkas B1000-1", 125000,1500, 450,"gta-sa"},
	{492, "BMW 5 Series F10", 540000,18000, 100,"bmw"},
	{421, "BMW 7 Series F01", 102500,11000, -1,"bmw"},
	{551, "BMW 750i e38", 15000,5000, -1,"bmw"},
	{551, "BMW M3 e46", 120000,14000, 30,"bmw"}, -- átírni
	{551, "BMW M5 e34", 1000000,21000, 20,"bmw"}, -- átírni
	{445, "BMW M5 e60", 115000,18000, 35,"bmw"},
	{491, "BMW M635 CSi e24", 1450000,25000, 0,"bmw"},
	{522, "BMW S1000",28570,6000, -1, "bmw"},
	{551, "BMW X5", 275000,15000, 120,"bmw"}, -- átírni
	{494, "Bugatti Chiron",2500000,40000, 0, "bugatti"},
	{415, "Bugatti Veyron SS", 1250000,35000, 0,"bugatti"},
	{551, "Chevrolet Bel Air", 800000,9000, 400,"chevrolet"}, -- átírni
	{544, "Chevrolet Camaro ZL1", 300000,18000, 18,"chevrolet"},
	{467, "Chevrolet Caprice '87", 50000,7000, 200,"chevrolet"},
	{542, "Chevrolet Chevelle '71", 2000,500, -1,"chevrolet"},
	{517, "Chevrolet Chevelle SS '67", 305000,18000, 22,"chevrolet"},
	{551, "Chevrolet Impala 64", 90000,15000, 40,"chevrolet"}, -- átírni
	{426, "Dodge Challenger SRT 8", 612000,25000, 0,"dodge"},
	{439, "Dodge Charger '69 R/T", 100000,8000, -1,"dodge"},
	{603, "Dodge Coronet 440", 120000,10000, -1,"dodge"},
	{554, "Dodge RAM 3500 HD.", 90000,8000, 80,"dodge"},
	{521, "Ducati Desmosedici RR", 28500,6000, 200,"ducati"},
	{555, "Ferrari 250 GTO", 4500000,30000, 4,"ferrari"},
	{411, "Ferrari 430 Scuderia", 475000,25000, 0,"Infernus"},
	{413, "Ford Econoline", 25000,3500, -1,"ford"},
	{543, "Ford F-150", 15500,4000, 500,"ford"},
	{401, "Ford Focus SVT", 300000,6000, 300,"ford"},
	{527, "Ford Mustang GT 2014", 180000,15000, 30,"ford"},
	{551, "Ford Pick Up Custom '51", 250000,18000, 20,"ford"}, -- átírni
	{551, "Ford Thunderbird '64", 785000,8500, 550,"ford"}, -- átírni
	{586, "Harley Davidson Fat Boy", 40000,3200, 400,"gta-sa"},
	{463, "Harley Davidson Knucklehead",30000,3200, 500, "gta-sa"},
	{551, "Honda Civic", 30000,13000, 70,"honda"}, -- átírni
	{462, "Honda Click", 700,300, -1,"honda"},
	{470, "Hummer H1", 340000,225000, 350,"gta-sa"},
	{500, "Jeep Wrangler", 240000,3000, 1000,"gta-sa"},
	{458, "Lada 2102", 3000,1100, -1,"lada"},
	{546, "Lada 2107", 3100,1100, -1,"intruder"},
	{451, "Lamborghini Huracan", 550000,25000, 18,"turismo"},
	{446, "Lampadati Toro", 12500,5000, -1,"squalo"},
	{429, "Lexus LFA", 333330,25000, -1,"lexus"},
	{409, "Lincoln Town Car", 1000000,9000, 60,"lincoln"},
	{551, "Lincoln Town Coupe", 350000,18000, 15,"lincoln"}, -- átírni
	{477, "Mazda RX-7", 127500,10000, 60,"mazda"},
	{506, "McLaren P1", 1200000,30000, 0,"mclaren"},
	{516, "Mercedes-Benz 300 SEL", 442000,18500, 300,"mercedes"},
	{438, "Mercedes-Benz E250 Estate", 500000,19500, 30,"mercedes"},
	{550, "Mercedes-Benz e420 w210", 140000,12000, 30,"mercedes"},
	{507, "Mercedes-Benz e500 w124", 200000,18000, -1,"mercedes"},
	{489, "Mercedes-Benz G65 AMG", 800000,22000, 0,"mercedes"},
	{503, "Mercedes-Benz SLS AMG", 900000,28000, 0,"mercedes"},
	{551, "Mitsubishi Lancer EVO X", 100000,19000, 60,"mitsubishi"}, -- átírni
	{551, "Nissan GT-R", 800000,28000, 30,"nissan"}, -- átírni
	{551, "Nissan Skyline R34 GT-R", 45000,10000, 60,"nissan"}, -- átírni
	{510, "Mountain Bike",12500,5000, -1, "mountain bike"},
	{488, "News Chopper",12500,5000, -1, "News Chopper"},
	{587, "Nissan GT-R", 12500,5000, -1,"euros"},
	{566, "Peugeot 406", 3250,2200, -1,"peugeot"},
	{475, "Plymouth Hemi 'Cuda '70",92500,12000, 65, "plymouth"},
	{402, "Pontiac Firebird", 135000,15000, 450,"buffalo"},
	{480, "Porsche 918 Spyder", 340000,28500, 65,"comet"},
	{579, "Range Rover Sport SC.", 110000,12000, 650,"land-rover"},
	{529, "Seat Leon", 12000,2100, 450,"seat"},
	{540, "Subaru Impreza WRX STI",170000,18500, 60, "subaru"},
	{551, "Toyota Supra US-Spec", 400000,18000, 34,"toyota"}, -- átírni
	{474, "Volkswagen Beetle 1973", 60000,12000, 130,"hermes"},
	{547, "Volkswagen Bora", 6000,1900, -1,"volkswagen"},
	{410, "Volkswagen Golf I",2500,5000, -1, "volkswagen"},
	{547, "Volkswagen Golf II",4000,5250, -1, "volkswagen"},
	{551, "Volkswagen Golf V GTI", 140000,13000, 60,"volkswagen"}, -- átírni
	{496, "Volkswagen Scirocco TSI", 60000,8000, 420,"volkswagen"},
	{452, "Wellcraft 38 Scarab KV",12500,5000, -1, "Speeder"},
	{502, "Wiesmann GT MF4-CS", 1240000,32000, 0,"wiesmann"},
}

function getVehicleShopCost(vehicleid)
	if allVehicleName[vehicleid] then
		for k, v in ipairs(sellVehicle) do
			if sellVehicle[k][1] == vehicleid then
				local cost = sellVehicle[k][3]
				return cost
			end
		end
	else
		return "Ismeretlen"
	end
end
