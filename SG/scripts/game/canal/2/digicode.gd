extends Control

var answer
var _code = ""
var _input = ""
var _KEYS = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var _keys = []

var clav = true

var _timer
var _effects = true
var _sound = true

signal right_input
signal wrong_input

######## Initialisation ########
func _ready():
	global.set_details({"area":"canal","level":"2","scene":"building"})
	set_process(true)
	
	if !global.get_state("canal_2_building_Grafiti") :
		get_node("Tag").hide()
		
		#Récupération du contenu de riddle.json
		var riddle = global.get_riddle("Digicode")
		answer = riddle["answer"]
		
		_timer = get_node("Timer")
		_timer.set_one_shot(true)
		_timer.set_wait_time(1)
		_timer.connect("timeout", self, "_on_Timer_timeout")
		get_node("validate").connect("pressed",self,"_validation")
		get_node("validate").set_default_cursor_shape(2)
		get_node("riddleOverlay").set_tip(global.get_game_text("DigicodeTip"))
		
		  #### Génération du clavier ####
	
		var row
		var codepad = get_node("codepad")
		
		var i = 0
		for key in range (0,15):
			if i == 0:
				row = HBoxContainer.new()
				codepad.add_child(row)
	
			i += 1
			var button = TextureButton.new()
			button.set_normal_texture(load("res://assets/game/canal/2/0_Digicode.png"))
			button.set_texture_scale(Vector2(0.47,0.55))
			button.set_toggle_mode(true)
			button.connect("pressed", self, "_press_key", [key])
			button.set_default_cursor_shape(2)
			button.add_to_group("codepad_keys")
			_keys.append(button)
			row.add_child(button)
	
			if i == 5:
				i = 0
	else :
		#Récupération du contenu de riddle.json
		var riddle = global.get_riddle("Digicode")
		answer = riddle["answer"]
		
		_timer = get_node("Timer")
		_timer.set_one_shot(true)
		_timer.set_wait_time(1)
		_timer.connect("timeout", self, "_on_Timer_timeout")
		get_node("validate").connect("pressed",self,"_validation")
		get_node("validate").set_default_cursor_shape(2)
		
		  #### Génération du clavier ####
	
		var row
		var codepad = get_node("codepad")
		
		var i = 0
		for key in range (0,15):
			if i == 0:
				row = HBoxContainer.new()
				codepad.add_child(row)
	
			i += 1
			var button = TextureButton.new()
			button.set_normal_texture(load("res://assets/game/canal/2/0_Digicode.png"))
			button.set_texture_scale(Vector2(0.47,0.55))
			button.set_toggle_mode(true)
			button.connect("pressed", self, "_press_key", [key])
			button.set_default_cursor_shape(2)
			button.add_to_group("codepad_keys")
			_keys.append(button)
			row.add_child(button)
	
			if i == 5:
				i = 0
####################
func _process(delta):
	if global.get_used_item() != "" :
		if global.get_used_item() == "canal_2_building_matG" :
			use_spray_on_wall()
		global.set_used_item("")


func use_spray_on_wall():
	global.use_item("canal_2_building_matG") # On utilise le spray, il disparait
	get_node("Tag").show()
	global.set_state("canal_2_building_Grafiti",true)
	
######## Appelé quand une touche est pressée ########
func _press_key(key):
	if _keys[key].is_pressed():
		_KEYS[key]=1
		_keys[key].set_pressed_texture(load("res://assets/game/canal/2/1_Digicode.png"))
	else : 
		_KEYS[key]=0
		_keys[key].set_normal_texture(load("res://assets/game/canal/2/0_Digicode.png"))

####################

func _validation():
	_code = str(_KEYS)
	if answer == _code :
		win()
	else :
		lose()

func win():
	global.set_target_node("digicode")
	get_node("riddleOverlay").riddle_solved(2,"res://scenes/game/canal/2/building.tscn")
	get_node("riddleOverlay").set_text(global.get_game_text("DigicodeWin"))
	global.set_state("canal_2_building_buildingDoorUnlocked",true)
	_timer.start()
	
func lose():
	get_node("riddleOverlay").set_text(global.get_game_text("DigicodeLose"))

func on_Timer_timeout():
	global.set_scene("res://scenes/game/canal/2/building.tscn")
	
######## Active/désactive toutes les touches du clavier ########
func enable_pad():
	for key in _keys:
		key.set_default_cursor_shape(2)
		key.set_disabled(false)

func disable_pad():
	for key in _keys:
		key.set_default_cursor_shape(0)
		key.set_disabled(true)
####################


######## Active/désactive les effets visuels et la temporisation ########
func set_effects(boolean):
	_effects = boolean
####################

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
	enable_pad()

	if _input == _code:
		emit_signal("right_input")
	else:
		emit_signal("wrong_input")
####################