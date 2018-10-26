extends Control

var typedPassword = ""
var correctPassword

func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"secretroom"})

	set_process(true)

	#### Affichage et traduction des textes ####
	get_node("VBoxContainer/screen/VBoxContainer/tipButton").set_text(global.get_game_text("computerPuzzlePasswordForgottenButton"))
	get_node("VBoxContainer/screen/VBoxContainer/validateButton").set_text(global.get_game_text("computerPuzzleConnectButton"))
	var message = get_node("VBoxContainer/screen/VBoxContainer 2/PanelContainer/message")
	message.set_use_bbcode(true)
	message.set_bbcode(global.get_game_text("computerPuzzleMessage"))
	var welcomeText = get_node("VBoxContainer/screen/VBoxContainer/welcomeText")
	welcomeText.set_use_bbcode(true)
	welcomeText.set_bbcode(global.get_game_text("computerPuzzleWelcomeText"))

	get_node("riddleOverlay").set_tip(global.get_game_text("computerPuzzleTip"))

	#### Récupération de la solution de l'énigme ####
	var riddle = global.get_riddle("computer")
	correctPassword = riddle["answer"]

	#### Affichage du message ou de l'énigme ####
	if global.get_state("tutorial_1_secretroom_computerPuzzleSolved"):
		hideHome()
	else:
		get_node("VBoxContainer/screen/VBoxContainer 2").hide()

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		global.set_used_item("")

######## Clavier de l'ordinateur ########
func _on_shortButton_pressed():
	typedPassword = str(typedPassword,"*")
	updatePasswordDisplay()

func _on_longButton_pressed():
	typedPassword = str(typedPassword,"-")
	updatePasswordDisplay()

func _on_correctButton_pressed():
	typedPassword = typedPassword.substr(0, typedPassword.length()-1)
	updatePasswordDisplay()

func _on_spaceButton_pressed():
	if typedPassword != "" and typedPassword[typedPassword.length()-1] != " ":			#empêcher d'ajouter plusieurs espaces à la suite
		typedPassword = str(typedPassword," ")
	updatePasswordDisplay()

func updatePasswordDisplay():
	get_node("VBoxContainer/screen/VBoxContainer/passwordDisplay/passwordDisplay").set_text(typedPassword)
####################

######## Bouton Valider ########
func _on_validateButton_pressed():
	if typedPassword == correctPassword or typedPassword == str(correctPassword, " "):
		get_node("riddleOverlay").set_text("")
		global.set_state("tutorial_1_secretroom_computerPuzzleSolved", true)
		hideHome()
		global.unlock_location("ligne_1")
		global.unlock_location("source_1")
		global.unlock_location("canal_1")
		#player.play_sound("right") # il y a déjà le son de l'achievement, c'est bien assez
	else:
		player.play_sound("wrong")
####################

######## Bouton Mot de passe oublié ########
func _on_tipButton_pressed():
	get_node("VBoxContainer/screen/VBoxContainer/tip").set_text(global.get_game_text("computerPuzzlePasswordForgotten"))
####################

######## Bouton Tricher ########
func cheat():
	typedPassword = correctPassword
	updatePasswordDisplay()
####################

######## Cacher l'énigme et afficher le message ########
func hideHome():
	get_node("VBoxContainer/screen/VBoxContainer").hide()
	get_node("VBoxContainer/screen/VBoxContainer 2").show()
	get_node("VBoxContainer/keyboard/keyboard/HBoxContainer/correctButton").set_disabled(true)
	get_node("VBoxContainer/keyboard/keyboard/HBoxContainer/shortButton").set_disabled(true)
	get_node("VBoxContainer/keyboard/keyboard/HBoxContainer/longButton").set_disabled(true)
	get_node("VBoxContainer/keyboard/keyboard/spaceButton").set_disabled(true)
	get_node("riddleOverlay").disable_tip()
####################