extends Node2D

func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"secretroom"})

	if !global.get_state("tutorial_1_secretroom_light"):
		get_node("riddleOverlay").set_tip_list( [global.get_game_text("lightOscilloNotIn")] )
	else:
		get_node("riddleOverlay").set_tip_list( [global.get_game_text("lightOscilloIn")] )

		var path = str("res://assets/game/tutorial/1/secretroom/signal_", settings.get_language(), ".png")
		var texture = load(path)
		if texture == null:
			path = "res://assets/game/tutorial/1/secretroom/signal_fr.png"
		get_node("oscilloscope").set_signal(path)
	
	get_node("oscilloscope").show()
	get_node("oscilloscope").disable_exit()