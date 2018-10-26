##### res://scripts/game/mini-item.gd
#####
##### Gestion des mini-items présents dans les énigmes


extends WindowDialog

var iconScale = 0.4

var useButton
var returnButton

var itemNameLabel
var itemDescriptionLabel
var itemIconTextureFrame

######################## Initialisation
func _ready():
	get_children()[0].set_default_cursor_shape(2)

	useButton = get_node("VBoxContainer/HBoxContainer/buttonsContainer/useButton")
	returnButton = get_node("VBoxContainer/HBoxContainer/buttonsContainer/returnButton")

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

	set_process_input(true)

	#### Curseurs ####
	if !useButton.is_disabled():
		useButton.set_default_cursor_shape(2)
	returnButton.set_default_cursor_shape(2)

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("interactWithItem"):
		_on_useButton_pressed()

func _on_useButton_pressed():
	if is_visible():
		global.set_used_item( Globals.get("selectedItem") )
		hide()

func _on_returnButton_pressed():
	hide()