extends Control

onready var h1 = $HealthBar
onready var h2 = $HealthBar2
onready var e1 = $EnergyBar
onready var e2 = $EnergyBar2

var isEqual = false

func _ready():
	h2.value = h2.value
	e2.value = e1.value

func _process(delta):
	if h1.value != h2.value or e1.value != e2.value and isEqual:
		isEqual = false
		#$Timer.start()

func _on_Timer_timeout():
	var delta = get_process_delta_time()
	print(get_process_delta_time())
	while true:
		print("test while")
		if h2.value > h1.value:
			h2.value -= 1 * delta
		if e2.value > e1.value:
			e2.value -= 1 * delta
		if h2.value < h1.value:
			h2.value = h1.value
		if e2.value < e1.value:
			e2.value = e1.value
		if h1.value == h2.value and e1.value == e2.value:
			isEqual = true
			break
