extends Node2D

var text
var answer
var state = "000000000000000000"

var stick_selected = false
var click = false
var solved = false

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"house"})

	set_process(true)

	#### Récupération du texte de l'énigme et de la solution
	var riddle = global.get_riddle("chest")
	text = riddle["riddle"][settings.get_language()]
	answer = riddle["answer"]

	#### Préparation de l'énigme ####
	# Signaux des trous
	for k in range(18):
		get_node("braille_cells/cell" + str(k/6+1) + "/hole" + str(k) + "/Area2D").connect("input_event", self, "_on_Area2D_input_event", [k])

	# Mise à zéro du bâtonnet et des trous ####
	get_node("moving_stick").hide()
	for k in range(18):
		get_node("braille_cells/cell" + str(k/6+1) + "/hole" + str(k) + "/stick_in").hide()

	# Par défaut, on cache les bâtonnets
	get_node("bowl_of_sticks").hide()
	
	#### Affichage des textes ####
	get_node("plaque/Label").set_text(text)
	get_node("validateButton").set_text(global.get_gui_text("validateButton"))

	get_node("riddleOverlay").set_tip(global.get_game_text("chestPuzzleTip1"))
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_house_sticks":
			get_node("riddleOverlay").set_tip(global.get_game_text("chestPuzzleTip2"))
			get_node("bowl_of_sticks").show()
		global.set_used_item("")
	
	#### Déplacement du bâtonnet ####
	if stick_selected:
		var mouse_pos = get_viewport().get_mouse_pos()
		get_node("moving_stick").set_pos(mouse_pos)

######## Bouton Tricher ########
func cheat():
	for k in range(18):
		if answer[k] == "0":
			get_node("braille_cells/cell" + str(k/6+1) + "/hole" + str(k) + "/stick_in").hide()
			state[k] = "0"
		else:
			get_node("braille_cells/cell" + str(k/6+1) + "/hole" + str(k) + "/stick_in").show()
			state[k] = "1"
####################

######## Clic dans le tas de bâtonnets ########
func _on_bowl_input_event( viewport, event, shape_idx ):
	#### Sélection du bâtonnet dans le tas de bâtonnets ####
	if !solved and event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT:
		if not click:
			click = true
			if not stick_selected:
				stick_selected = true
				get_node("moving_stick").show()
			else:
				stick_selected = false
				get_node("moving_stick").hide()
	else:
		click = false
####################

######## Clic sur un des trous ########
func _on_Area2D_input_event( viewport, event, shape_idx, index_hole ):
	if !solved and event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT:
		if not click:
			click = true
			#### Remplir un trou ####
			if stick_selected and state[index_hole] == "0":
				state[index_hole] = "1"
				get_node("braille_cells/cell" + str(index_hole/6 + 1) + "/hole" + str(index_hole) + "/stick_in").show()

			#### Enlever un bâtonnet ####
			elif state[index_hole] == "1":
				state[index_hole] = "0"
				get_node("braille_cells/cell" + str(index_hole/6 + 1) + "/hole" + str(index_hole) + "/stick_in").hide()
				stick_selected = true
				get_node("moving_stick").show()
	else:
		click = false
####################

######## Retour vers l'écran précédent après résolution ########
func back_to_house():
	global.set_state("tutorial_1_house_chestMessageShown", false)
	global.set_state("tutorial_1_house_chestPuzzleSolved", true)
	global.give_item("tutorial_1_house_scales")
	global.give_item("tutorial_1_house_marbles")
	global.give_item("tutorial_1_house_oscilloscope")
	global.use_item("tutorial_1_house_sticks")
	get_node("riddleOverlay").riddle_solved()
####################

######## Bouton Valider ########
func _on_validateButton_pressed():
	if state == answer:
		solved = true
		back_to_house()
	else:
		player.play_sound("wrong")
####################