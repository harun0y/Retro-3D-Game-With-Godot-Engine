extends Area

signal send_name_info(value, value2, is_e_pressed)

export var info = "Q"
export var image: Texture

func touched(is_e_pressed):
	emit_signal("send_name_info", info, image, is_e_pressed)

func die():
	queue_free()

