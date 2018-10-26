extends Control

var answer
var _code = ""
var _input = ""
var _KEYS = [0,0,0,0]
var _keys = []

var clav = true

var _timer
var _effects = true
var _sound = true

signal right_input
signal wrong_input

######## Initialisation ########
func _ready():
	global.set_details({"area":"canal","level":"2","scene":"floor"})
	set_process(true)
	
	if !global.get_state("canal_2_floor_controlPanelOut") :
		get_node("fils").hide()
		get_node("blackScreen").hide()
		get_node("validate").hide()
		get_node("riddleOverlay").set_tip(global.get_game_text("elevatorTip1"))
		
		#Récupération du contenu de riddle.json
		var riddle = global.get_riddle("elevator")
		answer = riddle["answer"]
		
		_timer = get_node("Timer")
		_timer.set_one_shot(true)
		_timer.set_wait_time(1)
		_timer.connect("timeout", self, "_on_Timer_timeout")
		get_node("validate").connect("pressed",self,"_validation")
		get_node("validate").set_default_cursor_shape(2)
		
		  #### Génération des différents fils ####
	
		var row
		var fils = get_node("fils")
		
		var i = 0
		for key in range (0,4):
			if i == 0:
				row = HBoxContainer.new()
				fils.add_child(row)
	
			i += 1
			var button = TextureButton.new()
			button.set_texture_scale(Vector2(2,1.5))
			button.set_normal_texture(load("res://assets/game/canal/2/filrouge.png"))
			button.set_toggle_mode(true)
			button.connect("pressed", self, "_press_key", [key])
			button.set_default_cursor_shape(2)
			button.add_to_group("codepad_keys")
			_keys.append(button)
			row.add_child(button)
	else :
		get_node("controlPanel").hide()
		get_node("riddleOverlay").set_tip(global.get_game_text("elevatorTip2"))
		#Récupération du contenu de riddle.json
		var riddle = global.get_riddle("elevator")
		answer = riddle["answer"]
		
		_timer = get_node("Timer")
		_timer.set_one_shot(true)
		_timer.set_wait_time(1)
		_timer.connect("timeout", self, "_on_Timer_timeout")
		get_node("validate").connect("pressed",self,"_validation")
		get_node("validate").set_default_cursor_shape(2)
		
		  #### Génération des différents fils ####
	
		var row
		var fils = get_node("fils")
		
		var i = 0
		for key in range (0,4):
			if i == 0:
				row = HBoxContainer.new()
				fils.add_child(row)
	
			i += 1
			var button = TextureButton.new()
			button.set_texture_scale(Vector2(2,1.5))
			button.set_normal_texture(load("res://assets/game/canal/2/filrouge.png"))
			button.set_toggle_mode(true)
			button.connect("pressed", self, "_press_key", [key])
			button.set_default_cursor_shape(2)
			button.add_to_group("codepad_keys")
			_keys.append(button)
			row.add_child(button)
####################

func _process(delta):
	if global.get_used_item() != "":
		if global.get_used_item() == "canal_2_floor_toolBox" :
			use_toolBox_on_elevator()
		global.set_used_item("")


func use_toolBox_on_elevator():
	global.set_state("canal_2_floor_elevatorBlocked", true) # On met à jour la condition d'ouverture de la porte
	global.use_item("canal_2_floor_toolBox") # On utilise la boite à outils, elle disparaît de l'inventaire
	get_node("controlPanel").queue_free()
	global.set_state("canal_2_floor_controlPanelOut",true)
	get_node("fils").show()
	get_node("blackScreen").show()
	get_node("validate").show()
	get_node("riddleOverlay").set_tip(global.get_game_text("elevatorTip2"))
#	get_node("gui").set_text(global.get_game_text("elevatorBlocked"))
	
######## Appelé quand une touche est pressée ########
func _press_key(key):
	if _keys[key].is_pressed():
		_KEYS[key]=1
		_keys[key].set_pressed_texture(load("res://assets/game/canal/2/FilRougeAttache.png"))
	else : 
		_KEYS[key]=0
		_keys[key].set_normal_texture(load("res://assets/game/canal/2/filrouge.png"))

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
	global.set_target_node("elevator")
	get_node("riddleOverlay").riddle_solved(2,"res://scenes/game/canal/2/loftEntrance.tscn")
	get_node("riddleOverlay").set_text(global.get_game_text("elevatorWin"))
	global.set_state("canal_2_floor_elevatorUnblocked",true)
	_timer.start()
	
func lose():
	get_node("riddleOverlay").set_text(global.get_game_text("elevatorLose"))

func on_Timer_timeout():
	global.set_scene("res://scenes/game/canal/2/loft.tscn")

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