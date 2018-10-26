##### res://scripts/game/juliette.gd 
#####
##### Ce script gère Juliette


extends Node2D

var bubble_pos = "right"
var margin = 0

######################### Initialisation de la position et de l'image
func _ready():
	if global.get_state("julietteGone"):
		get_node("Sprite").set_animation("ghost")
		get_node("Sprite/AnimationPlayer").play("ghost_right")
	else:
		get_node("Sprite/AnimationPlayer").play("idle_right")

	if get_parent().has_method("juliette_orientation"):
		set_orientation(get_parent().juliette_orientation())

	var text_pos = get_node("text").get_pos()
	var next_pos = get_node("next").get_pos()
	margin = next_pos.x - text_pos.x
	set_process(true)

func update_animation(anim):
	if global.get_state("julietteGone"):
		if anim == "idle_right" or anim == "walking_right":
			get_node("Sprite/AnimationPlayer").play("ghost_right")
		elif anim == "idle_left" or anim == "walking_left":
			get_node("Sprite/AnimationPlayer").play("ghost_left")

func get_orientation():
	if get_node("Sprite").is_flipped_h():
		return "left"
	return "right"

func set_orientation(o):
	if o == "right":
		get_node("Sprite").set_flip_h(false)
	elif o == "left":
		get_node("Sprite").set_flip_h(true)

#################################################################################
################################################### Changement de sens des bulles
func bubble_right():
	if bubble_pos == "left":
		get_node("bubble").set_flip_h( true )
		flip_bubble()

func bubble_left():
	if bubble_pos == "right":
		get_node("bubble").set_flip_h( false )
		flip_bubble()

func flip_bubble():
	var bubble_pos = get_node("bubble").get_pos()
	bubble_pos.x = - bubble_pos.x
	get_node("bubble").set_pos(bubble_pos)
	
	var text_pos = get_node("text").get_pos()
	var text_size = get_node("text").get_size()
	var next_pos = get_node("next").get_pos()
	
	text_pos.x = -text_pos.x - text_size.x
	get_node("text").set_pos(text_pos)
	next_pos.x = text_pos.x + margin
	get_node("next").set_pos(next_pos)

func activateCollision():
#	get_node("CollisionShape2D").set_trigger(false)
	pass

func deactivateCollision():
#	get_node("CollisionShape2D").set_trigger(true)
	pass