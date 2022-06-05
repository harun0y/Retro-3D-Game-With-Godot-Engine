extends Area

export var dialog_path : String 
var scene = preload("res://source/User Interface/Dialog/DialogControl.tscn")


func _on_Area_body_entered(body):
	if not get_parent().has_node("Navigation/Mage"):
		queue_free()
	if body.is_in_group("player"):
		$Graphics.visible = false
		var dialog_instance = scene.instance()
		dialog_instance.dialogPath = dialog_path
		get_parent().add_child(dialog_instance)
		GlobalScript.pause = true


func _on_DialogArea_body_exited(body):
	$Graphics.visible = true
	queue_free() 
