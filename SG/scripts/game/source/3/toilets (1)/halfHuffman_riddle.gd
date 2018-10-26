extends Node2D

var goodAnswer
var playerAnswer
var riddle
var halfHuffman
var language

func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"toilets"})
	set_process(true)

	#### Récupération de l'énigme ####
	halfHuffman = global.get_riddle("halfHuffman_riddle")
	riddle = halfHuffman["riddle"]
	goodAnswer = halfHuffman["answer"]
	
	#### Réponse du joueur
	playerAnswer = ""
	
	#### Affichage des textes
	get_node("Control/binaryText").set_text(riddle)
	get_node("riddleOverlay").set_tip(global.get_game_text("halfHuffmanRiddleTip"))
	get_node("Control/deleteButton").set_text(global.get_gui_text("deleteButton"))
	get_node("Control/validateButton").set_text(global.get_gui_text("validateButton"))

	#### Curseurs ####
	get_node("Control/deleteButton").set_default_cursor_shape(2)
	get_node("Control/validateButton").set_default_cursor_shape(2)

func displayPlayerAnswer():
	get_node("Control/Panel/display").set_text(playerAnswer)

func pressButton(button):
	playerAnswer = playerAnswer + button
	displayPlayerAnswer()

func _on_plus_pressed():
	pressButton(halfHuffman["plus"])
func _on_fois_pressed():
	pressButton(halfHuffman["fois"])
func _on_rond_pressed():
	pressButton(halfHuffman["rond"])
func _on_diese_pressed():
	pressButton(halfHuffman["diese"])
func _on_star_pressed():
	pressButton(halfHuffman["star"])

func _on_deleteButton_pressed():
	playerAnswer.erase(playerAnswer.length()-1,1)
	displayPlayerAnswer()
	print(playerAnswer)


func _on_validateButton_pressed():
	if playerAnswer == goodAnswer:
		#player.play_sound("right")
		global.set_state("source_3_toilets_halfHuffmanRiddleSolved", true)
		global.give_item("source_3_toilets_firstAidKit")
		get_node("riddleOverlay").set_text(global.get_game_text("halfHuffmanRiddleGood"))
		get_node("riddleOverlay").riddle_solved()
	else:
		get_node("riddleOverlay").set_text(global.get_game_text("halfHuffmanRiddleWrong"))
		player.play_sound("wrong")
		playerAnswer = ""
		displayPlayerAnswer()

func cheat():
	playerAnswer = goodAnswer
	displayPlayerAnswer()