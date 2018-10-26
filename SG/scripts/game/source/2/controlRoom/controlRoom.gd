extends Node2D

func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"controlRoom"})

	set_process_input(true)
	set_process(true)
	
	get_node("cinematic").connect("finished", self, "end_cinematic")
	if !global.get_state("source_2_controlRoom_enterControlRoomPlayed"):
		global.set_state("source_2_controlRoom_enterControlRoomPlayed", true)
		start_cinematic("enterControlRoom")
	elif global.get_state("source_2_controlRoom_controlRobotSolved") and !global.get_state("source_2_controlRoom_finishControlRobotPlayed"):
		global.set_state("source_2_controlRoom_finishControlRobotPlayed", true)
		start_cinematic("finishControlRobot")

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		# backToCasino
		if global.character_in_hitbox("backToCasino"):
			interact_backToCasino()
		# computer
		elif global.character_in_hitbox("computer"):
			interact_computer()
		elif global.character_in_hitbox("juliette"):
			interact_juliette()

######## Fonctions pour input ########
func interact_backToCasino():
	global.set_target_node("controlRoom")
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/source/2/casino.tscn")

func interact_computer():
	if get_node("/root/global").save_scene():
		if global.get_state("source_2_controlRoom_unlockedComputer"):
			# Le joueur a déjà déverrouillé l'ordinateur de contrôle
			get_node("/root/global").set_scene("res://scenes/game/source/2/controlRoom/unlockedComputer.tscn")
		else:
			get_node("/root/global").set_scene("res://scenes/game/source/2/controlRoom/shannonRiddle.tscn")

func interact_juliette():
	get_node("gui").set_text(global.get_game_text("julietteInteract"))
####################

func start_cinematic(name):
	get_node("cinematic").freeze_scene()
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic():
	get_node("cinematic").unfreeze_scene()