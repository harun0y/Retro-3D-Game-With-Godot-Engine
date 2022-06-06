extends KinematicBody

onready var anim_player = $Mesh/AnimationPlayer
onready var health_manager = $HealthManager
onready var character_mover = $CharacterMover
onready var nav : Navigation = get_parent()
onready var aimer = $AimAtObject
onready var bloodParticles = $BloodParticles 
onready var expDrop = $CollectableExp

enum STATES {IDLE, CHASE, ATTACK, DEAD, TIRED}
var current_state = STATES.IDLE

var player = null
var path = []

export var chasing_limit_time = 7
export var sight_angle = 45.0
export var turn_speed = deg2rad(360.0)
export var attack_angle = 5.0
export var attack_range = 2.0
export var attack_rate = 1.0
export var damage = 10
var attack_timer: Timer
var chase_timer: Timer
var can_attack = true

var starting_pos:Vector3

signal attack

func _ready():
	randomize()
	starting_pos = global_transform.origin
	
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	player = get_tree().get_nodes_in_group("player")[0]
	var bone_attachments = $Mesh/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt")
	
	health_manager.connect("dead", self, "set_state_dead")
	character_mover.init(self)
	set_state_idle()

func _process(delta):
	if GlobalScript.pause:
		anim_player.play("idle_loop")
		return

	match current_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)


func set_state_idle():
	current_state = STATES.IDLE
	anim_player.play("idle_loop")

func set_state_chase():
	current_state = STATES.CHASE
	anim_player.play("walk_loop")

func set_state_attack():
	current_state = STATES.ATTACK
	
func set_state_tired():
	current_state = STATES.TIRED

func set_state_dead():
	current_state = STATES.DEAD
	anim_player.play("dead")
	character_mover.freeze()
	$CollisionShape.set_deferred("disabled", true)
	expDrop.visible = true
	expDrop.get_child(0).monitoring = true
	$Timer.start()

func process_state_idle(delta):
	pass #alert() bekleniyor

func process_state_chase(delta):
	if within_distance_of_player(attack_range) and has_los_player():
		set_state_attack()
	var player_pos = player.global_transform.origin
	var our_pos = global_transform.origin
	path = nav.get_simple_path(our_pos, player_pos)
	var goal_pos = player_pos
	if path.size() > 1:
		goal_pos = path[1]
	var dir = goal_pos - our_pos
	dir.y = 0
	character_mover.set_move_vec(dir)
	face_dir(dir, delta)

func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO)
	
	if can_attack:
		if !within_distance_of_player(attack_range) or !can_see_player():
			set_state_chase()
		elif !player_within_angle(attack_angle):
			face_dir(global_transform.origin.direction_to(player.global_transform.origin), delta)
		else:
			start_attack()

func player_within_angle(angle: float):
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < angle 

func process_state_dead(delta):
	pass

func hurt(damage: int, dir: Vector3):
	if current_state == STATES.IDLE:
		set_state_chase()
	health_manager.hurt(damage, dir)
	bloodParticles.emitting = true
	if current_state == STATES.ATTACK and randi()%5+1 != 5:
		current_state = STATES.CHASE
		if anim_player.has_animation("impact"):
			anim_player.play("impact")
		else:
			anim_player.has_animation("idle_loop")

func start_attack():
	can_attack = false

	anim_player.play("attack")
	attack_timer.start()

func emit_attack_signal():
	emit_signal("attack")

func finish_attack():
	can_attack = true

func can_see_player():
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < sight_angle and has_los_player()

func has_los_player():
	var our_pos = global_transform.origin + Vector3.UP #yerden itibaren taramasın diye yükselttik
	var player_pos = player.global_transform.origin + Vector3.UP
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1)
	if result:
		return false
	return true

func face_dir(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_diff) < turn_speed * delta:
		rotation.y = atan2(dir.x, dir.z)
	else:
		rotation.y += turn_speed * delta * turn_right

func alert(rush):
	if current_state != STATES.IDLE or current_state == STATES.DEAD:
		return
	if rush:
		set_state_chase()
	if !rush and can_see_player():
		set_state_chase()
		return

func within_distance_of_player(distance: float):
	return global_transform.origin.distance_to(player.global_transform.origin) < attack_range

func _on_Timer_timeout():
	queue_free()
