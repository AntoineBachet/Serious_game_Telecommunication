extends Node2D

var events
var nb_events
var index_events = 0

var dialogue
var nb_dialogue = 0
var index_dialogue = -1

var key_pressed = false

var timer = 0
var duration = 0

######## Initialisation ########
func _ready():
	global.set_details({"area":"intro", "scene":"potato_field"})

	get_node("juliette").bubble_left()

	get_node("cinematic").get_events("main")
	get_node("cinematic").start()

	get_node("character").freeze_character()
	get_node("Camera2D").make_current()
	get_node("cinematic").connect("finished", self, "_cinematic_finished")

	set_process(true)
####################

func character_orientation():
	return "left"

func juliette_orientation():
	return "right"

func _cinematic_finished():
	global.set_scene("res://scenes/game/tutorial/1/village.tscn")