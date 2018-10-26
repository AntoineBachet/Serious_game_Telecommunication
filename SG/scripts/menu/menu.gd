##### res://scripts/menu/menu.gd
#####
##### Menu principal du jeu

extends Control

var lastSaveSlotNumber = -1

######## Initialisation ########
func _ready():
	global.set_details(global.get_details())
#	Globals.set("sceneDetails", {"area":"menu"})
#	player.process_music()

	#### Affichage/traduction des textes ####
	for node in ["settingsButton","newGameButton","saveGameButton","loadGameButton","exitGameButton","mainMenuButton","resumeButton","aboutButton","debugMenuButton","achievementsButton","characterCustomizationButton"]:
		get_node(str("menu/",node)).set_text(global.get_gui_text(node).to_upper())

	var confirmPopup_exitGame = get_node("confirmPopup_exitGame")
	confirmPopup_exitGame.set_text(global.get_gui_text("unsavedProgressWillBeLost"))
	confirmPopup_exitGame.set_title(global.get_gui_text("exitGameButton"))
	confirmPopup_exitGame.get_cancel().set_text(global.get_gui_text("cancel"))
	confirmPopup_exitGame.get_ok().set_text(global.get_gui_text("exitGameButton"))

	var confirmPopup_mainMenu = get_node("confirmPopup_mainMenu")
	confirmPopup_mainMenu.set_text(global.get_gui_text("unsavedProgressWillBeLost"))
	confirmPopup_mainMenu.set_title(global.get_gui_text("mainMenuButton"))
	confirmPopup_mainMenu.get_cancel().set_text(global.get_gui_text("cancel"))
	confirmPopup_mainMenu.get_ok().set_text(global.get_gui_text("mainMenuButton"))

	#### Afficher/cacher les boutons dans le menu principal/menu en jeu ####
	var resumeButton = get_node("menu/resumeButton")
	var mainMenuButton = get_node("menu/mainMenuButton")
	var saveGameButton = get_node("menu/saveGameButton")
	var newGameButton = get_node("menu/newGameButton")
	var aboutButton = get_node("menu/aboutButton")
	var debugMenuButton = get_node("menu/debugMenuButton")
	var achievementsButton = get_node("menu/achievementsButton")
	var characterCustomizationButton = get_node("menu/characterCustomizationButton")

	if Globals.get("menuState") == "mainMenu":
		resumeButton.show()
		getLastSave()
		mainMenuButton.hide()
		saveGameButton.hide()
		debugMenuButton.hide()
		newGameButton.show()
		aboutButton.show()
		achievementsButton.hide()
		characterCustomizationButton.hide()
	elif Globals.get("menuState") == "gameMenu":
		newGameButton.hide()
		aboutButton.hide()
		resumeButton.show()
		mainMenuButton.show()
		saveGameButton.show()
		achievementsButton.show()
		characterCustomizationButton.show()
		if Globals.get("gameState").has("unlockedHats") and Globals.get("gameState")["unlockedHats"].size()>0 or Globals.get("gameState").has("score_quiz") and int(Globals.get("gameState")["score_quiz"])>0:
			characterCustomizationButton.set_disabled(false)
		else:
			characterCustomizationButton.set_disabled(true)
		if settings.is_debug_mode():
			debugMenuButton.show()
		else:
			debugMenuButton.hide()

	set_process_input(true)
####################

######## Détermination de la sauvegarde la plus récente et activation du bouton Reprendre s'il y a lieu ########
func getLastSave():
	var loadGame = File.new()
	var saveDates = {}
	for slotNumber in [0,1,2,3]:
		if loadGame.file_exists(str("user://saves/save",slotNumber,".json")):		#Le fichier existe
			var saveContent = global.json_into_dictionary(str("user://saves/save",slotNumber,".json"), "nikolatesla")
			saveDates[slotNumber] = saveContent["saveDate"]
		loadGame.close()

	var lastSaveDate = {"year":0,"month":0, "day":0, "hours":0, "minutes":0, "seconds":0}

	if saveDates.values() != []:
		for slotNumber in saveDates:
			var date = saveDates[slotNumber]
			var currentSaveDate = {"day":int(date.substr(0,2)), "month":int(date.substr(3,2)), "year":int(date.substr(6,4)), "hours":int(date.substr(11,2)), "minutes":int(date.substr(14,2)), "seconds":int(date.substr(17,2))}
			if currentSaveDate.year > lastSaveDate["year"]:
				lastSaveSlotNumber = slotNumber
				lastSaveDate = currentSaveDate
			elif currentSaveDate.year == lastSaveDate["year"] and currentSaveDate.month > lastSaveDate["month"]:
				lastSaveSlotNumber = slotNumber
				lastSaveDate = currentSaveDate
			elif currentSaveDate.year == lastSaveDate["year"] and currentSaveDate.month == lastSaveDate["month"] and currentSaveDate.day > lastSaveDate["day"]:
				lastSaveSlotNumber = slotNumber
				lastSaveDate = currentSaveDate
			elif currentSaveDate.year == lastSaveDate["year"] and currentSaveDate.month == lastSaveDate["month"] and currentSaveDate.day == lastSaveDate["day"] and currentSaveDate.hours > lastSaveDate["hours"]:
				lastSaveSlotNumber = slotNumber
				lastSaveDate = currentSaveDate
			elif currentSaveDate.year == lastSaveDate["year"] and currentSaveDate.month == lastSaveDate["month"] and currentSaveDate.day == lastSaveDate["day"] and currentSaveDate.hours == lastSaveDate["hours"] and currentSaveDate.minutes > lastSaveDate["minutes"]:
				lastSaveSlotNumber = slotNumber
				lastSaveDate = currentSaveDate
			elif currentSaveDate.year == lastSaveDate["year"] and currentSaveDate.month == lastSaveDate["month"] and currentSaveDate.day == lastSaveDate["day"] and currentSaveDate.hours == lastSaveDate["hours"] and currentSaveDate.minutes == lastSaveDate["minutes"] and currentSaveDate.seconds > lastSaveDate["seconds"]:
				lastSaveSlotNumber = slotNumber
				lastSaveDate = currentSaveDate
			# si le joueur est hyperactif et fait deux sauvegardes dans la même seconde, tant pis pour lui
		get_node("menu/resumeButton").set_disabled(false)
	else:
		get_node("menu/resumeButton").set_disabled(true)
