##### res://scripts/menu/debugMenu.gd
#####
##### Que pour nous !

extends Control

var language

######## Initialisation ########
func _ready():
	language = settings.get_language()

	get_node("VBoxContainer/menuTitle").set_text(global.get_gui_text("debugMenuButton"))

	#### Items giver and user ####
	var items = global.json_into_dictionary("res://data/items.json")

	for item in items:
		var itemPickedUp = CheckBox.new()
		itemPickedUp.connect("toggled", self, "_on_itemPickedUp_toggled", [item])
		if global.get_state(str(item,"PickedUp")):
			itemPickedUp.set_pressed(true)
		else:
			itemPickedUp.set_pressed(false)

		var itemUsed = CheckBox.new()
		itemUsed.connect("toggled", self, "_on_itemUsed_toggled", [item])
		if global.get_state(str(item,"Used")):
			itemUsed.set_pressed(true)
		else:
			itemUsed.set_pressed(false)

		var itemCode = Label.new()
		itemCode.set_text(item)

		var itemName = Label.new()
		itemName.set_text(items[item].name[language])

		var itemControl = Control.new()
		var itemContainer = HBoxContainer.new()
		itemContainer.add_child(itemPickedUp)
		itemContainer.add_child(itemUsed)
		itemContainer.add_child(itemCode)
		itemContainer.add_child(itemName)

		itemControl.add_child(itemContainer)
		get_node("VBoxContainer/itemsGiver/VBoxContainer").add_child(itemControl)
	var lastItemControl = Control.new()
	get_node("VBoxContainer/itemsGiver/VBoxContainer").add_child(lastItemControl)
	####################

	#### Menus unlocker ####
	var menus = ["inventory", "log", "encyclopedia", "map"]

	for menu in menus:
		var menuUnlocked = CheckBox.new()
		menuUnlocked.connect("toggled", self, "_on_menuUnlocked_toggled", [menu])
		if global.get_state(str(menu,"Unlocked")):
			menuUnlocked.set_pressed(true)
		else:
			menuUnlocked.set_pressed(false)

		var menuCode = Label.new()
		menuCode.set_text(menu)

		var menuControl = Control.new()
		var menuContainer = HBoxContainer.new()
		menuContainer.add_child(menuUnlocked)
		menuContainer.add_child(menuCode)

		menuControl.add_child(menuContainer)
		get_node("VBoxContainer/menusUnlocker/VBoxContainer").add_child(menuControl)
	var lastMenuControl = Control.new()
	get_node("VBoxContainer/menusUnlocker/VBoxContainer").add_child(lastMenuControl)
	####################

	#### Teleporter ####
	var locations = global.json_into_dictionary("res://data/locations.json")
	for location in locations:
		var locationButton = Button.new()
		locationButton.connect("pressed", self, "_on_locationButton_pressed", [location])
		locationButton.set_text(global.get_gui_text("travelButton"))

		var locationPath = Label.new()
		locationPath.set_text(location)

		var locationName = Label.new()
		if locations[location].has(language):
			locationName.set_text(locations[location][language])
		else:
			locationName.set_text(locations[location]["fr"])

		var locationControl = Control.new()
		var locationContainer = HBoxContainer.new()
		locationContainer.add_child(locationButton)
		locationContainer.add_child(locationPath)
		locationContainer.add_child(locationName)

		locationControl.add_child(locationContainer)
		get_node("VBoxContainer/teleporter/VBoxContainer").add_child(locationControl)
	var lastLocationControl = Control.new()
	get_node("VBoxContainer/teleporter/VBoxContainer").add_child(lastLocationControl)
	####################

	#### Map locations unlocker ####
	var mapLocations = global.json_into_dictionary("res://data/map.json")
	for mapLocation in mapLocations:
		var mapLocationUnlocked = CheckBox.new()
		mapLocationUnlocked.connect("toggled", self, "_on_mapLocationUnlocked_toggled", [mapLocation])
		if global.get_state(str(mapLocation,"_unlocked")):
			mapLocationUnlocked.set_pressed(true)
		else:
			mapLocationUnlocked.set_pressed(false)

		var mapLocationCode = Label.new()
		mapLocationCode.set_text(mapLocation)

		var mapLocationName = Label.new()
		if mapLocations[mapLocation]["name"].has(language):
			mapLocationName.set_text(mapLocations[mapLocation]["name"][language])
		else:
			mapLocationName.set_text(mapLocations[mapLocation]["name"]["fr"])

		var mapLocationControl = Control.new()
		var mapLocationContainer = HBoxContainer.new()
		mapLocationContainer.add_child(mapLocationUnlocked)
		mapLocationContainer.add_child(mapLocationCode)
		mapLocationContainer.add_child(mapLocationName)

		mapLocationControl.add_child(mapLocationContainer)
		get_node("VBoxContainer/mapLocationsUnlocker/VBoxContainer").add_child(mapLocationControl)
	var lastMapLocationControl = Control.new()
	get_node("VBoxContainer/mapLocationsUnlocker/VBoxContainer").add_child(lastMapLocationControl)
	####################
	
	#### Hats unlocker ####
	var hats = global.json_into_dictionary("res://data/hats.json")
	for hat in hats:
		var hatUnlocked = CheckBox.new()
		hatUnlocked.connect("toggled", self, "_on_hatUnlocked_toggled", [hat])
		if Globals.get("gameState").has("unlockedHats") and Globals.get("gameState")["unlockedHats"].has(hat):
			hatUnlocked.set_pressed(true)
		else:
			hatUnlocked.set_pressed(false)
			
		var hatCode = Label.new()
		hatCode.set_text(hat)

		var hatName = Label.new()
		hatName.set_text(hats[hat].name[language])

		var hatControl = Control.new()
		var hatContainer = HBoxContainer.new()

		hatContainer.add_child(hatUnlocked)
		hatContainer.add_child(hatCode)
		hatContainer.add_child(hatName)

		hatControl.add_child(hatContainer)
		get_node("VBoxContainer/hatUnlocker/VBoxContainer").add_child(hatControl)
	var lastHatControl = Control.new()
	get_node("VBoxContainer/hatUnlocker/VBoxContainer").add_child(lastHatControl)
	####################
	
	#### Encyclopedia unlocker ####
	get_node("VBoxContainer/encyclopediaUnlocker/unlockButton").connect("pressed", self, "_on_unlockEncyclopediaButton_pressed")
	####################

	set_process_input(true)
