extends Spatial

var missile1 = preload("res://source/enemies/enemy stuff/Missile.tscn")
var missile2 = preload("res://source/enemies/enemy stuff/Missile.tscn")

func fireMissiles():
	var missile1_ins = missile1.instance()
	var missile2_ins = missile2.instance()

	get_parent().get_parent().get_parent().add_child(missile1_ins)
	get_parent().get_parent().get_parent().add_child(missile2_ins)

	missile1_ins.global_transform = global_transform
	missile2_ins.global_transform = $point.global_transform 

	missile1_ins.speed = 7
	missile2_ins.speed = 6

