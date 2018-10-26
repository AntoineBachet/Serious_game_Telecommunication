extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"uselesshouse"})

	set_process_input(true)
	set_process(true)

	#### Nettoyage de la scène ####
	if global.is_picked_up("tutorial_1_uselesshouse_plush") or global.get_state("tutorial_1_uselesshouse_plushGiven"):
		get_node("pikachu").free()
####################

######## Interactions avec l'environnement ########
func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		# Door
		if global.character_in_hitbox("door"):
			interact_door()

		# Tableau morse
		if global.character_in_hitbox("walrus"):
			interact_walrus()

		# Tableau loutre
		if global.character_in_hitbox("otter"):
			interact_otter()

		# Tableau Samuel Morse
		if global.character_in_hitbox("samuel"):
			interact_samuel()

		# Peluche Pikachu
		if global.character_in_hitbox("pikachu"):
			interact_pikachu()

		# Juliette
		if global.character_in_hitbox("juliette"):
			interact_juliette()
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_uselesshouse_plush" and global.character_in_hitbox("juliette"):
			use_plush_on_juliette()
		global.set_used_item("")

######## Fonctions pour input ########
func interact_walrus():
	get_node("gui").set_text(global.get_game_text("walrusInteract"))

func interact_otter():
	get_node("gui").set_text(global.get_game_text("otterInteract"))

func interact_samuel():
	get_node("gui").set_text(global.get_game_text("samuelInteract"))

func interact_pikachu():
	if global.get_state("tutorial_1_uselesshouse_julietteInteract") and global.get_state("tutorial_1_uselesshouse_plushInteract"):
		get_node("pikachu").free()
		global.give_item("tutorial_1_uselesshouse_plush")
		get_node("gui").set_text(global.get_game_text("plushPickedUp"))
	else:
		get_node("gui").set_text(global.get_game_text("plushInteract"))
		global.set_state("tutorial_1_uselesshouse_plushInteract", true)

func interact_juliette():
	if global.get_state("tutorial_1_uselesshouse_plushGiven"):
		get_node("gui").set_text(global.get_game_text("julietteGiven"))
	else:
		get_node("gui").set_text(global.get_game_text("julietteInteract"))
		global.set_state("tutorial_1_uselesshouse_julietteInteract", true)

func interact_door():
	global.set_target_node("uselesshouseDoor")
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/tutorial/1/village.tscn")
####################

######## Fonctions pour process ########
func use_plush_on_juliette():
	global.use_item("tutorial_1_uselesshouse_plush")
	global.set_state("tutorial_1_uselesshouse_plushGiven", true)
	get_node("gui").set_text(global.get_game_text("julietteGive"))
####################