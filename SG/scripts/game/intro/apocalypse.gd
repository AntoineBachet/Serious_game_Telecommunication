extends Control

######## Initialisation ########
func _ready():
	global.set_details({"area":"intro","scene":"apocalypse"})

	get_node("AnimationPlayer").play("TV")
	get_node("AnimationPlayer").get_node("AnimationPlayer 2").play("reporter")

	#### Ecriture du blabla d'intro
	var gameDescription = global.get_game_text("apocalypse")
	get_node("text").set_bbcode(str("[center]",gameDescription,"[/center]"))

	#### Affichage et traduction des textes ####
	get_node("nextButton").set_text(global.get_gui_text("nextButton"))

	#### Bouton Passer ####
	if !settings.is_debug_mode():
		get_node("skipButton").hide()
####################

######## Boutons ########
func _on_nextButton_pressed():
	get_node("nextButton").disconnect("pressed", self, "_on_nextButton_pressed")
	global.set_scene("res://scenes/game/intro/postApocalypse.tscn")

func _on_skipButton_pressed():
	global.set_scene("res://scenes/game/tutorial/1/village.tscn")
####################