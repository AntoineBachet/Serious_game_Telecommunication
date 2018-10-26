extends Control

######## Initialisation ########
func _ready():
	global.set_details({"area":"intro","scene":"postApocalypse"})

	#### Ecriture du blabla d'intro
	var gameDescription = global.get_game_text("postApocalypse")
	get_node("text").set_bbcode(gameDescription)
	get_node("AnimationPlayer").set_autoplay(true)
	set_process(true)

	#### Affichage et traduction des textes ####
	get_node("nextButton").set_text(global.get_gui_text("nextButton"))

	#### Bouton Passer ####
	if !settings.is_debug_mode():
		get_node("skipButton").hide()
####################

######## Boutons ########
func _on_nextButton_pressed():
	get_node("nextButton").disconnect("pressed", self, "_on_nextButton_pressed")
	global.set_scene("res://scenes/game/intro/potato_field.tscn")

func _on_skipButton_pressed():
	global.set_scene("res://scenes/game/tutorial/1/village.tscn")
####################

func _process(delta):
    var isPlaying = get_node("AnimationPlayer").is_playing()
    if isPlaying == false:
        get_node("AnimationPlayer").play()