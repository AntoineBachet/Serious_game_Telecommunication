extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"shop"})

	set_process(true)
	set_process_input(true)

	#### Restauration de l'état de la scène ####
	if global.get_state("source_3_shop_tileRiddle1Solved"):
		get_node("cabinetBottles/bottles").queue_free()
		if !global.get_state("source_3_shop_tileRiddle1TextShown"):
			global.set_state("source_3_shop_tileRiddle1TextShown", true)
			get_node("gui").set_text( global.get_game_text("cabinetBottlesOpen") )
	
	if global.get_state("source_3_shop_tileRiddle2Solved"):
		get_node("cabinetChocolate/chocolate").queue_free()
		if !global.get_state("source_3_shop_tileRiddle2TextShown"):
			global.set_state("source_3_shop_tileRiddle2TextShown", true)
			get_node("gui").set_text( global.get_game_text("cabinetChocolateOpen") )

	if global.get_state("source_3_shop_tileRiddle3Solved"):
		get_node("cabinetNoodles/noodles").queue_free()
		if !global.get_state("source_3_shop_tileRiddle3TextShown"):
			global.set_state("source_3_shop_tileRiddle3TextShown", true)
			get_node("gui").set_text( global.get_game_text("cabinetNoodlesOpen") )

	if global.is_picked_up("source_3_shop_tiles"):
		get_node("mahjongBox").queue_free()
	
	
	### Cinématique
	get_node("cinematic").connect("finished", self, "end_cinematic")
	if !global.get_state("source_3_shop_enterShopPlayed"):
		global.set_state("source_3_shop_enterShopPlayed", true)
		start_cinematic("enterShop")
####################

func _process(delta):
	if global.get_used_item() != "":
		if global.get_used_item() == "source_3_shop_tiles" and global.character_in_hitbox("cabinetBottles"):
			use_tiles_on_cabinetBottles()
		elif global.get_used_item() == "source_3_shop_tiles" and global.character_in_hitbox("cabinetChocolate"):
			use_tiles_on_cabinetChocolate()
		elif global.get_used_item() == "source_3_shop_tiles" and global.character_in_hitbox("cabinetNoodles"):
			use_tiles_on_cabinetNoodles()
		elif global.get_used_item() == "tutorial_1_village_shovel" and (global.character_in_hitbox("cabinetBottles") or global.character_in_hitbox("cabinetChocolate") or global.character_in_hitbox("cabinetNoodles")):
			use_shovel_on_cabinet()
		else:
			global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			if global.character_in_hitbox("juliette"):
				interact_juliette()
			elif global.character_in_hitbox("doorToOutside"):
				interact_doorToOutside()
			elif global.character_in_hitbox("doorToToilets"):
				interact_doorToToilets()
			elif global.character_in_hitbox("cabinetBottles"):
				interact_cabinetBottles()
			elif global.character_in_hitbox("cabinetChocolate"): 
				interact_cabinetChocolate()
			elif global.character_in_hitbox("cabinetNoodles"): 
				interact_cabinetNoodles()
			elif global.character_in_hitbox("mahjongBox"):
				interact_mahjongBox()
			elif global.character_in_hitbox("doorToChildren"):
				interact_doorToChildren()
			elif global.character_in_hitbox("doorToStorage"):
				interact_doorToStorage()

######## Fonctions pour input ########
func interact_juliette():
	if global.get_state("source_3_shop_tileRiddle1Solved") and global.get_state("source_3_shop_tileRiddle2Solved") and global.get_state("source_3_shop_tileRiddle3Solved"):
		if global.get_state("source_3_toilets_halfHuffmanRiddleSolved") and global.is_picked_up("source_3_toilets_bottles"):
			get_node("gui").set_text( global.get_game_text("interactJuliette3") )
		else:
			get_node("gui").set_text( global.get_game_text("interactJuliette2") )
	else:
		get_node("gui").set_text( global.get_game_text("interactJuliette1") )

func interact_doorToOutside():
	player.play_sound("woodendoor")
	global.set_target_node("doorToShop")
	global.set_scene("res://scenes/game/source/3/outside.tscn")

func interact_doorToToilets():
	if global.get_state("source_3_shop_tileRiddle1Solved") and global.get_state("source_3_shop_tileRiddle2Solved") and global.get_state("source_3_shop_tileRiddle3Solved"):
		player.play_sound("woodendoor")
		global.set_target_node("doorToShop")
		global.set_scene("res://scenes/game/source/3/toilets.tscn")
	else:
		get_node("gui").set_text( global.get_game_text("interactJulietteToilets") )

func interact_cabinetBottles():
	if !global.get_state("source_3_shop_tileRiddle1Solved"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/shop/tile_riddle1.tscn")
	else:
		get_node("gui").set_text( global.get_game_text("cabinetBottlesEmpty") )

func interact_cabinetChocolate():
	if !global.get_state("source_3_shop_tileRiddle2Solved"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/shop/tile_riddle2.tscn")
	else:
		get_node("gui").set_text( global.get_game_text("cabinetChocolateEmpty") )

func interact_cabinetNoodles():
	if !global.get_state("source_3_shop_tileRiddle3Solved"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/shop/tile_riddle3.tscn")
	else:
		get_node("gui").set_text( global.get_game_text("cabinetNoodlesEmpty") )

func interact_mahjongBox():
	get_node("gui").set_text( global.get_game_text("interactMahjong") )
	global.give_item("source_3_shop_tiles")
	get_node("mahjongBox").queue_free()

func interact_doorToChildren():
	if global.get_state("source_3_shop_doorToChildrenUnlocked"):
		player.play_sound("woodendoor")
		global.set_target_node("doorToShop")
		global.set_scene("res://scenes/game/source/3/children_area.tscn")
	else:
		global.set_state("source_3_shop_doorToChildrenUnlocked", true)
		get_node("gui").set_text(global.get_game_text("interactDoor"))

func interact_doorToStorage():
	player.play_sound("woodendoor")
	global.set_target_node("doorToShop")
	global.set_scene("res://scenes/game/source/3/storage.tscn")
####################

######## Fonctions pour process ########
func use_tiles_on_cabinetBottles():
	if !global.get_state("source_3_shop_tileRiddle1Solved"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/shop/tile_riddle1.tscn")

func use_tiles_on_cabinetChocolate():
	if !global.get_state("source_3_shop_tileRiddle2Solved"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/shop/tile_riddle2.tscn")

func use_tiles_on_cabinetNoodles():
	if !global.get_state("source_3_shop_tileRiddle3Solved"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/shop/tile_riddle3.tscn")

func use_shovel_on_cabinet():
	get_node("gui").set_text(global.get_game_text("cabinetShovel"))
####################



func start_cinematic(name):
	get_node("cinematic").get_events(name)
	get_node("cinematic").freeze_scene()
	get_node("cinematic").start()

func end_cinematic():
	get_node("cinematic").unfreeze_scene()