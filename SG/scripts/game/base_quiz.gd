extends Node2D

var nb_buttons = 4

func _ready():
	get_node("backwheel/AnimationPlayer").play("rolling")
	get_node("frontwheel/AnimationPlayer").play("wheelrolling")
	get_node("charette/AnimationPlayer 2").play("updown")
	get_node("walking_horse/AnimationPlayer").play("horse_walk")

	if has_node("juliette") and global.get_state("julietteGone"):
		var julietteGhostTexture = load("res://assets/game/juliette_ghost.png")
		get_node("juliette").set_texture(julietteGhostTexture)

	get_node("quiz").set_nb_buttons( nb_buttons )
	get_node("quiz_result").hide()

func start():
	get_node("quiz").set_quiz( global.get_quiz() )
	get_node("quiz").start_quiz()