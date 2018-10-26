##### res://scripts/gui/log.gd
#####
##### Ce script gère le journal, qui contient tous les quiz

extends Control

var quiz
var quizData
var quizList
var currentPage
var nbPages

var language

var leftPage
var rightPage
var leftButton
var rightButton
var quizTitle
var quizImage
var quizDescription
var quizResults
var quizQuestions
var quizReplayButton

######## Initialisation ########
func _ready():
	language = settings.get_language()

	#### Affichage/traduction des textes ####
	for node in ["buttonToInventory","buttonToEncyclopedia","buttonToMap"]:
		get_node(str("Control/VBoxContainer/tabs/",node)).set_text(global.get_gui_text(node))
	get_node("Control/VBoxContainer/tabs/menuTitle").set_text(global.get_gui_text("buttonToLog"))
	get_node("Control/VBoxContainer/buttonContainer/returnButton").set_text(global.get_gui_text("returnButton"))
	get_node("Control/VBoxContainer/contentContainer/rightPage/quizReplayButton").set_text(global.get_gui_text("logReplayQuiz"))

	#### Déblocage ou non des boutons vers les autres menus ####
	for guiElement in ["encyclopedia", "inventory", "map"]:
		if Globals.get("gameState").has(str(guiElement,"Unlocked")):
			get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_disabled(!Globals.get("gameState")[str(guiElement,"Unlocked")])
			if Globals.get("gameState")[str(guiElement,"Unlocked")]:
				get_node(str("Control/VBoxContainer/tabs/buttonTo",guiElement.capitalize())).set_default_cursor_shape(2)

	#### Curseurs ####
	get_node("Control/VBoxContainer/buttonContainer/returnButton").set_default_cursor_shape(2)
	get_node("Control/VBoxContainer/contentContainer/rightPage/quizReplayButton").set_default_cursor_shape(2)

	#### Récupération et préparation des nodes d'intérêt ####
	leftPage = get_node("Control/VBoxContainer/contentContainer/leftPage")
	rightPage = get_node("Control/VBoxContainer/contentContainer/rightPage")
	leftButton = get_node("Control/VBoxContainer/contentContainer/leftButton")
	rightButton = get_node("Control/VBoxContainer/contentContainer/rightButton")
	quizTitle = leftPage.get_node("quizTitle")
	quizTitle.set_use_bbcode(true)
	quizImage = get_node("Control/VBoxContainer/contentContainer/leftPage/quizImage")
	quizImage.hide()
	quizDescription = leftPage.get_node("quizDescription")
	quizDescription.set_use_bbcode(true)
	quizResults = rightPage.get_node("quizResults")
	quizResults.set_use_bbcode(true)
	quizQuestions = rightPage.get_node("quizQuestions")
	quizQuestions.set_use_bbcode(true)
	quizReplayButton = rightPage.get_node("quizReplayButton")

	get_node("Control/VBoxContainer/contentContainer/rightButton").connect("pressed", self, "turn_right")
	get_node("Control/VBoxContainer/contentContainer/leftButton").connect("pressed", self, "turn_left")

	#### Importation des quiz ####
	quiz = global.json_into_dictionary("res://data/quiz.json")
	quizList = []
	quizData = {}

	for area in quiz:
		quizData[area] = {}
		for level in quiz[area]:
			if Globals.get("gameState").has(area + "_" + level + "_quiz_finished") and Globals.get("gameState")[area + "_" + level + "_quiz_finished"]:
				quizData[area][level] = {}
				quizList.append([area, level])
				quizData[area][level]["score"] = get_score(area, level)
				quizData[area][level]["scoreMax"] = get_scoreMax(quiz[area][level])
				quizData[area][level]["numberOfQuestions"] = get_numberOfQuestions(quiz[area][level])
				quizData[area][level]["title"] = get_title(quiz[area][level], area, level)
				quizData[area][level]["description"] = get_description(quiz[area][level])		#si nom relatif au scénario pour le titre
				quizData[area][level]["quizImage"] = "Image du quiz"				#ça peut être une capture d'écran faite pendant le quiz et mise de côté pour plus tard
				quizData[area][level]["questions"] = get_questions(quiz[area][level])

	currentPage = 0
	nbPages = quizList.size()
	leftButton.set_disabled(true)
	if nbPages == 1:
		rightButton.set_disabled(true)

	display_quiz(quizList[0][0], quizList[0][1])

	set_process_input(true)
########################

######## Fonctions pour la construction de quizData ########
func get_score( area, level ):
	if Globals.get("gameState").has(area + "_" + level + "_quiz_score"):
		return Globals.get("gameState")[area + "_" + level + "_quiz_score"]
	else:
		return 0

func get_scoreMax(qu):
	var score_max = 0
	for q in qu["questions"]:
		if q.has("score"):
			score_max += int( q["score"] )
		else:
			score_max += 1
	return score_max

