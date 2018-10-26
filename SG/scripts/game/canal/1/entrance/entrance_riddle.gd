extends Control

var receivedMessage
var receivedWord
var originalWord

var messageContainer
var typingField
var validateButton

######## Initialisation ########
func _ready():
	global.set_details({"area":"canal", "level":"1", "scene":"entrance"})

	set_process(true)
	set_process_input(true)

	#### Récupération et préparation de l'énigme ####
	var riddle = global.get_riddle("entranceRiddle")
	receivedMessage = riddle["receivedMessage"]
	receivedWord = riddle["receivedWord"]
	originalWord = riddle["originalWord"]

	messageContainer = get_node("VBoxContainer/messageContainer")
	var lines = 4
	displayMessage(receivedMessage, lines)

	typingField = get_node("VBoxContainer/typingZone/HBoxContainer/typingField")
	typingField.grab_focus()
	get_node("riddleOverlay").deactivate_hotkeys()

	#### Affichage et traduction des textes + curseurs ####
	validateButton = get_node("VBoxContainer/typingZone/HBoxContainer/validateButton")
	validateButton.set_text(global.get_gui_text("validateButton"))
	validateButton.set_default_cursor_shape(2)

	if global.get_state("canal_1_entrance_entranceRiddleSolved"):
		get_node("riddleOverlay").set_tip("")
		deactivate_input()
	elif global.get_state("canal_1_entrance_entranceRiddleReceivedMessageDecoded"):
		get_node("riddleOverlay").set_tip(global.get_game_text("entranceRiddleTip3"))
	else:
		get_node("riddleOverlay").set_tip_list([global.get_game_text("entranceRiddleTip1"), global.get_game_text("entranceRiddleTip2")])
####################

######## Utilisation d'objets ########
func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")
####################

######## Gestion des inputs ########
func _input(event):
	if typingField.has_focus() and event.type == InputEvent.KEY and event.scancode == KEY_RETURN and !event.is_echo() and event.pressed:
		_on_validateButton_pressed()

func _on_validateButton_pressed():
	if typingField.get_text().capitalize() == receivedWord:
		get_node("riddleOverlay").set_tip(global.get_game_text("entranceRiddleTip3"))
		get_node("riddleOverlay").set_text(global.get_game_text("entranceRiddleAnswer1"))
		global.set_state("canal_1_entrance_entranceRiddleReceivedMessageDecoded", true)
		deactivate_input()
		get_node("riddleOverlay").riddle_solved(2)
	elif typingField.get_text().capitalize() == originalWord:
		get_node("riddleOverlay").set_text(global.get_game_text("entranceRiddleAnswer2"))
		global.set_state("canal_1_entrance_entranceRiddleSolved", true)
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
		if bitNumber >= message.length()-(lines-1):			# Les derniers bits de chaque colonne et la dernière colonne sont des bits de contrôle
			addControlBit(bit, true, line, message.length()/lines)
		elif line != lines :
			addControlBit(bit, false, 0, 0)
		else:			# Les autres sont des bits d'information
			addControlBit(bit, true, line, (bitNumber-bitNumber%lines)/lines)
			line = 0
			addColumn()
####################

######## Ajout d'une colonne ########
func addColumn():
	var messageColumn = VBoxContainer.new()
	messageColumn.set_h_size_flags(2)
	messageColumn.set_v_size_flags(1)
	messageColumn.set_custom_minimum_size(Vector2(40,0))
	messageContainer.add_child(messageColumn)
####################

######## Ajout d'un bit ########
func addControlBit(bit, boolean, line, column):			#False pour un bit normal, True pour un bit de contrôle
	var bitDisplay = Label.new()
	bitDisplay.set_text(bit)
	bitDisplay.set_h_size_flags(2)
	bitDisplay.set_v_size_flags(2)
	bitDisplay.set_align(1)
	bitDisplay.add_font_override("font",load("res://fonts/segoeuisl30.fnt"))
	bitDisplay.add_color_override("font_color", Color(0,0,0))
	if boolean:
		bitDisplay.add_color_override("font_color", Color(0.5,0.5,0.5))
	messageContainer.get_children()[-1].add_child(bitDisplay)
####################

######## Bouton de triche ########
func cheat():
	typingField.set_text(originalWord)
####################