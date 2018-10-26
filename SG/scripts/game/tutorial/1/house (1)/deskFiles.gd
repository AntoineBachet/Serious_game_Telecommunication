extends Node

var riddle
var language
var imagetexture

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"house"})

	set_process(true)

	get_node("feuilles").set_default_cursor_shape(2)
	get_node("safe").set_default_cursor_shape(2)
	get_node("eraser").set_default_cursor_shape(2)
	get_node("pencilCup").set_default_cursor_shape(2)

	#### Nettoyage et à mise à jour de la scène ####
	# Feuilles
	if !global.is_chapter_unlocked("braille"):
		get_node("feuilles").show()
	else:
		get_node("feuilles").queue_free()
		get_node("riddleOverlay").set_tip(global.get_game_text("whiteboardTip"))
	# Coffre
	if global.get_state("tutorial_1_house_deskPuzzleSolved"):
		get_node("safe").set_disabled(true)
		get_node("safe").set_default_cursor_shape(0)

	#### Récupération de l'énigme ####
	riddle = global.get_riddle("board")
	language = settings.get_language()
	imagetexture = ImageTexture.new()
	imagetexture.load(riddle[language])
	get_node("whiteboard").set_texture(imagetexture)
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		global.set_used_item("")

	#### Suppression des feuilles après les avoir ramassées puis cachées pour éviter un problème de clignotement ####
	if has_node("feuilles") and !get_node("feuilles").is_visible():
		get_node("feuilles").queue_free()
		get_node("riddleOverlay").set_text(global.get_game_text("deskInteract"))

######## Interactions avec l'environnement ########
func _on_feuilles_pressed():
	global.unlock_chapter_entries("braille")
	get_node("riddleOverlay").set_tip(global.get_game_text("whiteboardTip"))
	get_node("riddleOverlay").update()
	get_node("feuilles").hide() #plus de soucis de clignotement si on le cache au lieu de le supprimer : il ne peut pas être supprimé avant d'avoir fini d'émettre, du coup c'est le bordel

func _on_feuilles_mouse_enter():
	get_node("riddleOverlay").set_text(global.get_game_text("deskFilesBraille"))

func _on_feuilles_mouse_exit():
	get_node("riddleOverlay").set_text("")

func _on_safe_pressed():
	if !global.get_state("tutorial_1_house_deskPuzzleSolved"):
		global.set_scene("res://scenes/game/tutorial/1/house/deskPuzzle.tscn")

func _on_pencilCup_pressed():
	get_node("riddleOverlay").set_text(global.get_game_text("pencilCup"))

func _on_eraser_pressed():
	get_node("riddleOverlay").set_text(global.get_game_text("whiteboardEraser"))
####################

######## Pop-ups ########
func _on_safe_mouse_enter():
	if global.get_state("tutorial_1_house_deskPuzzleSolved"):
		get_node("riddleOverlay").set_text(global.get_game_text("deskUnlockedSafeHover"))
	else:
		get_node("riddleOverlay").set_text(global.get_game_text("deskLockedSafeHover"))

func _on_safe_mouse_exit():
	get_node("riddleOverlay").set_text("")

func _on_whiteboard_mouse_enter():
	get_node("riddleOverlay").set_text(global.get_game_text("whiteboardHover"))

func _on_whiteboard_mouse_exit():
	get_node("riddleOverlay").set_text("")
####################