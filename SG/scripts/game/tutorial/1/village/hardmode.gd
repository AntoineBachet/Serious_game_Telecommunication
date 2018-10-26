extends Node

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"village"})

	set_process_input(true)

	#### Affichage et traduction des textes ####
	get_node("VBoxContainer/Label").set_text(global.get_game_text("hardmode"))
	get_node("VBoxContainer/HBoxContainer/hitButton").set_text(global.get_game_text("hitJuliette"))
	get_node("VBoxContainer/HBoxContainer/spareButton").set_text(global.get_game_text("spareJuliette"))

	#### Curseurs ####
	get_node("VBoxContainer/HBoxContainer/hitButton").set_default_cursor_shape(2)
	get_node("VBoxContainer/HBoxContainer/spareButton").set_default_cursor_shape(2)
####################

######## Inputs par touches et boutons ########
func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("menu"):
			_on_spareButton_pressed()
		if event.is_action_pressed("interactWithItem"):
			_on_hitButton_pressed()

func _on_hitButton_pressed():
	player.play_sound("crush")
	global.set_state("julietteGone", true)
	global.load_scene()

func _on_spareButton_pressed():
	global.load_scene()
####################