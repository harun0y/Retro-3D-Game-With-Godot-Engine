extends KinematicBody

const MAX_SPEED = 10

export var max_speed = MAX_SPEED
export var acceleration = 70
export var friction = 60
export var air_friction = 10
export var gravity = -40
export var jump_impulse = 14
export var mouse_sensitivity = .1
export var controller_sensitivity = 3
export var rot_speed = 5
export (int, 0, 10) var push = 1
export var healing_amount = 45
export var energy_cost = 10
export var damage = 10;

var _input_vector = Vector3.ZERO
var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO

var frozen = false
var dead = false
var isRolling = false
var isAttacking = false
var isHealing = false
var hasBodyinLos = false
var comboCounter = 0 #saldırı kombolarını tutmak için
var isAreainsideTheBody = false
var keyPressTime = 0
var heavyControl = false
var experience = 0
var bullet_amount = 100
var pot_amount = 100
var level = 1

onready var animationPlayer = $Pivot/combined_kaol/AnimationPlayer
onready var spring_arm = $SpringArm
onready var pivot = $Pivot
onready var camera = $SpringArm/Camera
onready var health_manager = $HealthManager
onready var energy_manager = $EnergyManager
onready var health_bar = $UserInterface/HealthBar
onready var energy_bar = $UserInterface/EnergyBar
onready var exp_label = $UserInterface/exp_label
onready var pot_label = $UserInterface/potion_label
onready var bullet_label = $UserInterface/bullet_label
onready var alert_area_hearing = $AlertAreaHearing
onready var alert_area_los = $AlertAreaLos
onready var hitbox = $"Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment/KaolSwords/Position3D/DS_HitBox"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animationPlayer.get_animation("idle").loop = true
	animationPlayer.get_animation("walking").loop = true
	animationPlayer.get_animation("run ").loop = true # armed running
	#animationPlayer.get_animation("running").loop = true # normal running, unarmed
	animationPlayer.get_animation("falling idle").loop = true
	animationPlayer.get_animation("sitting idle").loop = true
	animationPlayer.get_animation("sword on shoulder R").loop = true
	
	health_manager.init()
	energy_manager.init()
	health_manager.connect("dead", self, "kill")
	health_bar.value = health_manager.cur_health
	energy_bar.value = energy_manager.cur_energy
	
	$UserInterface.visible = true

func _physics_process(delta): #saldırırken yerinde duracak, roll atınca saldırı bozulcak ama roll input vectörü alması lazım yoksa son durduğu yere gidecke olmaz öyle
	update_bars()
	if dead or GlobalScript.pause:
		$AnimationTree.set("parameters/idle2walk/blend_position", 0.01)
		return
	$SpringArm/Camera.current = true
	var input_vector
	if !isAttacking:
		input_vector = get_input_vector()
	else:
		input_vector = Vector3.ZERO
	
	
	var direction = get_direction(input_vector)
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	apply_controller_rotation()
	#frozenControl()
	heal(healing_amount)
	walk()
	jump()
	roll()
	attack_button_control(delta)
	damageControl()
	if hasBodyinLos:
		AlertAreaLos_body_entered(self)
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, 0.785398, false)
	fall()


func get_input_vector():
	if isRolling or isAttacking: #roll atarken yön değiştirmemesi için doğrultusunu koruduk 
		return _input_vector
	_input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_input_vector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return _input_vector.normalized() if _input_vector.length() > 1 else _input_vector

func get_direction(input_vector):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction

func apply_movement(input_vector, direction, delta):
	var speed
	if isRolling: # roll için ekstra hız
		speed = max_speed * 1.2
	else:
		speed = max_speed
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * speed, acceleration * delta).z
#		pivot.look_at(global_transform.origin + directon, Vector3.UP)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, atan2(-input_vector.x, -input_vector.z), rot_speed * delta)