####################

######## Inputs ########
# Sortie du menu en jeu/du menu principal avec le raccourci clavier
func _input(event):	
	if event.is_action_pressed("menu"):
		if Globals.get("menuState") == "mainMenu":
			_on_exitGameButton_pressed()
		elif Globals.get("menuState") == "gameMenu":
			if get_node("confirmPopup_exitGame").is_visible():
				get_node("confirmPopup_exitGame").hide()
				unfreeze_button()
			elif get_node("confirmPopup_mainMenu").is_visible():
				get_node("confirmPopup_mainMenu").hide()
				unfreeze_button()
			else:
				_on_resumeButton_pressed()

# Bouton Nouvelle partie
func _on_newGameButton_pressed():
	global.reset_global_variables()
	global.set_scene("res://scenes/game/intro/foreword.tscn")
	Globals.set("menuState","gameMenu")
	global.unlock_location("tutorial_1")
	player.play_sound("menu")

# Bouton Reprendre
func _on_resumeButton_pressed():
	if Globals.get("menuState") == "gameMenu":
		player.play_sound("menu")
		global.load_scene()
	else:
		get_node("saveFunctions").loadGame(lastSaveSlotNumber)

# Bouton Sauvegarder la partie
func _on_saveGameButton_pressed():
	global.set_scene("res://scenes/menu/save.tscn")
	player.play_sound("menu")

# Bouton Charger une partie
func _on_loadGameButton_pressed():
	global.set_scene("res://scenes/menu/load.tscn")
	player.play_sound("menu")

# Bouton Succès
func _on_achievementsButton_pressed():
	global.set_scene("res://scenes/menu/achievements.tscn")
	player.play_sound("menu")

# Bouton Personnalisation
func _on_characterCustomizationButton_pressed():
	global.set_scene("res://scenes/menu/characterCustomization.tscn")
	player.play_sound("menu")

# Bouton Options
func _on_settingsButton_pressed():
	global.set_scene("res://scenes/menu/settings.tscn")
	player.play_sound("menu")

# Bouton Menu de débug
func _on_debugMenuButton_pressed():
	global.set_scene("res://scenes/menu/debugMenu.tscn")
	player.play_sound("menu")

# Bouton Retour au menu principal
func _on_mainMenuButton_pressed():
	confirm_pop_up("mainMenu")

func mainMenu():
	Globals.set("menuState","mainMenu")
	player.play_sound("menu")
	global.set_scene("res://scenes/menu/splashScreen.tscn")

# Bouton A propos
func _on_aboutButton_pressed():
	global.set_scene("res://scenes/menu/about.tscn")
	player.play_sound("menu")

# Bouton Quitter le jeu
func _on_exitGameButton_pressed():
	if Globals.get("menuState") == "gameMenu":
		confirm_pop_up("exitGame")
	else:
		exitGame()

func exitGame():
	player.play_sound("menu")
	OS.delay_msec(500)
	get_tree().quit()
############

######## Pop-up de confirmation ########
func confirm_pop_up(what):
	freeze_button()
	var pop_up_window = null
	if what == "mainMenu":
		pop_up_window = get_node("confirmPopup_mainMenu")
		pop_up_window.connect("confirmed", self, "mainMenu")
	elif what == "exitGame":
		pop_up_window = get_node("confirmPopup_exitGame")
		pop_up_window.connect("confirmed", self, "exitGame")
	pop_up_window.connect("hide", self, "unfreeze_button")
	pop_up_window.show()

func freeze_button():
	for b in get_node("menu").get_children():
		if b.is_visible():
			b.set_disabled(true)

func unfreeze_button():
	for b in get_node("menu").get_children():
		if b.is_visible():
			b.set_disabled(false)
####################