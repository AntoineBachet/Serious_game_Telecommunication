extends Node2D

var language_riddle

func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"miniGameRoom", "type": "no_music"})

	set_process(true)

	### Ecriture de l'énigme
	var pianoKeys = global.get_gui_text("pianoKeys")
	var puzzle = global.get_riddle("piano")
	var answer = puzzle["answer"]
	var keys = answer.split(' ')
	
	language_riddle = settings.get_language()
	if !puzzle["riddle"].has(language_riddle):
		language_riddle = "fr"
	var text_entropie = "    "
	for i in keys:
		text_entropie += puzzle["riddle"][language_riddle][i]["info"] + "    "
	get_node("entropie").set_text(text_entropie)

	var language = settings.get_language()
	if !puzzle["probaTitle"].has(language):
		language = "fr"
	var text_proba = puzzle["probaTitle"][language] + "\n\n"
	var key_list = ["c1", "d1", "e1", "f1", "g1", "a1", "b1"]
	for i in range(7):
		if i == 4:
			text_proba += "\n\n"
		text_proba += pianoKeys[i] + " : " + puzzle["riddle"][language_riddle][key_list[i]]["proba"] + "         "
	get_node("proba").set_bbcode(text_proba)
	
	if !global.get_state("source_2_miniGameRoom_pianoSolved"):
		get_node("riddleOverlay").set_tip_list( [global.get_game_text("pianoTip"), global.get_game_text("pianoTip2")])


func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")