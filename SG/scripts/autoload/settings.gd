extends Node

const _defaultGameSettings = {
"navigation": "keyboard",
"language": "fr",
"fullscreen": true,
"music": true,
"musicLevel": 100,
"sound": true,
"soundLevel": 100
}

var _gameSettings

######## Initialisation ########
func _ready():
	#### Chargement des options ####
	var settingsFile = File.new()
	var change

	if settingsFile.file_exists(str("user://gameSettings.json")):		#S'il manque des options dans le fichier d'options
		_gameSettings = global.json_into_dictionary("user://gameSettings.json")
		for setting in _defaultGameSettings:
			if !_gameSettings.has(setting):
				_gameSettings[setting] = _defaultGameSettings[setting]
				change = true
	else:		#S'il n'y a pas de fichier d'options
		_gameSettings = _defaultGameSettings
		change = true
	apply()

	#### Création d'un fichier d'options ou complétion s'il existe déjà et qu'il manquait quelque chose ####
	if change:
		save()
####################

#### Sauvegarde des options actuelles dans gameSettings.json ####
func save():
	var data = _gameSettings
	var file = File.new()
	file.open("user://gameSettings.json", File.WRITE)
	file.store_line(data.to_json())
	file.close()
####################

#### Prise en compte des options actuelles ####
func apply():
	_update_display()
####################

#### Mise à jour de l'affichage (plein écran ou non) ####
func _update_display():
	if get_setting("fullscreen"):
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)
		OS.set_window_maximized(true)
####################

######## Getters ########
func get_setting(setting):
	if !_gameSettings.has(setting):
		print("[Error] Missing setting ", setting)
		return false
	else:
		return _gameSettings[setting]

func get_language():
	return get_setting("language")

func is_debug_mode():
	return get_setting("debugMode")

func get_settings():
	return _gameSettings

func has_setting(setting):
	if !_gameSettings.has(setting):
		return false
	else:
		return true

func set_setting(setting, value):
	_gameSettings[setting] = value
	apply()
####################

func reset():
	var language = get_language()
	_gameSettings = _defaultGameSettings
	_gameSettings[language] = language
	save()