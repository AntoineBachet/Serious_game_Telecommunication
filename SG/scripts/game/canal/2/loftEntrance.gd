extends Node2D

func _ready():
	global.set_details({"area":"canal", "level":"2", "scene":"loftEntrance"})
	set_process_input(true)   # On précise qu'on veut que le script lise la fonction _input à chaque événement
	set_process(true)
	if global.get_state("canal_2_loftEntrance_staircaseUnlocked"):
		get_node("grille").free()

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "canal_2_loft_keyRoofTop":
			if global.character_in_hitbox("staircase"):
				use_keyRoofTop()
		global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY:   # on a appuyé sur une touche
		if event.is_action_pressed("interactWithItem"):   # la touche correspond à une interaction
			if global.character_in_hitbox("elevator"):   # le personnage est dans la hitbox de door
				interact_elevator()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("door"):   # le personnage est dans la hitbox de door
				interact_door()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("digicode"):   # le personnage est dans la hitbox de digicode
				interact_digicode()   # on appelle la fonction associée à l'interaction avec digicode
			if global.character_in_hitbox("wall"):   # le personnage est dans la hitbox de wall
				interact_wall()   # on appelle la fonction associée à l'interaction avec wall
			if global.character_in_hitbox("staircase"):   # le personnage est dans la hitbox de wall
				interact_staircase()   # on appelle la fonction associée à l'interaction avec wall

func use_keyRoofTop():
	global.set_state("canal_2_loftEntrance_staircaseUnlocked",true)
	get_node("gui").set_text( global.get_game_text("staircaseUnlocked") )
	global.use_item("canal_2_loft_keyRoofTop")
	get_node("grille").free()

#func interact_elevator():
#	if global.save_scene():
#		global.set_scene("res://scenes/game/canal/2/ascenseur.tscn")

func interact_door():
	if !global.get_state("canal_2_loftEntrance_loftDoorUnlocked"):
		get_node("gui").set_text( global.get_game_text("loftDoorLocked") )
	else:
		global.set_target_node("door")
		global.set_scene("res://scenes/game/tobecontinued.tscn")

func interact_digicode():
	if !global.get_state("canal_2_loftEntrance_loftDoorUnlocked"):
		if global.save_scene():
			global.set_scene("res://scenes/game/canal/2/loftEntrance/loftDigic.tscn")

func interact_wall():
	get_node("gui").set_text( global.get_game_text("matriceInWall") )
	global.unlock_entry_s("canal","section2","entry2")

func interact_staircase():
	if !global.get_state("canal_2_loftEntrance_staircaseUnlocked"):
		get_node("gui").set_text( global.get_game_text("staircaseLocked") )
	else:
		global.set_scene("res://scenes/game/canal/2/quiz/canal_2_quizz.tscn")
