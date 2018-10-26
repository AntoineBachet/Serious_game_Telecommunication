extends Control

var answer
var _code = ""
var _input = ""
var _KEYS = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var _keys = []

var clav = true

var _timer
var _effects = true
var _sound = true

signal right_input
signal wrong_input

######## Initialisation ########
func _ready():
	global.set_details({"area":"canal","level":"2","scene":"roomFloor"})
	set_process(true)
	#Récupération du contenu de riddle.json
	var riddle = global.get_riddle("postIt")
	answer = riddle["answer"]
	
	get_node("riddleOverlay").set_tip(global.get_game_text("PostItTip"))
	
	_timer = get_node("Timer")
	_timer.set_one_shot(true)
	_timer.set_wait_time(1)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	get_node("validate").connect("pressed",self,"_validation")
	get_node("validate").set_default_cursor_shape(2)
	  #### Génération des différents fils ####

	var row
	var codepad = get_node("codepad")
	
	var i = 0
	for key in range (0,36):
		if i == 0:
			row = HBoxContainer.new()
			codepad.add_child(row)

		i += 1
		var button = TextureButton.new()
		button.set_texture_scale(Vector2(1,1.2))
		button.set_normal_texture(load("res://assets/game/canal/2/0_manuscrit.png"))
		button.set_toggle_mode(true)
		button.connect("pressed", self, "_press_key", [key])
		button.set_default_cursor_shape(2)
		button.add_to_group("codepad_keys")
		_keys.append(button)
		row.add_child(button)
		if i == 9:
			i = 0
			
####################

######## Appelé quand une touche est pressée ########
func _press_key(key):
	if _keys[key].is_pressed():
		_KEYS[key]=1
		_keys[key].set_pressed_texture(load("res://assets/game/canal/2/1_manuscrit.png"))
	else : 
		_KEYS[key]=0
		_keys[key].set_normal_texture(load("res://assets/game/canal/2/0_manuscrit.png"))

####################

func _validation():
	_code = str(_KEYS)
	if answer == _code :
		get_node("validate").set_toggle_mode(true)
		get_node("validate").set_pressed(true)
		win()
	else :
		lose()

func win():
	global.set_target_node("post_it")
	get_node("riddleOverlay").riddle_solved(2,"res://scenes/game/canal/2/roomFloor.tscn")
	get_node("riddleOverlay").set_text(global.get_game_text("PostItWin"))
	global.set_state("canal_2_roomFloor_PostItResolution",true)
	_timer.start()
	
func lose():
	get_node("riddleOverlay").set_text(global.get_game_text("PostItLose"))

func on_Timer_timeout():
	global.set_scene("res://scenes/game/canal/2/roomFloor.tscn")

######## Définit directement l'input ########
func set_input(input):
	_input = str(input)

####################

######## Active/désactive les effets sonores ########
func set_sound(boolean):
	_sound = boolean
####################

######## Valide la saisie ########
func _validate():
	if _input == _code:
		if _effects:
			disable_pad()
			_timer.start()
		else:
			emit_signal("right_input")
		if _sound:
			player.play_sound("right")
		# rajouter Timer + affichage rouge/vert et blocage + son avec plein d'options
	else:
		if _effects:
			disable_pad()
			_timer.start()
		else:
			emit_signal("wrong_input")
		if _sound:
			player.play_sound("wrong")
####################

######## ########
func _on_Timer_timeout():
	if _input == _code:
		emit_signal("right_input")
	else:
		emit_signal("wrong_input")
####################