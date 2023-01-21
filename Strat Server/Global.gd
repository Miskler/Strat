extends Node

var main_settings = { #Создаем конфиг
	"py_adress": "5.44.41.50:9999",#"5.44.41.50:9999",
	"ip": "5.44.41.50",#"5.44.41.50",
	"wait_time": 5,
	"mode": "PVP",
}

var server_settings = {
	"port": 8000,
}

onready var main = get_node("/root/Main")


remote func request(user_id:int, data:Dictionary, del:bool = false):
	if user_id in main.users and main.wait >= 0 and data["recipient"] != main.users[user_id] and int(data["how_many"]) > 0:
		
		var user_data = main.requests
		if user_data.has(main.users[user_id]):
			user_data = user_data[main.users[user_id]]
		else:
			user_data[main.users[user_id]] = []
			user_data = user_data[main.users[user_id]]
		
		if del:
			if user_data.size() > 0:
				for i in user_data:
					if i["type"] == data["type"] and i["recipient"] == data["recipient"]:
						main.countries[main.users[user_id]]["Gold"] += data["how_many"]
						user_data.erase(i)
						return
		else:
			if user_data.size() > 0:
				for i in user_data:
					if i["type"] == data["type"] and i["recipient"] == data["recipient"]:
						if main.countries[main.users[user_id]]["Gold"] >= data["how_many"]:
							i["how_many"] += data["how_many"]
							main.countries[main.users[user_id]]["Gold"] -= data["how_many"]
							return
			
			if main.countries[main.users[user_id]]["Gold"] >= data["how_many"]:
				user_data.append(data)
				main.countries[main.users[user_id]]["Gold"] -= data["how_many"]



var ad = [["Blue", "Green", "Red", "White", "Yellow"], []]
remote func i_connect(id:int, user_name:String):
	if main.wait <= 0 and not id in main.users.keys() and not user_name in main.users.values():
		main.users[id] = user_name
		
		if ad[1].size() <= 0:
			ad[1] = ad[0].duplicate(true)
		
		main.users_no_spawn[user_name] = {
			"Gold": 0, #Игрок
			"Alliance": ad[1][0],
			"Bot": false,
			"Territory": []
		}
		ad[1].erase(ad[1][0])
		
		print("User \""+user_name+"\" ("+str(id)+") connected!")
		Global.rpc_id(id, "game_start", main.countries, main.territory, main.ground)
	else:
		print("User \""+user_name+"\" ("+str(id)+") not connected!")
		Global.rpc_id(id, "game_start", main.countries, main.territory, main.ground)



remote func select_spawn(id:int, position_spawn:Vector2):
	#Проверяем зарегистрирован ли пользователь и в каком состоянии игра
	if main.wait <= 0 and id in main.users.keys():
		print(1245)
		#Проверяем входит ли точка в границу
		if position_spawn.x >= 0 and position_spawn.y >= 0:
			print(1245)
			#Проверяем не выходит ли точка из границы
			if position_spawn.x <= main.map_size.x and position_spawn.y <= main.map_size.y:
				#Проверяем не занята ли эта точка
				if not position_spawn in main.territory:
					var dat
					
					#Удаляем предыдущее место
					if main.users[id] in main.users_no_spawn.keys():
						dat = main.users_no_spawn[main.users[id]].duplicate(true)
						main.users_no_spawn.erase(main.users[id])
					else:
						dat = main.countries[main.users[id]].duplicate(true)
						for i in dat["Territory"]:
							main.territory.erase(i)
						dat["Territory"] = []
						main.countries.erase(main.users[id])
					
					#Устанавливаем новое место
					main.countries[main.users[id]] = dat
					main.countries[main.users[id]]["Territory"].append(position_spawn)
					main.territory[position_spawn] = {
						"tile_name": dat["Alliance"],
						"auto_tile": Vector2(0, 0),
						"Owner": main.users[id] #null - ничейная
					}
					
					print("User \""+main.users[id]+"\" ("+str(id)+") select pos in - " + str(position_spawn) + ". Result - OK")
					return
	print("User \""+main.users[id]+"\" ("+str(id)+") select pos in - " + str(position_spawn) + ". Result - ERROR")
