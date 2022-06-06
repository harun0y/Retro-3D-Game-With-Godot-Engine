extends Area

export var speed = 7
export var rotation_speed = 2.1 
var velocity = Vector3() 
var rot = Vector3() 

onready var target = get_node("../Player/target") as Spatial

func _physics_process(delta): 
	var direction = target.global_transform.origin - global_transform.origin 
	direction = direction.normalized() 
	
	var rotateAmount = direction.cross(global_transform.basis.z) 
	rot.y = rotateAmount.y * rotation_speed * delta 
	rot.x = rotateAmount.x * rotation_speed * delta 
	rotate(Vector3.UP, rot.y) 
	rotate(Vector3.RIGHT,rot.x) 
	global_translate(-global_transform.basis.z * speed * delta)

func _on_Missile_body_entered(body):
	if body.has_method("hurt"):
		#particle
		body.hurt(25, Vector3.ZERO)
		queue_free()

func _on_KillTimer_timeout():
	queue_free()
