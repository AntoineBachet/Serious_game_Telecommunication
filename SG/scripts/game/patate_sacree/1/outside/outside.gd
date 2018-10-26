extends Node2D

var patate_sacree_1_outside_doorUnlocked = false

func _ready():
	global.set_details({"area":"patate_sacree", "level":"1", "scene":"outside"})
	set_process_input(true)   # On précise qu'on veut que le script lise la fonction _input à chaque événement

func _input(event):
	if event.type == InputEvent.KEY:   # on a appuyé sur une touche
		if event.is_action_pressed("interactWithItem"):   # la touche correspond à une interaction
			if global.character_in_hitbox("cow"):   # le personnage est dans la hitbox de cow
				interact_cow()   # on appelle la fonction associée à l'interaction avec cow
#			if global.character_in_hitbox("juliette"):
#				interact_juliette()
			if global.character_in_hitbox("house"):
				interact_house()
			if global.character_in_hitbox("key"):
				interact_key()

func interact_cow():
	get_node("gui").set_text( global.get_game_text("cowInteract") )

#func interact_juliette():
#	get_node("gui").set_text( global.get_game_text("julietteInteract") )

func interact_house():
	if !global.get_state("patate_sacree_1_outside_doorUnlocked"):
		get_node("gui").set_text( global.get_game_text("doorLocked") )

func interact_key():
	get_node("gui").set_text( global.get_game_text("keyInteract") )
	get_node("key").queue_free()
	global.give_item("patate_sacree_1_outside_key")



