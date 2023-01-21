extends Control

var to = null

func reset_screen(to_sc):
	$"../Main/Box/Title".text = ""
	$"../Main/Box/Empty".hide()
	$"../Main/Box/Still".hide()
	$"../Main/Box/In Menu".hide()
	to = to_sc
	$Animation.play("def")

func animation_finished(anim_name):
	if to != null and to is String:
		get_tree().change_scene(to)
		to = null
		$Animation.play_backwards("def")
