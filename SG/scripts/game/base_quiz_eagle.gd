extends Node2D

var nb_buttons = 4

var victorYdelta
var julietteYdelta

func _ready():
	set_fixed_process(true)
	
	var vPos = get_node("victor_sprite").get_pos()
	var jPos = get_node("juliette_sprite").get_pos()
	var eaglePos = get_node("flying_eagle/Position2D").get_global_pos()
	victorYdelta = vPos.y - eaglePos.y
	julietteYdelta = jPos.y - eaglePos.y
	
	get_node("flying_eagle/AnimationPlayer").play("flying_eagle")

	if has_node("juliette") and global.get_state("julietteGone"):
		var julietteGhostTexture = load("res://assets/game/juliette_ghost.png")
		get_node("juliette_sprite").set_texture(julietteGhostTexture)

	get_node("quiz").set_nb_buttons( nb_buttons )
	get_node("quiz_result").hide()

func _fixed_process(delta):
	var vPos = get_node("victor_sprite").get_pos()
	var jPos = get_node("juliette_sprite").get_pos()
	var eaglePos = get_node("flying_eagle/Position2D").get_global_pos()
	vPos.y = eaglePos.y + victorYdelta
	jPos.y = eaglePos.y + julietteYdelta
	get_node("victor_sprite").set_pos(vPos)
	get_node("juliette_sprite").set_pos(jPos)

func start():
	get_node("quiz").set_quiz( global.get_quiz() )
	get_node("quiz").start_quiz()