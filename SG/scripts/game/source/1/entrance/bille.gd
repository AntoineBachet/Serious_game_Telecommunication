extends RigidBody2D

var bille_pressed = false
var click_space_limit = 10
var pos_on_click

func _ready():
	get_node("underscore").hide()
	set_process(true)
	get_node("Button").set_click_on_press(true)

func _process(delta):
	if bille_pressed:
		var mouse_pos = get_viewport().get_mouse_pos()
		set_pos(mouse_pos)

func _on_Button_pressed():
	if get_node("Button").get_click_on_press():
		pos_on_click = get_viewport().get_mouse_pos()
		get_node("Button").set_click_on_press(false)
	else:
		var current_pos = get_viewport().get_mouse_pos()
		if current_pos.distance_to(pos_on_click) < click_space_limit:
			bille_pressed = !bille_pressed
		else:
			get_node("Button").set_click_on_press(true)
	bille_pressed = !bille_pressed