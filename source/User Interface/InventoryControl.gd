extends Control



func _process(delta):
	if !visible:
		return
	
	printOnScreen()

func printOnScreen():
#	$TextureRect/StatsControl/lvl.text = get_parent().level
	$TextureRect/StatsControl/hp.text = str(get_parent().get_node("HealthManager").cur_health)
	$TextureRect/StatsControl/cur_exp.text = str(get_parent().experience)
#	$TextureRect/StatsControl/next_LVL_exp.text = str(get_parent())
	$TextureRect/StatsControl/str.text = str(get_parent().damage)
	$TextureRect/StatsControl/ranged.text = str(get_parent().damage * 0.75)
	$TextureRect/StatsControl/max_speed.text = str(get_parent().max_speed)
	$TextureRect/StatsControl/max_health.text = str(get_parent().get_node("HealthManager").max_health)
	$TextureRect/StatsControl/potion_regen.text = str(get_parent().healing_amount)
	$TextureRect/StatsControl/max_energy.text = str(get_parent().get_node("EnergyManager").max_energy)
	$TextureRect/StatsControl/stam_regen.text = str(get_parent().get_node("EnergyManager").energy_filling_speed)

