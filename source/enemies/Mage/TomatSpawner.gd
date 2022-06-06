extends Spatial

var tomat2 = preload("res://source/enemies/tomat.tscn")
var tomat3 = preload("res://source/enemies/tomat.tscn")

func spawnTomats():
	var tomat2_ins = tomat2.instance()
	var tomat3_ins = tomat3.instance()

	get_parent().get_parent().add_child(tomat2_ins)
	get_parent().get_parent().add_child(tomat3_ins)

	tomat2_ins.global_transform = global_transform 
	tomat3_ins.global_transform = $point.global_transform

