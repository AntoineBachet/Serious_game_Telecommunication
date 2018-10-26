extends Node

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"secretroom"})

	set_process_input(true)
	set_process(true)

	#### Curseur ####
	get_node("feuilles").set_default_cursor_shape(2)
	get_node("computer").set_default_cursor_shape(2)

	#### Nettoyage de la scène ####
	if global.is_chapter_unlocked("morse"):
		get_node("feuilles").hide()
####################

######## Utilisation d'objets ########
func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")
####################

######## Interaction avec l'environnement ########
func _on_feuilles_pressed():
	global.set_state("encyclopediaUnlocked", true)
	global.unlock_chapter_entries("morse")
	get_node("riddleOverlay").set_text(global.get_game_text("deskInteract"))
	get_node("riddleOverlay").update()
	get_node("feuilles").hide()
####################

######## Pop-ups ########
func _on_computer_mouse_enter():
	get_node("riddleOverlay").set_text(global.get_game_text("computerInteract"))

func _on_computer_mouse_exit():
	get_node("riddleOverlay").set_text("")

func _on_feuilles_mouse_enter():
	get_node("riddleOverlay").set_text(global.get_game_text("deskFilesMorse"))

func _on_feuilles_mouse_exit():
	get_node("riddleOverlay").set_text("")
####################

func _on_computer_pressed():
	global.set_scene("res://scenes/game/tutorial/1/secretroom/computerPuzzle.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("menu"):
		global.load_scene()