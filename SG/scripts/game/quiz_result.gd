##### res://scripts/game/quiz_result.gd
#####
##### Ce script gère l'affichage des résultats à la fin des quiz


extends Node2D

var mini = 0
var maxi = 100

########################### Initialisation
func _ready():
	get_node("next_scene").connect("pressed", self, "_on_next_scene_pressed")
	if global.get_state( "replaying_quiz" ):
		get_node("next_scene").set_text( global.get_gui_text( "backToLogButton" ) )
		Globals.get("gameState")["replaying_quiz"] = false
	else:
		get_node("next_scene").set_text( global.get_gui_text( "nextSceneButton" ) )
	connect("draw", self, "_on_draw")

### Mise à jour des points
func _process(delta):
	var value = get_node("pie_chart").get_value()
	var money = (maxi - mini) / 100 * value + mini
	var moneystr = str( int(money) )
	var text = "[right][img]res://assets/player/hats/coin_32.png[/img] " + moneystr + "[/right]"
	get_node("money").set_bbcode(text)

func _on_animation_finished():
	_process(0)
	set_process(false)

#### Scène suivante
func _on_next_scene_pressed():
	if Globals.get("gameState").has("nextPath"):
		global.set_scene(Globals.get("gameState")["nextPath"])

##### Affichage des résultats
func see_details():
	var text = ""
	var answers = get_parent().get_node("quiz").get_question_with_answer()
	#print(answers)
	var nb = answers.size()
	var right_answer = global.get_gui_text("right_answer")
	
	#### Détail question par question
	for i in range( nb ):
		if answers[i][2] == "none":
			text += global.get_gui_text("unavailableQuestion")
		else:
			text += answers[i][0]
			text += "\n   "
			#text += right_answer[0]
			text += answers[i][1]
			text += "\n   "
			if answers[i][2] == "right":
				text += "[img]res://assets/game/right_answer_small.png[/img]"
			else:
				text += "[img]res://assets/game/wrong_answer_small.png[/img]"

		if i < nb - 1:
			text += "\n"

	get_node("details").set_bbcode(text)


func _on_draw():
	disconnect("draw", self, "_on_draw")

	### Récupération du score et affichage
	if get_parent().has_node("quiz"):
		var score = get_parent().get_node("quiz").get_score()
		var score_max = get_parent().get_node("quiz").get_score_max()
		get_node("result").set_text( str(score) + " / " + str(score_max) )

		if score == score_max and !global.get_state("perfectQuiz"):
			Globals.get("gameState")["perfectQuiz"] = true

		### On modifie "fill_degrees" et pas "value" parce que "value" est une clé de l'animation, et 
		### je n'arrive pas à modifier les clé dans le script
		### En modifiant "fill_degrees", on change le remplissage du camembert sans changer l'animation
		get_node("pie_chart").set_fill_degrees( score * 360 / score_max )
		get_node("AnimationPlayer").play("fill")
	
		var points = 0
		var moneySpent = 0
		var score_delta = get_parent().get_node("quiz").get_score_delta()
		if Globals.get("gameState").has("score_quiz"):
			points = int(Globals.get("gameState")["score_quiz"])
		if Globals.get("gameState").has("moneySpent"):
			moneySpent = int(Globals.get("gameState")["moneySpent"])
		maxi = float( points - moneySpent )
		mini = float( points - moneySpent - score_delta)
		get_node("AnimationPlayer").connect("finished", self, "_on_animation_finished")
		set_process(true)