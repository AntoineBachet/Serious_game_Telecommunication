#### res://scripts/game/quiz.gd
####
#### Ce fichier est à utiliser tel quel dans les différentes scènes du jeu
#### Pour insérer un quiz dans une scène, rajouter "scenes/game/quiz.tscn" à la scène
#### Penser à ajouter les personnages devant parler au groupe "character" dans la scène principale
#### 
#### Elements utiles de ce script pour son utilisation :
####	Le quiz envoie un signal "finished"
####	func start_quiz()
####	func set_questions( q ) (q devra être un dictionnaire contenant le quiz)
####	func set_nb_buttons( n ) (n devra être un entier)
####	func get_score()
####	func get_score_max()
####	func get_question_with_answer()
################################

extends Node2D

### Le signal "finished" est emis à la fin du quiz
signal finished

var nb_buttons = 0
var quiz # Contient le quiz

var questions # Contient les questions du quiz
var nb_questions = 0
var index_question = -1
var dialogue # Contient les différents dialogues
var nb_dialogue = 0
var index_dialogue = -1

#### Variables pour les boutons
var right_answer
var other_answers
var nb_answers
var random_order

#### Attente pour passer à la bulle suivante
var wait_dialogue = 0.7
var can_pass_dialogue = true

#### Etat du quiz
var current

### Variables pour le redimensionnement du texte
var text_scale = {}
var text_size = {}

var score = 0
var score_delta = 0
var processing = false
var list

### Compteur réponses
var compt_right_answers = 0
var compt_wrong_answers = 0
var int_score = 0

func _ready():
	if !settings.is_debug_mode():
		get_node("pass").free()
	else:
		get_node("pass").connect("pressed", self, "_on_pass_pressed")
	get_node("Validate").connect("pressed", self, "_on_validate_pressed")
	get_node("Validate").set_disabled(true)
	get_node("Validate").hide()

func _on_pass_pressed():
	clear_bubbles()
	score = get_score_max()
	for q in questions:
		q["result"] = "right"
	finish_quiz()


func start_quiz():
	#### Connection des boutons
	#for i in range(nb_buttons):
	#	get_parent().get_node("VBoxContainer/Button" + str(i+1)).connect("pressed", self, "_on_button_pressed", [i])

	questions = quiz["questions"]
	nb_questions = questions.size()
	
	get_node("Timer").connect("timeout", self, "_on_Timer_timeout")

	#### Démarrage du quiz
	processing = true
	set_process_input(true)
	next_question()


func finish_quiz():
	if !Globals.get("gameState").has("logUnlocked"):
		Globals.get("gameState")["logUnlocked"] = true
	processing = false
	set_process_input(false)
	emit_signal("finished")

	if get_parent().has_node("quiz_result"):
		get_parent().get_node("quiz_result").see_details()

	var area = Globals.get("sceneDetails").area
	var level = Globals.get("sceneDetails").level
	if !(Globals.get("gameState").has(area + "_" + level + "_quiz_finished") and Globals.get("gameState")[area + "_" + level + "_quiz_finished"]):
		if !Globals.get("gameState").has("score_quiz"):
			Globals.get("gameState")["score_quiz"] = score
		else:
			Globals.get("gameState")["score_quiz"] += score
		Globals.get("gameState")[area + "_" + level + "_quiz_finished"] = true
		Globals.get("gameState")[area + "_" + level + "_quiz_score"] = score
		score_delta = score
	else:
		if !Globals.get("gameState").has(area + "_" + level + "_quiz_score"):
			Globals.get("gameState")[area + "_" + level + "_quiz_score"] = 0
		if !Globals.get("gameState").has("score_quiz"):
			Globals.get("gameState")["score_quiz"] = 0
		if score > Globals.get("gameState")[area + "_" + level + "_quiz_score"]:
			score_delta -= Globals.get("gameState")[area + "_" + level + "_quiz_score"]
			score_delta += score
			Globals.get("gameState")["score_quiz"] -= Globals.get("gameState")[area + "_" + level + "_quiz_score"]
			Globals.get("gameState")["score_quiz"] += score
			Globals.get("gameState")[area + "_" + level + "_quiz_score"] = score

	get_node("Timer").disconnect("timeout", self, "_on_Timer_timeout")
	get_node("Timer").connect("timeout", self, "show_result")
	get_node("Timer").set_wait_time(1)
	get_node("Timer").start()

