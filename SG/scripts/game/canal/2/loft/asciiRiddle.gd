extends Control

var receivedMessage
var receivedWord
var originalWord

var messageContainer
var typingField
var validateButton

######## Initialisation ########
func _ready():
	global.set_details({"area":"canal", "level":"2", "scene":"loft"})

	set_process_input(true)

	#### Récupération et préparation de l'énigme ####
	var riddle = global.get_riddle("asciiRiddle")
	receivedMessage = riddle["receivedMessage"]
	receivedWord = riddle["receivedWord"]
	originalWord = riddle["originalWord"]

	messageContainer = get_node("VBoxContainer/messageContainer")
	var lines = 3
	displayMessage(receivedMessage, lines)

	typingField = get_node("VBoxContainer/typingZone/HBoxContainer/typingField")
	typingField.grab_focus()
	get_node("riddleOverlay").deactivate_hotkeys()

	#### Affichage et traduction des textes + curseurs ####
	validateButton = get_node("VBoxContainer/typingZone/HBoxContainer/validateButton")
	validateButton.set_text(global.get_gui_text("validateButton"))
	validateButton.set_default_cursor_shape(2)

	if global.get_state("canal_2_loft_asciiRiddleSolved"):
		get_node("riddleOverlay").set_tip("")
		deactivate_input()
	elif global.get_state("canal_2_loft_asciiRiddleReceivedMessageDecoded"):
		get_node("riddleOverlay").set_tip(global.get_game_text("asciiRiddleTip3"))
	else:
		get_node("riddleOverlay").set_tip_list([global.get_game_text("asciiRiddleTip1"), global.get_game_text("asciiRiddleTip2")])
####################

######## Gestion des inputs ########
func _input(event):
	if typingField.has_focus() and event.type == InputEvent.KEY and event.scancode == KEY_RETURN and !event.is_echo() and event.pressed:
		_on_validateButton_pressed()

func _on_validateButton_pressed():
	if typingField.get_text().capitalize() == receivedWord:
		get_node("riddleOverlay").set_tip(global.get_game_text("asciiRiddleTip3"))
		get_node("riddleOverlay").set_text(global.get_game_text("asciiRiddleAnswer1"))
		global.set_state("canal_2_loft_asciiRiddleReceivedMessageDecoded", true)
		deactivate_input()
		get_node("riddleOverlay").riddle_solved(2)
	elif typingField.get_text() == originalWord:
		get_node("riddleOverlay").set_text(global.get_game_text("asciiRiddleAnswer2"))
		global.set_state("canal_2_loft_asciiRiddleSolved", true)
		deactivate_input()
		get_node("riddleOverlay").riddle_solved(2.5)
	else:
		player.play_sound("wrong")

func deactivate_input():
	validateButton.set_disabled(true)
	typingField.set_editable(false)
	set_process_input(false)
####################

######## Affichage sous forme matricielle du message ########
func displayMessage(message, lines):
	var line = 0
	addColumn()
	var bitNumber = 0
	for bit in message:
		line += 1
		bitNumber += 1
		if bitNumber >= message.length()-(lines-1): # Les derniers bits de chaque colonne et la dernière colonne sont des bits de contrôle
			addControlBit(bit, line, message.length()/lines)
		elif line != lines :
			addControlBit(bit, 0, 0)
		else:			# Les autres sont des bits d'information
			addControlBit(bit, line, (bitNumber-bitNumber%lines)/lines)
			line = 0
			addColumn()
####################

######## Ajout d'une colonne ########
func addColumn():
	var messageColumn = VBoxContainer.new()
	messageColumn.set_h_size_flags(2)
	messageColumn.set_v_size_flags(1)
	messageColumn.set_custom_minimum_size(Vector2(60,0))
	messageContainer.add_child(messageColumn)
####################

######## Ajout d'un bit ########
func addControlBit(bit, line, column):
	var bitDisplay = Label.new()
	bitDisplay.set_text(bit)
	bitDisplay.set_h_size_flags(2)
	bitDisplay.set_v_size_flags(2)
	bitDisplay.set_align(1)
	bitDisplay.add_font_override("font",load("res://fonts/segoeuisl30.fnt"))
	bitDisplay.add_color_override("font_color", Color(0,0,0))
	messageContainer.get_children()[-1].add_child(bitDisplay)
####################

######## Bouton de triche ########
func cheat():
	typingField.set_text(originalWord)
####################