####################

######## Inputs ########
# Retour au menu avec le raccourci clavier
func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("menu"):
		_on_returnButton_pressed()

# Retour au menu avec le bouton retour
func _on_returnButton_pressed():
	player.play_sound("menu")
	global.set_scene("res://scenes/menu/menu.tscn")

# Donner/retirer objet
func _on_itemPickedUp_toggled(pressed, itemCode):
	global.set_state(str(itemCode,"PickedUp"), pressed)

# Utiliser/désutiliser objet
func _on_itemUsed_toggled(pressed, itemCode):
	global.set_state(str(itemCode,"Used"), pressed)

# Débloquer/bloquer menu
func _on_menuUnlocked_toggled(pressed, menu):
	global.set_state(str(menu,"Unlocked"), pressed)

# Téléportation
func _on_locationButton_pressed(location):
	global.set_scene(location)

# Débloquer/bloquer destination
func _on_mapLocationUnlocked_toggled(pressed, mapLocation):
	global.set_state(str(mapLocation,"_unlocked"), pressed)

# Donner/retirer chapeau
func _on_hatUnlocked_toggled(pressed, hatCode):
	if pressed:
		global.unlock_hat(hatCode)
	else:
		if Globals.get("gameState").has("unlockedHats"):
			Globals.get("gameState")["unlockedHats"].remove(Globals.get("gameState")["unlockedHats"].find(hatCode))

func _on_unlockEncyclopediaButton_pressed():
	var chapter = get_node("VBoxContainer/encyclopediaUnlocker/chapterUnlocker").get_text()
	var section = get_node("VBoxContainer/encyclopediaUnlocker/sectionUnlocker").get_text()
	var entry = get_node("VBoxContainer/encyclopediaUnlocker/entryUnlocker").get_text()

	get_node("VBoxContainer/encyclopediaUnlocker/chapterUnlocker").set_text("")
	get_node("VBoxContainer/encyclopediaUnlocker/sectionUnlocker").set_text("")
	get_node("VBoxContainer/encyclopediaUnlocker/entryUnlocker").set_text("")

	if !(chapter == ""):
		if section == "":
			if entry == "":
				global.unlock_chapter_entries(chapter)
			else:
				global.unlock_entry(chapter, entry)
		else:
			if entry == "":
				global.unlock_section_entries(chapter, section)
			else:
				global.unlock_entry_s(chapter, section, entry)

# Afficher gameState
func _on_gameStateButton_pressed():
	print(Globals.get("gameState"))
####################