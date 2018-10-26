##### res://scripts/autoload/global.gd
#####
##### Ce script contient toutes les fonctions "globales", relatives :
#####		- au changement de scène
#####		- au chargement de données externes (contenues dans les fichiers .json)
#####		- à la sauvegarde et au chargement d'une partie
#####		- au dévérouillage des entrées d'encyclopédie
#####		- au blocage des controles
#####		- à la gestion des objets de l'inventaire


extends Node

var currentScene = null

var _guiText
var _gameText
var _riddles
var achievements
var encyclopedia

##################### Initialisation : chargement des dictionnaires et affichage de la première scène
func _ready():
	Globals.set("menuState", "gameMenu")
	Globals.set("ChangedArea", 1) #Cette variable est utile pour savoir si on a changé de zone. (Une zone = Ensemble de scènes où il doit y avoir la même musique de fond)

	# Chargement des textes qu'on voit dans beaucoup de scènes
	_guiText = json_into_dictionary("res://data/guiText.json")
	_gameText = json_into_dictionary("res://data/gameText.json")
	_riddles = json_into_dictionary("res://data/riddle.json")
	achievements = json_into_dictionary("res://data/achievements.json")
	encyclopedia = json_into_dictionary("res://data/encyclopedia.json")

	# Pour set_scene(scene)
	var root = get_tree().get_root()
	currentScene = root.get_child(root.get_child_count()-1)			#currentScene = last scene in tree

	OS.set_window_title(str(get_gui_text("gameTitle"), " - ", get_gui_text("gameVersion")))

	reset_global_variables()

#### Réinitialisation des variables globales avant de commencer une nouvelle partie ####	
func reset_global_variables():
	Globals.set("targetPosition",null)
	Globals.set("targetNode", null)
	Globals.set("gameState",{})
	Globals.set("usedItem", "")
####################

##############################################################################################
##############################################################################################
####################################################################################### Scènes
#### Fonction de changement de scène ####
func set_scene(scene):
	var boolean = false
	# Problème si on met à true : quand on utilise les batonnets sur le coffre (dans le tutoriel),
	# il reste dans la scène, et va à la scène du coffre quand on sort de la hitbox
	if boolean:
		transition.fadeTo(scene)
	else:
		change_scene(scene)
	#mettre boolean à true pour tester, je sais pas si ça rend bien ou pas

func change_scene(scene):
	call_deferred("_deferred_setScene",scene)

func _deferred_setScene(scene):
	if get_tree().get_current_scene().has_node("fade"): # Si on veut avoir une jolie transition fadeout
		get_tree().get_current_scene().get_node("fade").fade_to()
		yield(get_tree().get_current_scene().get_node("fade"), "finished" )
		#Ici il faudrait attendre que l'animation soit terminée
		
	#Puis on change de scène
	# Sauvegarde de l'orientation du personnage avant un changement de scène
	if get_tree().get_current_scene().has_node("character"):
		var orientation = get_tree().get_current_scene().get_node("character").orientation
		set_state("currentOrientation", orientation)
	currentScene.queue_free()
	var s = ResourceLoader.load(scene)
	currentScene = s.instance()
	get_tree().get_root().add_child(currentScene)
	get_tree().set_current_scene(currentScene)
	####################

###############################################################################################
###############################################################################################
############################################################################### Données externes
#### Chargement d'un fichier json quelconque dans un dictionnaire ####
func json_into_dictionary(path, password = ""):
	var file = File.new()
	var dictionary = {}
	if password == "":
		file.open(path, File.READ)
	else:
		file.open_encrypted_with_pass(path, File.READ, password)
	dictionary.parse_json(file.get_as_text())
	file.close()
	return dictionary
####################

#### Renvoie un texte d'interface dans la bonne langue ####
func get_gui_text(text):
	var language = settings.get_language()
	if !_guiText.has(text):
		print(str("[Error : Missing text, no key called \"", text, "\" in guiText.json]"))
		return ""
	elif !_guiText[text].has(language):
		print(str("[Error : Missing text, language unavailable for key \"", text, "\" in guiText.json]"))
		return _guiText[text]["fr"]
	else:
		return _guiText[text][language]
