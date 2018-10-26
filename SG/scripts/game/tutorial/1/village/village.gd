extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"village"})
	global.set_scene("res://scenes/game/canal/2/building.tscn")
	set_process(true)
	set_process_input(true)

	get_node("rubble1/AnimatedSprite").set_frame(0)
	get_node("rubble2/AnimatedSprite").set_frame(0)

	#### Nettoyage des objets ####
	if global.is_picked_up("tutorial_1_village_shovel"):
		get_node("shovel").free()
	if global.get_state("tutorial_1_village_rubble1Dug"):
		get_node("rubble1").free()
	if global.get_state("tutorial_1_village_rubble2Dug"):
		get_node("rubble2").free()
	if global.is_picked_up("tutorial_1_village_key"):
		get_node("key").free()
	if global.get_state("tutorial_1_village_doorUnlocked"):
		get_node("lock").free()

	if has_node("juliette") and global.get_state("julietteGone"):
		get_node("juliette/Sprite").set_animation("corpse")
		get_node("corpse").show()

	#### Cinématique d'intro ####
	if !global.get_state("tutorial_1_village_cinematic_played"):
		global.set_state("tutorial_1_village_cinematic_played", true)
		get_node("cinematic").connect("finished", self, "end_cinematic")
		start_cinematic("arrival")

	#### Placement initial de Juliette et Victor si la cinématique d'intro a été jouée ####
	else:
		# Détermination des positions de Victor et Juliette à la fin de la cinématique
		var introAnimation = get_node("cinematicAnimation").get_animation("enter_village")
		var trackIdV = introAnimation.find_track(NodePath("character:transform/pos"))
		var lastKeyV = introAnimation.track_get_key_count(trackIdV) - 1
		var trackIdJ = introAnimation.find_track(NodePath("juliette:transform/pos"))
		var lastKeyJ = introAnimation.track_get_key_count(trackIdJ) - 1
		var posV = introAnimation.track_get_key_value(trackIdV,lastKeyV)
		var posJ = introAnimation.track_get_key_value(trackIdJ,lastKeyJ)

		if get_node("character").get_pos().x < 0:
			get_node("character").set_pos(posV)
		get_node("juliette").set_pos(posJ)
####################

######## Interactions avec l'environnement ########
func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			# Juliette
			if global.character_in_hitbox("juliette"):
				interact_juliette()
			#Shovel
			if global.character_in_hitbox("shovel"):
				interact_shovel()
			# Rubble 1
			if global.character_in_hitbox("rubble1"):
				interact_rubble1()
			# Street sign
			if global.character_in_hitbox("streetsign"):
				interact_streetsign()
			# Rubble 2
			if global.character_in_hitbox("rubble2"):
				interact_rubble2()
			# Key
			if global.get_state("tutorial_1_village_rubble2Dug") and global.character_in_hitbox("key"):
				interact_key()
			# House
			if global.character_in_hitbox("house"):
				interact_house()
			#UselessHouse	
			if global.character_in_hitbox("uselesshouse"):
				interact_uselessHouse()
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		#Juliette
		if global.character_in_hitbox("juliette") and global.get_used_item() == "tutorial_1_village_shovel":
			use_shovel_on_juliette()
		# Rubble 1
		if global.character_in_hitbox("rubble1") and global.get_used_item() == "tutorial_1_village_shovel":
			use_shovel_on_rubble1()
		#Rubble 2
		if global.character_in_hitbox("rubble2") and global.get_used_item() == "tutorial_1_village_shovel":
			use_shovel_on_rubble2()
		#House	
		if global.character_in_hitbox("lock") and global.get_used_item() == "tutorial_1_village_key":
			use_key_on_door()
		if global.character_in_hitbox("house") and global.get_used_item() == "tutorial_1_village_shovel":
			use_shovel_on_door()

		global.set_used_item("")

	#### Pop-ups ####
	if global.character_in_hitbox("shovel"):
		get_node("gui").set_text(global.get_game_text("shovelPopup"))

######## Fonctions pour input ########
func interact_juliette():
	if !global.get_state("julietteGone"):
		get_node("gui").set_text(global.get_game_text("julietteTalk"))
	else:
		get_node("gui").set_text(global.get_game_text("julietteInteract"))

func interact_shovel():
	get_node("shovel").queue_free()
	get_node("gui").set_text(global.get_game_text("shovelPickedUp"))
	global.give_item("tutorial_1_village_shovel")

func interact_rubble1():
	get_node("gui").set_text(global.get_game_text("rubble1Interact"))

func interact_rubble2():
	get_node("gui").set_text(global.get_game_text("rubble2Interact"))

func interact_streetsign():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/village/streetsignview.tscn")

func interact_key():
	get_node("key").queue_free()
	global.give_item("tutorial_1_village_key")
	get_node("gui").set_text(global.get_game_text("keyPickedUp"))

func interact_house():
	if global.get_state("tutorial_1_village_doorUnlocked"):
		global.set_scene("res://scenes/game/tutorial/1/house.tscn")
		player.play_sound("woodendoor")
	else:
		get_node("gui").set_text(global.get_game_text("houseDoorLocked"))

func interact_uselessHouse():
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/tutorial/1/uselesshouse.tscn")
####################

######## Fonctions pour process ########
func use_shovel_on_juliette():
	if !global.get_state("julietteGone"):
		if global.save_scene():
			global.set_scene("res://scenes/game/tutorial/1/village/hardmode.tscn")
	else:
		get_node("gui").set_text(global.get_game_text("julietteShovelBis"))

func use_shovel_on_rubble1():
	get_node("cinematic").freeze_scene()
	get_node("rubble1").get_node("AnimationPlayer").play("dig")
	get_node("rubble1").get_node("AnimationPlayer").connect("finished", self, "rubble_free", [1])
	get_node("gui").set_text(global.get_game_text("rubble1Dug"))
	global.set_state("tutorial_1_village_rubble1Dug", true)
	player.play_sound("shovel_digging")

func use_shovel_on_rubble2():
	get_node("cinematic").freeze_scene()
	get_node("rubble2").get_node("AnimationPlayer").play("dig")
	get_node("rubble2").get_node("AnimationPlayer").connect("finished", self, "rubble_free", [2])
	get_node("gui").set_text(global.get_game_text("rubble2Dug"))
	global.set_state("tutorial_1_village_rubble2Dug", true)
	player.play_sound("shovel_digging")

func rubble_free(rubble_index):
	get_node("cinematic").unfreeze_scene()
	get_node("rubble" + str(rubble_index)).free()

func use_shovel_on_door():
	get_node("gui").set_text(global.get_game_text("houseDoorShovel"))
	player.play_sound("metal_on_wood")

func use_key_on_door():
	global.set_state("tutorial_1_village_doorUnlocked", true)
	global.use_item("tutorial_1_village_key")
	get_node("lock").queue_free()
	get_node("gui").set_text(global.get_game_text("houseDoorUnlocked"))
####################

######## Fonctions pour la cinématique ########
func start_cinematic(name):
	get_node("cinematic").freeze_scene()
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()
	
func end_cinematic():
	get_node("cinematic").unfreeze_scene()
	get_node("gui").set_text(global.get_game_text("howToMove"))
####################