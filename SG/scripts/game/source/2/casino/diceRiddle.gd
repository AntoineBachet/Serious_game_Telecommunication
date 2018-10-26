extends Control

var frequencies = {"2": 1, "3": 2, "4": 3, "5": 4, "6": 3, "7": 2, "8": 1}

var totalRemainingInformation
var selectedInformation
var selectedButtons
var questionsAsked
var disabledButtonsCounter

var currentNeedleAngle = 90

var diceSum
var wins = 0

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"casino"})

	#### Génération des boutons de réponse ####
	var answerButtonsContainer = get_node("answerButtonsContainer/answerButtonsContainer")
	for i in range(2,9):
		var answerButton = Button.new()
		answerButton.set_text(str(i))
		answerButton.connect("pressed", self, "_answerButton_pressed", [answerButton])
		answerButton.set_h_size_flags(3)
		answerButton.set_name(str(i))
		answerButtonsContainer.add_child(answerButton)
		answerButton.set_disabled(true)

	#### Affichage et traduction des textes + curseurs ####
	var resetButton = get_node("answerButtonsContainer/HBoxContainer/resetButton")
	resetButton.set_text(global.get_game_text("diceRiddleReset"))
	resetButton.set_disabled(true)

	var askButton = get_node("answerButtonsContainer/HBoxContainer/askButton")
	askButton.set_text(global.get_game_text("diceRiddleAsk"))
	askButton.set_disabled(true)

	get_node("riddleInstructions").set_use_bbcode(true)
	
	get_node("riddleOverlay").set_tip_list(global.get_game_text("diceRiddleTips"))

	get_node("infometer/infometerNo/infometer/infometerName").set_text(global.get_game_text("diceRiddleInfometer"))
	get_node("infometer/infometerYes/infometer/infometerName").set_text(global.get_game_text("diceRiddleInfometer"))
	get_node("infometer/infometerNo/noBar/probameterName").set_text(global.get_game_text("diceRiddleProbameter"))
	get_node("infometer/infometerYes/yesBar/probameterName").set_text(global.get_game_text("diceRiddleProbameter"))
	get_node("infometer/infometerYes/yesLabel").set_text(global.get_gui_text("yes"))
	get_node("infometer/infometerNo/noLabel").set_text(global.get_gui_text("no"))

	get_node("throwDice").set_text(global.get_game_text("diceRiddleThrowDice"))
	get_node("throwDice").connect("pressed", self, "_newGame")

	set_process(true)
########################################

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

######## Nouvelle manche ########
func _newGame():
	get_node("throwDice").hide()

	#### (Ré)activation des boutons ####
	get_node("answerButtonsContainer/HBoxContainer/askButton").set_disabled(false)
	get_node("answerButtonsContainer/HBoxContainer/askButton").set_default_cursor_shape(2)
	get_node("answerButtonsContainer/HBoxContainer/resetButton").set_disabled(false)
	get_node("answerButtonsContainer/HBoxContainer/resetButton").set_default_cursor_shape(2)

	totalRemainingInformation = 16
	selectedInformation = 0
	selectedButtons = []
	questionsAsked = 0
	get_node("riddleInstructions").set_bbcode(global.get_game_text("diceRiddleInstructions") % [str(wins+1), str(3-questionsAsked)])
	disabledButtonsCounter = 0

	diceSum = _throwDice()
	player.play_sound("dice")
	_moveNeedle("yes", -currentNeedleAngle,-90)
	_moveNeedle("no", currentNeedleAngle, 90)
	get_node("infometer/infometerYes/yesBar").set_value(float(selectedInformation)/float(totalRemainingInformation)*100)
	get_node("infometer/infometerNo/noBar").set_value((1-float(selectedInformation)/float(totalRemainingInformation))*100)
	currentNeedleAngle = 90

	for answerButton in get_node("answerButtonsContainer/answerButtonsContainer").get_children():
		answerButton.set_disabled(false)
		answerButton.set_text(answerButton.get_name())
		answerButton.set_default_cursor_shape(2)
####################

######## Résolution de l'énigme ########
func _riddle_solved():
	get_node("riddleOverlay").set_text(global.get_game_text("diceRiddleSolved"))
	global.set_state("source_2_casino_diceRiddleSolved", true)
	global.give_item("source_2_casino_diceToken")
	get_node("riddleOverlay").riddle_solved(2)
####################

######## Bouton de triche ########
func cheat():
	_riddle_solved()
#########################

