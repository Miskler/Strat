extends Control

func still_pressed():
	$"../Transition/Animation".play_backwards("def")

func in_menu_pressed():
	get_tree().network_peer = null
	$"../Transition/Animation".play_backwards("def")
	get_tree().change_scene("res://Scenes/Main Menu/Menu.tscn")
