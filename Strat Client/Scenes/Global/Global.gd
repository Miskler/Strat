extends Node

var settings = {
	"rendering_range": 5,
	"my_name": "",
	"adress": ["", ""],
	"py_adress": "5.44.41.50:9999",
}


remote func game_event(countries, territory, requests, time, time_hou = 0, users:int = 0, count:int = 0):
	if get_node_or_null("/root/Game/Map") != null:
		get_node("/root/Game/Map").countries = countries
		get_node("/root/Game/Map").territory = territory
		
		get_node("/root/Game/Player/Camera/Interface/Control/Reqs/Box").visible = time > 0
		get_node("/root/Game/Player/Camera/Interface/Control/ListOfActions/Attack").visible = time > 0
		get_node("/root/Game/Player/Camera/Interface/Control/ListOfActions/Give").visible = time > 0
		
		get_node("/root/Game/Player/Camera/Interface/Control/Scroll").visible = time > 0 and get_node("/root/Game/Map").countries.has(Global.settings["my_name"])
		
		get_node("/root/Game/Player/Camera/Interface/Control/Reqs/Panel/Panel").visible = time <= 0
		get_node("/root/Game/Player/Camera/Interface/Control/ListOfActions/SelectPos").visible = time <= 0
		
		#print(time)
		if time <= 0:
			printt(time, abs(float(time))/abs(float(time_hou)))
			get_node("/root/Game/Player/Camera/Interface/Control/Reqs/Panel/Panel").event(users, count, abs(float(time)), abs(float(time_hou)))
			get_node("/root/Game/Player/Camera/Interface/Control/ListOfActions/ColorRect").rect_size.x = 118
		else:
			get_node("/root/Game/Player/Camera/Interface").reqs_event(requests)
			get_node("/root/Game/Player/Camera/Interface/Control/ListOfActions/ColorRect").rect_size.x = 224
		
		get_node("/root/Game/Map").render()

remote func game_user_dead(user_name):
	if get_node_or_null("/root/Game/Map") != null and Global.settings["my_name"] == user_name:
		$CanvasLayer/Main/Box/Title.text = "Поражение"
		$CanvasLayer/Main/Box/Empty.show()
		$CanvasLayer/Main/Box/Still.show()
		$"CanvasLayer/Main/Box/In Menu".show()
		
		$CanvasLayer/Transition/Animation.play("def")

remote func user_win(user_name):
	if get_node_or_null("/root/Game/Map") != null and Global.settings["my_name"] == user_name:
		$CanvasLayer/Main/Box/Title.text = "Победа"
		$CanvasLayer/Main/Box/Empty.show()
		$CanvasLayer/Main/Box/Still.show()
		$"CanvasLayer/Main/Box/In Menu".show()
		
		$CanvasLayer/Transition/Animation.play("def")

remote func game_start(countries, territory, ground):
	if get_node_or_null("/root/Game/Map") != null:
		print(ground.size())
		get_node("/root/Game/Map").ground = get_node("/root/Game/Map").interpretator(ground)
		get_node("/root/Game/Map").countries = countries
		get_node("/root/Game/Map").territory = territory
		
		get_node("/root/Game/Map").render()


func send_req(type:String, recipient, hou:int, del:bool = false):
	var dat = {
		"type": type,
		"how_many": hou,
		"recipient": recipient
	}
	
	rpc_id(1, "request", get_tree().get_network_unique_id(), dat, del)

func reset_scene(text, yeid, toscene):
	pass
