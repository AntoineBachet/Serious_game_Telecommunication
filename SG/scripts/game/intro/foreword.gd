extends Control

######## Initialisation ########
func _ready():
	global.set_details({"area":"intro","scene":"apocalypse", "type": "no_music"})

	#### Affichage et traduction des textes ####
	get_node("foreword").set_use_bbcode(true)
	get_node("foreword").set_bbcode(str("[center]",global.get_gui_text("foreword"),"[/center]"))
	get_node("startGame").set_text(global.get_gui_text("startGame"))

	#### Bouton Passer ####
	if !settings.is_debug_mode():
		get_node("skipButton").hide()
####################

######## Boutons ########
func _on_startGame_pressed():
	global.set_scene("res://scenes/game/intro/apocalypse.tscn")

func _on_skipButton_pressed():
	global.set_scene("res://scenes/game/tutorial/1/village.tscn")
####################