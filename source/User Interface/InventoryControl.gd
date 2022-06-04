extends Control

var nextLVLexp = 10


func _process(delta):
	if Input.is_action_just_pressed("pad_select"):
		printOnScreen()
		visible =  !visible 


func printOnScreen():
	calculateEXP()
	$TextureRect/StatsControl/lvl.text = str(get_parent().level)
	$TextureRect/StatsControl/hp.text = str(get_parent().get_node("HealthManager").cur_health)
	$TextureRect/StatsControl/cur_exp.text = str(get_parent().experience)
	$TextureRect/StatsControl/next_LVL_exp.text = str(nextLVLexp)
	$TextureRect/StatsControl/str.text = str(get_parent().damage)
	$TextureRect/StatsControl/ranged.text = str(get_parent().damage * 0.75)
	$TextureRect/StatsControl/max_speed.text = str(get_parent().max_speed)
	$TextureRect/StatsControl/max_health.text = str(get_parent().get_node("HealthManager").max_health)
	$TextureRect/StatsControl/potion_regen.text = str(get_parent().healing_amount)
	$TextureRect/StatsControl/max_energy.text = str(get_parent().get_node("EnergyManager").max_energy)
	$TextureRect/StatsControl/stam_regen.text = str(get_parent().get_node("EnergyManager").energy_filling_speed)

func calculateEXP():
	nextLVLexp = 10
	for x in range(0,get_parent().level):
		nextLVLexp *= 2

	if get_parent().experience >= nextLVLexp:
		get_parent().experience -= nextLVLexp
		get_parent().level += 1
		print("leveled up")
