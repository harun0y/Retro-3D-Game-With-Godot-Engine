extends Area

class_name HitBox

signal hurt

func hurt(damage: int):
	emit_signal("hurt", damage)
	print("selam")
