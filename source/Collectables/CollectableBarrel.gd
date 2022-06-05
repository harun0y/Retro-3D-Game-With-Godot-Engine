extends StaticBody
export var mix_it: bool = true
export var pot_value = 1
export var bullet_value = 1

func _ready():
	if mix_it:
		randomize()
		pot_value = randi()%3+1
		bullet_value = randi()%3+1

func destroy():
	$Mesh.visible = false
	$CollisionShape.disabled = false
	$Graphics/dustParticles.emitting = true
	$Graphics/woodParticles.emitting = true
	$Timer.start()


