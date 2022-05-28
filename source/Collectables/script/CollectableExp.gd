extends Spatial

export var value = 10

func _ready():
	pass # Replace with function body.

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.experience += value
		queue_free()
