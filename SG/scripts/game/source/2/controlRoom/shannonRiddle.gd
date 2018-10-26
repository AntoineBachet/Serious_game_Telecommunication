extends Node2D

var playerAnswer = ""
var score = 0
var correctAnswer
var wrongLetterComment
var rightLetterComment
var comments
var counter = 0
var entropy

func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"controlRoom"})
	var language = settings.get_language()

	set_process_input(true)
	set_process(true)

	#### Récupération de l'énigme
	var riddle = global.get_riddle("shannonRiddle")
	var answers = riddle["answers"][language]
	entropy = float(riddle["entropy"][language])
	var randomNumber

	if !Globals.get("gameState").has("source_2_controlRoom_shannonRiddleRandomNumber"):
		randomize()
		randomNumber = randi()%3
		global.set_state("source_2_controlRoom_shannonRiddleRandomNumber", randomNumber)

	correctAnswer = answers[int(global.get_state("source_2_controlRoom_shannonRiddleRandomNumber"))]

	wrongLetterComment = global.get_game_text("shannonRiddleWrongLetter")
	rightLetterComment = global.get_game_text("shannonRiddleRightLetter")

	for key in get_node("Control/ligne1").get_children():
		key.set_default_cursor_shape(2)
	for key in get_node("Control/ligne2").get_children():
		key.set_default_cursor_shape(2)
	for key in get_node("Control/ligne3").get_children():
		key.set_default_cursor_shape(2)

	#### Traduction et affichage des textes
	get_node("Control/instructions").set_text(global.get_game_text("shannonRiddleInstructions"))
	get_node("riddleOverlay").set_tip(global.get_game_text("shannonRiddleTip"))

	#### Traitement des touches 
	for button in get_tree().get_nodes_in_group("alphabet"):
		button.connect("pressed", self, "_some_button_pressed", [button])

	get_node("riddleOverlay").deactivate_hotkeys()

	displayPlayerAnswer()

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY and event.is_pressed() and !event.is_echo():
		if (event.scancode >= KEY_A and event.scancode <= KEY_Z) or event.scancode == KEY_SPACE or event.scancode == KEY_PERIOD:
			var raw = RawArray([event.scancode])
			var letter =  raw.get_string_from_ascii()
			var okLetter = false
			
			if letter == " " and !get_node("Control/ligne3/toucheEspace").is_disabled():
				okLetter = true
			elif letter == "." and !get_node("Control/ligne3/touchePoint").is_disabled():
				okLetter = true
			else:
				for i in range(1,4):
					if get_node("Control/ligne"+str(i)).has_node("touche" + letter):
						if !get_node("Control/ligne" + str(i) + "/touche" + letter).is_disabled():
							okLetter = true

			if okLetter:
				playerAnswer = playerAnswer + letter
				displayPlayerAnswer()
				_on_validateLetter()

func displayPlayerAnswer():
	var text = ""
	for letter in playerAnswer:
		text += str(letter)
	text += "_"
	get_node("Control/Panel/phrase").set_text(text)

func displayScore():
	var text = global.get_game_text( "shannonErrorCount" ) % [score]
	get_node("Control/score").set_text(text)

func wrongLetter():
	###Le joueur a proposé une mauvaise lettre.
	var text = get_node("riddleOverlay").set_text(wrongLetterComment)
	var letter = playerAnswer[ playerAnswer.length() - 1 ]
	playerAnswer.erase(playerAnswer.length()-1,1)
	displayPlayerAnswer()
	score = score + 1
	displayScore()

	### Désactiver le bouton
	if letter == " ":
		get_node("Control/ligne3/toucheEspace").set_disabled(true)
		get_node("Control/ligne3/toucheEspace").set_default_cursor_shape(0)
	elif letter == ".":
		get_node("Control/ligne3/touchePoint").set_disabled(true)
		get_node("Control/ligne3/touchePoint").set_default_cursor_shape(0)
	else:
		for i in range(1,4):
			if get_node("Control/ligne"+str(i)).has_node("touche" + letter):
				get_node("Control/ligne" + str(i) + "/touche" + letter).set_disabled(true)
				get_node("Control/ligne" + str(i) + "/touche" + letter).set_default_cursor_shape(0)

func _on_validateLetter():
	counter += 1
	if playerAnswer.length() != correctAnswer.length():
		## Le joueur n'a pas encore trouvé toutes les lettres de la phrase.
		if correctAnswer.begins_with(playerAnswer):
			get_node("riddleOverlay").set_text(rightLetterComment)
			reactivateButtons()
		else : 
			wrongLetter()
	else:
		## C'est la dernière lettre.
		if correctAnswer == playerAnswer:
			win()
		else:
			wrongLetter()

func _some_button_pressed(button):
	button.release_focus()
	var letter = button.get_text()
	playerAnswer = playerAnswer + str(letter)
	displayPlayerAnswer()
	_on_validateLetter()

func win():
	global.set_state("source_2_controlRoom_unlockedComputer", true)
	var empiricalEntropy = float(counter)/float(correctAnswer.length())
	if empiricalEntropy < entropy + 1:
		global.set_state("source_2_controlRoom_shannonRiddleAchievement", true)
	get_node("riddleOverlay").set_text(global.get_game_text("shannonWin") % [counter, correctAnswer.length(), empiricalEntropy])
	get_node("riddleOverlay").riddle_solved(4, "res://scenes/game/source/2/controlRoom/unlockedComputer.tscn")
	reactivateButtons()

func cheat():
	win()

func reactivateButtons():
	for letter in get_tree().get_nodes_in_group("alphabet"):
		letter.set_disabled(false)
		letter.set_default_cursor_shape(2)