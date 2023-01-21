extends Control


var search = true

signal ok()


func _ready():
	$Main/Scroll/Box/LineEdit.text = Global.settings["my_name"]


func exit():
	get_tree().quit()


func from_to_screen(from, to):
	var twee = create_tween().set_trans(Tween.TRANS_QUAD)
	twee.parallel()
	
	from.show()
	to.show()
	
	from.rect_position = $Main.rect_size / 2.0 - from.rect_pivot_offset
	to.rect_position.y = 6000
	
	twee.tween_property(from, "rect_position", Vector2(from.rect_position.x, -6000), 0.5)
	twee.tween_property(to, "rect_position", ($Main.rect_size / 2.0)-to.rect_pivot_offset, .5)
	
	#twee.play()
	
	yield(twee, "finished")
	
	from.hide()
	to.show()
	
	emit_signal("ok")


func stop_search():
	search = false
	from_to_screen($Main/Panel, $Main/Scroll)


func PVP_pressed():
	from_to_screen($Main/Scroll, $Main/Panel)
	yield(self, "ok")
	search = true
	$Request.request("http://"+Global.settings["py_adress"]+"/select_mode/PVP")


func request_completed(result, response_code, headers, body):
	if search:
		search = false
		
		var response = body.get_string_from_utf8()
		print(response)
		response = parse_json(response)
		if response != null and response.has("data"):
			Global.settings["adress"] = [response["data"].back()["adress"], response["data"].back()["port"]]
			Global.get_node("CanvasLayer/Transition").reset_screen("res://Scenes/Game.tscn")
		else:
			if response["error"]:
				$Main/Error/What.text = "Все игровые сервера заняты"
			else:
				$Main/Error/What.text = "Сервер не имеет такого режима игры"
			
			from_to_screen($Main/Panel, $Main/Error)
			
			yield(get_tree().create_timer(5), "timeout")
			
			from_to_screen($Main/Error, $Main/Scroll)


func name_user_changed(new_text):
	if new_text.length() > 2:
		Global.settings["my_name"] = new_text