func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		else:
			velocity.x = velocity.move_toward(Vector3.ZERO, air_friction * delta).x
			velocity.z = velocity.move_toward(Vector3.ZERO, air_friction * delta).z

func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_impulse)

func update_snap_vector():
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN

func jump():
	if is_on_floor() and Input.is_action_just_pressed("2B") and !isRolling and not getLeftJoystickStrength() and !isAttacking and !isHealing and energy_manager.energy_control(energy_cost):
		energy_manager.burn(energy_cost)
		$AnimationTree.set("parameters/States/current", 6)
		$AnimationTree.set("parameters/OneShotAll/active", true)
		snap_vector = Vector3.ZERO
		velocity.y = jump_impulse
	if Input.is_action_just_released("jump") and velocity.y > jump_impulse / 2:
		velocity.y = jump_impulse / 2

func walk():
	lerp(spring_arm.rotation.y, rotation.y, 10)
	if is_on_floor():
		if velocity.length() >= 0:
			$AnimationTree.set("parameters/idle2walk/blend_position", velocity.length())
		else: 
			$AnimationTree.set("parameters/idle2walk/blend_position", 0.01)

func roll():
	if  is_on_floor() and Input.is_action_just_pressed("2B") and !isAttacking and !isHealing and !isRolling and getLeftJoystickStrength() and energy_manager.energy_control(energy_cost*0.8):
		$Timers/RollTimer.start()
		isRolling = true
		$AnimationTree.set("parameters/States/current", 8)
		$AnimationTree.set("parameters/OneShotAll/active", true)
		energy_manager.burn(energy_cost)

func attack_button_control(delta):
	if Input.is_action_pressed("4X"):
		keyPressTime += delta
	if Input.is_action_just_released("4X"):
		if keyPressTime > 0.3:
			attack(true) #heavy attack
		else:
			attack(false) #normal attack
		keyPressTime = 0

func attack(heavy):
	if heavy and !isAttacking and energy_manager.energy_control(energy_cost*2) and bullet_amount > 0:
		isAttacking = true
		frozen = true
		$AnimationTree.set("parameters/States/current", 3)
		$AnimationTree.set("parameters/OneShotAll/active", true)
		$Timers/AttackTimer.wait_time = animationPlayer.get_animation("gunplay").length - 0.5
		$Timers/AttackTimer.start()
		$Timers/FireTimer.start()
		bullet_amount -= 1 
	elif is_on_floor() and comboCounter == 0 and !isAttacking and !isHealing and energy_manager.energy_control(energy_cost):
		isAttacking = true
		frozen = true
		$Timers/AttackTimer.wait_time = animationPlayer.get_animation("combo attack no 1").length - 1.5
		$Timers/AttackTimer/ComboTimer.wait_time = animationPlayer.get_animation("combo attack no 1").length - 1
		$Timers/AttackTimer.start()
		$Timers/AttackTimer/ComboTimer.start()
		$AnimationTree.set("parameters/States/current", 0)
		$AnimationTree.set("parameters/OneShotAll/active", true)
		comboCounter = 1
		energy_manager.burn(energy_cost)
	elif is_on_floor() and comboCounter == 1 and !isAttacking and energy_manager.energy_control(energy_cost):
		isAttacking = true
		frozen = true
		$Timers/AttackTimer.wait_time = animationPlayer.get_animation("combo attack no 2").length - 0.7
		$Timers/AttackTimer/ComboTimer.wait_time = animationPlayer.get_animation("combo attack no 2").length - 0.2
		$Timers/AttackTimer.start()
		$Timers/AttackTimer/ComboTimer.start()
		$AnimationTree.set("parameters/States/current", 1)
		$AnimationTree.set("parameters/OneShotAll/active", true)
		comboCounter = 2
		energy_manager.burn(energy_cost)
	elif is_on_floor() and comboCounter == 2 and !isAttacking and energy_manager.energy_control(energy_cost):
		isAttacking = true
		frozen = true
		$Timers/AttackTimer.wait_time = animationPlayer.get_animation("attack combo no 3").length - 1.5
		$Timers/AttackTimer.start()
		$AnimationTree.set("parameters/States/current", 2)
		$AnimationTree.set("parameters/OneShotAll/active", true)
		comboCounter = 0
		energy_manager.burn(energy_cost)

