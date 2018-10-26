extends Node2D

var right_answer = ""

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"controlRoom"})

	set_process(true)

	if !global.get_state("source_2_controlRoom_login"):
		global.set_state("source_2_controlRoom_login", true)
		player.play_sound("computer_login")

	get_node("control_robot_program").connect("pressed", self, "robot_program_pressed")
	get_node("control_robot_program").set_default_cursor_shape(2)

	get_node("robot_program/validate").connect("pressed", self, "validate")
	get_node("robot_program/validate").set_default_cursor_shape(2)
	get_node("robot_program").connect("hide", self, "hide_window")

	get_node("documents_program").connect("pressed", self, "documents_program")
	get_node("documents_program").set_default_cursor_shape(2)

	get_node("mail_program").connect("pressed", self, "mail_program")
	get_node("mail_program").set_default_cursor_shape(2)

	var puzzle = global.get_riddle("unlockControlRobots")
	right_answer = stringToRightForm(puzzle["answer"], 2)

	var language = settings.get_language()
	if !puzzle["question"].has(language):
		language = "fr"
	get_node("robot_program").set_title(global.get_game_text("controlRobotProgramLabel"))
	get_node("robot_program/RichTextLabel").set_bbcode(puzzle["question"][language])

	get_node("robot_program/validate").set_text(global.get_gui_text("validateButton"))
	get_node("riddleOverlay").set_tip(global.get_game_text("clickOnTheIconTip"))
	get_node("control_robot_program/Label").set_text(global.get_game_text("controlRobotProgramLabel"))
	get_node("documents_program/Label").set_text(global.get_game_text("documentsProgramLabel"))
	get_node("mail_program/Label").set_text(global.get_game_text("mailProgramLabel"))

	get_node("error").set_title(global.get_gui_text("error"))
	if global.get_state("source_2_controlRoom_controlRobotSolved"):
		get_node("error").set_text(global.get_game_text("alreadyExecuted"))
		get_node("riddleOverlay").disable_tip()
	else:
		get_node("error").set_text(global.get_game_text("error"))
####################

### Validation de l'énigme via le clavier
func _input(event):
	if get_node("robot_program").is_visible() and get_node("robot_program/LineEdit").has_focus() and event.type == InputEvent.KEY and event.scancode == KEY_RETURN and  !event.is_echo() and event.pressed:
		validate()

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

func cheat():
	get_node("robot_program/LineEdit").set_text(right_answer)

### Affichage du programme
func robot_program_pressed():
	player.play_sound("computer_button_pressed")
	robot_program()
	
func robot_program():
	if !global.get_state("source_2_controlRoom_controlRobots"):
		get_node("riddleOverlay").set_tip(global.get_game_text("entropieTip"))
		get_node("robot_program").show()
		get_node("robot_program/LineEdit").grab_focus()
		set_process_input(true)
	### Si on n'a pas réussi les deux énigmes du casino, message d'erreur
	elif !(global.get_state("source_2_casino_loadedDiceRiddleSolved") and global.get_state("source_2_casino_cardRiddleSolved")):
		get_node("riddleOverlay").set_tip(global.get_game_text("unlockTheRobotsTip"))
		player.play_sound("computer_error")
		get_node("error").show()
	elif !global.get_state("source_2_controlRoom_controlRobotSolved"):
		global.set_scene("res://scenes/game/source/2/controlRoom/controlRobot.tscn")
	else:
		player.play_sound("computer_error")
		get_node("error").show()

func hide_window():
	get_node("riddleOverlay").set_tip(global.get_game_text("clickOnTheIconTip"))
	set_process_input(false)

### Bouton de validation. Mise en forme de la réponse et comparaison
func validate():
	var answer = get_node("robot_program/LineEdit").get_text()
	answer = stringToRightForm(answer, 2)
	if answer == right_answer:
		unlockControlRobots()
	else:
		player.play_sound("wrong")

##### Enigme réussie : on envoie vers le mini-jeu
func unlockControlRobots():
	global.set_state("source_2_controlRoom_controlRobots", true)
	player.play_sound("right")
	get_node("Timer").connect("timeout", self, "_on_Timer_timeout")
	get_node("Timer").set_wait_time(1)
	get_node("Timer").start()

func _on_Timer_timeout():
	get_node("robot_program").hide()
	robot_program()

### Ecriture des String sous une forme correcte : 9.99
func stringToRightForm(s, nb_decimal):
	s = s.replace(',', '.')
	var split = s.split('.')
	### On met sous forme décimale
	if split.size() == 1:
		split.append('')
	if split.size() == 2:
		### On enlève les décimales en trop
		if split[1].length() > nb_decimal:
			split[1] = split[1][0] + split[1][1]
		### On rajoute des décimales nulles
		while split[1].length() < nb_decimal:
			split[1] = split[1] + '0'
		### On enlève les zéros en trop
		while split[0].length() > 1 and split[0][0] == '0':
			split[0] = split[0].right(1)
		return split[0] + '.' + split[1]
	else: ### Si on a écrit n'importe quoi
		return ''

func documents_program():
	player.play_sound("computer_button_pressed")
	if !global.is_entry_s_unlocked("source", "section1", "entry3"):
		global.unlock_entry_s("source", "section1", "entry3")
		get_node("riddleOverlay").set_text(global.get_game_text("documentsProgram1"))
		get_node("riddleOverlay").update()
	else:
		get_node("riddleOverlay").set_text(global.get_game_text("documentsProgram2"))

func mail_program():
	player.play_sound("computer_button_pressed")
	if !global.is_entry_s_unlocked("source", "section1", "entry7"):
		global.unlock_entry_s("source", "section1", "entry7")
		get_node("riddleOverlay").set_text(global.get_game_text("mailProgram1"))
		get_node("riddleOverlay").update()
	else:
		get_node("riddleOverlay").set_text(global.get_game_text("mailProgram2"))