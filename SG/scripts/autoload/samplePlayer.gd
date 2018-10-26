##### res://scripts/autoload/samplePlayer.gd
#####
##### Ce script gère la musique et les sons

extends StreamPlayer

var _sceneDetails
var _currentSong
var _currentSongName

var _play = true
var _music = {}
var _musicList = {}

var _index = 0 # Compteur de bouclage de la musique
var _musicOrder = []
var _starting = true

var _sampleLibrary

######## Initialisation : récupération des données de music.json et musicList.json ########
func _ready():
	connect("finished", self, "_on_player_finished")

	#### Récupération des données de music.json et musicList.json ####
	var file = File.new()
	file.open("res://data/music.json", File.READ)
	_music.parse_json(file.get_as_text())
	file.open("res://data/musicList.json", File.READ)
	_musicList.parse_json(file.get_as_text())

	#### Récupération des données de songList.json, création de la SampleLibrary ####
	if get_node("Sound").get_sample_library(): # Vider le SamplePlayer au cas où
		for sample in get_node("Sound").get_sample_library().get_sample_list(): 
			get_node("Sound").get_sample_library().remove_sample(sample)
	else:
		var lib = SampleLibrary.new()
		get_node("Sound").set_sample_library(lib)
	file.open("res://data/soundList.json", File.READ)
	var soundList = {}
	soundList.parse_json(file.get_as_text())
	for sound in soundList:
		var sample = load(soundList[sound])
		get_node("Sound").get_sample_library().add_sample(sound, sample)
	file.close()

	_sampleLibrary = get_node("Sound").get_sample_library()

	if _musicList.size() > 0:
		var keys = _musicList.keys()
		_currentSong = load(_musicList[keys[0]])
		_currentSongName = ""
####################


########## Cette fonction met à jour la musique de fond. Elle doit être appelée dans le ready
########## de chaque scène, juste après l'instruction Globals.set("sceneDetails", ...)
######## Changement, choix aléatoire et lancement de la musique de fond ########
func process_music():
#	stop_sound() # c'est lui qui coupe le son des portes

	#### Récupération du nom de la scène en cours ####
	_sceneDetails = Globals.get("sceneDetails")

	#### Modification du volume ####
	if settings.has_setting("musicLevel"):
		set_volume(settings.get_setting("musicLevel")/100)
	if settings.has_setting("soundLevel"):
		get_node("Sound").set_default_volume(settings.get_setting("soundLevel")/100)

	# S'il n'y a pas déjà une musique qui joue en fond, on cherche quelle musique de fond jouer
	var songs_in_scene = _get_musicList()
	if songs_in_scene.size() == 0:
		print("No song found in scene", _sceneDetails)

	if settings.get_setting("music"):
		if !is_playing() or !songs_in_scene.has(_currentSongName):
			if songs_in_scene.size() > 0:
				if !songs_in_scene.has(_currentSongName): # Si on a changé de liste de musiques
					_index = 0
					_set_random_order(songs_in_scene.size())
				if _index == songs_in_scene.size(): # Si on a joué toutes les musiques de la scène
					_index = 0
				if _musicList.has( songs_in_scene[ _musicOrder[_index] ] ): # Musique suivante
					_currentSong = load(_musicList[ songs_in_scene[ _musicOrder[_index]] ])
					_currentSongName = songs_in_scene[ _musicOrder[_index] ]
					self.set_stream(_currentSong)
					self.play()

	if songs_in_scene.size() == 0 or !settings.get_setting("music"):
		#Si la scène n'appartient à aucune des listes, on ne joue rien du tout
		self.stop()
		_index = 0
####################


#### Mise à jour de la musique quand elle se termine ####
func _on_player_finished():
	_index += 1
	process_music()
####################

######## Génération aléatoire d'une liste d'indices mélangés pour l'ordre des musiques ########
func _set_random_order(size):
	randomize()

	_musicOrder = []
	var indexList = range(size)

	for i in range(size):
		var index = randi() % indexList.size()
		_musicOrder.append(indexList[index])
		indexList.remove(index)
####################

#### Arrêt des sons ####
func stop_sound():
	get_node("Sound").stop_all()
####################

#### Récupération des musiques de l'écran courant en fonction de sceneDetails ####
func _get_musicList():
	if _sceneDetails.has("type") and _music.has( _sceneDetails["type"] ) and _music[_sceneDetails["type"]].has("music"):
		return _music[ _sceneDetails["type"] ]["music"]
	if _sceneDetails.has("area") and _music.has( _sceneDetails["area"] ):
		if _sceneDetails.has("level") and _music[_sceneDetails["area"]].has( _sceneDetails["level"] ):
			if _sceneDetails.has("scene") and _music[_sceneDetails["area"]][_sceneDetails["level"]].has( _sceneDetails["scene"] ):
				if _music[ _sceneDetails["area"] ][ _sceneDetails["level"] ][ _sceneDetails["scene"] ].has("music"):
					return _music[ _sceneDetails["area"] ][ _sceneDetails["level"] ][ _sceneDetails["scene"] ]["music"] 
			else:
				if _music[ _sceneDetails["area"] ][ _sceneDetails["level"] ].has("music"):
					return _music[ _sceneDetails["area"] ][ _sceneDetails["level"] ]["music"]
		else:
			if _music[ _sceneDetails["area"] ].has("music"):
				return _music[ _sceneDetails["area"] ]["music"]
	return []
####################

#### Démarrage d'un son ####
func play_sound(soundName):
	if settings.get_setting("sound"):
		if _sampleLibrary.has_sample(soundName):
			get_node("Sound").play(soundName)
		else:
			print("[Error] No sound named ", soundName, " in player.")
####################