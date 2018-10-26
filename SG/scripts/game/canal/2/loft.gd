extends Node2D

func _ready():
	global.set_details({"area":"canal", "level":"2", "scene":"loft"})
	set_process_input(true)   # On précise qu'on veut que le script lise la fonction _input à chaque événement
	set_process(true)

func _input(event):
	if event.type == InputEvent.KEY:   # on a appuyé sur une touche
		if event.is_action_pressed("interactWithItem"):   # la touche correspond à une interaction
			if global.character_in_hitbox("Nikola"):   # le personnage est dans la hitbox de door
				interact_oldScientist()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("door"):   # le personnage est dans la hitbox de door
				interact_door()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("docs"):   # le personnage est dans la hitbox de door
				interact_docs()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("piano"):   # le personnage est dans la hitbox de door
				interact_piano()   # on appelle la fonction associée à l'interaction avec door

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "canal_2_loft_asciiRiddle":
			use_asciiRiddle()
		global.set_used_item("")


func interact_oldScientist():
	if global.get_state("canal_2_loft_afterAsciiRiddleSolved"):
		# Quand on a déjà donné la solution de l'énigme au scientifique
		get_node("gui").set_text(global.get_game_text("interactScientist2")) #Dire qu'on doit aller chercher les médocs pour continuer
	elif global.get_state("canal_2_loft_asciiRiddleSolved"):
		# Quand on vient de résoudre l'énigme et qu'on va voir le scientifique
		global.set_state("canal_2_loft_afterAsciiRiddleSolved", true)
		get_node("Nikola/StaticBody2D").free()
		global.use_item("canal_2_loft_asciiRiddle")
		start_cinematic("talk_with_Nikola_RiddleSolved")
	elif global.get_state("canal_2_loft_asciiRiddleReceivedMessageDecoded"):
		# Quand on a mal résolu l'énigme et qu'on va voir Freddy
		get_node("gui").set_text(global.get_game_text("interactScientist3"))
	elif !global.get_state("canal_2_loft_asciiRiddlePickedUp"):
		start_cinematic("talk_with_Nikola")
		# Quand on n'a jamais parlé à l'ancien scientifique
#		global.give_item("canal_2_loft_asciiRiddle")
	else:
		# Quand on parle à Freddy avant d'avoir (bien ou mal) résolu l'énigme
		get_node("gui").set_text(global.get_game_text("interactScientist1"))

func interact_door():
	if global.save_scene():
		global.set_target_node("door")
		global.set_scene("res://scenes/game/canal/2/loftEntrance.tscn")

func interact_docs():
	if global.save_scene():
		global.set_scene("res://scenes/game/canal/2/staircase/Interruptor.tscn")

func interact_piano():
	if global.save_scene():
		global.set_scene("res://scenes/game/canal/2/loft/piano.tscn")

func use_asciiRiddle():
	if global.save_scene():
		global.set_scene("res://scenes/game/canal/2/loft/asciiRiddle.tscn")

func start_cinematic(name):
	get_node("character").bubble_left()
	get_node("cinematic").connect("finished", self, "end_cinematic", [name])
	get_node("cinematic").freeze_scene()
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic(name):
	get_node("cinematic").disconnect("finished", self, "end_cinematic")
	get_node("cinematic").unfreeze_scene()
	if name == "talk_with_Nikola":
		global.give_item("canal_2_loft_asciiRiddle")
		get_node("character").bubble_right()
	if name == "talk_with_Nikola_RiddleSolved" :
		global.give_item("canal_2_loft_keyRoofTop")
		