func damageControl():
	if isAttacking and !isAreainsideTheBody:
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("enemies") and body.has_method("hurt"):
				isAreainsideTheBody = true
				body.hurt(damage, Vector3.ZERO)
			if body.is_in_group("destructible"):
				body.destroy()
				pot_amount += body.pot_value
				bullet_amount += body.bullet_value
				body.pot_value = 0
				body.bullet_value = 0
			if body.is_in_group("chest"):
				body.destroy()

func heal(amount):
	if not $AnimationTree.get("parameters/OneShotInteract/active") and Input.is_action_just_pressed("1Y") and is_on_floor() and pot_amount > 0:
# warning-ignore:integer_division
		isHealing = true
		$"Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment2/gun".visible = false
		$"Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment2/potion".visible = true
		$Timers/HealTimer.start()
		max_speed = MAX_SPEED / 3
		$AnimationTree.set("parameters/InteractStates/current", 0)
		$AnimationTree.set("parameters/OneShotInteract/active", true)
		healing_amount = amount
		pot_amount -= 1
func AlertAreaLos_body_exited(_body):
	hasBodyinLos = false
func AlertAreaLos_body_entered(_body):
	hasBodyinLos = true
	var nearby_enemies = alert_area_los.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert(false)

func AlertAreaHearing_body_entered(_body):
	var nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert(true)

func hurt(damage, dir):
	health_manager.hurt(damage, dir)
	$BloodParticles.emitting = true

func update_bars():
	pot_label.text = str(pot_amount)
	bullet_label.text = str(bullet_amount)
	health_bar.value = health_manager.cur_health
	energy_bar.value = energy_manager.cur_energy
	exp_label.text = str(experience)
	if velocity.length() > 1:
		$InventoryControl.visible = false

func kill():
	dead = true
	$AnimationTree.active = false
	$Pivot/combined_kaol/AnimationPlayer.play("death")
	freeze()
	$DeathScreenControl/AnimationPlayer.play("death_screen")

func freeze():
	frozen = true

func unfreeze():
	frozen = false

func fall():
	if is_on_floor(): #havada mı?
		$AnimationTree.set("parameters/idleStates/current", 0)
	else:
		$AnimationTree.set("parameters/idleStates/current", 1)


func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		spring_arm.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity)
	
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg2rad(-75), deg2rad(75)) 

func _on_fov_updated(value):
	camera.fov = value

func _on_mouse_sens_updated(value):
	mouse_sensitivity = value

func _on_RollTimer_timeout():
	isRolling = false

func _on_AttackTimer_timeout():
	isAttacking = false


func _on_HealTimer_timeout():
	health_manager.heal(healing_amount)
	max_speed = MAX_SPEED
	isHealing = false
	$"Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment2/gun".visible = true
	$"Pivot/combined_kaol/kaol bones/Skeleton/BoneAttachment2/potion".visible = false

func _on_ComboTimer_timeout():
	comboCounter = 0

func getLeftJoystickStrength(): #sol joystick aktif mi?
	return (Input.get_action_strength("move_right") != 0 or Input.get_action_strength("move_left") != 0 or Input.get_action_strength("move_forward") != 0 or Input.get_action_strength("move_back") != 0)

func frozenControl():
	if isAttacking:
		return true
	else:
		return false

func _on_DS_HitBox_body_exited(body):
	isAreainsideTheBody = false

func _on_FireTimer_timeout():
	energy_manager.burn(energy_cost*2)
	$Pivot/bulletSpawner.fire()

func restart_game():
	get_tree().change_scene("res://source/Levels/Island/Island.tscn")



