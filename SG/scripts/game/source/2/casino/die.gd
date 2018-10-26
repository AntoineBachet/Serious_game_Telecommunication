extends RigidBody2D

var _is_held = false
var _is_hovered = false
var _number = 0

var _click = false

var bille = preload("res://scenes/game/source/2/casino/die.tscn")

func _ready():
	_set_scale(0.4)
	set_pickable(true)
	set_gravity_scale(3)
	get_node("Label").set_use_bbcode(true)

	set_process_input(true)
	set_process(true)

func _process(delta):
	if _is_held:
		set_pos(get_global_mouse_pos())

func _set_scale(scale):
	get_node("CollisionPolygon2D").set_scale( Vector2(scale, scale) )
	get_node("Sprite").set_scale( Vector2(scale, scale) )
	
func set_number(number):
	_number = number
	var text = str("[b][center]", _number, "[/center][/b]")
	if str(_number) in ["6", "9"]:
		text = str("[u]", text, "[/u]")
	get_node("Label").set_bbcode(text)

func get_number():
	return _number

func _input(event):
	if _is_hovered:
		if event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1:
			if !_click:
				_click = true
	#			if event.pressed:
	#				_is_held = true
	#			else:
	#				_is_held = false
				_is_held = !_is_held
		else:
			_click = false

func _on_dice_mouse_enter():
	_is_hovered = true

func _on_dice_mouse_exit():
	if !_is_held:
		_is_hovered = false