extends Node2D

func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"outside"})

	set_process(true)
	set_process_input(true)

	get_node("cinematic").connect("finished", self, "end_cinematic")
	if !global.get_state("source_3_outside_introPlayed"):
		global.set_state("source_3_outside_introPlayed", true)
		start_cinematic("intro")
	
	else:
		# Détermination des positions de Victor et Juliette à la fin de la cinématique
		var introAnimation = get_node("cinematicAnimation").get_animation("enter")
		var trackIdV = introAnimation.find_track(NodePath("character:transform/pos"))
		var lastKeyV = introAnimation.track_get_key_count(trackIdV) - 1
		var trackIdJ = introAnimation.find_track(NodePath("juliette:transform/pos"))
		var lastKeyJ = introAnimation.track_get_key_count(trackIdJ) - 1
		var posV = introAnimation.track_get_key_value(trackIdV,lastKeyV)
		var posJ = introAnimation.track_get_key_value(trackIdJ,lastKeyJ)

		if get_node("character").get_pos().x < -550:
			get_node("character").set_pos(posV)
		get_node("juliette").set_pos(posJ)
		

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")


func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			if global.character_in_hitbox("juliette"):
				interact_juliette()
			elif global.character_in_hitbox("doorToShop"):
				interact_doorToShop()
			elif global.character_in_hitbox("doorToChildren"):
				interact_doorToChildren()
			elif global.character_in_hitbox("roadsign"):
				interact_roadsign()
			elif global.character_in_hitbox("pump"):
				interact_pump()

func interact_doorToShop():
	player.play_sound("woodendoor")
	global.set_target_node("doorToOutside")
	global.set_scene("res://scenes/game/source/3/shop.tscn")

func interact_juliette():
	if global.get_state("source_3_finished"):
		get_node("gui").set_text( global.get_game_text("interactJuliette2") )
	else:
		get_node("gui").set_text( global.get_game_text("interactJuliette") )
	
func interact_doorToChildren():
	global.set_scene("res://scenes/game/source/3/children_area.tscn")

func interact_roadsign():
	get_node("gui").set_text( global.get_game_text("interactRoadsign"))

func interact_pump():
	get_node("gui").set_text( global.get_game_text("interactPump") )


func start_cinematic(name):
	get_node("cinematic").get_events(name)
	get_node("cinematic").freeze_scene()
	get_node("cinematic").start()

func end_cinematic():
	get_node("cinematic").unfreeze_scene()