##### res://scripts/gui/map.gd
#####
##### Ce script gère la carte : affichage des différents endroits et voyage.

extends Control

var mapData

#### Chargement des icônes des points sur la carte ####
var location_default = load("res://assets/map/location_default.png")
var location_hover = load("res://assets/map/location_hover.png")
var location_selected = load("res://assets/map/location_selected.png")
var location_disabled = load("res://assets/map/location_disabled.png")
var location_current = load("res://assets/map/location_current.png")
var location_finished = load("res://assets/map/location_finished.png")
var location_finished_current = load("res://assets/map/location_finished_current.png")

var locationPath

var language

######## Initialisation ########
func _ready():
	language = settings.get_language()

	#### Affichage/traduction des textes ####
	for node in ["buttonToInventory","buttonToEncyclopedia","buttonToLog"]:
		get_node(str("Control/VBoxContainer/tabs/",node)).set_text(global.get_gui_text(node))
	get_node("Control/VBoxContainer/tabs/menuTitle").set_text(global.get_gui_text("buttonToMap"))
	get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/goButton").set_text(global.get_gui_text("travelButton"))
	get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/returnButton").set_text(global.get_gui_text("returnButton"))

	#### Déblocage ou non des boutons vers les autres menus ####
	for guiElement in ["encyclopedia", "log", "inventory"]:
		if Globals.get("gameState").has(str(guiElement,"Unlocked")):
			get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_disabled(!Globals.get("gameState")[str(guiElement,"Unlocked")])
			if Globals.get("gameState")[str(guiElement,"Unlocked")]:
				get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_default_cursor_shape(2)

	## Curseurs
	get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/returnButton").set_default_cursor_shape(2)
	##########

	#### Récupération des données de la carte ####
	mapData = global.json_into_dictionary("res://data/map.json")

	get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/goButton").set_disabled(true)

	#### Déblocage ou non des lieux, et connexion ####
	for location in mapData:
		if !(Globals.get("sceneDetails") != null and str(Globals.get("sceneDetails").area,"_",Globals.get("sceneDetails").level) == location):
			if global.get_state(mapData[location]["condition_finished"]):
				get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_normal_texture(location_finished)
			else:
				get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_normal_texture(location_default)
		else:
			if global.get_state(mapData[location]["condition_finished"]):
				get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_normal_texture(location_finished_current)
			else:
				get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_normal_texture(location_current)
		get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_hover_texture(location_hover)
		get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_pressed_texture(location_hover)
		get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_disabled_texture(location_disabled)
		get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_focused_texture(location_selected)
		get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_tooltip(mapData[location]["name"][language])
		if Globals.get("gameState").has(str(location,"_unlocked")) and Globals.get("gameState")[str(location,"_unlocked")]:
			get_node(str("Control/VBoxContainer/mapCanvas/",location)).connect("pressed", self, "_on_location_pressed", [location])
		else:
			get_node(str("Control/VBoxContainer/mapCanvas/",location)).set_disabled(true)

		# Sélection et affichage de la zone actuelle
		if Globals.get("sceneDetails")!=null:
			display_location(str(Globals.get("sceneDetails").area, "_", Globals.get("sceneDetails").level))
			get_node(str("Control/VBoxContainer/mapCanvas/",Globals.get("sceneDetails").area,"_",Globals.get("sceneDetails").level)).grab_focus()

	set_process_input(true)
####################

######## Afficher le nom et la description du lieu sélectionné dans le cadre en bas ########
func display_location(locationCode):
	#### Bouton Voyager ####
	if !(Globals.get("sceneDetails")!=null and str(Globals.get("sceneDetails").area,"_",Globals.get("sceneDetails").level) == locationCode):
		get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/goButton").set_disabled(false)
	else:
		get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/goButton").set_disabled(true)

	#### Remplissage du cadre ####
	var location = mapData[locationCode]
	var text = ""
	get_node("Control/VBoxContainer/HBoxContainer/location").clear()
	if get_node(str("Control/VBoxContainer/mapCanvas/",locationCode)).get_normal_texture() in [location_finished, location_finished_current]:
		text += global.get_gui_text("mapFinished")
	if Globals.get("sceneDetails") != null and str(Globals.get("sceneDetails").area,"_",Globals.get("sceneDetails").level) == locationCode:
		text += global.get_gui_text("mapHere")
	text += location["name"][language]
	text += str("\n",location["description"][language])
	get_node("Control/VBoxContainer/HBoxContainer/location").add_text(text)

	locationPath = location["path"]
####################

#### Voyager vers la destination sélectionnée ####
func _on_goButton_pressed():
	get_node("saveFunctions").saveGame("0") # autosave
	if Globals.has("sceneDetails"):
		Globals.get("gameState")["nextPath"] = locationPath
		var area = Globals.get("sceneDetails").area
		var level = Globals.get("sceneDetails").level
		var quiz = global.json_into_dictionary("res://data/quiz.json")
		if global.get_state(str(area, "_", level, "_finished")):
			if !global.get_state(str(area, "_", level, "_quiz_finished")):
				var quizPath = str("res://scenes/game/", area, "/", level, "/quiz/", area, "_", level, "_quiz.tscn")
				if quiz.has(area) and quiz[area].has(level):
					global.set_scene(quizPath)
				else:
					global.set_scene(locationPath)
			else:
				global.set_scene(locationPath)
		else:
			global.set_scene(locationPath)
	else:
		global.set_scene(locationPath)
####################

#### Sélection d'un lieu ####
func _on_location_pressed(location):
	display_location(location)
####################

######## Inputs ########
# Sortie de la carte avec le raccourci clavier
func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("map") or event.is_action_pressed("menu"):
			_on_returnButton_pressed()
		if event.is_action_pressed("interactWithItem"):
			if !get_node("Control/VBoxContainer/HBoxContainer/buttonsContainer/goButton").is_disabled():
				_on_goButton_pressed()

# Sortie de la carte avec le bouton retour
func _on_returnButton_pressed():
	global.load_scene()

# Passage à l'encyclopédie avec le bouton
func _on_buttonToEncyclopedia_pressed():
	player.play_sound("encyclopedia")
	global.set_scene("res://scenes/gui/encyclopedia.tscn")

# Passage à l'inventaire avec le bouton
func _on_buttonToInventory_pressed():
	player.play_sound("inventory")
	global.set_scene("res://scenes/gui/inventory.tscn")

# Passage au journal avec le bouton
func _on_buttonToLog_pressed():
	player.play_sound("log")
	global.set_scene("res://scenes/gui/log.tscn")
####################