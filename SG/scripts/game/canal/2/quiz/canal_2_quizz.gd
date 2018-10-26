extends Node2D

func _ready():
	global.set_details({"area":"canal", "level": "2", "type": "quiz"})

	get_node("bg_animation").play("bg")
	
	get_node("base_quiz").start()