func show_result():
	if get_parent().has_node("quiz_result"):
		get_parent().get_node("quiz_result").show()


func _input(event):
	#### Avancée dans le dialogue
	if ((event.type == InputEvent.KEY and (event.scancode == KEY_E or event.scancode == KEY_RETURN or event.scancode == KEY_SPACE)) or (event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT)) and !event.is_pressed() and !event.is_echo():
		if (current == "dialogue" or current == "alternative_dialogue" or current == "end_dialogue") and can_pass_dialogue:
			process_dialogue()


######### Passage à la question suivante
func next_question():
	clear_buttons()
	clear_bubbles()
	index_question += 1
	if index_question < nb_questions:
		start_question()
	else:
		end_quiz()

######## Début d'une question. On commence par un dialogue
func start_question():
	if questions[index_question].has("condition"): #### Si il y a une condition, on affiche le dialogue alternatif
		var condition = questions[index_question]["condition"]
		if Globals.get("gameState").has(condition) and Globals.get("gameState")[condition]:
			get_dialogue()
			get_answers()
			current = "dialogue"
			process_dialogue()

		else:
			get_alternative_dialogue()
			current = "alternative_dialogue"
			process_dialogue()

	else:
		#### Démarrage d'un dialogue
		get_dialogue()
		get_answers()
		current = "dialogue"
		process_dialogue()

############################## Fin des questions du quiz : on affiche le dialogue de fin
func end_quiz():
	get_end_dialogue()
	current = "end_dialogue"
	process_dialogue()

##############################
func process_dialogue():
	if index_dialogue < nb_dialogue - 1:
		clear_bubbles()
		index_dialogue += 1
		if get_parent().has_node( dialogue[index_dialogue]["character"] ):
			#### Récupération du texte dans la bonne langue
			var language = settings.get_language()
			if !dialogue[index_dialogue]["text"].has(language):
				language = "fr"
			var text = dialogue[index_dialogue]["text"][language]

			#### Affichage du texte
			get_parent().get_node( dialogue[index_dialogue]["character"] + "/text" ).set_text(text)
			get_parent().get_node( dialogue[index_dialogue]["character"] + "/bubble" ).show()

		############################################ Redimensionnement du texte
		# il faudrait factoriser ça et celui de cinematics.gd dans un même script
			var text =  get_parent().get_node( dialogue[index_dialogue]["character"] + "/text" )
			#### Si on a changé la taille des bulles, on remet la taille de base
			if text_scale.has( dialogue[index_dialogue]["character"] ) and text_size.has( dialogue[index_dialogue]["character"] ):
				text.set_scale( text_scale[ dialogue[index_dialogue]["character"] ] )
				text.set_size( text_size[ dialogue[index_dialogue]["character"] ] )

			var line_height = text.get_line_height()
			var max_line = int( text.get_size().y / (line_height * text.get_scale().y) )
			#### Réduction de la taille si le texte est trop grand
			if text.get_line_count() > max_line:
				var old_scale = text.get_scale()
				var old_size = text.get_size()

				### Récupération de la taille de base
				if !( text_scale.has( dialogue[index_dialogue]["character"] ) and text_size.has( dialogue[index_dialogue]["character"] ) ):
					text_scale[ dialogue[index_dialogue]["character"] ] = old_scale
					text_size[ dialogue[index_dialogue]["character"] ] = old_size

				var new_scale = old_scale
				var new_size = old_size
				while text.get_line_count() > max_line and new_scale.x >= 0.1:
					### Réduction de la taille du texte
					new_scale.x -= 0.1
					new_scale.y -= 0.1
					new_size.x = old_size.x / new_scale.x * old_scale.x
					new_size.y = old_size.y / new_scale.y * old_scale.y
					text.set_scale(new_scale)
					text.set_size(new_size)
					max_line = int( old_size.y / (int(line_height * new_scale.y)) - 0.5 )
			########################################

		### On bloque le passage à la bulle suivante
		can_pass_dialogue = false
		get_node("Timer").set_wait_time(wait_dialogue)
		get_node("Timer").start()

	#### Fin du dialogue -> on passe aux réponses
	else:
		if current == "dialogue":
			clear_next()
			current = "answers"
			set_answers_buttons()
		elif current == "alternative_dialogue":
			next_question()
		elif current == "end_dialogue":
			clear_bubbles()
			finish_quiz()

