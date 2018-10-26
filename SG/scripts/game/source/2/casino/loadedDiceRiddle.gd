extends Node2D

var die = preload("res://scenes/game/source/2/casino/die.tscn")
const numberOfDice = 12

var loadedDieNumber

onready var leftBasket = get_node("croupier/Sprite/leftBasket")
onready var rightBasket = get_node("croupier/Sprite/rightBasket")
var leftBasketDice
var rightBasketDice
var middleDice

var leftMass
var rightMass

var croupierAngle

var currentLeftNeedleAngle = -90
var currentMiddleNeedleAngle = 90
var currentRightNeedleAngle = -90
var currentBLeftNeedleAngle = 90
var currentBMiddleNeedleAngle = 90
var currentBRightNeedleAngle = 90

var numberOfAttempts = 0
var knownEvents
var knownResult = false

var informativeDice

var _toggled = true

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"casino"})

	set_process(true)

	#### Affichage et traduction des textes ####
	get_node("infometer/infometerLeft/leftLabel").set_text(global.get_game_text("loadedDiceRiddleLeft"))
	get_node("infometer/infometerMiddle/middleLabel").set_text(global.get_game_text("loadedDiceRiddleMiddle"))
	get_node("infometer/infometerRight/rightLabel").set_text(global.get_game_text("loadedDiceRiddleRight"))
	get_node("infometer/infometerLeft/leftBar/probameterName").set_text(global.get_game_text("diceRiddleProbameter"))
	get_node("infometer/infometerRight/rightBar/probameterName").set_text(global.get_game_text("diceRiddleProbameter"))
	get_node("infometer/infometerMiddle/middleBar/probameterName").set_text(global.get_game_text("diceRiddleProbameter"))
	get_node("infometer/infometerRight/infometer/infometerName").set_text(global.get_game_text("diceRiddleInfometer"))
	get_node("infometer/infometerLeft/infometer/infometerName").set_text(global.get_game_text("diceRiddleInfometer"))
	get_node("infometer/infometerMiddle/infometer/infometerName").set_text(global.get_game_text("diceRiddleInfometer"))
	get_node("infometer/infometerLeft/uncertaintymeter/uncertaintymeterName").set_text(global.get_game_text("loadedDiceRiddleUncertaintyMeter"))
	get_node("infometer/infometerMiddle/uncertaintymeter/uncertaintymeterName").set_text(global.get_game_text("loadedDiceRiddleUncertaintyMeter"))
	get_node("infometer/infometerRight/uncertaintymeter/uncertaintymeterName").set_text(global.get_game_text("loadedDiceRiddleUncertaintyMeter"))

	get_node("answerCircle/answerCircleLabel").set_text(global.get_game_text("loadedDiceRiddleCircleLabel"))
	get_node("croupier/Sprite/weighButton").set_tooltip(global.get_game_text("loadedDiceRiddleWeighButton"))
	get_node("answerButton").set_text(global.get_game_text("loadedDiceRiddleAnswerButton"))
	get_node("croupier/Sprite/newGameButton").set_tooltip(global.get_game_text("loadedDiceRiddleNewGameButton"))

	get_node("riddleOverlay").set_tip_list(global.get_game_text("loadedDiceRiddleTips"))
	get_node("riddleOverlay").disable_tip()

	#### Préparation des nodes d'intérêt ####
	get_node("instructions").set_use_bbcode(true)
	_toggle_buttons()

	randomize()
####################

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

######## Désactiver les boutons du jeu et activer celui de nouvelle partie, ou l'inverse + le texte à afficher ########
func _toggle_buttons():
	if _toggled:
		get_node("croupier/Sprite/newGameButton").set_default_cursor_shape(2)
		get_node("croupier/Sprite/newGameButton").set_disabled(false)
		get_node("croupier/Sprite/weighButton").set_default_cursor_shape(0)
		get_node("croupier/Sprite/weighButton").set_disabled(true)
		get_node("answerButton").set_default_cursor_shape(0)
		get_node("answerButton").set_disabled(true)
		get_node("instructions").set_bbcode(global.get_game_text("loadedDiceRiddleNewGameText"))
	else:
		get_node("croupier/Sprite/newGameButton").set_default_cursor_shape(0)
		get_node("croupier/Sprite/newGameButton").set_disabled(true)
		get_node("croupier/Sprite/weighButton").set_default_cursor_shape(2)
		get_node("croupier/Sprite/weighButton").set_disabled(false)
		get_node("answerButton").set_default_cursor_shape(2)
		get_node("answerButton").set_disabled(false)
		get_node("instructions").set_bbcode(global.get_game_text("loadedDiceRiddleInstructions"))
	_toggled = !_toggled
