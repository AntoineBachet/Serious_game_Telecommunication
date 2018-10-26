extends Node2D

var answer
var state = "000000000000000000000000000000000000000000000000"

var marble_selected = false
var click = false

var solved = false

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"house"})

	set_process(true)

	#### Récupération de l'énigme ####
	var riddle = global.get_riddle("secret_door")
	answer = riddle["answer"]

	#### Signal des trous et mise à zéro ####
	for i in range(8):
		for j in range(6):
			get_node("braille_cells/cell" + str(i) + "/hole" + str(j)).connect("input_event", self, "_on_hole_input_event", [i,j])
			get_node("braille_cells/cell" + str(i) + "/hole" + str(j) + "/marble_in").hide()
			get_node("moving_marble").hide()
	get_node("marbles_bag").connect("input_event", self, "_on_bag_input_event")

	# Par défaut, on cache les billes
	get_node("marbles_bag").hide()
	get_node("riddleOverlay").set_tip(global.get_game_text("secretDoorPuzzleTip1"))

	#### Affichage et traduction des textes, préparation des nodes ####
	get_node("validateButton").set_text(global.get_gui_text("validateButton"))
	get_node("validateButton").connect("pressed", self, "_on_validateButton_pressed")
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "": # Si on a utilisé les billes devant la porte ou dans l'écran de l'énigme, on les affiche et on change l'astuce
		if global.get_used_item() == "tutorial_1_house_marbles":
			get_node("marbles_bag").show()
			get_node("riddleOverlay").set_tip(global.get_game_text("secretDoorPuzzleTip2"))
		global.set_used_item("")

	#### Déplacement du bâtonnet ####
	if marble_selected:
		var mouse_pos = get_viewport().get_mouse_pos()
		get_node("moving_marble").set_pos(mouse_pos)

######## Bouton de triche ########
func cheat():
	for i in range(8):
		for j in range(6):
			if answer[i * 6 + j] == "0":
				get_node("braille_cells/cell" + str(i) + "/hole" + str(j) + "/marble_in").hide()
				state[i * 6 + j] = "0"
			else:
				get_node("braille_cells/cell" + str(i) + "/hole" + str(j) + "/marble_in").show()
				state[i * 6 + j] = "1"
####################

######## Retour vers l'écran précédent ########
func back_to_house():
	global.set_state("tutorial_1_house_secretDoorPuzzleSolved", true)
	global.use_item("tutorial_1_house_marbles")
	get_node("riddleOverlay").riddle_solved()
####################

######## Clic sur le sac de billes ########
func _on_bag_input_event(viewport, event, shape_idx):
	#### Sélection d'une bille dans le sac de billes
	if !solved and event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT:
		if not click:
			click = true
			if not marble_selected:
				marble_selected = true
				get_node("moving_marble").show()
			else:
				marble_selected = false
				get_node("moving_marble").hide()
	else:
		click = false
####################

######## Clic sur un trou ########
func _on_hole_input_event(viewport, event, shape_idx, index_cell, index_hole):
	if !solved and event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT:
		if not click:
			click = true
			# Remplir du trou
			if marble_selected and state[index_cell * 6 + index_hole] == "0":
				state[index_cell * 6 + index_hole] = "1"
				get_node("braille_cells/cell" + str(index_cell) + "/hole" + str(index_hole) + "/marble_in").show()

			# Enlever une bille
			elif state[index_cell * 6 + index_hole] == "1":
				state[index_cell * 6 + index_hole] = "0"
				get_node("braille_cells/cell" + str(index_cell) + "/hole" + str(index_hole) + "/marble_in").hide()
				marble_selected = true
				get_node("moving_marble").show()
	else:
		click = false
####################

######## Bouton Valider ########
func _on_validateButton_pressed():
	if state == answer:
		solved = true
		back_to_house()
	else:
		player.play_sound("wrong")
####################