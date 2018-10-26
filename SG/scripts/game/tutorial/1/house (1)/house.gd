extends Node2D

var chestOpened = load("res://assets/game/tutorial/1/house/chest_opened.png")
var deskWithoutBraille = load("res://assets/game/tutorial/1/house/desk_house_without_braille.png")

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"house"})

	set_process(true)
	set_process_input(true)

	#### Nettoyage et mise à jour des objets ####
	# Bookshelf ouverte
	if global.get_state("tutorial_1_house_bookshelfMoved"):
		var bookshelfAnimation = get_node("bookshelf/AnimationPlayer").get_animation("bookshelfOpening")
		var trackId = bookshelfAnimation.find_track(".:transform/pos")
		var lastKey = bookshelfAnimation.track_get_key_count(trackId) - 1
		var pos = bookshelfAnimation.track_get_key_value(trackId, lastKey)
		get_node("bookshelf").set_pos(pos)
	else:
		get_node("character").cannotInteract("secretDoor")

	# Bureau
	if global.is_chapter_unlocked("braille"):
		get_node("desk").set_texture(deskWithoutBraille)

	#### Pop-ups ####
	# Affichage du message si on a réussi à ouvrir le coffre + son + màj liste des objets interactifs
	if global.get_state("tutorial_1_house_chestPuzzleSolved"):
		open_chest()
	# Affichage du message si on a réussi le mini jeu du piano
	if global.get_state("tutorial_1_house_pianoSolved") and !global.get_state("tutorial_1_house_pianoMessageShown"):
		display_piano_message()
	# Affichage du message si on a réussi à ouvrir la porte
	if global.get_state("tutorial_1_house_secretDoorPuzzleSolved") and !global.get_state("tutorial_1_house_secretDoorMessageShown"):
		display_door_message()
	# Affichage du message si on a réussi l'énigme du bureau
	if !global.get_state("tutorial_1_house_deskMessageShown") and global.get_state("tutorial_1_house_deskPuzzleSolved"):
		display_desk_message()
		get_node("gui").update()

	#### Cinématique d'intro ####
	if !global.get_state("tutorial_1_house_cinematic_played"):
		global.set_state("tutorial_1_house_cinematic_played", true)
		get_node("cinematic").connect("finished", self, "end_cinematic")
		start_cinematic("enter_room")
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_house_sticks" and !global.get_state("tutorial_1_house_chestPuzzleSolved") and global.character_in_hitbox("chest"):
			use_sticks_on_chest()
		elif global.get_used_item() == "tutorial_1_house_marbles" and !global.get_state("tutorial_1_house_secretDoorPuzzleSolved") and global.character_in_hitbox("secretDoor"):
			use_marbles_on_door()
		else: # Il faut le mettre dans else sinon on n'utilise pas les objets dans les énigmes
			global.set_used_item("")

######## Interactions avec l'environnement ########
func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		# Juliette
		if global.character_in_hitbox("juliette"):
			interact_juliette()
		# Bureau
		if global.character_in_hitbox("desk"):
			interact_desk()
		# Chest
		if !global.get_state("tutorial_1_house_chestPuzzleSolved") and global.character_in_hitbox("chest"):
			interact_chest()
		# Bookshelf
		if global.get_state("tutorial_1_house_sticksPickedUp") and !global.get_state("tutorial_1_house_bookshelfMoved") and !get_node("bookshelf/AnimationPlayer").is_playing() and global.character_in_hitbox("bookshelf"):
			move_bookshelf()
		if !global.get_state("tutorial_1_house_sticksPickedUp") and global.character_in_hitbox("bookshelf"):
			interact_bookshelf_before()
		if global.get_state("tutorial_1_house_bookshelfMoved") and global.character_in_hitbox("bookshelf"):
			interact_bookshelf_after()
		#Secret door
		if global.get_state("tutorial_1_house_bookshelfMoved") and global.character_in_hitbox("secretDoor"):
			interact_secretDoor()
		# Porte vers le village
		if global.character_in_hitbox("entranceDoor"):
			interact_entranceDoor()
		#Piano
		if global.character_in_hitbox("piano"):
			interact_piano()
		# Posters inutiles
		if global.character_in_hitbox("useless"):
			interact_posters()
