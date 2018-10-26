extends Node2D

var canInteractPiano = true
var canInteractPianoRobot = true

func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"miniGameRoom"})

	set_process_input(true)
	set_process(true)

	### Cinématique si on a fini le piano
	if global.get_state("source_2_miniGameRoom_pianoSolved"):
		get_node("character").cannotInteract("pianoRobot")
		canInteractPianoRobot = false
		if !global.get_state("source_2_miniGameRoom_pianoSolvedPlayed"):
			global.set_state("source_2_miniGameRoom_pianoSolvedPlayed", true)
			start_cinematic("pianoSolved")

	## On ne peut pas aller dans le piano si on a pas d'abord parlé au robot
	elif !global.get_state("source_2_miniGameRoom_pianoHelpPlayed"):
		get_node("character").cannotInteract("piano")
		canInteractPiano = false
	
	if global.is_picked_up("source_2_miniGameRoom_sparePart") and !global.get_state("source_2_miniGameRoom_blackjackMessageShown"):
		get_node("gui").set_text(global.get_game_text("blackjackMessage"))
		global.set_state("source_2_miniGameRoom_blackjackMessageShown", true)
	
	get_node("cinematic").connect("finished", self, "end_cinematic")

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		# backToCasino
		if global.character_in_hitbox("backToCasino"):
			interact_backToCasino()
		# piano
		elif canInteractPiano and global.character_in_hitbox("piano"):
			interact_piano()
		# pianoRobot
		elif canInteractPianoRobot and global.character_in_hitbox("pianoRobot"):
			interact_pianoRobot()
		# Juliette
		elif global.character_in_hitbox("juliette"):
			interact_juliette()
		#le bar
		elif global.character_in_hitbox("bar"):
			interact_bar()

######## Fonctions pour input ########
func interact_backToCasino():
	global.set_target_node("miniGameRoom")
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/source/2/casino.tscn")

func interact_piano():
	if get_node("/root/global").save_scene():
		get_node("/root/global").set_scene("res://scenes/game/source/2/miniGameRoom/piano.tscn")

func interact_pianoRobot():
	if !global.get_state("source_2_miniGameRoom_pianoHelpPlayed"):
		global.set_state("source_2_miniGameRoom_pianoHelpPlayed", true)
		get_node("character").canInteract("piano")
		canInteractPiano = true
		start_cinematic("pianoHelp")
	else:
		get_node("gui").set_text( global.get_game_text("talkWithPianoRobot") )

func interact_juliette():
	get_node("gui").set_text(global.get_game_text("julietteInteract"))

func interact_bar():
	if !global.get_state("source_2_miniGameRoom_barInteract1"):
		get_node("gui").set_text(global.get_game_text("barInteract1"))
		global.set_state("source_2_miniGameRoom_barInteract1", true)
	elif !global.get_state("source_2_miniGameRoom_barInteract2"):
		get_node("gui").set_text(global.get_game_text("barInteract2"))
		global.set_state("source_2_miniGameRoom_barInteract2", true)
	elif !global.get_state("source_2_miniGameRoom_barInteract3"):
		get_node("gui").set_text(global.get_game_text("barInteract3"))
		global.set_state("source_2_miniGameRoom_barInteract3", true)
	elif !global.get_state("source_2_miniGameRoom_barInteract4"):
		get_node("gui").set_text(global.get_game_text("barInteract4"))
		global.set_state("source_2_miniGameRoom_barInteract4", true)
	elif !global.get_state("source_2_miniGameRoom_barInteract5"):
		get_node("gui").set_text(global.get_game_text("barInteract5"))
		global.set_state("source_2_miniGameRoom_barInteract5", true)
	elif !global.is_picked_up("source_2_miniGameRoom_sparePart"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/2/miniGameRoom/blackjack.tscn")
	else:
		get_node("gui").set_text(global.get_game_text("barInteract6"))
####################

### Cinématiques
func start_cinematic(name):
	get_node("cinematic").get_events(name)
	get_node("cinematic").freeze_scene()
	get_node("cinematic").start()

func end_cinematic():
	get_node("cinematic").unfreeze_scene()