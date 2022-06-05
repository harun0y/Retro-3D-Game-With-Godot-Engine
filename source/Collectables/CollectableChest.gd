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
		body.get_node("Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment/KaolSwords/drslayer").visible = false
		body.get_node("Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment/KaolSwords/hslayer").visible = false
		body.get_node("Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment/KaolSwords/HR sword").visible = false
		body.get_node("Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment/KaolSwords/" + sword_type).visible = true
		queue_free()
