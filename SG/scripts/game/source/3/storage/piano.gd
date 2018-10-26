extends Node2D

func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"storage", "type": "no_music"})
	set_process(true)

	#### Récupération de l'énigme
	var riddle = global.get_riddle("piano")["riddle"]
	get_node("musicSheet/riddle").set_bbcode(riddle)
	
	#### Récupération du codage
	var code = global.get_riddle("piano")["code"]
	var codage1 = ""
	var codage2 = ""
	var keys1 = ["c1", "d1", "e1", "f1"]
	var keys2 = ["g1", "a1", "b1", "c2"]
	for i in keys1:
		codage1 += "\n" + code[i][0] + " : " + code[i][1]
	for i in keys2:
		codage2 += "\n" + code[i][0] + " : " + code[i][1]
	
	get_node("code1").set_bbcode(codage1)
	get_node("code2").set_bbcode(codage2)

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")