##### res://scripts/gui/inventory
#####
##### Ce script gère l'inventaire

extends Control

var selectedItem

var iconScale = 1

var useButton
var returnButton
var itemList
var itemNameLabel
var itemDescriptionLabel
var itemIconTextureFrame

######## Initialisation ########
func _ready():
	#### Récupération des nodes d'intérêt ####
	useButton = get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/useButton")
	returnButton = get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/returnButton")
	itemList = get_node("Control/VBoxContainer/ItemList")
	itemNameLabel = get_node("Control/VBoxContainer/HBoxContainer/descriptionContainer/itemName")
	itemDescriptionLabel = get_node("Control/VBoxContainer/HBoxContainer/descriptionContainer/itemDescription")
	itemIconTextureFrame = get_node("Control/VBoxContainer/HBoxContainer/itemIcon")

	#### Affichage/traduction des textes ####
	for node in ["buttonToMap","buttonToEncyclopedia","buttonToLog"]:
		get_node(str("Control/VBoxContainer/tabs/",node)).set_text(global.get_gui_text(node))
	get_node("Control/VBoxContainer/tabs/menuTitle").set_text(global.get_gui_text("buttonToInventory"))
	useButton.set_text(global.get_gui_text("useButton"))
	returnButton.set_text(global.get_gui_text("returnButton"))

	#### Déblocage ou non des boutons vers les autres menus ####
	for guiElement in ["encyclopedia", "log", "map"]:
		if Globals.get("gameState").has(str(guiElement,"Unlocked")):
			get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_disabled(!Globals.get("gameState")[str(guiElement,"Unlocked")])
			if Globals.get("gameState")[str(guiElement,"Unlocked")]:
				get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_default_cursor_shape(2)

	#### Curseurs ####
	returnButton.set_default_cursor_shape(2)
	if !useButton.is_disabled():
		useButton.set_default_cursor_shape(2)

	Globals.set("selectedItem", "")
	get_node("inventoryFunctions").display_inventory(itemList, iconScale, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel)

	set_process_input(true)
####################

######## Affichage des détails d'un objet sélectionné ########
func _on_ItemList_item_selected(index):
	var metadata = itemList.get_item_metadata(index)
	if metadata != null:
		get_node("inventoryFunctions").display_item(iconScale, metadata.code, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel)
####################

######## Utilisation d'un objet par double-clic ########
func _on_ItemList_item_activated( index ):
	_on_useButton_pressed()
####################

######## Inputs ########
func _input(event):
	if event.type == InputEvent.KEY:
		# Sortie de l'inventaire en utilisant le raccourci clavier
		if event.is_action_pressed("inventory") or event.is_action_pressed("menu"):
			_on_returnButton_pressed()

		# Utilisation d'un objet et sortie de l'inventaire avec le raccourci clavier
		if Globals.get("selectedItem") != "" and event.is_action_pressed("interactWithItem"):
			_on_useButton_pressed()

# Sortie de l'inventaire en utilisant le bouton retour
func _on_returnButton_pressed():
	Globals.set("selectedItem", "")
	global.load_scene()

# Utilisation d'un objet et sortie de l'inventaire avec le bouton utiliser
func _on_useButton_pressed():
	get_node("Control/VBoxContainer/ItemList").release_focus() # Sinon Enter agit sur l'ItemList de façon indésirable et il ne se passe rien
	global.set_used_item( Globals.get("selectedItem") )
	Globals.set("selectedItem", "")
	global.load_scene()

# Passage au journal avec le bouton
func _on_buttonToLog_pressed():
	Globals.set("selectedItem", "")
	player.play_sound("log")
	global.set_scene("res://scenes/gui/log.tscn")

# Passage à la carte avec le bouton
func _on_buttonToMap_pressed():
	Globals.set("selectedItem", "")
	player.play_sound("map")
	global.set_scene("res://scenes/gui/map.tscn")

# Passage à l'encyclopédie avec le bouton
func _on_buttonToEncyclopedia_pressed():
	Globals.set("selectedItem", "")
	player.play_sound("encyclopedia")
	global.set_scene("res://scenes/gui/encyclopedia.tscn")
####################