
extends Node2D

var nb_buttons = 4

func _ready():
	global.set_details({"area":"source", "level": "3", "type": "quiz"})

	get_node("bg_animation").play("bg")
	
	get_node("base_quiz").start()