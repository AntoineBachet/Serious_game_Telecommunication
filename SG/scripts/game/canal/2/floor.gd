extends Node2D

func _ready():
	global.set_details({"area":"canal", "level":"2", "scene":"floor"})
	set_process_input(true)
	set_process(true)
	
	if !global.get_state("canal_2_floor_introPlayed"):
		global.set_state("canal_2_floor_introPlayed", true)
		start_cinematic("intro")
	
	if global.is_picked_up("canal_2_floor_toolBox"): # Si on a pris la boite à outils, on l'enlève de la scène
		get_node("toolBox").free()


func _input(event):
	if event.type == InputEvent.KEY:   # on a appuyé sur une touche
		if event.is_action_pressed("interactWithItem"):   # la touche correspond à une interaction
			if global.character_in_hitbox("toolBox"):   # le personnage est dans la hitbox de door
				interact_toolBox()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("elevator"):   # le personnage est dans la hitbox de door
				interact_elevator()
			if global.character_in_hitbox("door"):   # le personnage est dans la hitbox de door
				interact_door() 

func interact_toolBox():
	get_node("gui").set_text( global.get_game_text("toolBoxInteract") )
	get_node("toolBox").queue_free()
	global.give_item("canal_2_floor_toolBox")

func interact_elevator():
	if global.save_scene():
		global.set_scene("res://scenes/game/canal/2/ascenseur.tscn")

func interact_door():
	if global.save_scene():
		global.set_target_node("door")
		global.set_scene("res://scenes/game/canal/2/roomFloor.tscn")

func start_cinematic(name):
	get_node("cinematic").connect("finished", self, "end_cinematic", [name])
	get_node("cinematic").freeze_scene()
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic(name):
	get_node("cinematic").disconnect("finished", self, "end_cinematic")
	get_node("cinematic").unfreeze_scene()

