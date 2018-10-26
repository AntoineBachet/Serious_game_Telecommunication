extends Node2D

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"house", "type": "no_music"})

	set_process(true)

	if !global.get_state("tutorial_1_house_pianoSolved"):
		get_node("riddleOverlay").set_tip(global.get_game_text("pianoPuzzleTip"))


func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		global.set_used_item("")