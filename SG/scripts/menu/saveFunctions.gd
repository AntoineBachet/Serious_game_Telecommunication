extends Node

func _ready():
	pass

######## Fonction de chargement de la sauvegarde slotNumber ########
func loadGame(slotNumber):
	var loadGame = File.new()

	var gameData = global.json_into_dictionary(str("user://saves/save",slotNumber,".json"), "nikolatesla")

	gameData.erase("saveDate")

	# Chargement de la scène sauvegardée
	global.set_scene(gameData["currentScenePath"])
	gameData.erase("currentScenePath")

	# Restauration de la position
	Globals.set("targetPosition",Vector2(gameData["currentXPosition"],gameData["currentYPosition"]))
	gameData.erase("currentXPosition")
	gameData.erase("currentYPosition")

	# Restauration de l'orientation
	if gameData.has("currentOrientation"):
		Globals.get("gameState")["currentOrientation"] = gameData["currentOrientation"]
	else:
		Globals.get("gameState")["currentOrientation"] = "right"

#	# Chargement des variables globales
	Globals.set("gameState",gameData)
	Globals.set("menuState","gameMenu")
####################

######## Fonction de suppression de la sauvegarde slotNumber ########
func deleteGame(slotNumber):	
	var dir = Directory.new()
	dir.remove(str("user://saves/save",slotNumber,".json"))
	dir.remove(str("user://saves/preview",slotNumber,".png"))
####################

######## Fonction de sauvegarde du jeu dans l'emplacement slotNumber ########
func saveGame(slotNumber):
	# Création du répertoire de sauvegardes si nécessaire
	var dir = Directory.new()
	if !dir.dir_exists("user://saves"):
		dir.open("user://")
		dir.make_dir("user://saves")

	# Création du fichier de sauvegarde
	var saveGame = File.new()
#	saveGame.open(str("user://saves/save",slotNumber,".json"), File.WRITE)
	saveGame.open_encrypted_with_pass(str("user://saves/save",slotNumber,".json"), File.WRITE, "nikolatesla")
	var data = Globals.get("gameState")

	var date = OS.get_date()
	var time = OS.get_time()

	# Ajout d'un zéro devant ce qui n'en a pas et devrait en avoir un pour que ce soit joli
	if date["day"]<10:
		date["day"]=str("0",date["day"])
	if date["month"]<10:
		date["month"]=str("0",date["month"])
	if time["hour"]<10:
		time["hour"]=str("0",time["hour"])
	if time["minute"]<10:
		time["minute"]=str("0",time["minute"])
	if time["second"]<10:
		time["second"]=str("0",time["second"])

	data["saveDate"]=str(date["day"],"/",date["month"],"/",date["year"]," ",time["hour"],":",time["minute"],":",time["second"])

	saveGame.store_line(data.to_json())
	saveGame.close()

	## Création de l'aperçu de la sauvegarde
	var previewName = str("preview",slotNumber)
	if Globals.get("screenshot") != null:
		var previewImage = Globals.get("screenshot").resized(1920*100/1080,100)
		previewImage.save_png(str("user://saves/",previewName,".png"))
####################