####################

######## Fonctions pour process ########
func use_sticks_on_chest():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/house/chestPuzzle.tscn")

func use_marbles_on_door():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/house/secretDoorPuzzle.tscn")
####################

######## Fonctions pour input ########
func interact_juliette():
	if !global.get_state( "tutorial_1_secretroom_computerPuzzleSolved" ):
		get_node("gui").set_text(global.get_game_text("julietteInteract"))
	elif !global.get_state( "mapUnlocked" ):
		get_node("gui").set_text(global.get_game_text("julietteInteractMap"))
	else:
		get_node("gui").set_text(global.get_game_text("julietteInteractNextLocation"))

func interact_desk():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/house/deskFiles.tscn")

func interact_chest():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/house/chestPuzzle.tscn")

func move_bookshelf():
	get_node("character").canInteract( "secretDoor" )
	get_node("gui").set_text(global.get_game_text("bookshelfMove"))
	get_node("bookshelf/AnimationPlayer").play("bookshelfOpening")
	set_process(false)
	set_process_input(false)
	get_node("character").freeze_character()
	get_node("gui").set_gui_off()
	
func interact_bookshelf_before():
	global.give_item("tutorial_1_house_sticks")
	get_node("gui").set_text(global.get_game_text("bookshelfFindSticks"))

func interact_bookshelf_after():
	get_node("gui").set_text(global.get_game_text("bookshelfInteract"))

func interact_secretDoor():
	if global.get_state("tutorial_1_house_secretDoorPuzzleSolved"):
		global.set_scene("res://scenes/game/tutorial/1/secretroom.tscn")
		player.play_sound("woodendoor")
	else:
		if global.save_scene():
			global.set_scene("res://scenes/game/tutorial/1/house/secretDoorPuzzle.tscn")

func interact_entranceDoor():
	global.set_target_node("houseDoor")
	player.play_sound("woodendoor")
	global.set_scene("res://scenes/game/tutorial/1/village.tscn")

func interact_piano():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/house/pianoPuzzle.tscn")

func interact_posters():
	if global.save_scene():
		global.set_scene("res://scenes/game/tutorial/1/house/uselessPosters.tscn")
####################

######## Fin de l'ouverture de la bibliothèque ########
func _on_AnimationPlayer_finished():
	global.set_state("tutorial_1_house_bookshelfMoved", true)
	global.set_state("tutorial_1_house_movedBookshelfXPosition", get_node("bookshelf").get_pos().x)
	global.set_state("tutorial_1_house_movedBookshelfYPosition", get_node("bookshelf").get_pos().y)
	get_node("cinematic").unfreeze_scene()
####################

######## Fonctions pour la cinématique ########
func start_cinematic(name):
	get_node("cinematic").freeze_scene()
	get_node("cinematic").get_events(name)
	get_node("cinematic").start()

func end_cinematic():
	get_node("cinematic").unfreeze_scene()
##################

######## Fonctions pour ready ########
func open_chest():
	get_node("character").cannotInteract("chest")
	get_node("chest").set_texture(chestOpened)
	if !global.get_state("tutorial_1_house_chestMessageShown"):
		player.play_sound("chestopening")
		global.set_state("tutorial_1_house_chestMessageShown", true)
		get_node("gui").set_text(global.get_game_text("chestOpen"))

func display_piano_message():
	global.set_state("tutorial_1_house_pianoMessageShown", true)
	get_node("gui").set_text(global.get_game_text("pianoSolved"))

func display_door_message():
	global.set_state("tutorial_1_house_secretDoorMessageShown", true)
	get_node("gui").set_text(global.get_game_text("secretDoorOpen"))

func display_desk_message():
	global.set_state("tutorial_1_house_deskMessageShown", true)
	global.set_state("mapUnlocked", true)
	get_node("gui").set_text(global.get_game_text("deskPuzzleSolved"))
####################