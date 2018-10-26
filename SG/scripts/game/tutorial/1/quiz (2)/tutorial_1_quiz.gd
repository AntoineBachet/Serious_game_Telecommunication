extends Node2D

func _ready():
	global.set_details({"area":"tutorial", "level": "1", "type": "quiz"})
	
	get_node("bg_animation").play("bg")
	get_node("base_quiz").start()