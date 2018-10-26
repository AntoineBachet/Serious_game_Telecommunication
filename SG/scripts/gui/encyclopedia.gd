##### res://scripts/gui/encyclopedia.gd
#####
##### Ce script gère l'encyclopédie : affichage de différentes entrées à droite et d'un sommaire
##### à gauche.

extends Control

var tree

######## Initialisation ########
func _ready():
	#### Affichage/traduction des textes ####
	for node in ["buttonToMap","buttonToInventory","buttonToLog"]:
		get_node(str("Control/VBoxContainer/tabs/",node)).set_text(global.get_gui_text(node))
	get_node("Control/VBoxContainer/tabs/menuTitle").set_text(global.get_gui_text("buttonToEncyclopedia"))
	get_node("Control/VBoxContainer/returnButton").set_text(global.get_gui_text("returnButton"))

	#### Déblocage ou non des boutons vers les autres menus ####
	for guiElement in ["inventory", "log", "map"]:
		if Globals.get("gameState").has(str(guiElement,"Unlocked")):
			get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_disabled(!Globals.get("gameState")[str(guiElement,"Unlocked")])
			## Curseurs
			if Globals.get("gameState")[str(guiElement,"Unlocked")]:
				get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_default_cursor_shape(2)

	#### Curseurs ####
	get_node("Control/VBoxContainer/returnButton").set_default_cursor_shape(2)

	#### Affichage des entrées d'encyclopédie ####
	tree = get_node("Control/VBoxContainer/HBoxContainer/Tree")
	get_node("encyclopediaFunctions").display_encyclopedia(tree)

	set_process_input(true)
####################

#### Affichage de l'entrée sélectionnée ####
func _on_Tree_cell_selected():
	if tree.get_selected().get_metadata(0)!=null:
		if global.get_state("unreadEntries").has(tree.get_selected().get_metadata(0)[0]):
			global.get_state("unreadEntries").remove(global.get_state("unreadEntries").find(tree.get_selected().get_metadata(0)[0]))
			tree.get_selected().set_text(0,tree.get_selected().get_text(0).split(str("(", global.get_gui_text("encyclopediaUnread"), ") "))[1])
		get_node("Control/VBoxContainer/HBoxContainer/VBoxContainer/entryTitle").set_text(tree.get_selected().get_text(0))
		get_node("Control/VBoxContainer/HBoxContainer/VBoxContainer/entryContent").set_bbcode(tree.get_selected().get_metadata(0)[1])
		# remove l'entrée de unreadEntries
####################

######## Inputs ########
# Sortie de l'encyclopédie avec le raccourci clavier
func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("encyclopedia") or event.is_action_pressed("menu"):
			global.load_scene()

# Sortie de l'encyclopédie avec le bouton retour
func _on_returnButton_pressed():
	global.load_scene()

# Passage au journal avec le bouton
func _on_buttonToLog_pressed():
	global.set_scene("res://scenes/gui/log.tscn")
	player.play_sound("log")

# Passage à la carte avec le bouton
func _on_buttonToMap_pressed():
	player.play_sound("map")
	global.set_scene("res://scenes/gui/map.tscn")

# Passage à l'inventaire avec le bouton
func _on_buttonToInventory_pressed():
	player.play_sound("inventory")
	global.set_scene("res://scenes/gui/inventory.tscn")
####################