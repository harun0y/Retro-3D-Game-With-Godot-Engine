extends StaticBody

export(String, "drslayer", "hslayer", "HR sword") var sword_type

func _ready():
	$Mesh/KaolSwords.visible = false

func destroy():
	$Mesh/chest.visible = false
	$CollisionShape.disabled = true
	$Graphics/dustParticles.emitting = true
	$Graphics/woodParticles.emitting = true
	$Mesh/KaolSwords.visible = true
	get_node("Mesh/KaolSwords/" + sword_type).visible = true
	$Mesh/AnimationPlayer.play("anim_loop")
	$Timer.start()




func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		queue_free()
