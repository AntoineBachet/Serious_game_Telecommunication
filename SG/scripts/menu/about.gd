##### res://scripts/menu/about.gd
#####
##### Affichage des informations sur le jeu

extends Control

######## Initialisation ########
func _ready():
	#### Affichage/traduction des textes ####
	get_node("VBoxContainer/returnButton").set_text(global.get_gui_text("returnButton"))
	get_node("VBoxContainer/menuTitle").set_text(global.get_gui_text("aboutButton"))
	var aboutText = get_node("VBoxContainer/aboutText")
	aboutText.set_use_bbcode(true)
	aboutText.set_bbcode(str(global.get_gui_text("gameTitle")," - ",global.get_gui_text("gameVersion"),"\n",global.get_gui_text("aboutText")))

	set_process_input(true)
####################

######## Inputs ########
# Retour au menu principal avec le raccourci clavier
func _input(event):
	if event.type == InputEvent.KEY and event.pressed and event.is_action_pressed("menu"):
		_on_returnButton_pressed()

# Bouton Retour
func _on_returnButton_pressed():
	player.play_sound("menu")
	global.set_scene("res://scenes/menu/menu.tscn")
####################