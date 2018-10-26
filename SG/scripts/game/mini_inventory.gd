##### res://scripts/game/mini-inventory.gd
#####
##### Gestion du mini-inventaire présent dans les énigmes


extends WindowDialog

var hotkeys_activated = true

var iconScale = 0.4

var useButton
var returnButton
var itemList

var itemNameLabel
var itemDescriptionLabel
var itemIconTextureFrame

######################## Initialisation
func _ready():
	get_children()[0].set_default_cursor_shape(2)

	useButton = get_node("VBoxContainer/HBoxContainer/buttonsContainer/useButton")
	returnButton = get_node("VBoxContainer/HBoxContainer/buttonsContainer/returnButton")
	itemList = get_node("VBoxContainer/ItemList")

	itemNameLabel = get_node("VBoxContainer/HBoxContainer/descriptionContainer/itemName")
	itemDescriptionLabel = get_node("VBoxContainer/HBoxContainer/descriptionContainer/itemDescription")
	itemIconTextureFrame = get_node("VBoxContainer/HBoxContainer/itemIcon")
	itemIconTextureFrame.set_expand(true)

	#### Affichage et traduction des textes statiques ####
	set_title(global.get_gui_text("buttonToInventory"))
	useButton.set_text(global.get_gui_text("useButton"))
	returnButton.set_text(global.get_gui_text("returnButton"))

	#### Paramétrage de la fenêtre ####
	get_node("VBoxContainer").set_size(get_size())

	Globals.set("selectedItem", "")

	get_node("inventoryFunctions").display_inventory(itemList, iconScale, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel)

	set_process_input(true)

	#### Curseurs ####
	if !useButton.is_disabled():
		useButton.set_default_cursor_shape(2)
	returnButton.set_default_cursor_shape(2)

#### Mise à jour de l'inventaire
func update():
	itemList.clear()
	get_node("inventoryFunctions").display_inventory(itemList, iconScale, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel)

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		_on_useButton_pressed()

func _on_useButton_pressed():
	if is_visible():
		global.set_used_item( Globals.get("selectedItem") )
		hide()

#### Quand un objet est sélectionné ####
func _on_ItemList_item_selected( index ):
	var metadata = itemList.get_item_metadata(index)
	if metadata != null:
		get_node("inventoryFunctions").display_item(iconScale, metadata.code, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel)

#### Double-clic sur un objet ####
func _on_ItemList_item_activated(index):
	var metadata = itemList.get_item_metadata(index)
	get_node("inventoryFunctions").display_item(iconScale, metadata.code, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel)
	_on_useButton_pressed()

func _on_returnButton_pressed():
	hide()