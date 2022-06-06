extends Sprite3D

onready var health_manager = get_parent().get_node("HealthManager")

func _process(delta):
	scale.x = scale.x * (health_manager.cur_health / health_manager.max_health)
