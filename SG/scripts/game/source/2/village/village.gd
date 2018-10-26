extends Node2D

func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"village"})

	set_process_input(true)
	set_process(true)
	
	if !global.get_state("source_2_finished"):
		get_node("exit").queue_free()
	
	get_node("juliette").deactivateCollision()
	get_node("cinematic").connect("finished", self, "end_cinematic")
	
	if !global.get_state("source_2_village_enterVillagePlayed"):
		global.set_state("source_2_village_enterVillagePlayed", true)
		start_cinematic("enterVillage")
	elif global.get_state("source_2_finished") and !global.get_state("source_2_village_exitCasinoPlayed"):
		global.set_state("mapUnlocked", true)
		global.unlock_location("source_3")
		global.set_state("source_2_village_exitCasinoPlayed", true)
		start_cinematic("exitCasino")
	else:
		var introAnimation = get_node("cinematicAnimation").get_animation("enterVillage")
		var trackIdV = introAnimation.find_track(NodePath("character:transform/pos"))
		var lastKeyV = introAnimation.track_get_key_count(trackIdV) - 1
		var trackIdJ = introAnimation.find_track(NodePath("juliette:transform/pos"))
		var lastKeyJ = introAnimation.track_get_key_count(trackIdJ) - 1
		var posV = introAnimation.track_get_key_value(trackIdV,lastKeyV)
		var posJ = introAnimation.track_get_key_value(trackIdJ,lastKeyJ)

		if get_node("character").get_pos().x <= 0:
			get_node("character").set_pos(posV)
		get_node("juliette").set_pos(posJ)

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		# backToEntry
		if global.character_in_hitbox("backToEntry"):
			interact_backToEntry()
		# casinoDoor
		elif global.character_in_hitbox("casino_door"):
			interact_casinoDoor()
		# Juliette
		elif global.character_in_hitbox("juliette"):
			interact_juliette()
		# exit
		elif global.character_in_hitbox("exit"):
			interact_exit()

######## Fonctions pour input ########
func interact_backToEntry():
	global.set_target_node("gateEntrance")
	global.set_scene("res://scenes/game/source/1/source_entry.tscn")

func interact_casinoDoor():
	global.set_scene("res://scenes/game/source/2/casino.tscn")
	player.play_sound("woodendoor")

func interact_juliette():
	if global.get_state("source_2_finished"):
		get_node("gui").set_text(global.get_game_text("julietteInteract2"))
	else:
		get_node("gui").set_text(global.get_game_text("julietteInteract1"))

func interact_exit():
	if !global.get_state("source_2_quiz_finished"):
		Globals.get("gameState")["nextPath"] = "res://scenes/game/source/3/outside.tscn"
		global.set_scene("res://scenes/game/source/2/quiz/source_2_quiz.tscn")
	else:
		get_node("gui").set_text("Ouvrez la carte")
####################


func set_exit_pos():
	var doorPos = get_node("casino_door").get_pos()
	var characterPos = get_node("character").get_pos()
	var juliettePos = get_node("juliette").get_pos()
	characterPos.x = doorPos.x
	juliettePos.x = doorPos.x - 200
	get_node("character").set_pos(characterPos)
	get_node("juliette").set_pos(juliettePos)

func start_cinematic(name):
	if name == "exitCasino":
		set_exit_pos()
	get_node("cinematic").get_events(name)
	get_node("cinematic").freeze_scene()
	get_node("cinematic").start()

func end_cinematic():
	get_node("cinematic").unfreeze_scene()