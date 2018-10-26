extends Node2D

var anthillCrushed

######## Initialisation ########
func _ready():
	global.set_details({"area":"canal", "level":"1", "scene":"entrance"})

	set_process(true)
	set_process_input(true)

	#### Placement initial de Juliette et Victor si la cinématique d'intro a été jouée ####
	if global.get_state("canal_1_entrance_introPlayed"):
		var introAnimation = get_node("cinematicAnimation").get_animation("enter_area")
		var trackIdV = introAnimation.find_track(NodePath("character:transform/pos"))
		var lastKeyV = introAnimation.track_get_key_count(trackIdV) - 1
		var trackIdJ = introAnimation.find_track(NodePath("juliette:transform/pos"))
		var lastKeyJ = introAnimation.track_get_key_count(trackIdJ) - 1
		var posV = introAnimation.track_get_key_value(trackIdV,lastKeyV)
		var posJ = introAnimation.track_get_key_value(trackIdJ,lastKeyJ)

		if get_node("character").get_pos().x<0:
			get_node("character").set_pos(posV)
		get_node("juliette").set_pos(posJ)

	#### Nettoyage et mise à jour de la scène ####
	if global.get_state("canal_1_entrance_outroPlayed"):
		get_node("freddy/StaticBody2D").free()
	if global.get_state("canal_1_entrance_anthillDestroyed"):
		anthillCrushed = load("res://assets/game/canal/1/entrance/anthill_crushed.png")
		get_node("anthill").set_texture(anthillCrushed)

	#### Cinématique d'intro ####
	if !global.get_state("canal_1_entrance_introPlayed"):
		global.set_state("canal_1_entrance_introPlayed", true)
		start_cinematic("intro")
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "canal_1_entrance_entranceRiddle":
			use_entranceRiddle()
		if global.get_used_item() == "tutorial_1_village_shovel":
			if global.character_in_hitbox("freddy"):
				use_shovel_freddy()
			if global.character_in_hitbox("anthill"):
				use_shovel_anthill()

		global.set_used_item("")

######## Interactions avec l'environnement ########
func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			if global.character_in_hitbox("freddy"):
				interact_freddy()
			if global.character_in_hitbox("juliette"):
				interact_juliette()
			if global.character_in_hitbox("bin"):
				interact_bin()
			if global.character_in_hitbox("anthill"):
				interact_anthill()
			if global.character_in_hitbox("exitToHospital"):
				interact_exit()
####################

######## Fonctions pour process ########
func use_entranceRiddle():
	if global.save_scene():
		global.set_scene("res://scenes/game/canal/1/entrance/entrance_riddle.tscn")

func use_shovel_freddy():
	get_node("gui").set_text(global.get_game_text("useShovelFreddy"))

func use_shovel_anthill():
	if !global.get_state("canal_1_entrance_anthillDestroyed"):
		anthillCrushed = load("res://assets/game/canal/1/entrance/anthill_crushed.png")
		get_node("gui").set_text(global.get_game_text("useShovelAnthill"))
		global.set_state("canal_1_entrance_anthillDestroyed", true)
		get_node("anthill").set_texture(anthillCrushed)
####################

######## Fonctions pour input ########
func interact_exit():
	if global.save_scene():
		global.set_scene("res://scenes/game/canal/2/building.tscn")

func interact_anthill():
	if global.get_state("canal_1_entrance_anthillDestroyed"):
		get_node("gui").set_text(global.get_game_text("interactAnthillCrushed"))
	else:
		get_node("gui").set_text(global.get_game_text("interactAnthill"))

func interact_bin():
	if global.get_state("canal_1_entrance_binInteract"):
		get_node("gui").set_text(global.get_game_text("binInteract2"))
	else:
		get_node("gui").set_text(global.get_game_text("binInteract1"))
		global.set_state("canal_1_entrance_binInteract", true)

func interact_freddy():
	if global.get_state("canal_1_entrance_outroPlayed"):
		# Quand on a déjà donné la solution de l'énigme à Freddy
		get_node("gui").set_text(global.get_game_text("interactFreddy4"))
	elif has_node("freddy/StaticBody2D") and global.get_state("canal_1_entrance_entranceRiddleSolved"):
		# Quand on vient de résoudre l'énigme et qu'on va voir Freddy
		global.set_state("canal_1_entrance_outroPlayed", true)
		start_cinematic("outro")
		get_node("freddy/StaticBody2D").free()
		global.use_item("canal_1_entrance_entranceRiddle")
	elif global.get_state("canal_1_entrance_entranceRiddleReceivedMessageDecoded"):
		# Quand on a mal résolu l'énigme et qu'on va voir Freddy
		get_node("gui").set_text(global.get_game_text("interactFreddy3"))
	elif !global.get_state("canal_1_entrance_entranceRiddlePickedUp"):
		# Quand on n'a jamais parlé à Freddy
		get_node("gui").set_text(global.get_game_text("interactFreddy1"))
		global.give_item("canal_1_entrance_entranceRiddle")
	else:
		# Quand on parle à Freddy avant d'avoir (bien ou mal) résolu l'énigme
		get_node("gui").set_text(global.get_game_text("interactFreddy2"))
	
func interact_juliette():
	if !has_node("freddy/StaticBody2D") and global.get_state("canal_1_entrance_entranceRiddleSolved"):
		get_node("gui").set_text(global.get_game_text("interactJuliette3"))
	elif global.get_state("canal_1_entrance_entranceRiddleSolved"):
		get_node("gui").set_text(global.get_game_text("interactJuliette2"))
	else:
		get_node("gui").set_text(global.get_game_text("interactJuliette"))
####################

######## Fonctions pour les cinématiques ########
func start_cinematic(name):
	if name == "outro":
		get_node("character").bubble_left()
	get_node("cinematic").connect("finished", self, "end_cinematic", [name])
	get_node("cinematic").freeze_scene()
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic(name):
	get_node("cinematic").disconnect("finished", self, "end_cinematic")
	get_node("cinematic").unfreeze_scene()
	if name == "outro":
		get_node("character").bubble_right()
####################