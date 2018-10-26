extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"casino"})

	set_process_input(true)
	set_process(true)

	get_node("controlRoom/Panel/Label").set_text(global.get_game_text("controlRoomLabel"))

	if !global.get_state("source_2_casino_enterCasinoPlayed"):
		global.set_state("source_2_casino_enterCasinoPlayed", true)
		get_node("character").canInteract("rubble")
		get_node("character").cannotInteract("backToCasino")
		start_cinematic("enterCasino")
		global.set_state("mapUnlocked", false)
	elif !global.get_state("source_2_finished"):
		get_node("rubble").show()
	
	if global.get_state("source_2_casino_slotMachineOpened"):
		var slotMachineOpenedTexture = load("res://assets/game/source/2/casino/slotmachineopen.png")
		get_node("slotMachine6").set_texture(slotMachineOpenedTexture)
		
	if get_node("rubble").is_visible():
		get_node("character").canInteract("rubble")
		get_node("character").cannotInteract("backToVillage")
	
	if global.is_entry_s_unlocked("source", "section1", "entry2"):
		get_node("slotMachine2/paper").queue_free()
	
	if global.get_state("source_2_casino_diceRiddleSolved") and !global.get_state("source_2_casino_diceRiddleMessageShown"):
		global.set_state("source_2_casino_diceRiddleMessageShown", true)
		get_node("gui").set_text( global.get_game_text("diceWon") )
	
	if global.get_state("source_2_casino_cardRiddleSolved") and !global.get_state("source_2_casino_cardRiddleMessageShown"):
		global.set_state("source_2_casino_cardRiddleMessageShown", true)
		get_node("gui").set_text( global.get_game_text("cardWon") )

	if global.get_state("source_2_casino_loadedDiceRiddleSolved") and !global.get_state("source_2_casino_loadedDiceRiddleMessageShown"):
		global.set_state("source_2_casino_loadedDiceRiddleMessageShown", true)
		get_node("gui").set_text( global.get_game_text("loadedDiceWon") )

	if global.get_state("source_2_casino_slotMachineOpened") and !global.get_state("source_2_casino_slotMachineRepaired"):
		var slotMachineOpenedTexture = load("res://assets/game/source/2/casino/slotmachineopen.png")
		get_node("slotMachine6").set_texture(slotMachineOpenedTexture)
####################

func _process(delta):
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_village_shovel":
			if global.character_in_hitbox("diceRobot"):
				use_shovel_on_diceRobot()
			elif global.character_in_hitbox("rubble"):
				use_shovel_on_rubble()
			elif global.character_in_hitbox("slotMachine6"):
				use_shovel_on_slotMachineRight()
			elif global.character_in_hitbox("securityRobot"):
				use_shovel_on_securityRobot()

		elif global.get_used_item() == "source_2_casino_cardToken" or global.get_used_item() == "source_2_casino_diceToken" or global.get_used_item() == "source_2_casino_loadedDiceToken":
			if global.character_in_hitbox("slotMachine2"):
				use_token_on_slotMachine(global.get_used_item())
			elif global.character_in_hitbox("slotMachine6"):
				use_token_on_slotMachineRight()

		elif global.get_used_item() == "source_2_miniGameRoom_sparePart":
			if global.character_in_hitbox("receptionistRobot"):
				use_sparePart_on_receptionistRobot()
			elif global.character_in_hitbox("slotMachine6"):
				use_sparePart_on_slotMachineRight()
			elif global.character_in_hitbox("slotMachine2"):
				use_sparePart_on_slotMachineLeft()
			elif global.character_in_hitbox("diceRobot"):
				use_sparePart_on_diceRobot()

		elif global.get_used_item() == "source_2_casino_tool":
			if global.character_in_hitbox("slotMachine2"):
				use_sparePart_on_slotMachineLeft()
			elif global.character_in_hitbox("slotMachine6"):
				use_tool_on_slotMachineRight()
			elif global.character_in_hitbox("diceRobot"):
				use_tool_on_diceRobot()

		global.set_used_item("")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		# backToVillage
		if !get_node("rubble").is_visible() and global.character_in_hitbox("backToVillage"):
			interact_backToVillage()
		# controlRoom
		elif global.character_in_hitbox("controlRoom"):
			interact_controlRoom()
		# miniGameRoom
		elif global.character_in_hitbox("miniGameRoom"):
			interact_miniGameRoom()
		# diceRiddle
		elif global.character_in_hitbox("diceRobot"):
			interact_diceRobot()
		# cardRiddle
		elif global.character_in_hitbox("cardRobot"):
			interact_cardRobot()
		# slotMachine gauche
		elif global.character_in_hitbox("slotMachine2"):
			interact_slotMachine()
		# slotMachine droite
		elif global.character_in_hitbox("slotMachine6"):
			interact_slotMachine2()
		# receptionistRobot
		elif global.character_in_hitbox("receptionistRobot"):
			interact_receptionistRobot()
		# securityRobot
		elif global.character_in_hitbox("securityRobot"):
			interact_securityRobot()
		# cautionSign
		elif global.character_in_hitbox("cautionSign"):
			interact_cautionSign()
		# Juliette
		elif global.character_in_hitbox("juliette"):
			interact_juliette()
		# rubble
		elif get_node("rubble").is_visible() and global.character_in_hitbox("rubble"):
			interact_rubble()

