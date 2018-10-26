extends Node2D

var doorcinematic = false

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"1", "scene":"source_entry"})

	set_process_input(true)
	set_process(true)

	#### Z de la porte : en avant si la porte est ouverte, normal sinon
	if global.get_state("source_1_source_entry_robervalRiddleSolved"):
		get_node("wallright").set_z(10)
	else:
		get_node("wallright").set_z(0)

	##### Si on n'a jamais vu la cinématique d'arrivée, on la joue
	if !global.get_state("source_1_entrance_arrivalPlayed"):
		global.set_state("source_1_entrance_arrivalPlayed", true)
		start_cinematic("arrival")
	elif global.get_state("source_1_entrance_noMoreDoorPlayed"):
		get_node("door").queue_free()
		get_node("triggerRobot").queue_free()
	elif global.get_state("source_1_source_entry_robervalRiddleSolved"):
		global.set_state("source_1_entrance_noMoreDoorPlayed", true)
		start_cinematic("nomoredoor")
	##### Remettre le robot à sa place si on a vu la cinématique
	elif global.get_state("source_1_entrance_robotFallPlayed"):
		get_node("cinematicAnimation").play("robotbonneplace")
		get_node("robot").set_animation("happy")
		get_node("character").canInteract("robot")
	##### Si on a vu la cinématique de la porte, le E apparaît
	elif has_node("door") and !global.get_state("source_1_entrance_noMoreDoorPlayed") and global.get_state("source_1_entrance_doorPlayed"):
		get_node("character").canInteract("door")
		if !global.get_state("source_1_entrance_robotFallPlayed") and get_node("character").get_pos().x < get_node("robot").get_pos().x + 250:
			get_node("character").set_pos(Vector2(1100,868))				# replacement en venant d'un autre endroit pour ne pas être coincé par le robot	

	get_node("cinematic").connect("finished", self, "end_cinematic")
####################

func _process(delta):
	#### Cinématique de la porte ####
	if !global.get_state("source_1_entrance_doorPlayed") and global.character_in_hitbox("door"):
		global.set_state("source_1_entrance_doorPlayed", true)
		start_cinematic("doorLocked")

	#### Utilisation de la balance sur le robot ####
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_house_scales":
			#Si on met la condition ci-dessous au-dessus, il rentre pas dedans parce que character_in_hitbox n'est pas vrai à la toute première frame mais seulement à partir de la deuxième :(
			if global.get_state("source_1_entrance_doorPlayed") and global.get_state("source_1_entrance_robotFallPlayed") and !global.get_state("source_1_entrance_noMoreDoorPlayed") and global.character_in_hitbox("robot") and !global.get_state("source_1_source_entry_robervalRiddleSolved"):
				interact_robot()
		else: ### Si on ne met pas dans un else, le scène ne se lance pas après
			global.set_used_item("")

	#### Cinématique du robot qui tombe
	if global.character_in_hitbox("triggerRobot") and global.get_state("source_1_entrance_doorPlayed") and !global.get_state("source_1_entrance_robotFallPlayed") and !global.get_state("source_1_source_entry_robervalRiddleSolved"):
		global.set_state("source_1_entrance_robotFallPlayed", true)
		start_cinematic("robotfall")
		get_node("character").canInteract("robot")

######## Interactions avec l'environnement ########
func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			if global.character_in_hitbox("juliette"):
				interact_juliette()
			if global.character_in_hitbox("door"):
				interact_door()
			if global.character_in_hitbox("robot"):
				interact_robot()
			if global.character_in_hitbox("gateEntrance"):
				interact_exit()

func interact_juliette():
	if !global.get_state("source_1_entrance_noMoreDoorPlayed"):
		get_node("gui").set_text(global.get_game_text("julietteTalk"))
	else:
		get_node("gui").set_text(global.get_game_text("julietteTalk2"))

func interact_door():
	get_node("gui").set_text(global.get_game_text("door"))

func interact_robot():
	if !global.get_state("source_1_entrance_noMoreDoorPlayed") and global.character_in_hitbox("robot") and global.get_state("source_1_entrance_doorPlayed") and global.get_state("source_1_entrance_robotFallPlayed"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/1/entrance/roberval_riddle.tscn")

func interact_exit():
	global.set_scene("res://scenes/game/source/2/village.tscn")
####################

######## Fonctions pour les cinématiques ########
func start_cinematic(name):
	if name != "doorLocked":
		get_node("cinematic").freeze_scene()
	else:
		doorcinematic = true
	if name == "nomoredoor":
		global.unlock_location("source_2")
		get_node("Camera2D").make_current()
		get_node("character").set_pos(Vector2(750,868.263))
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic():
	get_node("cinematic").unfreeze_scene()
	if !get_node("character/Camera2D").is_current():
		get_node("character/Camera2D").make_current()
	if doorcinematic : 
		get_node("character").canInteract("door")
####################