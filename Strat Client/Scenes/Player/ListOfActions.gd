extends Control

var p = Vector2()

func reset():
	self.set_global_position(get_global_mouse_position())
	p = get_node("/root/Game/Map/Countries").get_global_mouse_position()
	show()


func attack():
	var dat = calculations()
	printt("attack", dat[0], dat[1])
	Global.send_req("attack", dat[0], dat[1])
	hide()

func give():
	var dat = calculations()
	Global.send_req("give", dat[0], dat[1])
	hide()

func select_pos():
	Global.rpc("select_spawn", get_tree().get_network_unique_id(), get_node("/root/Game/Map/Countries").world_to_map(p))
	hide()



func calculations():
	var col = get_parent().get_parent().procent
	var iam = Global.settings["my_name"]
	
	if get_node("/root/Game/Map").countries.has(iam):
		printt(get_node("/root/Game/Map").countries[iam]["Gold"], col)
		col = (get_node("/root/Game/Map").countries[iam]["Gold"]/100.0)*col
	
	var pos = get_node("/root/Game/Map/Countries").world_to_map(p)
	
	if get_node("/root/Game/Map").territory.has(pos):
		pos = get_node("/root/Game/Map").territory[pos]["Owner"]
	else:
		pos = null
	
	return [pos, int(round(col))]
