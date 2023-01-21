extends KinematicBody2D

var speed = Vector2(400, 400)

var vec = Vector2()

func _process(delta):
	if Input.is_action_pressed("to_map") and not $Camera/Interface/Control/ListOfActions.visible:
		$Camera/Interface/Control/ListOfActions.reset()
	
	if Input.is_action_just_pressed("attack free"):
		Global.send_req("attack", null, 10)
	
	
	if Input.is_action_pressed("D"):
		vec.x = speed.x
		$Camera/Interface/Control/ListOfActions.hide()
	elif Input.is_action_pressed("A"):
		vec.x = -speed.x
		$Camera/Interface/Control/ListOfActions.hide()
	else:
		vec.x = 0
	
	if Input.is_action_pressed("W"):
		vec.y = -speed.y
		$Camera/Interface/Control/ListOfActions.hide()
	elif Input.is_action_pressed("S"):
		vec.y = speed.y
		$Camera/Interface/Control/ListOfActions.hide()
	else:
		vec.y = 0
	
	vec = move_and_slide(vec)
