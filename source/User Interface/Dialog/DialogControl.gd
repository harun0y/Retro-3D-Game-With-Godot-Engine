extends Control
 
export var dialogPath = "res://source/User Interface/Dialog/dialogs/dialog0.json"
export(float) var textSpeed = 0.03
 
var dialog
 
var phraseNum = 0
var finished = false
 
onready var speach_text = $"Dialog Box/Speach"
onready var name_text = $"Dialog Box/Name"
onready var ok_button = $"Dialog Box/OkButton"


func _ready():
	$"Dialog Box/Timer".wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()
 
func _process(_delta):
	ok_button.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()
		else:
			speach_text.visible_characters = len(speach_text.text)
 
func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(dialogPath), "dosya bulunamadi laa")
	
	f.open(dialogPath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
 
func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		GlobalScript.pause = false
		queue_free()
		return
	
	finished = false

	name_text.bbcode_text = dialog[phraseNum]["Name"]
	if dialog[phraseNum]["Name"] == "kaolzaogoch":
		var character = get_tree().get_nodes_in_group("player")[0]
		character.get_node("Pivot/FaceCam").current = true
	elif dialog[phraseNum]["Name"] == "narblin":
		var character = get_tree().get_nodes_in_group("narblin")[0]
		character.get_node("FaceCam").current = true
	
	speach_text.bbcode_text = dialog[phraseNum]["Speach"]
	
	speach_text.visible_characters = 0
	
	while speach_text.visible_characters < len(speach_text.text):
		speach_text.visible_characters += 1
		
		$"Dialog Box/Timer".start()
		yield($"Dialog Box/Timer", "timeout")
	
	finished = true
	phraseNum += 1
	
	return
