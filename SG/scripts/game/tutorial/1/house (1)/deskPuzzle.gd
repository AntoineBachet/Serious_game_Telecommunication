extends Control

var correctAnswer

######## initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"house"})

	set_process(true)
#	set_process_input(true)

	#### Affichage/traduction des textes ####
	get_node("riddleOverlay").set_tip(global.get_game_text("deskPuzzleTip"))

	#### Récupération de la réponse de l'énigme ####
	var answers = global.get_riddle("desk")["answers"]
	var randomNumber

	if !global.get_state("tutorial_1_house_deskPuzzleRandomNumber"):
		randomize()
		randomNumber = randi() % answers.size()
		global.set_state("tutorial_1_house_deskPuzzleRandomNumber", str(randomNumber))

	correctAnswer = answers[int(global.get_state("tutorial_1_house_deskPuzzleRandomNumber"))]

	get_node("codepad").connect("", self, "")
	get_node("codepad").set_code(correctAnswer)
	get_node("codepad").connect("right_input", self, "win")
	get_node("codepad").set_max_size(correctAnswer.length())
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		global.set_used_item("")

######## Retour vers l'écran précédent après résolution ########
func win():
	print("a")
	global.set_state("tutorial_1_house_deskPuzzleSolved", true)
	global.load_scene()
####################

######## Bouton de triche ########
func cheat():
	get_node("codepad").set_input(correctAnswer)
####################