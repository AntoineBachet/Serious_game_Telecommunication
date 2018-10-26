extends KinematicBody2D

# Petit problème lorsqu'on veut poser une tuile sur une autre
# Ca à l'air d'être un problème de Z

# Récupération des différentes tuiles
var _tile_path = ["res://assets/game/source/3/shop/red_dragon.png",
				"res://assets/game/source/3/shop/green_dragon.png",
				"res://assets/game/source/3/shop/white_dragon.png",
				"res://assets/game/source/3/shop/east_wind.png",
				"res://assets/game/source/3/shop/bamboo.png"]

signal release
signal taken

var _tile_pressed = false
var _click_space_limit = 10
var _pos_on_click

var _type = 0

func _ready():
	var tile_size = get_node("TextureButton").get_size()
	var tile_scale = get_node("TextureButton").get_scale()
	get_node("TextureButton").set_pos( Vector2(-(tile_size.x * tile_scale.x) / 2, -(tile_size.y * tile_scale.y) / 2) )
	
	get_node("TextureButton").connect("pressed", self, "_on_Button_pressed")
	set_process(true)
	get_node("TextureButton").set_click_on_press(true)

# Changement de texture de la tuile
func set_type( type ):
	if 0 <= type and type < 5:
		_type = type
		var tile = load(_tile_path[type])
		get_node("TextureButton").set_normal_texture(tile)

func get_type():
	return _type

func is_moving():
	return _tile_pressed

# Déplacement de la tuile
func _process(delta):
	if _tile_pressed and is_visible():
		var mouse_pos = get_viewport().get_mouse_pos()
		set_pos(mouse_pos)

func _on_Button_pressed():
	if _tile_pressed or !global.get_state("source_3_shop_tileMoving"):
		if !global.get_state("source_3_shop_tileMoving"):
			emit_signal("taken")
			get_tree().get_current_scene().current_z += 1
			set_z( get_tree().get_current_scene().current_z )
		
		if get_node("TextureButton").get_click_on_press():
			_pos_on_click = get_viewport().get_mouse_pos()
			get_node("TextureButton").set_click_on_press(false)
		else:
			var current_pos = get_viewport().get_mouse_pos()
			if current_pos.distance_to(_pos_on_click) < _click_space_limit:
				_tile_pressed = !_tile_pressed
			else:
				get_node("TextureButton").set_click_on_press(true)
		_tile_pressed = !_tile_pressed
		
		global.set_state("source_3_shop_tileMoving", _tile_pressed)
		
		if !_tile_pressed:
			emit_signal("release")