############################# Ecriture des boutons de réponse dans un ordre aléatoire
func set_answers_buttons():
	list = Array()
	for i in range(right_answer.size()):
		list.append(i)
	for i in range(nb_answers):
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).set_disabled(false)
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).show()
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).set_toggle_mode(true)
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).connect("button_down", self, "_on_button_down", [i])
		#get_parent().get_node("VBoxContainer/Button" + str(i+1)).connect("button_up", self, "_on_button_up", [i])
		var text
		if !(random_order[i] in list):
			text = other_answers[random_order[i] - right_answer.size()]
		else:
			text = right_answer[random_order[i]]
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).set_text(text)
	### Ecriture de la question
	get_node("Validate").set_disabled(false)
	get_node("Validate").show()
	#get_parent().get_node("VBoxContainer/Button" + str(nb_answers+1)).set_disabled(false)
	#get_parent().get_node("VBoxContainer/Button" + str(nb_answers+1)).show()
	#get_parent().get_node("VBoxContainer/Button" + str(nb_answers+1)).set_text("Valider")
	#get_parent().get_node("VBoxContainer/Button" + str(nb_answers+1)).connect("pressed",self,"_on_validate_pressed")
	#get_parent().get_node("VBoxContainer/Button" + str(nb_answers+1)).set_toggle_mode(false)
	if questions[index_question].has("question"):
		var language = settings.get_language()
		if !questions[index_question]["question"].has(language):
			language = "fr"
		var text = questions[index_question]["question"][language]
		get_parent().get_node("question_bg").show()
		get_parent().get_node("question_bg/question").set_text( text )
#############################

#### Clic sur une réponse
func _on_button_down(button):
	#get_parent().get_node("question_bg").hide()
	if random_order[button] in list: #### Bonne réponse -> on augmente le score
		if !get_parent().get_node("VBoxContainer/Button" + str(button+1)).is_pressed():
			compt_right_answers += 1
		else : 
			compt_right_answers -= 1
		#if questions[index_question].has("score"):
			#score += int( questions[index_question]["score"] )/right_answer.size()
		#else:
			#score += 1/right_answer.size()
		#questions[index_question]["result"] = "right"
	#if random_order[button] == nb_answers + 1 :
	#	next_question()### On passe à la question suivante
	else:
		if !get_parent().get_node("VBoxContainer/Button" + str(button+1)).is_pressed():
			compt_wrong_answers += 1
		else : 
			compt_wrong_answers -= 1
		#questions[index_question]["result"] = "wrong"
	 ### On passe à la question suivante

#func _on_button_up(button):
#	if random_order[button] in list:
#		compt_right_answers -= 1
#	else:
#		compt_wrong_answers -= 1

func _on_validate_pressed():
	get_parent().get_node("question_bg").hide()
	if questions[index_question].has("score"):
		int_score += (compt_right_answers-compt_wrong_answers)*int(questions[index_question]["score"])/right_answer.size()
	else :
		int_score += (compt_right_answers-compt_wrong_answers)/right_answer.size()
	if compt_right_answers == right_answer.size() and compt_wrong_answers == 0:
		questions[index_question]["result"] = "right"
	else : 
		questions[index_question]["result"] = "wrong"
	if int_score > 0:
		score += int_score
	int_score = 0
	compt_right_answers = 0
	compt_wrong_answers = 0
	for i in range(nb_answers): 
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).set_toggle_mode(false)
	get_node("Validate").set_disabled(true)
	get_node("Validate").hide()
	next_question()
		
		
