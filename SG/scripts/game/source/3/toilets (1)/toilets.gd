extends Node2D

var armoirePharmacie_opened = load("res://assets/game/source/3/toilets/armoirePharmacie_opened.png")
var openStallTexture = load("res://assets/game/source/3/toilets/stall_open.png")
var closedStallTexture = load("res://assets/game/source/3/toilets/stall_closed.png")

func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"toilets"})

	set_process(true)
	set_process_input(true)

	#### Mise à jour de la scène
	if global.get_state("source_3_toilets_halfHuffmanRiddleSolved"):
		get_node("firstAid").set_texture(armoirePharmacie_opened)
		get_node("firstAid").set_scale(Vector2(0.8,1.2))
		get_node("character").cannotInteract("firstAid")

	for i in [1,2,3,4]:
		if global.get_state(str("source_3_toilets_stall",str(i),"Open")):
			get_node(str("stall", str(i))).set_texture(openStallTexture)

	# Affichage du message si on a réussi l'énigme Demi-Huffman
	if global.get_state("source_3_toilets_halfHuffmanRiddleSolved") and !global.get_state("source_3_toilets_halfHuffmanMessageShown"):
		if global.is_picked_up("source_3_toilets_bottles"):
			start_cinematic("endLevel")
		
		global.set_state("source_3_toilets_halfHuffmanMessageShown", true)
		get_node("gui").set_text(global.get_game_text("halfHuffmanSolved"))

	if global.get_state("source_3_toilets_huffmanRiddleSolved") and !global.has_state("source_3_toilets_huffmanMessageShown"):
		global.set_state("source_3_toilets_huffmanMessageShown", true)
		get_node("gui").set_text(global.get_game_text("huffmanSolved"))


func _process(delta):
	if global.get_used_item() != "":
		if global.character_in_hitbox("sink") :
			if global.get_used_item() == "source_3_shop_bottles":
				use_empty_bottles_on_sink()
			elif global.get_used_item() == "source_3_toilets_bottles":
				use_filled_bottles_on_sink()
		global.set_used_item("")


func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			if global.character_in_hitbox("juliette"):
				interact_juliette()
			# Retour vers la boutique
			elif global.character_in_hitbox("doorToShop"):
				interact_doorToShop()
			# Kit de premiers secours (demi-Huffman)
			elif global.character_in_hitbox("firstAid"):
				interact_firstAid()
			elif global.character_in_hitbox("sink") :
				interact_sink()
			elif global.character_in_hitbox("stall1"):
				interact_stall(1)
			elif global.character_in_hitbox("stall2"):
				interact_stall(2)
			elif global.character_in_hitbox("stall3"):
				interact_stall(3)
			elif global.character_in_hitbox("stall4"):
				interact_stall(4)

func interact_juliette():
	if global.is_picked_up("source_3_toilets_bottles") and global.is_picked_up("source_3_toilets_firstAidKit"):
		get_node("gui").set_text( global.get_game_text("interactJuliette3") )
	elif global.is_picked_up("source_3_toilets_firstAidKit"):
		get_node("gui").set_text( global.get_game_text("interactJuliette2") )
	else:
		get_node("gui").set_text( global.get_game_text("interactJuliette1") )

func interact_doorToShop():
	player.play_sound("woodendoor")
	global.set_target_node("doorToToilets")
	global.set_scene("res://scenes/game/source/3/shop.tscn")

func interact_firstAid():
	if !global.get_state("source_3_toilets_halfHuffmanRiddleSolved"):
		if global.save_scene():
			global.set_scene("res://scenes/game/source/3/toilets/halfHuffman_riddle.tscn")

func interact_sink():
	if !global.get_state("source_3_toilets_huffmanRiddleSolved"):
		if !global.get_state("source_3_toilets_repairSinkPlayed"):
			global.set_state("source_3_toilets_repairSinkPlayed", true)
			start_cinematic("repairSink")
		elif global.save_scene():
			global.set_scene("res://scenes/game/source/3/toilets/huffman_riddle.tscn")
	if global.get_state("source_3_toilets_huffmanRiddleSolved") and global.get_state("source_3_toilets_huffmanMessageShown"):
		get_node("gui").set_text(global.get_game_text("getWater1"))


func interact_stall(id):
	var stall = get_node(str("stall", str(id)))
	player.play_sound("woodendoor")
	if stall.get_texture() == openStallTexture:
		stall.set_texture(closedStallTexture)
		global.set_state(str("source_3_toilets_stall", str(id), "Open"), false)
	else:
		stall.set_texture(openStallTexture)
		global.set_state(str("source_3_toilets_stall", str(id), "Open"), true)

func use_empty_bottles_on_sink():
	if global.get_state("source_3_toilets_huffmanRiddleSolved"):
		if global.get_state("source_3_toilets_halfHuffmanRiddleSolved"):
			start_cinematic("endLevel")
		get_node("gui").set_text(global.get_game_text("getWater2"))
		global.use_item("source_3_shop_bottles")
		global.give_item("source_3_toilets_bottles")


func use_filled_bottles_on_sink():
	if global.get_state("source_3_toilets_huffmanRiddleSolved"):
		get_node("gui").set_text( global.get_game_text("getWater3") )


#####################
func start_cinematic(name):
	get_node("cinematic").connect("finished", self, "end_cinematic", [name])
	get_node("cinematic").get_events(name)
	get_node("cinematic").freeze_scene()
	get_node("cinematic").start()

func end_cinematic(name):
	get_node("cinematic").disconnect("finished", self, "end_cinematic")
	get_node("cinematic").unfreeze_scene()
	if name == "endLevel":
		global.set_state("source_3_finished", true)