######## Demander si la somme est parmi les nombres sélectionnés ########
func _on_askButton_pressed():
	if selectedButtons.size() > 0:
		if str(diceSum) in selectedButtons: #La somme des deux dés est dans les nombres sélectionnés
			get_node("riddleOverlay").set_text(global.get_game_text("diceRiddleYes"))
			for button in get_node("answerButtonsContainer/answerButtonsContainer").get_children():
				if !button.is_disabled() and !button.get_name() in selectedButtons:
					button.set_disabled(true)
					button.set_default_cursor_shape(0)
					disabledButtonsCounter += 1
					totalRemainingInformation -= frequencies[button.get_name()]
		else:
			get_node("riddleOverlay").set_text(global.get_game_text("diceRiddleNo"))
			for button in get_node("answerButtonsContainer/answerButtonsContainer").get_children():
				if !button.is_disabled() and button.get_name() in selectedButtons:
					button.set_disabled(true)
					button.set_default_cursor_shape(0)
					disabledButtonsCounter += 1
					totalRemainingInformation -= frequencies[button.get_name()]
	
		questionsAsked += 1
		get_node("riddleInstructions").set_bbcode(global.get_game_text("diceRiddleInstructions") % [str(wins+1), str(3-questionsAsked)])
	
		if disabledButtonsCounter == 6:
			get_node("answerButtonsContainer/HBoxContainer/askButton").set_disabled(true)
			get_node("answerButtonsContainer/HBoxContainer/resetButton").set_disabled(true)
			get_node("answerButtonsContainer/HBoxContainer/askButton").set_default_cursor_shape(0)
			get_node("answerButtonsContainer/HBoxContainer/resetButton").set_default_cursor_shape(0)
	
			wins += 1
			if wins == 3:
				_riddle_solved()
			else:
				get_node("riddleOverlay").set_text(global.get_game_text("diceRiddleWin"))
				get_node("throwDice").show()
				# jouer un son de victoire quand même ?
		elif questionsAsked == 3:
			get_node("answerButtonsContainer/HBoxContainer/askButton").set_disabled(true)
			get_node("answerButtonsContainer/HBoxContainer/resetButton").set_disabled(true)
			get_node("answerButtonsContainer/HBoxContainer/askButton").set_default_cursor_shape(0)
			get_node("answerButtonsContainer/HBoxContainer/resetButton").set_default_cursor_shape(0)
	
			get_node("riddleOverlay").set_text(global.get_game_text("diceRiddleFail"))
			player.play_sound("wrong")
			wins = 0
			get_node("throwDice").show()
	
		_on_resetButton_pressed()
####################



######## Déselection de tous les nombres ########
func _on_resetButton_pressed():
	for button in get_node("answerButtonsContainer/answerButtonsContainer").get_children():
		if button.get_name() in selectedButtons:
			_answerButton_pressed(button)
####################








######## (Dé)sélection d'un nombre ########
func _answerButton_pressed(button):
	var buttonNumber = button.get_name()

	if !(buttonNumber in selectedButtons):
		button.set_text(str("(", buttonNumber, ")"))
		selectedButtons.append(buttonNumber)
		selectedInformation += frequencies[buttonNumber]

	else:
		button.set_text(buttonNumber)
		selectedButtons.remove(selectedButtons.find(buttonNumber))
		selectedInformation -= frequencies[buttonNumber]

	_updateInformationDisplay()
####################

######## Mise à jour de l'information-o'meter ########
func _updateInformationDisplay():
	var newNeedleAngle
	if totalRemainingInformation != 0:
		newNeedleAngle = (1-float(selectedInformation)*2/float(totalRemainingInformation))*90
	else:
		newNeedleAngle = 90
	_moveNeedle("no", currentNeedleAngle, newNeedleAngle)
	_moveNeedle("yes", -currentNeedleAngle, -newNeedleAngle)

	# à animer avec un Tween aussi ? c'est pas trop moche même sans
	get_node("infometer/infometerYes/yesBar").set_value(float(selectedInformation)/float(totalRemainingInformation)*100)
	get_node("infometer/infometerNo/noBar").set_value((1-float(selectedInformation)/float(totalRemainingInformation))*100)

	currentNeedleAngle = newNeedleAngle
####################

######## Faire tourner l'aiguille d'un angle à un autre ########
func _moveNeedle(side, start, end):
	var tween = get_node("Tween")
	var animationDuration = 0.3

	var needle
	if side == "yes":
		needle = get_node("infometer/infometerYes/infometer/needle")
	elif side == "no":
		needle = get_node("infometer/infometerNo/infometer/needle")

	tween.interpolate_property(needle, "transform/rot", start, end, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	needle.set_rot(end)
####################

######## 2D6 ########
func _throwDice():
	randomize()
	var dice1 = randi() % 4 + 1
	var dice2 = randi() % 4 + 1
	return dice1 + dice2
####################