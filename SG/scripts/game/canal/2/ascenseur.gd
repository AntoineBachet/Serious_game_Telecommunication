extends Node2D

func _ready():
	global.set_details({"area":"canal", "level":"2", "scene":"ascenseur"})
	set_process_input(true)   # On précise qu'on veut que le script lise la fonction _input à chaque événement

func _input(event):
	if event.type == InputEvent.KEY:   # on a appuyé sur une touche
		if event.is_action_pressed("interactWithItem"):   # la touche correspond à une interaction
			if global.character_in_hitbox("door"):   # le personnage est dans la hitbox de door
				interact_door()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("ControlEnclosure"):   # le personnage est dans la hitbox de door
				interact_controlEnclosure() 


func interact_controlEnclosure():
	if global.save_scene():
		global.set_scene("res://scenes/game/canal/2/ascenseur/elevator.tscn")

func interact_door():
	if global.save_scene():
		global.set_target_node("elevator")
		global.set_scene("res://scenes/game/canal/2/floor.tscn")

