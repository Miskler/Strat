extends TextureButton

onready var cam = get_node("/root/Game/Player/Camera")

func _input(event):
	if Input.is_action_just_pressed("scale_plus"): _pressed()
	elif Input.is_action_just_pressed("scale_minus"): $"../Minus"._pressed()

func _pressed():
	cam.zoom.x = clamp(cam.zoom.x+1, 1, 8)
	cam.zoom.y = clamp(cam.zoom.y+1, 1, 8)
	$"../../ListOfActions".hide()