####################

######## Bouton Nouvelle partie ########
func _on_newGameButton_pressed():
	player.play_sound("menu")
	_start_game()
####################

######## Initialisation d'une nouvelle partie #######
func _start_game():
	_toggle_buttons()
	
	if get_tree().get_nodes_in_group("dice").size() > 0:
		for die in get_tree().get_nodes_in_group("dice"):
			die.queue_free()

	get_node("riddleOverlay").enable_tip()

	#### Remise à zéro ####
	numberOfAttempts = 0

	knownEvents = {}

	leftBasketDice = []
	rightBasketDice = []
	middleDice = []

	leftMass = 0
	rightMass = 0

	croupierAngle = "middle"
	get_node("croupier").set_rot(0)
	_move_needle("left", 0, -90)
	_move_needle("right", 0, -90)
	_move_needle("middle", 0, 90)
	get_node("infometer/infometerLeft/leftBar").set_value(0)
	get_node("infometer/infometerRight/rightBar").set_value(0)
	get_node("infometer/infometerMiddle/middleBar").set_value(100)

	informativeDice = []

	get_node("answerCircle/answerCircle").set_texture(load("res://assets/game/source/2/casino/purple_circle.png"))

	_connect_all()

	get_node("instructions").set_bbcode(global.get_game_text("loadedDiceRiddleInstructions") % str(3 - numberOfAttempts))

	#### Instanciation des dés et choix du dé pipé ####
	loadedDieNumber = randi() % numberOfDice + 1

	for i in range(1, numberOfDice + 1):
		var d = die.instance()
		d.add_to_group("dice")
		add_child(d)
		d.set_pos( Vector2(rand_range(3*get_viewport().get_visible_rect().size.x/4,get_viewport().get_visible_rect().size.x), 950) )
		d.set_number(i)
		if i == loadedDieNumber:
			var rand = randf()
			if rand > 0.5:
				d.set_mass(1.5)
			else:
				d.set_mass(0.5)
		informativeDice.append(d)
		middleDice.append(d)
	player.play_sound("dice")
####################

######## Connexion des Area2D détectant les dés ########
func _connect_all():
	leftBasket.get_node("Area2D").connect("body_enter", self, "_on_basket_body_update", ["in", "left"])
	rightBasket.get_node("Area2D").connect("body_enter", self, "_on_basket_body_update", ["in", "right"])
	leftBasket.get_node("Area2D").connect("body_exit", self, "_on_basket_body_update", ["out", "left"])
	rightBasket.get_node("Area2D").connect("body_exit", self, "_on_basket_body_update", ["out", "right"])
####################

######## Déconnexion des Area2D détectant les dés ########
#func _disconnect_all():
#	leftBasket.get_node("Area2D").disconnect("body_enter", self, "_on_basket_body_update")
#	rightBasket.get_node("Area2D").disconnect("body_enter", self, "_on_basket_body_update")
#	leftBasket.get_node("Area2D").disconnect("body_exit", self, "_on_basket_body_update")
#	rightBasket.get_node("Area2D").disconnect("body_exit", self, "_on_basket_body_update")
####################

######## Bouton de triche ########
func cheat():
	_riddle_solved()
####################

######## Faire pivoter le croupier de sa position actuelle vers une position cible ########
func _rotate_croupier(target):
	if croupierAngle != target:
		get_node("AnimationPlayer").play(str(croupierAngle,"_to_",target))
		croupierAngle = target
####################

