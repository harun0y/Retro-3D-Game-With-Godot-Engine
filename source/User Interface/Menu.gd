extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalScript.pause = true
	get_parent().get_node("Player/SpringArm/Camera").current = false
	get_parent().get_node("Player/UserInterface").visible = false
	$Camera.current = true
	$AnimationPlayer.play("New Anim")
	$Menu/PlayButton.grab_focus()


func _on_PlayButton_pressed():
	GlobalScript.pause = false
	start()

func _on_TestButton_pressed():
	get_tree().change_scene("res://source/Levels/TestLevel.tscn")
	start()


func _on_QuitButton_pressed():
	get_tree().quit()

func start():
	GlobalScript.pause = false
	get_parent().get_node("Player/SpringArm/Camera").current = true
	get_parent().get_node("Player/UserInterface").visible = true
	queue_free()
