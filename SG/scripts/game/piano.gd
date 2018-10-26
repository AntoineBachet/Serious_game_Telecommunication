extends Node2D

var Musique_jouee = ""
var Musique_a_jouer = ""

var solved = false

var keys = []
var rythme = []
var music_length = 0
var index = 0
var noire = 0

func _ready():
	set_process(true)

	#### Affichage et traduction des textes statiques ####
	# Noms des touches
	var pianoKeys = global.get_gui_text("pianoKeys")
	var doLabel = get_node("doLabel")
	var do2Label = get_node("do2Label")
	var reLabel = get_node("reLabel")
	var miLabel = get_node("miLabel")
	var faLabel = get_node("faLabel")
	var solLabel = get_node("solLabel")
	var laLabel = get_node("laLabel")
	var siLabel = get_node("siLabel")
	var labels = [doLabel, reLabel, miLabel, faLabel, solLabel, laLabel, siLabel]
	for label in labels:
		if label.get_name() == "do2Label":
			label.set_text(pianoKeys[labels.find(doLabel)])
		else:
			label.set_text(pianoKeys[labels.find(label)])
	####################

	#### Connexion des touches ####
	get_node("PianoDo").connect("pressed", self, "_on_pianoKey_pressed", ["c1"])
	get_node("PianoDo2").connect("pressed", self, "_on_pianoKey_pressed", ["c2"])
	get_node("PianoRe").connect("pressed", self, "_on_pianoKey_pressed", ["d1"])
	get_node("PianoMi").connect("pressed", self, "_on_pianoKey_pressed", ["e1"])
	get_node("PianoFa").connect("pressed", self, "_on_pianoKey_pressed", ["f1"])
	get_node("PianoSol").connect("pressed", self, "_on_pianoKey_pressed", ["g1"])
	get_node("PianoLa").connect("pressed", self, "_on_pianoKey_pressed", ["a1"])
	get_node("PianoSi").connect("pressed", self, "_on_pianoKey_pressed", ["b1"])
	get_node("PianoDoDiese").connect("pressed", self, "_on_pianoKey_pressed", ["c1s"])
	get_node("PianoReDiese").connect("pressed", self, "_on_pianoKey_pressed", ["d1s"])
	get_node("PianoFaDiese").connect("pressed", self, "_on_pianoKey_pressed", ["f1s"])
	get_node("PianoSolDiese").connect("pressed", self, "_on_pianoKey_pressed", ["g1s"])
	get_node("PianoLaDiese").connect("pressed", self, "_on_pianoKey_pressed", ["a1s"])
	####################

	### Récupération de l'énigme appelée "piano"
	var puzzle = global.get_riddle("piano")
	var answer = puzzle["answer"]
	Musique_a_jouer = answer.replace(' ', '')
	
	### Récupération des notes et du rythme pour la lecture automatique à la fin de l'énigme
	keys = answer.split(' ')
	rythme = puzzle["rythme"]
	rythme = rythme.split(' ')
	music_length = keys.size()
	if music_length != rythme.size():
		music_length = 0
	var tempo = puzzle["tempo"]
	noire = 1 / (float(tempo) / 60)

func get_solved_string():
	var scene_details = global.get_details()
	return scene_details.area + "_" + scene_details.level + "_" + scene_details.scene + "_pianoSolved"

func _process(delta):
	# On cherche l'enchaînement de notes à jouer dans ce qui a été joué
	# On a trouvé la solution
	if !solved and Musique_jouee.find(Musique_a_jouer) > -1 and !global.get_state( get_solved_string() ): #Retourne -1 Si Musique_a_jouer n'est pas trouvé dans Musique_jouee
		solved = true
		get_node("Timer").set_wait_time(0.5) ### Sinon ça coupe le son de la dernière note
		get_node("Timer").start()
		get_node("Timer").connect("timeout", self, "back_to_house")

#### Association des touches avec les sons ####
func _on_pianoKey_pressed(key):
	if !solved:
		player.play_sound(str("piano_", key))
		Musique_jouee = Musique_jouee+key
####################

func back_to_house():
	if !global.get_state( get_solved_string() ):
		global.set_state(get_solved_string(), true)
		get_parent().get_node("riddleOverlay").riddle_solved(get_total_time() + 2)
		start_auto()

#### Bouton de triche ####
func cheat():
	Musique_jouee = Musique_jouee + Musique_a_jouer
####################


########## A la fin, la musique se joue avec le rythme
func get_total_time():
	var time = 0
	for i in range(music_length):
		time += get_time(rythme[i])
	return time

func start_auto():
	if settings.get_setting("sound"):
		index = -1
		get_node("Timer").connect("timeout", self, "_on_Timer_timeout")
		get_node("Timer").set_wait_time(1)
		get_node("Timer").start()

func play_current():
	player.play_sound(str("piano_", keys[index]))
	get_node("Timer").set_wait_time(get_time(rythme[index]))
	get_node("Timer").start()

func _on_Timer_timeout():
	index += 1
	if index < music_length:
		play_current()

func get_time(r):
	var base_time = 0
	if r[0] == "d": ## Double croche
		base_time = noire / 4
	elif r[0] == "c": ## Croche
		base_time = noire / 2
	elif r[0] == "n": ## Noire
		base_time = noire
	elif r[0] == "b": ## Blanche
		base_time = noire * 2
	elif r[0] == "r": ## Ronde
		base_time = noire * 4
	if r.length() == 2 and r[1] == "*":
		return base_time * 1.5
	elif r.length() == 2 and r[1] == "3":
		return base_time * 2/3
	else:
		return base_time