######## Appelé lorsqu'un dé entre ou sort d'un panier ########
######## Met à jour la liste des dés contenus dans ce panier et la masse du panier, demande la màj de l'affichage ########
func _on_basket_body_update(body, event, basket):
	var area
	var diceList
	var mass

	if basket == "right":
		area = rightBasket.get_node("Area2D")
		diceList = rightBasketDice
		mass = rightMass
	elif basket == "left":
		area = leftBasket.get_node("Area2D")
		diceList = leftBasketDice
		mass = leftMass

	if event == "in":
		diceList.append(body)
		middleDice.remove(middleDice.find(body))
		mass += body.get_mass()
	elif event == "out":
		diceList.remove(diceList.find(body))
		middleDice.append(body)
		mass -= body.get_mass()

	if basket == "right":
		rightMass = mass
	elif basket == "left":
		leftMass = mass

	_update_information_display()
####################

######## Bouton Répondre ########
func _on_answerButton_pressed():
	var numberOfDiceInCircle = get_node("answerCircle/answerCircle/Area2D").get_overlapping_bodies().size()

	if numberOfDiceInCircle == 1:
		if loadedDieNumber == get_node("answerCircle/answerCircle/Area2D").get_overlapping_bodies()[0].get_number():
			_riddle_solved()
		else:
			_lose()

	elif numberOfDiceInCircle == 0:
		get_node("riddleOverlay").set_text(global.get_game_text("loadedDiceRiddleNoDie"))
	else: # Trop de dés dans le cercle
		get_node("riddleOverlay").set_text(global.get_game_text("loadedDieRiddleOverOneDie"))
####################

######## Mauvais dé placé dans le cercle ########
func _lose():
	get_node("answerCircle/answerCircle").set_texture(load("res://assets/game/source/2/casino/red_circle.png"))
	get_node("riddleOverlay").set_text(global.get_game_text("loadedDiceRiddleWrong"))
	get_node("instructions").set_bbcode(global.get_game_text("loadedDiceRiddleNewGameText"))
	_toggle_buttons()
	player.play_sound("wrong")
	get_node("riddleOverlay").disable_tip()
####################

######## Bon dé placé dans le cercle ########
func _riddle_solved():
	get_node("answerButton").set_disabled(true)
	get_node("answerCircle/answerCircle").set_texture(load("res://assets/game/source/2/casino/green_circle.png"))
	get_node("riddleOverlay").set_text(global.get_game_text("loadedDiceRiddleSolved"))
	global.set_state("source_2_casino_loadedDiceRiddleSolved", true)
	global.give_item("source_2_casino_loadedDiceToken")
	get_node("riddleOverlay").riddle_solved(2)
#	player.play_sound("right")
####################

######## Bouton Peser ########
func _on_weighButton_pressed():
	player.play_sound("menu")

	if leftBasketDice.size() != rightBasketDice.size():
		get_node("riddleOverlay").set_text(global.get_game_text("loadedDiceRiddleUnevenWeighing"))
	else:
		if leftBasketDice.size() == 0:
			get_node("riddleOverlay").set_text(global.get_game_text("loadedDiceRiddleEmptyWeighing"))
		elif knownResult:
			get_node("riddleOverlay").set_text(global.get_game_text("loadedDiceRiddleKnownResult"))
		else: # S'il y a au moins un dé dans la balance et le même nombre de dés de chaque côté
			numberOfAttempts += 1

			get_node("instructions").set_bbcode(global.get_game_text("loadedDiceRiddleInstructions") % str(3 - numberOfAttempts))
			if numberOfAttempts == 3:
				get_node("croupier/Sprite/weighButton").set_disabled(true)
				get_node("croupier/Sprite/weighButton").set_default_cursor_shape(0)

			var uninformativeDice = []

			if leftMass > rightMass:
				_rotate_croupier("left")
				uninformativeDice = [] + middleDice
				knownEvents[knownEvents.size()] = {"basket1": [] + leftBasketDice, "basket2": [] + rightBasketDice, "result":">"}
			elif leftMass < rightMass:
				_rotate_croupier("right")
				uninformativeDice = [] + middleDice
				knownEvents[knownEvents.size()] = {"basket1": [] + leftBasketDice, "basket2": [] + rightBasketDice, "result":"<"}
			else:
				_rotate_croupier("middle")
				uninformativeDice = [] + leftBasketDice + rightBasketDice # pour qu'il fasse une vraie copie

			var i = 0
			while i < informativeDice.size():
				if informativeDice[i] in uninformativeDice:
					informativeDice.remove(i)
				else:
					i += 1

	_update_information_display()
