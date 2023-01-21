extends Node


signal user_dead(user_name)


var users = {
	#1: "Server"
}


var ground = {
	#Vector2(): {
	#	"tile_name": "",
	#	"auto_tile": Vector2()
	#}
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

var territory = {
	#Vector2(0, 0): {
	#	"tile_name": "Red",
	#	"auto_tile": Vector2(0, 0),
	#	"Owner": "Miskler" #null - ничейная
	#}
}




var requests = {
	#"Miskler": [
	#	{
	#		"type": "give", #give, attack
	#		"recipient": "",
	#		"how_many": "" 
	#	}
	#]
}

var map_size = Vector2(200, 200)
var users_no_spawn = {}
var last = Vector2(0, 0)


func _ready():
	var cmd = OS.get_cmdline_args() #Проект -> Настройки проекта -> Редактор -> Основные аргументы запуска
	print(cmd)
	for command in range(cmd.size()):
		if cmd[command] in Global.main_settings.keys() and command < cmd.size()-1:
			Global.main_settings[cmd[command]] = cmd[command+1]
	print(Global.main_settings)
	
	randomize()
	
	get_tree().connect("network_peer_disconnected", self, "user_disconnect")
	
	restart()



func event():
	wait += 1
	
	var d = requests.duplicate(true)
	for users_req in d.keys():
		var delt = 0
		for i in range(requests[users_req].size()):
			var l = true
			if requests[users_req][i]["type"] == "give":
				if countries.has(requests[users_req][i]["recipient"]):
					countries[requests[users_req][i]["recipient"]]["Gold"] += d[users_req][i]["how_many"]
				else:
					countries[users_req]["Gold"] += d[users_req][i]["how_many"]
				l = false
				requests[users_req][i]["how_many"] = 0
			elif d[users_req][i]["type"] == "attack":
				if d[users_req][i]["recipient"] != null:
					for j in requests[d[users_req][i]["recipient"]]:
						if j["type"] == "attack" and j["recipient"] == users_req:
							print("")
							printt(j["how_many"], d[users_req][i]["how_many"])
							if j["how_many"] > d[users_req][i]["how_many"]:
								j["how_many"] -= d[users_req][i]["how_many"]
								d[users_req][i]["how_many"] = 0
							else:
								d[users_req][i]["how_many"] -= j["how_many"]
								j["how_many"] = 0
							printt(j["how_many"], d[users_req][i]["how_many"])
							#var k = [j["how_many"] - d[users_req][i]["how_many"], d[users_req][i]["how_many"] - j["how_many"]]
							#printt(j["how_many"], d[users_req][i]["how_many"], k)
							#j["how_many"] = k[0]
							#d[users_req][i]["how_many"] = k[1]
				
				for ter in countries[users_req]["Territory"].duplicate(true):
					if l:
						for dop in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
							if ground.has(ter+dop) and ((d[users_req][i]["recipient"] == null and not territory.has(ter+dop)) or (territory.has(ter+dop) and d[users_req][i]["recipient"] == territory[ter+dop]["Owner"])):
								if requests[users_req][i]["how_many"] <= 0:
									break
								
								countries[users_req]["Territory"].append(ter+dop)
								#countries[users_req]["Gold"] -= 1
								requests[users_req][i]["how_many"] -= 1
								if (territory.has(ter+dop) and d[users_req][i]["recipient"] == territory[ter+dop]["Owner"]):
									countries[d[users_req][i]["recipient"]]["Territory"].erase(ter+dop)
									territory[ter+dop]["Owner"] = users_req
									territory[ter+dop]["tile_name"] = countries[users_req]["Alliance"]
								else:
									territory[ter+dop] = {
										"tile_name": countries[users_req]["Alliance"],
										"auto_tile": Vector2(0, 0),
										"Owner": users_req #null - ничейная
									}
								
								delt += 1
			
			
			#if not l:
			#	printt(users_req, i)
			#	requests[users_req].pop_at(i)
		
		for i in requests[users_req]:
			if i["how_many"] <= 0:
				requests[users_req].erase(i)
	
	
	for g in users.keys():
		var i = users[g]
		countries[i]["Gold"] += clamp(countries[i]["Territory"].size() / 100, 1, 1000)
		if countries[i]["Territory"].size() <= 0:
			emit_signal("user_dead", i)
			Global.rpc("game_user_dead", i)
			countries.erase(i)
			users.erase(g)
	
	Global.rpc("game_event", countries, territory, requests, wait)
	
	if users.size() <= 1:
		if users.size() >= 1:
			Global.rpc("user_win", users.values()[0])
		
		$Timer.stop()
		yield(get_tree().create_timer(5.0), "timeout")
		
		get_tree().network_peer = null
		users = {}
		ground = {}
		countries = {}
		users_no_spawn = {}
		requests = {}
		wait = -Global.main_settings["wait_time"]
		$"Not Players".start()
		
		restart()

func restart():
	get_tree().network_peer = null
	
	var net = NetworkedMultiplayerENet.new()
	Global.server_settings["port"] = int(round(rand_range(1111, 9998)))
	
	net.create_server(Global.server_settings["port"])
	get_tree().network_peer = net
	
	
	ground = $Generation.generate(map_size.x, map_size.y)
	
	
	#ГЕНЕРИРУЕМ БОТОВ
	pass
	
	
	#СПАВНИМ БОТОВ
	var cou = $Generation.structure(map_size, users_no_spawn, 10)
	
	territory = cou[0]
	countries = cou[1]
	users_no_spawn = {}
	last = cou[3]
	
	
	$"Python Server".request("http://"+str(Global.main_settings["py_adress"])+"/iamserver/"+str(Global.main_settings["mode"])+"/"+Global.main_settings["ip"]+"/"+str(Global.server_settings["port"]))

onready var wait = -Global.main_settings["wait_time"]
func not_players():
	$"Python Server".request("http://"+str(Global.main_settings["py_adress"])+"/iamserver/"+str(Global.main_settings["mode"])+"/"+Global.main_settings["ip"]+"/"+str(Global.server_settings["port"]))
	
	wait += 1
	Global.rpc("game_event", countries, territory, requests, wait-1, Global.main_settings["wait_time"], users.size(), 2)
	
	if wait >= 0:
		if users.size() > 1:
			wait = 1
			$"Not Players".stop()
			$Timer.start()
			start()
		else:
			print("NOT START. Users len - "+str(users.size()))
			
			wait = -Global.main_settings["wait_time"]
			
			#$"Python Server".request("http://"+str(Global.main_settings["py_adress"])+"/deletserver/"+str(Global.main_settings["mode"])+"/"+Global.main_settings["ip"]+"/"+str(Global.server_settings["port"]))
			#$"Python Server".request("http://"+str(Global.main_settings["py_adress"])+"/iamserver/"+str(Global.main_settings["mode"])+"/"+Global.main_settings["ip"]+"/"+str(Global.server_settings["port"]))



func start():
	print("START")
	
	$"Python Server".request("http://"+str(Global.main_settings["py_adress"])+"/deletserver/"+str(Global.main_settings["mode"])+"/"+Global.main_settings["ip"]+"/"+str(Global.server_settings["port"]))
	
	
	var cou = $Generation.structure(map_size, users_no_spawn, 30, territory, last)
	
	territory = cou[0]
	for i in cou[1].keys():
		countries[i] = cou[1][i]
	users_no_spawn = cou[2]
	
	
	var new_users = {}
	for i in range(users.size()):
		if not users.values()[i] in users_no_spawn.keys():
			new_users[users.keys()[i]] = users.values()[i]
	users = new_users
	
	
	Global.rpc("game_start", countries, territory, ground)

func user_disconnect(id):
	if users.has(id):
		print("Player \""+str(users[id])+"\" ("+str(id)+") disconnect! Users now - "+str(users.size()-1))
		
		if countries.has(users[id]):
			if wait <= 0:
				for i in countries[users[id]]["Territory"]:
					territory.erase(i)
				countries.erase(users[id])
			else:
				countries[users[id]]["Bot"] = true
		elif users_no_spawn.has(users[id]):
			users_no_spawn.erase(users[id])
		
		users.erase(id)
