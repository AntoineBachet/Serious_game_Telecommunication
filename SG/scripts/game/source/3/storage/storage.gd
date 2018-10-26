extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"storage"})

	set_process(true)
	set_process_input(true)
####################

func _process(delta):
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_village_shovel" and global.character_in_hitbox("car"):
			use_shovel_on_car()
		else:
			global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			if global.character_in_hitbox("doorToShop"):
				interact_doorToShop()
			elif global.character_in_hitbox("car"):
				interact_car()
			elif global.character_in_hitbox("piano"):
				interact_piano()
			elif global.character_in_hitbox("cardboardBoxes"):
				interact_cardboardBoxes()
			elif global.character_in_hitbox("juliette"):
				interact_juliette()

######## Fonctions pour input ########
func interact_doorToShop():
	player.play_sound("woodendoor")
	global.set_target_node("doorToStorage")
	global.set_scene("res://scenes/game/source/3/shop.tscn")

func interact_car():
	if global.get_state("source_3_storage_carOpen"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/storage/car.tscn")
	else:
		get_node("gui").set_text( global.get_game_text("carInteract") )

func interact_piano():
	if global.save_scene():
		global.set_scene("res://scenes/game/source/3/storage/piano.tscn")

func interact_cardboardBoxes():
	if !global.is_section_unlocked("source", "section2"):
		get_node("gui").set_text( global.get_game_text("cardboardBoxesInteract") )
		global.unlock_chapter_entries("source")
	else:
		get_node("gui").set_text( global.get_game_text("cardboardBoxesInteract2") )

func interact_juliette():
	get_node("gui").set_text( global.get_game_text("julietteInteract") )
####################

######## Fonctions pour process ########
func use_shovel_on_car():
	get_node("gui").set_text( global.get_game_text("carShovel") )
	global.set_state("source_3_storage_carOpen", true)
####################