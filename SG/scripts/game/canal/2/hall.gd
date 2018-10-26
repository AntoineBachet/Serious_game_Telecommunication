extends Node2D

func _ready():
	global.set_details({"area":"canal", "level":"2", "scene":"hall"})
	set_process_input(true)   # On précise qu'on veut que le script lise la fonction _input à chaque événement
	if global.get_state("canal_2_hall_elevatorUnlocked"):
		get_node("bg").set_texture(load("res://assets/game/canal/2/B2N2-bg2_allume.jpg"))

func _input(event):
	if event.type == InputEvent.KEY:   # on a appuyé sur une touche
		if event.is_action_pressed("interactWithItem"):   # la touche correspond à une interaction
			if global.character_in_hitbox("door"):   # le personnage est dans la hitbox de door
				interact_door()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("elevator"):   # le personnage est dans la hitbox de door
				interact_elevator() 


func interact_elevator():
	if !global.get_state("canal_2_hall_elevatorUnlocked"):
		get_node("gui").set_text( global.get_game_text("elevatorLocked") )
	else:
		global.set_target_node("elevator")
		global.set_scene("res://scenes/game/canal/2/floor.tscn")

func interact_door():
	if global.save_scene():
		global.set_target_node("door")
		global.set_scene("res://scenes/game/canal/2/staircase.tscn")

