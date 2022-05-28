extends Spatial

signal burn
signal fill

export var max_energy = 100
var cur_energy = 1
var energy_filling_speed = 7

func _ready():
	init()

func _physics_process(delta):
	fill(delta)

func init():
	cur_energy = max_energy

func burn(amount: int):
	if cur_energy <= amount:
		return
	cur_energy -= amount
	emit_signal("burn")

func energy_control(amount):
	if cur_energy <= amount:
		return false
	else:
		return true

func fill(delta):
	if cur_energy >= max_energy:
		cur_energy = max_energy
	else:
		cur_energy += energy_filling_speed * delta
