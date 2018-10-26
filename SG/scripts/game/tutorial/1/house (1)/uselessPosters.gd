extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"house"})

	set_process_input(true)

	#### Curseurs ####
	get_node("retour").set_default_cursor_shape(2)
####################

#### Inputs ####
func _input(event):
	if event.type == InputEvent.KEY and (event.is_action_pressed("interactWithItem") or event.is_action_pressed("menu")):
		_on_retour_pressed()

func _on_retour_pressed():
	global.load_scene()
####################