####################

#### Renvoie un texte de jeu dans la bonne langue ####
func get_game_text(text):
	var language = settings.get_language()
	var sceneDetails = get_details()
	if sceneDetails.has("level"):
		if !(_gameText.has(sceneDetails.area) and _gameText[sceneDetails.area].has(sceneDetails.level) and _gameText[sceneDetails.area][sceneDetails.level].has(sceneDetails.scene) and _gameText[sceneDetails.area][sceneDetails.level][sceneDetails.scene].has(text)):
			print(str("[Error : Missing text, no key called \"", sceneDetails.area, "/", sceneDetails.level, "/", sceneDetails.scene, "/", text, "\" in gameText.json]"))
			return ""
		elif !_gameText[sceneDetails.area][sceneDetails.level][sceneDetails.scene][text].has(language):
			print(str("[Error : Missing text, language unavailable for key \"", sceneDetails.area, "/", sceneDetails.level, "/", sceneDetails.scene, "/", text, "\"  in gameText.json. Displaying French version.]"))
			return _gameText[sceneDetails.area][sceneDetails.level][sceneDetails.scene][text]["fr"]
		else:
			return _gameText[sceneDetails.area][sceneDetails.level][sceneDetails.scene][text][language]
	else:
		if !(_gameText.has(sceneDetails.area) and _gameText[sceneDetails.area].has(sceneDetails.scene) and _gameText[sceneDetails.area][sceneDetails.scene].has(text)):
			print(str("[Error : Missing text, no key called \"", sceneDetails.area, "/", sceneDetails.scene, "/", text, "\" in gameText.json]"))
			return ""
		elif !_gameText[sceneDetails.area][sceneDetails.scene][text].has(language):
			print(str("[Error : Missing text, language unavailable for key \"", sceneDetails.area, "/", sceneDetails.scene, "/", text, "\"  in gameText.json. Displaying French version.]"))
			return _gameText[sceneDetails.area][sceneDetails.scene][text]["fr"]
		else:
			return _gameText[sceneDetails.area][sceneDetails.scene][text][language]
####################

#### Renvoie une cinématique ####
func get_cinematic(cinematic):
	var sceneDetails = get_details()
	if sceneDetails.has("level"):
		return json_into_dictionary("res://data/cinematics.json")[sceneDetails.area][sceneDetails.level][sceneDetails.scene][cinematic]
	else:
		return json_into_dictionary("res://data/cinematics.json")[sceneDetails.area][sceneDetails.scene][cinematic]

#### Renvoie un quiz ####
func get_quiz():
	var sceneDetails = get_details()
	if sceneDetails.has("level"):
		return json_into_dictionary("res://data/quiz.json")[sceneDetails.area][sceneDetails.level]
	else:
		return json_into_dictionary("res://data/quiz.json")[sceneDetails.area]

#### Renvoie des éléments d'énigme dans la bonne langue ####
func get_riddle(riddle):
	var sceneDetails = get_details()
	if sceneDetails.has("level"):
		return _riddles[sceneDetails.area][sceneDetails.level][sceneDetails.scene][riddle]
	else:
		return _riddles[sceneDetails.area][sceneDetails.scene][riddle]

#### Renvoie un nom de lieu dans la bonne langue ####
func get_location(path):
	return json_into_dictionary("res://data/locations.json")[path][settings.get_language()]
####################

#### Renvoie un achievement dans la bonne langue ####
func get_achievement(achievement):
	var language = settings.get_language()
	if achievements.has(achievement):
		var title
		var description
		var category
		if achievements[achievement]["title"].has(language):
			title = achievements[achievement]["title"][language]
		else:
			title = achievements[achievement]["title"]["fr"]
			print(str("[Error : Missing text, language unavailable for title of achievement ", achievement, " in achievements.json]"))
		if achievements[achievement]["description"].has(language):
			description = achievements[achievement]["description"][language]
		else:
			description = achievements[achievement]["description"]["fr"]
			print(str("[Error : Missing text, language unavailable for description of achievement ", achievement, " in achievements.json]"))
		category = achievements[achievement]["category"]
		return {"title": title, "description": description, "category": category}
	else:
		return ""
		print(str("[Error : no key ", achievement, " in achievements.json]"))