######## Fonctions pour _input ########
func interact_backToVillage():
	global.set_target_node("casino_door")
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/source/2/village.tscn")

func interact_controlRoom():
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/source/2/controlRoom.tscn")

func interact_miniGameRoom():
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/source/2/miniGameRoom.tscn")

func interact_diceRobot():
	if global.get_state("source_2_casino_loadedDiceRiddleSolved"):
		get_node("gui").set_text(global.get_game_text("diceRobotInteract3"))
	elif global.get_state("source_2_casino_diceRobotPlayed2"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/2/casino/loadedDiceRiddle.tscn")
	elif global.get_state("source_2_casino_diceRobotDialogue2"):
		global.set_state("source_2_casino_diceRobotPlayed2", true)
		start_cinematic("diceRobot2")
	elif global.get_state("source_2_casino_diceRiddleSolved"):
		get_node("gui").set_text(global.get_game_text("diceRobotInteract2"))
		global.set_state("source_2_casino_diceRobotDialogue2", true)
	elif global.get_state("source_2_casino_diceRobotPlayed"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/2/casino/diceRiddle.tscn")
	elif global.get_state("source_2_casino_diceRobotDialogue"):
		global.set_state("source_2_casino_diceRobotPlayed", true)
		start_cinematic("diceRobot")
	else:
		get_node("gui").set_text(global.get_game_text("diceRobotInteract"))
		global.set_state("source_2_casino_diceRobotDialogue", true)

func interact_cardRobot():
	if !global.get_state("source_2_casino_cardRobotPlayed"):
		global.set_state("source_2_casino_cardRobotPlayed", true)
		start_cinematic("cardRobot")
	elif global.get_state("source_2_casino_cardRiddleSolved"):
		get_node("gui").set_text(global.get_game_text("cardRiddleSolved"))
	else:
		if global.save_scene():
			global.set_scene("res://scenes/game/source/2/casino/cardRiddle.tscn")

func interact_slotMachine():
	if !global.get_state("source_2_casino_slotMachineInteract"):
		get_node("gui").set_text(global.get_game_text("slotMachineInteract1"))
		global.set_state("source_2_casino_slotMachineInteract", true)
	elif !global.is_entry_s_unlocked("source", "section1", "entry2"):
		get_node("gui").set_text(global.get_game_text("slotMachineInteract2"))
		global.unlock_entry_s("source", "section1", "entry2")
		get_node("slotMachine2/paper").queue_free()
	else:
		get_node("gui").set_text(global.get_game_text("slotMachineInteract3"))

func interact_slotMachine2():
	if !global.get_state("source_2_casino_slotMachineRepaired"):
		get_node("gui").set_text(global.get_game_text("slotMachineBroken"))
	else:
		get_node("gui").set_text(global.get_game_text("slotMachineRepaired"))

func interact_receptionistRobot():
	if !global.get_state("source_2_casino_receptionistHello"):
		get_node("gui").set_text(global.get_game_text("receptionistRobotInteract1"))
		global.set_state("source_2_casino_receptionistHello", true)
	elif !global.is_entry_s_unlocked("source", "section1", "entry1"):
		get_node("gui").set_text(global.get_game_text("receptionistRobotInteract2"))
		global.unlock_entry_s("source", "section1", "entry1")
	else:
		get_node("gui").set_text(global.get_game_text("receptionistRobotInteract3"))

func interact_securityRobot():
	get_node("gui").set_text(global.get_game_text("securityRobotInteract"))

func interact_cautionSign():
	get_node("gui").set_text(global.get_game_text("cautionSignInteract"))

func interact_juliette():
	if global.get_state("source_2_finished"):
		get_node("gui").set_text(global.get_game_text("julietteInteract2"))
	else:
		get_node("gui").set_text(global.get_game_text("julietteInteract1"))

func interact_rubble():
	get_node("gui").set_text(global.get_game_text("rubbleInteract"))
####################


######## Fonctions pour process ########
func use_shovel_on_diceRobot():
	get_node("gui").set_text(global.get_game_text("diceRobotShovel"))
	player.play_sound("metal_on_metal")

func use_shovel_on_rubble():
	get_node("gui").set_text(global.get_game_text("rubbleShovel"))

func use_token_on_slotMachine(item):
	if is_lucky():
		jackpot()
	else:
		get_node("gui").set_text(global.get_game_text("slotMachineToken"))
		player.play_sound("coins")
		if item == "source_2_casino_cardToken":
			global.unlock_entry_s("source", "section1", "entry4")
		elif item == "source_2_casino_diceToken":
			global.unlock_entry_s("source", "section1", "entry5")
		elif item == "source_2_casino_loadedDiceToken":
			global.unlock_entry_s("source", "section1", "entry6")
		global.use_item(item)

func use_token_on_slotMachineRight():
	if global.get_state("source_2_casino_slotMachineRepaired"):
		get_node("gui").set_text(global.get_game_text("slotMachineRightToken2"))
	else:
		get_node("gui").set_text(global.get_game_text("slotMachineRightToken1"))

func use_tool_on_slotMachineRight():
	if !global.get_state("source_2_casino_slotMachineOpened"):
		get_node("gui").set_text(global.get_game_text("slotMachineRightTool1"))
		var slotMachineOpenedTexture = load("res://assets/game/source/2/casino/slotmachineopen.png")
		get_node("slotMachine6").set_texture(slotMachineOpenedTexture)
		global.set_state("source_2_casino_slotMachineOpened",true)
		
		global.set_state("source_2_casino_slotMachineOpened", true)
	elif global.is_used("source_2_miniGameRoom_sparePart"):
		get_node("gui").set_text(global.get_game_text("slotMachineRightTool2"))
		var slotMachineTexture = load("res://assets/game/source/2/casino/slotmachine.png")
		get_node("slotMachine6").set_texture(slotMachineTexture)
		global.set_state("source_2_casino_slotMachineOpened",false)
		global.use_item("source_2_casino_tool")
		global.set_state("source_2_casino_slotMachineRepaired", true)
		global.unlock_hat("cap")
	else:
		get_node("gui").set_text(global.get_game_text("slotMachineRightTool3"))

func use_sparePart_on_receptionistRobot():
	if !global.is_picked_up("source_2_casino_tool"):
		get_node("gui").set_text(global.get_game_text("receptionistRobotTool"))
		global.give_item("source_2_casino_tool")
	
func use_sparePart_on_slotMachineRight():
	if !global.get_state("source_2_casino_slotMachineOpened"):
		get_node("gui").set_text(global.get_game_text("slotMachineRightSparePart1"))
	else:
		get_node("gui").set_text(global.get_game_text("slotMachineRightSparePart2"))
		global.use_item("source_2_miniGameRoom_sparePart")

func use_sparePart_on_slotMachineLeft():
	get_node("gui").set_text(global.get_game_text("slotMachineLeftSparePart"))

func use_shovel_on_slotMachineRight():
	if global.is_picked_up("source_2_miniGameRoom_sparePart"):
		get_node("gui").set_text(global.get_game_text("slotMachineRightShovel2"))
	else:
		get_node("gui").set_text(global.get_game_text("slotMachineRightShovel1"))

func use_shovel_on_securityRobot():
	get_node("gui").set_text(global.get_game_text("securityRobotShovel"))

func use_sparePart_on_diceRobot():
	get_node("gui").set_text(global.get_game_text("diceRobotSparePart"))

func use_tool_on_diceRobot():
	get_node("gui").set_text(global.get_game_text("diceRobotTool"))

####################

func is_lucky():
	if !global.get_state("source_2_casino_jackpot"):
		randomize()
		var d100 = randi() % 100 + 1
		return (d100 == 1)

func jackpot():
	global.set_state("source_2_casino_jackpot", true)
	start_cinematic("jackpot")

######## Fonctions pour les cinématiques ########
func start_cinematic(name):
	if name == "diceRobot" or name == "diceRobot2" or name == "cardRobot":
		get_node("character").bubble_left()
	get_node("cinematic").freeze_scene()
	get_node("cinematic").connect("finished", self, "end_cinematic", [name])
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic(name):
	get_node("cinematic").disconnect("finished", self, "end_cinematic")
	get_node("cinematic").unfreeze_scene()
	if name == "diceRobot" or name == "cardRobot":
		get_node("character").bubble_right()
	elif name == "jackpot":
		get_node("gui").set_text(global.get_game_text("slotMachineJackpot"))
####################