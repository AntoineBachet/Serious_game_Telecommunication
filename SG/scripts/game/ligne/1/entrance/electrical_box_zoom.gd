extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"ligne", "level":"1", "scene":"entry"})

	set_process(true)

	#### Affichage et traduction des textes ####
	get_node("riddleOverlay").set_tip( global.get_game_text("electricalBoxTip") )

	get_node("oscilloscope").set_signal("res://assets/game/ligne/1/nrz.png")
################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_house_oscilloscope":
			get_node("oscilloscope").show()
			get_node("riddleOverlay").set_tip_list([global.get_game_text("riddleTip1"), global.get_game_text("riddleTip2")])
			if !global.get_state("ligne_1_signalFound"):
				global.set_state("ligne_1_signalFound", true)
		global.set_used_item("")