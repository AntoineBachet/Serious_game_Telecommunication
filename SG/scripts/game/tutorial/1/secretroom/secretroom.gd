extends Node2D

var safe_opened = load("res://assets/game/tutorial/1/secretroom/safe_opened.png")
var desk_without_morse = load("res://assets/game/tutorial/1/secretroom/desk_without_morse.png")

func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"secretroom"})

	set_process(true)
	set_process_input(true)

	#### Nettoyage et mise à jour de la scène ####
	if global.get_state("tutorial_1_secretroom_safePuzzleSolved"):
		get_node("safe").set_texture(safe_opened)
		get_node("safe").set_scale(Vector2(1,1))
		get_node("character").cannotInteract("safe")
		
		# Affichage du message si on a réussi l'éngime du coffre-fort
		if !global.get_state("tutorial_1_secretroom_safeMessageShown"):
			global.set_state("tutorial_1_secretroom_safeMessageShown", true)
			get_node("gui").set_text(global.get_game_text("safeSolved"))

	if global.is_chapter_unlocked("morse"):
		get_node("desk").set_texture(desk_without_morse)

	if global.get_state("tutorial_1_secretroom_light"):
		get_node("lamp/light").start_light()

	#### Démarrage des cinématiques ####
	if !global.get_state("tutorial_1_secretroom_enter_roomPlayed"):
		global.set_state("tutorial_1_secretroom_enter_roomPlayed", true)
		start_cinematic("enter_room")
	elif global.get_state("tutorial_1_secretroom_computerPuzzleSolved") and !global.get_state("tutorial_1_secretroom_end_levelPlayed"):
		global.set_state("tutorial_1_secretroom_end_levelPlayed", true)
		global.set_state("tutorial_1_finished", true)
		start_cinematic("end_level")

######## Utilisation d'objets ########
func _process(delta):
	if global.get_used_item() != "":
		# Ampoule sur lampe
		if global.character_in_hitbox("lamp") and global.get_used_item() == "tutorial_1_secretroom_ampoule":
			use_lightbulb_on_lamp()
		# Oscilloscope sur lampe
		if global.character_in_hitbox("lamp") and global.get_used_item() == "tutorial_1_house_oscilloscope":
			use_oscilloscope_on_lamp()

		global.set_used_item("")
####################

######## Interactions avec l'environnement ########
func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		#Lamp
		if global.character_in_hitbox("lamp"):
			interact_lamp()
		#Desk
		if global.character_in_hitbox("desk"):
			interact_desk()
		#Entrance door
		if global.character_in_hitbox("entranceDoor"):
			interact_door()
		#Safe
		if global.character_in_hitbox("safe") and !global.get_state("tutorial_1_secretroom_safePuzzleSolved"):
			interact_safe()
		# Cartons
		if global.character_in_hitbox("cardboardBoxes"):
			interact_cardboardBoxes()

######## Fonctions pour process ########
func use_lightbulb_on_lamp():
	if !global.get_state("tutorial_1_secretroom_light_bulb_in_lamp"):
		global.set_state("tutorial_1_secretroom_light_bulb_in_lamp", true)
		global.use_item("tutorial_1_secretroom_ampoule")
		get_node("gui").set_text(global.get_game_text("lampInteractPutLightBulb"))

func use_oscilloscope_on_lamp():
	if global.get_state("tutorial_1_secretroom_light_played"):
		if global.get_state("tutorial_1_secretroom_light_played"):
			if global.save_scene():
				global.set_scene("res://scenes/game/tutorial/1/secretroom/lightPuzzle.tscn")
####################

######## Fonctions pour input ########
func interact_lamp():
	if !global.get_state("tutorial_1_secretroom_light_bulb_in_lamp"):
		get_node("gui").set_text(global.get_game_text("lampInteract"))
	else:
		if get_node("lamp/light").is_lamp_on():
			get_node("lamp/light").stop_light()
			get_node("gui").set_text(global.get_game_text("lampInteractOff"))
		else:
			get_node("lamp/light").start_light()
			if (!global.get_state("tutorial_1_secretroom_light_played")):
				global.set_state("tutorial_1_secretroom_light_played", true)
				get_node("cinematic").connect("finished", self, "end_cinematic", ["light"])
				start_cinematic("light")
			get_node("gui").set_text(global.get_game_text("lampInteractOn"))

func interact_desk():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/secretroom/desk.tscn")

func interact_door():
	global.set_target_node("secretDoor")
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/tutorial/1/house.tscn")

func interact_safe():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/secretroom/safePuzzle.tscn")

func interact_cardboardBoxes():
	if global.get_state("tutorial_1_secretroom_brailleDisplayPickedUp"):
		get_node("gui").set_text(global.get_game_text("cardboardBoxesInteract3"))
	elif global.get_state("tutorial_1_secretroom_cardboardBoxesInteract"):
		get_node("gui").set_text(global.get_game_text("cardboardBoxesInteract2"))
		global.give_item("tutorial_1_secretroom_brailleDisplay")
	else:
		get_node("gui").set_text(global.get_game_text("cardboardBoxesInteract"))
		global.set_state("tutorial_1_secretroom_cardboardBoxesInteract", true)
####################

######## Fonctions pour les cinématiques ########
func start_cinematic(name):
	if name == "end_level":
		get_node("juliette").bubble_left()
	get_node("cinematic").connect("finished", self, "end_cinematic", [name])
	get_node("cinematic").get_events(name)
	get_node("cinematic").freeze_scene()
	get_node("cinematic").start()

func end_cinematic(name):
	get_node("cinematic").unfreeze_scene()
	if name == "end_level":
		get_node("juliette").queue_free()
####################