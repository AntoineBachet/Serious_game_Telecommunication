extends Node2D

var password = ""

######## Initialisation ########
func _ready():
	global.set_details({"area":"ligne", "level":"1", "scene":"entry"})

	set_process(true)
	set_process_input(true)

	#### Placement de Juliette et Victor ####
	if global.get_state("ligne_1_entry_intro_played"):
		var introAnimation = get_node("cinematicAnimation").get_animation("enter")
		var trackIdV = introAnimation.find_track(NodePath("character:transform/pos"))
		var lastKeyV = introAnimation.track_get_key_count(trackIdV) - 1
		var trackIdJ = introAnimation.find_track(NodePath("juliette:transform/pos"))
		var lastKeyJ = introAnimation.track_get_key_count(trackIdJ) - 1
		var posV = introAnimation.track_get_key_value(trackIdV,lastKeyV)
		var posJ = introAnimation.track_get_key_value(trackIdJ,lastKeyJ)

		if get_node("character").get_pos().x <= 0:
			get_node("character").set_pos(posV)
		get_node("juliette").set_pos(posJ)

	#### Récupération du mot de passe ####
	password = global.get_riddle("answer")
	var language = settings.get_language()
	if !password.has("language"):
		language = "fr"
	password = password[language]

	#### Position initiale du robot ####
	if global.get_state("ligne_1_entrySolved"):
		var robot_pos = get_node("robot").get_pos()
		robot_pos.x = 1350
		get_node("robot").set_pos(robot_pos)

	password_hide()

	#### Cinématique d'intro ####
	if !global.get_state("ligne_1_entry_introPlayed"):
		global.set_state("ligne_1_entry_introPlayed", true)
		start_cinematic("intro")
	else:
		#### On remet Juliette à sa place
		var pos_j = get_node("juliette").get_pos()
		pos_j.x = 50
		get_node("juliette").set_pos(pos_j)
		
		#### Si on démarre au début du niveau, on met Victor à sa place
		var pos_v = get_node("character").get_pos()
		if pos_v.x < 0:
			pos_v.x = 250
			get_node("character").set_pos(pos_v)
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_house_oscilloscope" and !global.get_state("ligne_1_entrySolved"):
			if global.character_in_hitbox("electrical_box"):
				go_to_riddle()
		else: # pour que l'oscillo soit utilisé directement dans electrical_box
			global.set_used_item("")

######## Interactions avec l'environnement ########
func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		# Juliette
		if global.character_in_hitbox("juliette"):
			interact_juliette()
		# Electrical box
		if global.character_in_hitbox("electrical_box"):
			interact_electrical_box()
		# Door
		elif global.character_in_hitbox("door"):
			interact_door()
		# Robot
		elif global.character_in_hitbox("robot"):
			interact_robot()
####################

######## Fonctions pour input ########
func interact_juliette():
	if global.get_state("ligne_1_entrySolved"):
		get_node("gui").set_text( global.get_game_text("interactJuliette4") )
	elif global.get_state("ligne_1_talkedToRobot"):
		if global.get_state("ligne_1_signalFound"):
			get_node("gui").set_text( global.get_game_text("interactJuliette3") )
		else:
			get_node("gui").set_text( global.get_game_text("interactJuliette2") )
	else:
		get_node("gui").set_text( global.get_game_text("interactJuliette") )
####################

######## Fonctions pour input ########
func interact_electrical_box():
	if global.save_scene():
		global.set_scene("res://scenes/game/ligne/1/entrance/electrical_box_zoom.tscn")

func interact_door():
	global.set_state("ligne_1_finished", true)
	# Vers le niveau suivant
	if global.save_scene():
		global.set_scene("res://scenes/game/tobecontinued.tscn")

func interact_robot():
	if !global.get_state("ligne_1_talkedToRobot"):
		global.set_state("ligne_1_talkedToRobot", true)
	if global.get_state("ligne_1_entrySolved"):
		start_cinematic("talk_with_robot2")
	else:
		start_cinematic("talk_with_robot")
####################

######## Enigme ########
func go_to_riddle():
	if global.save_scene():
		global.set_scene("res://scenes/game/ligne/1/entrance/electrical_box_zoom.tscn")

func password_show():
	get_node("password").show()
	get_node("password/LineEdit").set_text("")
	get_node("password/Button").set_disabled(false)
	get_node("password/Button").connect("pressed", self, "_on_password_pressed")

func password_hide():
	get_node("password").hide()
	get_node("password/Button").set_disabled(true)

func _on_password_pressed():
	password_hide()
	var text = get_node("password/LineEdit").get_text()
	text = text.to_lower()
	if text == password:
		start_cinematic("can_pass")
		global.set_state("ligne_1_entrySolved", true)
		player.play_sound("right")
	else:
		start_cinematic("cannot_pass")
		player.play_sound("wrong")
####################

######## Fonctions pour les cinématiques ########
func start_cinematic(name):
	if name != "can_pass" and name != "cannot_pass":
		get_node("cinematic").freeze_scene()
	get_node("cinematic").connect("finished", self, "end_cinematic", [name])
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic(name):
	get_node("cinematic").disconnect("finished", self, "end_cinematic")
	if name != "talk_with_robot":
		get_node("cinematic").unfreeze_scene()
	else:
		password_show()
####################