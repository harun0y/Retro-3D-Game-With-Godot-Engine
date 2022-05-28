extends Area

export var damage = 1

func set_damage(_damage: int):
	damage = _damage

func fire():
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("hurt"):
			body.hurt(damage, Vector3.ZERO)