####################################################### Récupération des dialogues
#### Récupération du dialogue
func get_dialogue():
	#### Chargement du dialogue
	if questions[index_question].has("dialogue"):
		dialogue = questions[index_question]["dialogue"]
	else:
		dialogue = []
	nb_dialogue = dialogue.size()
	index_dialogue = -1
############################

func get_alternative_dialogue():
	if questions[index_question].has("alternative_dialogue"):
		dialogue = questions[index_question]["alternative_dialogue"]
	else:
		dialogue = []
	nb_dialogue = dialogue.size()
	index_dialogue = -1
#############################

func get_end_dialogue():
	if quiz.has("end_dialogue"):
		dialogue = quiz["end_dialogue"]
		nb_dialogue = dialogue.size()
		index_dialogue = -1
	else:
		finish_quiz()
###############################
####################################################################################

#### Récupération des différentes réponses, et création d'un ordre aléatoire pour les réponses
func get_answers():
	#### Chargement des réponses
	var language = settings.get_language()
	if !questions[index_question]["right_answer"].has(language) or !questions[index_question]["other_answers"].has(language):
		language = "fr"
	right_answer = questions[index_question]["right_answer"][language]
	other_answers = questions[index_question]["other_answers"][language]
	nb_answers = other_answers.size() + right_answer.size()
	#### Ordre aléatoire
	random_order = Array()
	randomize()
	for i in range(nb_answers):
		var ind = randi() % nb_answers
		while ind in random_order:
			ind = randi() % nb_answers
		random_order.append(ind)
#############################

#### Disparition des boutons
func clear_buttons():
	for i in range(nb_buttons):
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).set_disabled(true)
		get_parent().get_node("VBoxContainer/Button" + str(i+1)).hide()
############################

#### Disparition des bulles de texte
func clear_bubbles():
	for c in get_tree().get_nodes_in_group("character"):
		c.get_node("text").set_text("")
		c.get_node("bubble").hide()
		if c.has_node("next"):
			c.get_node("next").hide()
#############################
func clear_next():
	for c in get_tree().get_nodes_in_group("character"):
		if c.has_node("next"):
			c.get_node("next").hide()

##################################################################################################
################################################################ Fonctions utiles hors de ce script
##################################################################################################
### func start_quiz() (voir plus haut)

func get_score():
	return score

func get_score_delta():
	return score_delta

func get_score_max():
	var score_max = 0
	for q in questions:
		if q.has("score"):
			score_max += int( q["score"] )
		else:
			score_max += 1
	return score_max

func set_quiz(q):
	quiz = q

func set_nb_buttons(n):
	nb_buttons = n

func get_question_with_answer():
	var res = Array()
	for q in questions:
		var language = settings.get_language()
		if !q["question"].has("language") or !q["right_answer"].has("language"):
			language = "fr"
		var result = "none"
		if q.has("result"):
			result = q["result"]
		var answer = q["right_answer"][language][0]
		if language == "fr":
			for i in range(q["right_answer"][language].size()-1):
				answer += " et " + q["right_answer"][language][i+1]
		else:
			for i in range(q["right_answer"][language].size()-1):
				answer += " and " + q["right_answer"][language][i+1]
		res.append( [ q["question"][language], answer, result ] )
	return res
##################################################################################################
##################################################################################################


################################################################################## Signaux

##### Fin du timer
func _on_Timer_timeout():
	if processing:
		if (current == "dialogue" or current == "alternative_dialogue" or current == "end_dialogue") and index_dialogue < nb_dialogue:
			if get_parent().has_node( dialogue[index_dialogue]["character"] ) and get_parent().get_node( dialogue[index_dialogue]["character"] ).has_node("next"):
				get_parent().get_node( dialogue[index_dialogue]["character"] + "/next" ).show()
				can_pass_dialogue = true