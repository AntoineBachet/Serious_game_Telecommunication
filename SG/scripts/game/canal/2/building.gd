extends Node2D

func _ready():
	global.set_details({"area":"canal", "level":"2", "scene":"building"})
	set_process_input(true)   # On précise qu'on veut que le script lise la fonction _input à chaque événement

func _input(event):
	if event.type == InputEvent.KEY:   # on a appuyé sur une touche
		if event.is_action_pressed("interactWithItem"):   # la touche correspond à une interaction
			if global.character_in_hitbox("door"):   # le personnage est dans la hitbox de door
				interact_door()   # on appelle la fonction associée à l'interaction avec door
			if global.character_in_hitbox("digicode"):   # le personnage est dans la hitbox de door
				interact_digicode() 
			if global.character_in_hitbox("flower"):
				interact_flower()

func interact_door():
	if !global.get_state("canal_2_building_buildingDoorUnlocked"):
		get_node("gui").set_text( global.get_game_text("buildingDoorLocked") )
	else:
		global.set_target_node("comptoir")
		global.set_scene("res://scenes/game/canal/2/hall.tscn")

func interact_digicode():
	if !global.get_state("canal_2_building_buildingDoorUnlocked"):
		if global.save_scene():
			global.set_scene("res://scenes/game/canal/2/building/buildingDigic.tscn")

func interact_flower():
#	global.give_item("canal_2_building_matG")
	global.unlock_entry_s("canal","section1","entry1")
	global.unlock_entry_s("canal","section1","entry2")
	global.unlock_entry_s("canal","section1","entry3")
	global.unlock_entry_s("canal","section1","entry4")
	global.unlock_entry_s("canal","section1","entry5")
	global.unlock_entry_s("canal","section2","entry1")