extends Panel

var hou = 0
var req
var type = "give"


signal bust(type, req, hou)
signal stop(type, req, hou)


func bust_pressed():
	emit_signal("bust", type, req, hou)

func stop_pressed():
	emit_signal("stop", type, req, hou)
