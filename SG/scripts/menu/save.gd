##### res://scripts/menu/save.gd
#####
##### Sauvegarde de la partie en cours

extends Control

######## Initialisation ########
func _ready():
	#### Récupération et rangement de toutes les nodes d'intérêt ####
	var deleteButtonSlot1 = get_node("VBoxContainer/saveSlot1Box/saveSlot1ButtonsBox/deleteButtonSlot1")
	var deleteButtonSlot2 = get_node("VBoxContainer/saveSlot2Box/saveSlot2ButtonsBox/deleteButtonSlot2")
	var deleteButtonSlot3 = get_node("VBoxContainer/saveSlot3Box/saveSlot3ButtonsBox/deleteButtonSlot3")
	var saveButtonSlot1 = get_node("VBoxContainer/saveSlot1Box/saveSlot1ButtonsBox/saveButtonSlot1")
	var saveButtonSlot2 = get_node("VBoxContainer/saveSlot2Box/saveSlot2ButtonsBox/saveButtonSlot2")
	var saveButtonSlot3 = get_node("VBoxContainer/saveSlot3Box/saveSlot3ButtonsBox/saveButtonSlot3")
	var saveTextSlot1 = get_node("VBoxContainer/saveSlot1Box/saveSlot1DisplayBox/saveTextSlot1")
	var saveTextSlot2 = get_node("VBoxContainer/saveSlot2Box/saveSlot2DisplayBox/saveTextSlot2")
	var saveTextSlot3 = get_node("VBoxContainer/saveSlot3Box/saveSlot3DisplayBox/saveTextSlot3")
	var previewSlot1 = get_node("VBoxContainer/saveSlot1Box/saveSlot1DisplayBox/previewSlot1")
	var previewSlot2 = get_node("VBoxContainer/saveSlot2Box/saveSlot2DisplayBox/previewSlot2")
	var previewSlot3 = get_node("VBoxContainer/saveSlot3Box/saveSlot3DisplayBox/previewSlot3")

	var nodesDictionary = {1:{"saveText" : saveTextSlot1, "deleteButton": deleteButtonSlot1, "saveButton": saveButtonSlot1, "preview": previewSlot1},
	2:{"saveText" : saveTextSlot2, "deleteButton": deleteButtonSlot2, "saveButton": saveButtonSlot2, "preview": previewSlot2},
	3:{"saveText" : saveTextSlot3, "deleteButton": deleteButtonSlot3, "saveButton": saveButtonSlot3, "preview": previewSlot3}}

	#### Affichage et traduction des textes statiques - part 1####
	get_node("VBoxContainer/returnButton").set_text(global.get_gui_text("returnButton"))
	get_node("VBoxContainer/menuTitle").set_text(global.get_gui_text("saveGameButton"))

	#### Paramétrages des nodes des trois emplacements de sauvegarde ####
	## Détermination des sauvegardes qui existent ou non, affichage de celles qui existent, connexion et activation des boutons, traduction... ##
	var saveButtonText = global.get_gui_text("saveButton")
	var deleteButtonText = global.get_gui_text("deleteButton")
	var emptySlotText = global.get_gui_text("emptySlot")

	var loadGame = File.new()
	for slotNumber in nodesDictionary:
		# Affichage et traduction des textes statiques - part 2
		nodesDictionary[slotNumber]["saveButton"].set_text(saveButtonText)
		nodesDictionary[slotNumber]["deleteButton"].set_text(deleteButtonText)

		# Connexion des boutons de sauvegarde
		nodesDictionary[slotNumber]["saveButton"].connect("pressed", self, "_on_saveButton_pressed", [slotNumber])

		# Recherche des sauvegardes existantes et affichage de leurs détails le cas échéant + connexion bouton suppression, sinon désactivation des boutons
		nodesDictionary[slotNumber]["saveText"].set_use_bbcode(true)

		if loadGame.file_exists(str("user://saves/save",slotNumber,".json")):		# Le fichier existe
			var saveContent = global.json_into_dictionary(str("user://saves/save",slotNumber,".json"), "nikolatesla")
			var saveArea = global.get_location(saveContent["currentScenePath"])
			nodesDictionary[slotNumber]["saveText"].set_bbcode(str("[center]", saveArea," (",saveContent["saveDate"],")", "[/center]"))
			nodesDictionary[slotNumber]["deleteButton"].connect("pressed", self, "_on_deleteButton_pressed", [slotNumber])
			nodesDictionary[slotNumber]["deleteButton"].set_disabled(false)
			var previewImage = load(str("user://saves/preview",slotNumber,".png"))
			nodesDictionary[slotNumber]["preview"].set_texture(previewImage)

		else:						# Le fichier n'existe pas, Supprimer désactivé
			nodesDictionary[slotNumber]["saveText"].set_bbcode(str("[center]", emptySlotText, "[/center]"))
			nodesDictionary[slotNumber]["deleteButton"].set_disabled(true)
			nodesDictionary[slotNumber]["preview"].hide()
	loadGame.close()

	set_process_input(true)
####################

######## Fonction de sauvegarde du jeu dans l'emplacement slotNumber ########
func _on_saveButton_pressed(slotNumber):
	player.play_sound("menu")
	get_node("saveFunctions").saveGame(slotNumber)
	global.set_scene("res://scenes/menu/save.tscn")
####################

######## Fonction de suppression de la sauvegarde slotNumber ########
func _on_deleteButton_pressed(slotNumber):
	player.play_sound("menu")
	get_node("saveFunctions").deleteGame(slotNumber)
	global.set_scene("res://scenes/menu/save.tscn")
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
####################