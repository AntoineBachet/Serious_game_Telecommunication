##### res://scripts/menu/splashScreen.gd
#####
##### Ecran d'accueil qui mène directement au menu principal

extends Control

######## Initialisation ########
func _ready():
	Globals.set("menuState","mainMenu")
	Globals.set("sceneDetails", {"area":"menu"})
	player.process_music()

	set_process_input(true)

	#### Traduction et affichage des textes ####
	get_node("pressToContinue").set_text(global.get_gui_text("pressAnyKeyToContinue"))
####################

######## Fin de l'affichage du logo : clignotement du texte pour passer à la suite ########
func _on_AnimationPlayer_finished():
	get_node("AnimationPlayer").play("blink")
####################

######## Inputs ########
func _input(event):
	if !event.is_pressed() and ((event.type == InputEvent.KEY) or (event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT)):
		global.set_scene("res://scenes/menu/menu.tscn")
####################