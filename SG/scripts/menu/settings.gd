##### res://scripts/menu/settings.gd
#####
##### Options

extends Control

var currentGameSettings
var newGameSettings = {}

var musicSliderLevel
var soundSliderLevel

var languageButton
var languages

var debugButton
var debugField
var fullscreenButton
var musicButton
var musicSlider
var soundButton
var soundSlider

######## Initialisation ########
func _ready():

	display_text()

	#### Préparation des nodes ####
	languages = global.json_into_dictionary("res://data/languages.json")
	languageButton = get_node("VBoxContainer/VBoxContainer/languageBox/languageButton")
	var i = 0
	for language in languages:
		languageButton.add_item(language, i)
		languageButton.set_item_metadata(i, languages[language])
		i += 1
	languageButton.connect("item_selected", self, "_on_language_selected")
	
	debugButton = get_node("VBoxContainer/VBoxContainer/debugBox/debugButton")
	debugButton.connect("toggled" , self, "_on_CheckButton_toggled", ["debugMode"])
	debugField = get_node("VBoxContainer/VBoxContainer/debugBox/debugField")

	fullscreenButton = get_node("VBoxContainer/VBoxContainer/fullscreenBox/fullscreenButton")
	fullscreenButton.connect("toggled", self, "_on_CheckButton_toggled", ["fullscreen"])

	musicButton = get_node("VBoxContainer/VBoxContainer/musicBox/musicBox/musicBox/musicButton")
	musicSlider = get_node("VBoxContainer/VBoxContainer/musicBox/musicBox/musicBox/musicSlider")
	musicSlider.set_ticks(11)
	musicSliderLevel = get_node("VBoxContainer/VBoxContainer/musicBox/musicBox/musicSliderLevel")
	musicButton.connect("toggled", self, "_on_CheckButton_toggled", ["music"])
	musicSlider.connect("value_changed", self, "_on_Slider_value_changed", ["musicLevel", musicSliderLevel])

	soundButton = get_node("VBoxContainer/VBoxContainer/soundBox/soundBox/soundBox/soundButton")
	soundSlider = get_node("VBoxContainer/VBoxContainer/soundBox/soundBox/soundBox/soundSlider")
	soundSlider.set_ticks(11)
	soundSliderLevel = get_node("VBoxContainer/VBoxContainer/soundBox/soundBox/soundSliderLevel")
	soundButton.connect("toggled", self, "_on_CheckButton_toggled", ["sound"])
	soundSlider.connect("value_changed", self, "_on_Slider_value_changed", ["soundLevel", soundSliderLevel])

	#### Affichage des valeurs actuelles des options ####
	display_current_options()

	set_process_input(true)
####################

######## Affichage et traduction des textes ########
func display_text():
	get_node("VBoxContainer/menuTitle").set_text(global.get_gui_text("settingsButton"))
	get_node("VBoxContainer/buttonsBox/returnButton").set_text(global.get_gui_text("returnButton"))
	get_node("VBoxContainer/buttonsBox/applyButton").set_text(global.get_gui_text("applyButton"))
	get_node("VBoxContainer/resetButton").set_text(global.get_gui_text("resetSettings"))

	get_node("VBoxContainer/VBoxContainer/languageBox/languageLabel").set_text(global.get_gui_text("languageLabel"))
	get_node("VBoxContainer/VBoxContainer/debugBox/debugLabel").set_text(global.get_gui_text("debugModeLabel"))
	get_node("VBoxContainer/VBoxContainer/debugBox/debugField/debugLineEdit").set_placeholder(global.get_gui_text("password"))
	get_node("VBoxContainer/VBoxContainer/fullscreenBox/fullscreenLabel").set_text(global.get_gui_text("fullscreenLabel"))
####################

######## Affichage des valeurs des options ########
func display_current_options():
	currentGameSettings = settings.get_settings()

	# Language
	for i in range(languageButton.get_item_count()):
		if currentGameSettings["language"] == languageButton.get_item_metadata(i):
			languageButton.select(i)

	debugButton.set_pressed(settings.get_setting("debugMode"))
	if settings.get_setting("debugMode"):
		debugButton.show()
		debugField.hide()
	else:
		debugField.show()
		debugButton.hide()
	fullscreenButton.set_pressed(settings.get_setting("fullscreen"))
	soundButton.set_pressed(settings.get_setting("sound"))
	musicButton.set_pressed(settings.get_setting("music"))

	if currentGameSettings.has("musicLevel"):
		musicSlider.set_value(int(currentGameSettings["musicLevel"]))
	else:
		musicSlider.set_value(100)

	if currentGameSettings.has("soundLevel"):
		soundSlider.set_value(int(currentGameSettings["soundLevel"]))
	else:
		soundSlider.set_value(100)
####################

######## Connexions ########
func _on_language_selected(ID): #language
	newGameSettings["language"] = languageButton.get_item_metadata(ID)

func _on_CheckButton_toggled(pressed, setting): #debugMode, fullscreen, sound, music
	newGameSettings[setting] = pressed

func _on_Slider_value_changed(value, setting, sliderLevel): #soundLevel, musicLevel
	newGameSettings[setting] = value
	sliderLevel.set_text(str(int(value)))
####################

######## Mise à jour des options ########
func _on_applyButton_pressed():
	if currentGameSettings != newGameSettings:
		for setting in newGameSettings:
			currentGameSettings[setting] = newGameSettings[setting]

	settings.save()
	display_current_options()
	display_text()
	settings.apply()
	player.process_music()

	player.play_sound("menu") # il faut le mettre là, sinon le son est coupé
####################

######## Ràz des options ########
func _on_resetButton_pressed():
	settings.reset()
	display_current_options()
####################

######## Autres inputs ########
# Retour au menu avec le raccourci clavier
func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("menu"):
		_on_returnButton_pressed()

# Retour au menu avec le bouton retour
func _on_returnButton_pressed():
	player.play_sound("menu")
	global.set_scene("res://scenes/menu/menu.tscn")
####################

func _on_debugFieldButton_pressed():
	if debugField.get_node("debugLineEdit").get_text() == "newton":
		newGameSettings["debugMode"] = true
		settings.set_setting("debugMode", true)
		display_current_options()
	debugField.get_node("debugLineEdit").clear()