extends Node2D

var correctAnswer
var playerAnswer
var display

var riddle
var language

func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"secretroom"})
	set_process(true)

	#### Récupération de l'énigme ####
	language = settings.get_language()
	riddle = global.get_riddle("safe")
	correctAnswer = riddle["answer"][language]
	var riddleImage = load(riddle["lien"][language])
	get_node("Control/riddleImage").set_texture(riddleImage)

	playerAnswer = []

	#### Récupération des nodes d'intérêt ####
	display = get_node("Control/PanelContainer/display")

	#### Traduction et affichage des textes ####
	get_node("Control/deleteButton").set_text(global.get_gui_text("deleteButton"))
	get_node("Control/validateButton").set_text(global.get_gui_text("validateButton"))

	get_node("riddleOverlay").set_tip(global.get_game_text("safeTip"))

########Utilisation d'objets ########
func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")
####################

######## Bouton du coffre ########
func _on_validateButton_pressed():
	if playerAnswer == correctAnswer:
		global.set_state("tutorial_1_secretroom_safePuzzleSolved", true)
		global.set_state("tutorial_1_secretroom_safeMessageShown", false)
		global.give_item("tutorial_1_secretroom_ampoule")
		get_node("riddleOverlay").riddle_solved()
		get_node("Control/validateButton").set_disabled(true)
		get_node("Control/deleteButton").set_disabled(true)
	else:
		player.play_sound("wrong")
		playerAnswer = []
		displayPlayerAnswer()

func _on_deleteButton_pressed():
	if playerAnswer.size()>0:
		playerAnswer.pop_back()
	displayPlayerAnswer()

func pressButton(color):
	playerAnswer = playerAnswer + [color] #avec append, correctAnswerr et playerAnswer sont le même objet
	displayPlayerAnswer()

func displayPlayerAnswer():
	var text = ""
	for word in playerAnswer:
		text += str(word, " ")
	display.set_text(text)

func _on_green_pressed():
	pressButton(riddle["green"][language])
func _on_carrot_pressed():
	pressButton(riddle["carrot"][language])
func _on_pink_pressed():
	pressButton(riddle["pink"][language])
func _on_lemon_pressed():
	pressButton(riddle["lemon"][language])
func _on_purple_pressed():
	pressButton(riddle["purple"][language])
func _on_blue_pressed():
	pressButton(riddle["blue"][language])
####################

######## Bouton Tricher ########
func cheat():
	playerAnswer = correctAnswer
	displayPlayerAnswer()
####################