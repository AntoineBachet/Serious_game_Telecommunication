extends Control

var _code = ""
var _input = ""
const _KEYS = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "V", "0", "C"]
var _keys = []

var _max_size = 8

var _is_displaying = true
var _display
var _timer
var _effects = true
var _sound = true

signal right_input
signal wrong_input

######## Initialisation ########
func _ready():
	_display = get_node("codepad/displayPanel/display")
	_display.set_custom_minimum_size(Vector2(0,50))
	_display.set_use_bbcode(true)

	_timer = get_node("Timer")
	_timer.set_one_shot(true)
	_timer.set_wait_time(1)
	_timer.connect("timeout", self, "_on_Timer_timeout")

	#### Génération du clavier ####
	var row
	var codepad = get_node("codepad")

	var i = 0
	for key in _KEYS:
		if i == 0:
			row = HBoxContainer.new()
			codepad.add_child(row)

		i += 1
		var button = Button.new()
		button.set_text(key)
		button.set_custom_minimum_size(Vector2(60,60))
		button.connect("pressed", self, "_press_key", [key])
		button.set_default_cursor_shape(2)
		button.add_to_group("codepad_keys")
		_keys.append(button)
		row.add_child(button)

		if i == 3:
			i = 0
####################

######## Appelé quand une touche est pressée ########
func _press_key(key):
	if key == "V":
		_validate()
	elif key == "C":
		_correct()
	else:
		if _input.length() < _max_size:
			_input += key
			_update_display()
####################

######## Efface le dernier chiffre ########
func _correct():
	if _input.length() > 0:
		_input = _input.substr(0, _input.length()-1)
		_update_display()
####################

######## Met à jour l'afficheur ########
func _update_display():
	if _is_displaying:
		_display.set_bbcode(str("[center]",_input,"[/center]"))
####################

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

######## Définit le code ########
func set_code(code):
	_code = str(code)
####################

######## Affiche/cache l'afficheur ########
func set_display(boolean):
	_is_displaying = boolean
	if _is_displaying:
		get_node("codepad/displayPanel").show()
	else:
		get_node("codepad/displayPanel").hide()
####################

######## Active/désactive les effets visuels et la temporisation ########
func set_effects(boolean):
	_effects = boolean
####################

######## Définit la taille maximale de la saisie ########
func set_max_size(size):
	_max_size = size
####################

######## Définit directement l'input ########
func set_input(input):
	_input = str(input)
	_update_display()
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
			_display.set_bbcode(str("[center][color=green]",_input,"[/color][/center]"))
			_timer.start()
		else:
			emit_signal("right_input")
		if _sound:
			player.play_sound("right")
		# rajouter Timer + affichage rouge/vert et blocage + son avec plein d'options
	else:
		if _effects:
			disable_pad()
			_display.set_bbcode(str("[center][color=red]",_input,"[/color][/center]"))
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

	_input = ""
	_update_display()
####################