####################


###############################################################################################
###############################################################################################
####################################################################### Sauvegarde et chargement
#### Fonction de sauvegarde de scène ####
func save_scene():
	if get_tree().get_current_scene().has_node("character"):
		# Sauvegarde de la position du personnage (qu'on devrait peut-être renommer "player")
		set_state("currentXPosition", get_tree().get_current_scene().get_node("character").get_pos().x)
		set_state("currentYPosition", get_tree().get_current_scene().get_node("character").get_pos().y)

		# Sauvegarde du chemin de la scène
		var root = get_tree().get_root()
		var currentScene = root.get_child(root.get_child_count()-1)
		var currentScenePath = currentScene.get_filename()
		set_state("currentScenePath", currentScenePath)
		return true
	return false
####################

#### Fonction de chargement de scène ####
func load_scene():
	if has_state("currentScenePath"):
		set_scene(get_state("currentScenePath"))
		Globals.get("gameState").erase("currentScenePath")

		Globals.set("targetPosition",Vector2(get_state("currentXPosition"), get_state("currentYPosition")))
		Globals.get("gameState").erase("currentXPosition")
		Globals.get("gameState").erase("currentYPosition")
####################


##############################################################################################
##############################################################################################
############################################################### Déverrouillage de l'encyclopédie
#### Déverrouiller toutes les (sections et) entrées d'un chapitre ####
func unlock_chapter_entries(chapter):
	if encyclopedia.has(chapter):
		_unlock_encyclopedia()
		set_state(str(chapter,"Unlocked"), true)

		if encyclopedia[chapter].has("entries"):
			for y in encyclopedia[chapter].entries:
				unlock_entry(chapter, y)
		elif encyclopedia[chapter].has("sections"):
			for y in encyclopedia[chapter].sections:
				set_state(str(chapter,"_",y,"Unlocked"), true)
				for z in encyclopedia[chapter].sections[y].entries:
					unlock_entry_s(chapter, y, z)
	else:
		print("[Error: no chapter ", chapter, " in encyclopedia.json]")
####################

#### Déverrouiller toutes les entrées d'une section d'un chapitre (et le chapitre en question si besoin) ####
func unlock_section_entries(chapter, section):
	if encyclopedia.has(chapter):
		if encyclopedia[chapter].has("sections") and encyclopedia[chapter].sections.has(section):
			_unlock_encyclopedia()
			set_state(str(chapter,"Unlocked"), true)
			set_state(str(chapter,"_",section,"Unlocked"), true)

			if encyclopedia[chapter].sections[section].has("entries"):
				for y in encyclopedia[chapter].sections[section].entries:
					unlock_entry_s(chapter, section, y)
		else:
			print("[Error: no section ", section,  " in chapter ", chapter, " in encyclopedia.json]")
	else:
		print("[Error: no chapter ", chapter, " in encyclopedia.json]")
####################

#### Déverrouiller une entrée précise (et sa section, et son chapitre) ####
func unlock_entry_s(chapter, section, entry):
	_unlock_encyclopedia()
	set_state(str(chapter,"Unlocked"), true)
	set_state(str(chapter,"_",section,"Unlocked"), true)
	set_state(str(chapter,"_",section,"_",entry,"Unlocked"), true)
	if !has_state("unreadEntries"):
		Globals.get("gameState")["unreadEntries"] = []
	get_state("unreadEntries").append(str(chapter,"_",section,"_",entry))
####################

#### Déverrouiller une entrée précise (et son chapitre) ####
func unlock_entry(chapter, entry):
	_unlock_encyclopedia()
	set_state(str(chapter,"Unlocked"), true)
	set_state(str(chapter,"_",entry,"Unlocked"), true)
	if !has_state("unreadEntries"):
		Globals.get("gameState")["unreadEntries"] = []
	get_state("unreadEntries").append(str(chapter,"_",entry))
