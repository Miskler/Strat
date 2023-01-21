extends Node



func generate(width:int = 100, height:int = 100, settings:Dictionary = {}, seed_map = null): #Генерирует только образ карты, возращает итог
	var til = {}
	
	var noise = OpenSimplexNoise.new()
	if seed_map == null:
		noise.seed = randi()
	else:
		noise.seed = seed_map
	
	if settings.has("octaves"):
		noise.octaves = settings["octaves"]
	else:
		noise.octaves = 4
	
	if settings.has("period"):
		noise.period = settings["period"]
	else:
		noise.period = 15
	
	if settings.has("lacunarity"):
		noise.lacunarity = settings["lacunarity"]
	else:
		noise.lacunarity = 1.5
	
	if settings.has("persistence"):
		noise.persistence = settings["persistence"]
	else:
		noise.persistence = 0.75
	
	for x in range(width):
		til[x] = {}
		for y in range(height):
			var dar = noise.get_noise_2d(x, y)
			
			#print(dar)
			
			if dar > 0.0:
				til[Vector2(x, y)] = {"tile_name": "ice"}
			elif dar > -0.1:
				til[Vector2(x, y)] = {"tile_name": "dead"}
			else:
				til[Vector2(x, y)] = {"tile_name": "standart"}
	
	return til


func structure(size_map:Vector2, manual:Dictionary = {"Miskler": {}}, distance:int = 0, map:Dictionary = {}, last = null): #Генерирует структуру по заранее заготовленной инструкции с возможностью повторения несколько раз
	var dop_manual = manual.duplicate(true)
	
	if manual.size() > 0:
		for x in range(size_map.x):
			for y in range(size_map.y):
				var yes = false
				
				if (last == null or last.distance_to(Vector2(x, y)) > distance) and not Vector2(x, y) in map.keys():
					yes = true
				
				if yes == true:
					last = Vector2(x, y)
					
					var did = round(rand_range(0, manual.size()-1))
					while map.has(manual.keys()[did]):
						did = round(rand_range(0, manual.size()-1))
					
					map[Vector2(x, y)] = {
						"tile_name": manual[manual.keys()[did]]["Alliance"],
						"auto_tile": Vector2(0, 0),
						"Owner": manual.keys()[did] #null - ничейная
					}
					dop_manual[manual.keys()[did]]["Territory"].append(Vector2(x, y))
					
					map[manual.keys()[did]] = {}
					
					map[manual.keys()[did]] = {Vector2(x, y): manual.keys()[did]}
					
					manual.erase(manual.keys()[did])
					if manual.size() <= 0:
						return [map, dop_manual, manual, last]
					#elif manual[manual.keys()[did]].size() <= 0:
					#	manual.erase(manual.keys()[did])
	
	return [map, dop_manual, manual, last]
