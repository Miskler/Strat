extends TextureButton

onready var cam = get_node("/root/Game/Player/Camera")

func _pressed():
	cam.zoom.x = clamp(cam.zoom.x-1, 1, 8)
	cam.zoom.y = clamp(cam.zoom.y-1, 1, 8)
	$"../../ListOfActions".hide()
