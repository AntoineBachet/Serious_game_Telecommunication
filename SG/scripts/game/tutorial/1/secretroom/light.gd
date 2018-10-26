extends Light2D

var delay_short = 0.5
var delay_long = 1.5
var delay_between = 0.2
var delay_between_letters = 3
var delay_end = 10

var code
var size_code
var index

func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"secretroom"})

	index = 0

	#### Récupération du code morse ####
	var riddle = global.get_riddle("lamp")
	code = riddle["code"][settings.get_language()]
	size_code = code.length()

	if !global.get_state("tutorial_1_secretroom_light_on"):
		set_enabled(false)
	else:
		start_light()

func start_light():
	# Démarrage de la lumière
	index = 0
	global.set_state("tutorial_1_secretroom_light", true)
	if size_code > 0:
		if code[index] == '*':
			get_node("Timer").set_wait_time(delay_short)
			player.play_sound("light_bulb1")
			set_enabled(true)
		elif code[index] == '-':
			get_node("Timer").set_wait_time(delay_long)
			player.play_sound("light_bulb2")
			set_enabled(true)
		else:
			get_node("Timer").set_wait_time(delay_between_letters)
			player.stop_sound()
			set_enabled(false)
		get_node("Timer").start()

func stop_light():
	global.set_state("tutorial_1_secretroom_light", false)
	get_node("Timer").stop()
	set_enabled(false)

func _on_Timer_timeout():
	# A chaque changement "d'état" de la lampe : 
	if is_enabled(): # Si la lumière est allumée, on l'éteint
		player.stop_sound()
		set_enabled(false)
		get_node("Timer").set_wait_time(delay_between)
		get_node("Timer").start()

	else: # Si la lumière est éteinte, on passe au signal suivant
		index += 1
		if index >= size_code:
			get_node("Timer").set_wait_time(delay_end)
			index = -1
			if get_color() != Color(1,1,1):
				set_color(Color(1,1,1))
			else:
				set_color(Color(1,0.3,1))
		elif code[index] == '*':
			get_node("Timer").set_wait_time(delay_short)
			player.play_sound("light_bulb1")
			set_enabled(true)
		elif code[index] == '-':
			get_node("Timer").set_wait_time(delay_long)
			player.play_sound("light_bulb2")
			set_enabled(true)
		else:
			get_node("Timer").set_wait_time(delay_between_letters)
		get_node("Timer").start()

func is_lamp_on():
	return global.get_state("tutorial_1_secretroom_light")