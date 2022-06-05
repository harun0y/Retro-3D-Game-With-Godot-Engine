extends Spatial

var bullet = preload("res://source/enemies/magician/magician/Bullet.tscn")

var bodies_to_exclude = []
export var damage = 15
export var speed = 50

func set_damage(_damage: int):
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	var bullet_inst = bullet.instance()
	bullet_inst.set_bodies_to_exclude(bodies_to_exclude)
	get_tree().get_root().add_child(bullet_inst)
	bullet_inst.global_transform = global_transform
	bullet_inst.impact_damage = damage
	bullet_inst.speed = speed