####################

#### Déverrouillage de l'encyclopédie si ce n'est pas encore fait ####
func _unlock_encyclopedia():
	if !get_state("encyclopediaUnlocked"): # déverrouillage de l'encyclopédie si ce n'est pas encore fait
		Globals.get("gameState")["encyclopediaUnlocked"] = true
		if get_tree().get_current_scene().get_node("gui"):
			get_tree().get_current_scene().get_node("gui").update()
####################

#### Vérifier le déverrouillage d'une entrée, etc. ####
func is_entry_s_unlocked(chapter, section, entry):
	return get_state(str(chapter,"_",section,"_",entry,"Unlocked"))
func is_entry_unlocked(chapter, entry):
	return get_state(str(chapter,"_",entry,"Unlocked"))
func is_section_unlocked(chapter, section):
	return get_state(str(chapter,"_",section,"Unlocked"))
func is_chapter_unlocked(chapter):
	return get_state(str(chapter,"Unlocked"))
####################

############################################################################################
############################################################################################
func get_state(variable):
	if !Globals.get("gameState").has(variable):
		return false
	else:
		return Globals.get("gameState")[variable]

func set_state(variable, value):
	Globals.get("gameState")[variable] = value
	achievementDisplay.check_achievements()

func has_state(variable):
	if !Globals.get("gameState").has(variable):
		return false
	else:
		return true
#############################################################################################
#############################################################################################		
func set_details(details):
	Globals.set("sceneDetails", details)
	player.process_music()

func get_details():
	return Globals.get("sceneDetails")
#############################################################################################
#############################################################################################
########################################################## Gestion des objets de l'inventaire
func is_picked_up(itemCode):
	return get_state(str(itemCode,"PickedUp"))

func is_used(itemCode):
	return get_state(str(itemCode,"Used"))

func give_item(itemCode):
	set_state(str(itemCode, "PickedUp"), true)
	player.play_sound("inventory")
	if !get_state("inventoryUnlocked"):
		set_state("inventoryUnlocked", true)
		if get_tree().get_current_scene().get_node("gui"):
			get_tree().get_current_scene().get_node("gui").update()

func use_item(itemCode):
	set_state(str(itemCode, "Used"), true)

func get_used_item():
	return Globals.get("usedItem")

func set_used_item(i):
	Globals.set("usedItem", i)
#############################################################################################
#############################################################################################
func is_displayed_achievement(achievement):
	return get_state(str("achievement_",achievement,"_displayed"))

func unlock_location(locationCode):
	set_state(str(locationCode, "_unlocked"), true)
#######################

######## Chapeaux ########
func unlock_hat(hatCode):
	if !global.has_state("unlockedHats"):
		global.set_state("unlockedHats", [])
	if !global.get_state("unlockedHats").has("hatCode"):
		global.get_state("unlockedHats").append(hatCode)

func has_hat(hatCode):
	return has_state("unlockedHats") and get_state("unlockedHats").has(hatCode)
####################

######## Target ########
func set_target_node(nodeName):
	Globals.set("targetNode", nodeName)
	#Globals.set("targetPosition",Vector2(Globals.get("gameState")["tutorial_1_village_uselesshouseDoorXPosition"],Globals.get("gameState")["tutorial_1_village_uselesshouseDoorYPosition"]))

func get_target_node():
	return Globals.get("targetNode")
####################

######## Fonction pour savoir si le personnage est dans la hitbox d'un node
func character_in_hitbox( nodeName ):
	if get_tree().get_current_scene().has_node("character") and get_tree().get_current_scene().get_node("character").is_processing():
		if get_tree().get_current_scene().has_node( nodeName ):
			if get_tree().get_current_scene().get_node( nodeName ).has_node("hitbox"):
				return get_tree().get_current_scene().get_node(nodeName + "/hitbox").overlaps_body(get_tree().get_current_scene().get_node("character"))
			else:
				print(nodeName + " has no node named 'hitbox'")