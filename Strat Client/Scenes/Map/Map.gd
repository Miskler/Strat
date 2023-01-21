extends Node2D

onready var player = get_parent().get_node("Player/Camera")


var ground = {
	Vector2(0, 0): {
		"tile_name": "",
		"auto_tile": Vector2()
	}
}

var buildings = {
	Vector2(0, 0): {
		"tile_name": "",
		"auto_tile": Vector2()
	}
}

var territory = {
	Vector2(0, 0): {
		"tile_name": "",
		"auto_tile": Vector2()
	}
}

var countries = {
	#"Miskler": {
	#	"Gold": 0, #Игрок
	#	"Alliance": "Red",
	#	"Bot": false,
	#	"Territory": [
	#		Vector2(0, 0),
	#		Vector2(0, 0),
	#	]
	#}
}

func interpretator(map):
	
	var itog = map.duplicate(true)
	for i in map.keys():
		if i is Vector2:
			var all = {"standart": ["Grass", Vector2(0, 0), Vector2(1, 2)], "dead": ["Dead Grass", Vector2(0, 0), Vector2(1, 2)], "ice": ["Winter", Vector2(3, 0), Vector2(5, 0)]}
			
			itog[i]["auto_tile"] = Vector2(round(rand_range(all[itog[i]["tile_name"]][1].x, all[itog[i]["tile_name"]][2].x)), round(rand_range(all[itog[i]["tile_name"]][1].y, all[itog[i]["tile_name"]][2].y)))
			itog[i]["tile_name"] = all[itog[i]["tile_name"]][0]
		else:
			itog.erase(i)
	print(itog.size())
	return itog

var all = {"Blue": Color("0200ff"), "Green": Color("00ff16"), "Red": Color("ff0000"), "White": Color("ffffff"), "Yellow": Color("fdff00")}
func render(): #camera - принимает путь до отрисовываймой камеры, если пуст то отрисовывается все отновительно камеры игрока
	var ground_node = $Ground
	if ground_node.tile_set != null:
		var corners = [player.global_position - Vector2(1024 * player.zoom.x / 2, 600 * player.zoom.y / 2), player.global_position + Vector2(1024 * player.zoom.x / 2, 600 * player.zoom.y / 2)]
		
		corners[0] = ground_node.world_to_map(corners[0]) - Vector2(Global.settings["rendering_range"], Global.settings["rendering_range"])
		corners[1] = ground_node.world_to_map(corners[1]) + Vector2(Global.settings["rendering_range"], Global.settings["rendering_range"])
		
		#print(corners)
		#print(corners[1] - corners[0])
		
		for i in $Names.get_children():
			i.queue_free()
		
		for data_node in [[ground_node, ground], [$Buildings, buildings]]:#, [self, background]]:
			pod_rende(corners, data_node[0], data_node[1], data_node[1])
		$Countries.clear()
		for user_k in countries.keys():
			var user = countries[user_k]
			
			
			pod_rende(corners, $Countries, user["Territory"], territory)
			
			
			var user_node = $"*Sample".duplicate()
			user_node.show()
			
			var sizes = [(user_k.length()*6)+6, (str(user["Gold"]).length()*6)+6]
			user_node.rect_size.x = sizes.max()
			user_node.rect_pivot_offset = user_node.rect_size / 2.0
			
			user_node.modulate = all[user["Alliance"]]
			
			user_node.name = user_k
			
			user_node.get_node("User Name").text = user_k
			user_node.get_node("Gold").text = str(user["Gold"])
			
			var siz = [null, null, null, null] #Макс-X, Минимум-X, Макс-Y, Минимум-Y 
			
			#Проходим по циклу и ищем крайние точки
			for vector in user["Territory"]:
				if siz[0] == null or siz[0] > vector.x: # 3 > 2   -3 < -2
					siz[0] = vector.x
				if siz[1] == null or siz[1] < vector.x:
					siz[1] = vector.x
				
				if siz[2] == null or siz[2] > vector.y:
					siz[2] = vector.y
				if siz[3] == null or siz[3] < vector.y:
					siz[3] = vector.y
			
			#(0, 0) - (34, 29) = (-34, -29)/2 = (-17, -14.5) + (16, 16)
			#print("")
			user_node.rect_position = ((Vector2(siz[1], siz[3]) - Vector2(siz[0], siz[2])))/2.0
			#printt(user_node.rect_position, ((Vector2(siz[1], siz[3]) - Vector2(siz[0], siz[2])))/2.0)
			user_node.rect_position = ((Vector2(siz[0], siz[2])+user_node.rect_position)*$Countries.cell_size) + ($Countries.cell_size/2.0) #((3,3) - (1,1))/2.0 + (1,1)
			#printt(user_node.rect_position, siz)
			user_node.rect_position -= user_node.rect_pivot_offset
			
			if user["Bot"]:
				user_node.modulate.a = 0.7
			
			$Names.add_child(user_node)
func pod_rende(corners, tile_map, manual, dop_manual):
	for X in corners[1].x - corners[0].x:
		for Y in corners[1].y - corners[0].y:
			var tile_pos = Vector2(X, Y)+corners[0]
			if manual.has(tile_pos) and tile_map.tile_set.find_tile_by_name(dop_manual[tile_pos]["tile_name"]) != -1:
				tile_map.set_cell(tile_pos.x, tile_pos.y, tile_map.tile_set.find_tile_by_name(dop_manual[tile_pos]["tile_name"]), false, false, false, dop_manual[tile_pos]["auto_tile"])