func get_numberOfQuestions(qu):
	if qu.has("questions"):
		return qu["questions"].size()
	else:
		return 0

func get_title(qu, area, level):
	if qu.has("title"):
		var language = settings.get_language()
		if !qu["title"].has(language):
			language = "fr"
		return qu["title"][language]
	return "Quiz " + area + " " + level

func get_description(qu):
	if qu.has("description"):
		if qu["description"].has(language):
			return qu["description"][language]
		else:
			return qu["description"]["fr"]
	else:
		return ""

func get_questions(qu):
	var questions = []
	if qu.has("questions"):
		for question in qu["questions"]:
			if ((question.has("condition") and global.get_state(question.condition)) or !question.has("condition")):
				if question.question.has(language):
					questions.append(question.question[language])
				else:
					questions.append(question.question["fr"])
	return questions
####################

######## Affichage d'un quiz ########
func display_quiz(area,level):
	var text = ""

	# Affichage de la page de gauche
	text += str("[center]", quizData[area][level]["title"], "[/center]\n\n")

	# C'est pas beau, on arrangera ça plus tard, il faut déplacer la fonction de map.gd qui fait ça dans global.gd
	var mapData = global.json_into_dictionary("res://data/map.json")
	if mapData[str(area, "_", level)].name.has(language):
		text += str("[b]", global.get_gui_text("logQuizPlace"), ":[/b] ", mapData[str(area, "_", level)].name[language])
	else:
		text += str("[b]", global.get_gui_text("logQuizPlace"), ":[/b] ", mapData[str(area, "_", level)].name["fr"])

	quizTitle.set_bbcode(text)

	# Image ?

	quizDescription.set_bbcode(str("[b]Description :[/b] ", quizData[area][level]["description"]))

	# Affichage de la page à droite
	text = str(quizData[area][level]["numberOfQuestions"], " ")
	if quizData[area][level]["numberOfQuestions"] > 1:
		text += global.get_gui_text("logMoreThanOneQuestion")
	else:
		text += global.get_gui_text("logOneQuestion")
	text += str("\n\n", global.get_gui_text("logCurrentScore"), " : ")
	text += str(quizData[area][level]["score"]) + " / " + str(quizData[area][level]["scoreMax"])
	quizResults.set_bbcode(text)
	
	var questions = str("[b]", global.get_gui_text("logQuestions"), " :[/b]\n")
	for question in quizData[area][level]["questions"]:
		questions += str(question, "\n")
	if quizData[area][level]["questions"].size() < quizData[area][level]["numberOfQuestions"]:
		questions += str("[i]", global.get_gui_text("logQuestionsLocked")," :[/i] ", quizData[area][level]["numberOfQuestions"] - quizData[area][level]["questions"].size())
	quizQuestions.set_bbcode(questions)

	quizReplayButton.connect("pressed", self, "replay_quiz", [area, level])
####################

######## Navigation entre les quiz ########
func turn_right():
	if currentPage < nbPages - 1:
		leftButton.set_disabled(false)
		currentPage += 1
		if currentPage == nbPages - 1:
			rightButton.set_disabled(true)
		else:
			rightButton.set_disabled(false)
		display_quiz(quizList[currentPage][0], quizList[currentPage][1])

func turn_left():
	if currentPage > 0:
		rightButton.set_disabled(false)
		currentPage -= 1
		if currentPage == 0:
			leftButton.set_disabled(true)
		else:
			leftButton.set_disabled(false)
		display_quiz(quizList[currentPage][0], quizList[currentPage][1])
####################

######## Rejouer un quiz ########
func replay_quiz(area, level):
	Globals.get("gameState")["nextPath"] = "res://scenes/gui/log.tscn"
	Globals.get("gameState")["replaying_quiz"] = true
	global.set_scene(str("res://scenes/game/",area,"/",level,"/quiz/",area,"_",level,"_quiz.tscn"))
####################

######## Inputs ########
# Sortie du journal avec le raccourci clavier
func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("log") or event.is_action_pressed("menu"):
			_on_returnButton_pressed()

# Sortie du journal avec le bouton retour
func _on_returnButton_pressed():
	global.load_scene()

# Passage à l'inventaire avec le bouton
func _on_buttonToInventory_pressed():
	player.play_sound("inventory")
	global.set_scene("res://scenes/gui/inventory.tscn")

# Passage à l'encyclopédie avec le bouton
func _on_buttonToEncyclopedia_pressed():
	player.play_sound("encyclopedia")
	global.set_scene("res://scenes/gui/encyclopedia.tscn")

# Passage à la carte avec le bouton
func _on_buttonToMap_pressed():
	player.play_sound("map")
	global.set_scene("res://scenes/gui/map.tscn")
####################