####################

######## Faire tourner l'aiguille d'un angle à un autre ########
func _move_needle(infometer, start, end):
	var tween = get_node("Tween")
	var animationDuration = 0.5

	var needle
	if infometer == "left":
		needle = get_node("infometer/infometerLeft/infometer/needle")
	elif infometer == "middle":
		needle = get_node("infometer/infometerMiddle/infometer/needle")
	elif infometer == "right":
		needle = get_node("infometer/infometerRight/infometer/needle")
	elif infometer == "bleft":
		needle = get_node("infometer/infometerLeft/uncertaintymeter/needle")
	elif infometer == "bmiddle":
		needle = get_node("infometer/infometerMiddle/uncertaintymeter/needle")
	elif infometer == "bright":
		needle = get_node("infometer/infometerRight/uncertaintymeter/needle")

	tween.interpolate_property(needle, "transform/rot", start, end, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	needle.set_rot(end)
	
	if infometer == "left":
		currentLeftNeedleAngle = end
	elif infometer == "right":
		currentRightNeedleAngle = end
	elif infometer == "middle":
		currentMiddleNeedleAngle = end
	elif infometer == "bleft":
		currentBLeftNeedleAngle = end
	elif infometer == "bright":
		currentBRightNeedleAngle = end
	elif infometer == "bmiddle":
		currentBMiddleNeedleAngle = end
####################

######## Mise à jour des infomètres ########
func _update_information_display():
	var newLeftNeedleAngle
	var newMiddleNeedleAngle
	var newRightNeedleAngle
	
	knownResult = false
	
	var remainingInformation = informativeDice.size()

	if leftBasketDice.size() == 0 and rightBasketDice.size() == 0:
		_move_needle("left", currentLeftNeedleAngle, -90)
		_move_needle("right", currentRightNeedleAngle, -90)
		_move_needle("middle", currentMiddleNeedleAngle, 90)
		_move_needle("bleft", currentBLeftNeedleAngle, 90)
		_move_needle("bright", currentBRightNeedleAngle, 90)
		_move_needle("bmiddle", currentBMiddleNeedleAngle, -90)
		get_node("infometer/infometerLeft/leftBar").set_value(0)
		get_node("infometer/infometerRight/rightBar").set_value(0)
		get_node("infometer/infometerMiddle/middleBar").set_value(100)
	elif leftBasketDice.size() > rightBasketDice.size():
		_move_needle("left", currentLeftNeedleAngle, 90)
		_move_needle("right", currentRightNeedleAngle, -90)
		_move_needle("middle", currentMiddleNeedleAngle, -90)
		_move_needle("bleft", currentBLeftNeedleAngle, -90)
		_move_needle("bright", currentBRightNeedleAngle, 90)
		_move_needle("bmiddle", currentBMiddleNeedleAngle, 90)
		get_node("infometer/infometerLeft/leftBar").set_value(100)
		get_node("infometer/infometerRight/rightBar").set_value(0)
		get_node("infometer/infometerMiddle/middleBar").set_value(0)
	elif leftBasketDice.size() < rightBasketDice.size():
		_move_needle("left", currentLeftNeedleAngle, -90)
		_move_needle("right", currentRightNeedleAngle, 90)
		_move_needle("middle", currentMiddleNeedleAngle, -90)
		_move_needle("bleft", currentBLeftNeedleAngle, 90)
		_move_needle("bright", currentBRightNeedleAngle, -90)
		_move_needle("bmiddle", currentBMiddleNeedleAngle, 90)
		get_node("infometer/infometerLeft/leftBar").set_value(0)
		get_node("infometer/infometerRight/rightBar").set_value(100)
		get_node("infometer/infometerMiddle/middleBar").set_value(0)
	else:
		var known_events = _get_known_events()
	
		if known_events:
			knownResult = true
			if known_events == ">":
				_move_needle("left", currentLeftNeedleAngle, 90)
				_move_needle("right", currentRightNeedleAngle, -90)
				_move_needle("middle", currentMiddleNeedleAngle, -90)
				_move_needle("bleft", currentBLeftNeedleAngle, -90)
				_move_needle("bright", currentBRightNeedleAngle, 90)
				_move_needle("bmiddle", currentBMiddleNeedleAngle, 90)
				get_node("infometer/infometerLeft/leftBar").set_value(100)
				get_node("infometer/infometerRight/rightBar").set_value(0)
				get_node("infometer/infometerMiddle/middleBar").set_value(0)
			elif known_events == "<":
				_move_needle("left", currentLeftNeedleAngle, -90)
				_move_needle("right", currentRightNeedleAngle, 90)
				_move_needle("middle", currentMiddleNeedleAngle, -90)
				_move_needle("bleft", currentBLeftNeedleAngle, 90)
				_move_needle("bright", currentBRightNeedleAngle, -90)
				_move_needle("bmiddle", currentBMiddleNeedleAngle, 90)
				get_node("infometer/infometerLeft/leftBar").set_value(0)
				get_node("infometer/infometerRight/rightBar").set_value(100)
				get_node("infometer/infometerMiddle/middleBar").set_value(0)
		else:
			var leftRightInformation = 0
			var middleInformation = 0
			var newLeftRightNeedleAngle
			var newMiddleNeedleAngle
			var newBLeftRightNeedleAngle
			var newBMiddleNeedleAngle
	
			for die in informativeDice:
				if die in leftBasketDice or die in rightBasketDice:
					leftRightInformation += 1
				else:
					middleInformation += 1
			
			if leftRightInformation == 0:
				knownResult = true
	
			get_node("infometer/infometerLeft/leftBar").set_value(float(leftRightInformation)/(2*float(remainingInformation))*100)
			get_node("infometer/infometerRight/rightBar").set_value(float(leftRightInformation)/(2*float(remainingInformation))*100)
			get_node("infometer/infometerMiddle/middleBar").set_value(float(middleInformation)/float(remainingInformation)*100)
	
			newLeftRightNeedleAngle = -(1-float(leftRightInformation)/float(remainingInformation))*90
			newMiddleNeedleAngle = -(1-float(middleInformation)*2/float(remainingInformation))*90
			newBLeftRightNeedleAngle = newMiddleNeedleAngle
			newBMiddleNeedleAngle = newLeftRightNeedleAngle
	
			_move_needle("left", currentLeftNeedleAngle, newLeftRightNeedleAngle)
			_move_needle("right", currentRightNeedleAngle, newLeftRightNeedleAngle)
			_move_needle("middle", currentMiddleNeedleAngle, newMiddleNeedleAngle)
			_move_needle("bleft", currentBLeftNeedleAngle, newBLeftRightNeedleAngle)
			_move_needle("bright", currentBRightNeedleAngle, newBLeftRightNeedleAngle)
			_move_needle("bmiddle", currentBMiddleNeedleAngle, newBMiddleNeedleAngle)
####################

######## Si une combinaison de dés déséquilibrant la balance est connue, on renvoie le côté duquel elle fait pencher la balance ########
func _get_known_events():
	for event in knownEvents:
		var u = 0
		for die in leftBasketDice:
			if die in knownEvents[event]["basket1"]:
				u += 1
		var v = 0
		for die in rightBasketDice:
			if die in knownEvents[event]["basket2"]:
				v += 1
		if u == leftBasketDice.size() and v == rightBasketDice.size():
			return knownEvents[event]["result"]

	for event in knownEvents:
		var u = 0
		for die in rightBasketDice:
			if die in knownEvents[event]["basket1"]:
				u += 1
		var v = 0
		for die in leftBasketDice:
			if die in knownEvents[event]["basket2"]:
				v += 1
		if u == rightBasketDice.size() and v == leftBasketDice.size():
			if knownEvents[event]["result"] == ">":
				return "<"
			else:
				return ">"
		
	return false
####################