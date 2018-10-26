
extends Node

var selectedButtons=[]
var selectedButtonsColumn=[]
var selectedButtonsRow=[]
var allButtons=[]
var cartes =[]
var carteADeviner

var allPressed=false
var pique = preload("res://assets/game/source/2/casino/pique.png")
var carreau = preload("res://assets/game/source/2/casino/carreau.png")
var coeur = preload("res://assets/game/source/2/casino/coeur.png")
var trefle = preload("res://assets/game/source/2/casino/trefle.png")

var disabledButtonsCounter = 0
var questionAsked = 0


func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"casino"})

	#### Affichage et traduction des textes ####
	get_node("Label").set_use_bbcode(true)
	get_node("Label").set_bbcode(str("[center]",global.get_game_text("cardRiddleQuestion"),"[/center]"))
	get_node("Check").set_text(global.get_game_text("diceRiddleAsk"))
	
	
	get_node("riddleOverlay").set_tip( global.get_game_text("cardRiddleTip") )

	# Création des cartes
	var cartesButton = get_node("Cartes")
	cartesButton.set_columns(9)
	for j in range(1,6): #4 lignes pour les couleurs plus une pour sélectionner directement plusieurs cartes de même valeurs
		for i in range(0,9): #La colonne 0 est pour la sélection de couleur en entier, les 8 autres sont pour les valeurs des couleurs
			var answerButton = Button.new()
			answerButton.set_default_cursor_shape(2)
			if j==1:
				if i==0: # La première colonne sert à sélectionner entièrement une couleur
					answerButton.set_button_icon(pique)
					answerButton.set_name("Pique")
					answerButton.connect("pressed", self, "_answerButtonRow_pressed", [answerButton])
					answerButton.add_to_group("color")
				else :
					var val = str(i+6)
					if val == "11":
						val = "J"
					elif val == "12":
						val = "Q"
					elif val == "13":
						val = "K"
					elif val == "14":
						val = "A"
					answerButton.set_text(val)
					answerButton.connect("pressed", self, "_answerButton_pressed", [answerButton])
					answerButton.set_name(str(i)+ " Pique")
					answerButton.set_button_icon(pique)
					cartes.append(answerButton)
					answerButton.add_to_group("Pique")
					answerButton.add_to_group(str(i))
					

			elif j==2 :
				if i==0:
					answerButton.set_button_icon(carreau)
					answerButton.set_name("Carreau")
					answerButton.connect("pressed", self, "_answerButtonRow_pressed", [answerButton])
					answerButton.add_to_group("color")
				else:
					var val = str(i+6)
					if val == "11":
						val = "J"
					elif val == "12":
						val = "Q"
					elif val == "13":
						val = "K"
					elif val == "14":
						val = "A"
					answerButton.set_text(val)
					answerButton.connect("pressed", self, "_answerButton_pressed", [answerButton])
					answerButton.set_name(str(i)+ " Carreau")
					answerButton.set_button_icon(carreau)
					cartes.append(answerButton)
					answerButton.add_to_group("Carreau")
					answerButton.add_to_group(str(i))

			elif j==3 :
				if i==0:
					answerButton.set_button_icon(coeur)
					answerButton.set_name("Coeur")
					answerButton.connect("pressed", self, "_answerButtonRow_pressed", [answerButton])
					answerButton.add_to_group("color")
				else:
					var val = str(i+6)
					if val == "11":
						val = "J"
					elif val == "12":
						val = "Q"
					elif val == "13":
						val = "K"
					elif val == "14":
						val = "A"
					answerButton.set_text(val)
					answerButton.connect("pressed", self, "_answerButton_pressed", [answerButton])
					answerButton.set_name(str(i)+ " Coeur")
					answerButton.set_button_icon(coeur)
					cartes.append(answerButton)
					answerButton.add_to_group("Coeur")
					answerButton.add_to_group(str(i))

			elif j==4:
				if i==0:
					answerButton.set_button_icon(trefle)
					answerButton.set_name("Trefle")
					answerButton.connect("pressed", self, "_answerButtonRow_pressed", [answerButton])
					answerButton.add_to_group("color")
				else:
					var val = str(i+6)
					if val == "11":
						val = "J"
					elif val == "12":
						val = "Q"
					elif val == "13":
						val = "K"
					elif val == "14":
						val = "A"
					answerButton.set_text(val)
					answerButton.connect("pressed", self, "_answerButton_pressed", [answerButton])
					answerButton.set_name(str(i)+ " Trefle")
					answerButton.set_button_icon(trefle)
					cartes.append(answerButton)
					answerButton.add_to_group("Trefle")
					answerButton.add_to_group(str(i))
			
			else : # La dernière ligne sert à sélectionner toutes les cartes d'une même valeur
				if i==0: # Ce bouton sert à tout sélectionner / tout déselectionner
					answerButton.set_text(global.get_game_text("cardRiddleAllButton"))
					answerButton.set_name("All")
					answerButton.connect("pressed", self, "_answerButtonAll_pressed", [answerButton])
				else :
					var val = str(i+6)
					if val == "11":
						val = "J"
					elif val == "12":
						val = "Q"
					elif val == "13":
						val = "K"
					elif val == "14":
						val = "A"
					answerButton.set_text(val)
					answerButton.connect("pressed", self, "_answerButtoncolumn_pressed", [answerButton])
					answerButton.set_name(str(i))
					answerButton.set_text_align(2)
					answerButton.add_to_group("value")
			allButtons.append(answerButton)
			answerButton.set_flat(true)
			cartesButton.add_child(answerButton)
	
	### On va choisir une carte au hasard à deviner parmi les 36 cartes
	randomize()
	var nbCartes = cartes.size()
	carteADeviner = randi()%nbCartes
	print(cartes[carteADeviner].get_name())
	
	set_process(true)
########################################

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

### Fonction qui vérifie si le bouton à ajouter est déjà dans la liste (Ex. Ajout de 3 pique par la sélection rapide de tous les 3, puis ajout du 3 pique en cliquant dessus)
func addButtontoselectedButtons(buttonName):
	if !(buttonName in selectedButtons):
		selectedButtons.append(buttonName)
	#var alreadyInList = false
	#for i in range(selectedButtons.size()):
	#	if selectedButtons[i]==buttonName:
	#		alreadyInList = true
	#if alreadyInList==false:
	#	selectedButtons.append(buttonName)

### Appuyer sur un bouton sans passer par la sélection rapide par couleur ou valeur
func _answerButton_pressed(button):
	var buttonName = button.get_name()
	if !(buttonName in selectedButtons):
		button.set_flat(false)
		button.add_color_override("font_color", Color(0,1,0,1))
		
		addButtontoselectedButtons(buttonName)
	else:
		button.set_flat(true)
		button.add_color_override("font_color", Color(1,1,1,1))
		selectedButtons.remove(selectedButtons.find(buttonName))
		
### Sélection rapide par valeur
func _answerButtoncolumn_pressed(button):
		var buttonName = button.get_name()
		### Sélection
		if !(buttonName in selectedButtonsColumn): ### Pour retenir quels colonnes sont sélectionnées ou non
			selectedButtonsColumn.append(buttonName)
			button.set_flat(false)
			button.add_color_override("font_color", Color(0,1,0,1))
			for b in get_tree().get_nodes_in_group(buttonName):
				b.set_flat(false)
				b.add_color_override("font_color", Color(0,1,0,1))
				addButtontoselectedButtons(b.get_name())
				
			#for i in range(cartes.size()): ### Pour toutes les cartes on regarde si le nom de la colonne apparait dans le nom de la carte (Ex. Pique apparait dans 3 Pique)
			#	if cartes[i].get_name().find(buttonName) != -1 :
			#		cartes[i].set_flat(false)
			#		addButtontoselectedButtons(cartes[i].get_name())
		
		### Déselection
		else:
			button.set_flat(true)
			button.add_color_override("font_color", Color(1,1,1,1))
			selectedButtonsColumn.remove(selectedButtonsColumn.find(buttonName))
			
			for b in get_tree().get_nodes_in_group(buttonName):
				b.set_flat(true)
				b.add_color_override("font_color", Color(1,1,1,1))
				selectedButtons.remove(selectedButtons.find(b.get_name()))
			
				for c in get_tree().get_nodes_in_group("color"):
					if !c.is_flat() and b.is_in_group( c.get_name() ): ## Si une ligne est sélectionne, on ne déselectionne pas la carte à l'intersection
						b.set_flat(false)
						b.add_color_override("font_color", Color(0,1,0,1))
						addButtontoselectedButtons( b.get_name() )
			
			#for i in range(cartes.size()):
			#	if cartes[i].get_name().find(buttonName) != -1 :
			#		cartes[i].set_flat(true)
			#		selectedButtons.remove(selectedButtons.find(cartes[i].get_name()))

### Sélection rapide par couleur
func _answerButtonRow_pressed(button):
		var buttonName = button.get_name()
		
		if !(buttonName in selectedButtonsRow):
			button.set_flat(false)
			button.add_color_override("font_color", Color(0,1,0,1))
			selectedButtonsRow.append(buttonName)
			
			for b in get_tree().get_nodes_in_group( buttonName ):
				b.set_flat(false)
				b.add_color_override("font_color", Color(0,1,0,1))
				addButtontoselectedButtons(b.get_name())
			
			#for i in range(cartes.size()):
			#	if cartes[i].get_name().find(buttonName) != -1 :
			#		cartes[i].set_flat(false)
			#		addButtontoselectedButtons(cartes[i].get_name())
		else:
			button.set_flat(true)
			button.add_color_override("font_color", Color(1,1,1,1))
			selectedButtonsRow.remove(selectedButtonsRow.find(buttonName))
			
			for b in get_tree().get_nodes_in_group(buttonName):
				b.set_flat(true)
				b.add_color_override("font_color", Color(1,1,1,1))
				selectedButtons.remove(selectedButtons.find(b.get_name()))
			
				for v in get_tree().get_nodes_in_group("value"):
					if !v.is_flat() and b.is_in_group( v.get_name() ): ## Si une ligne est sélectionne, on ne déselectionne pas la carte à l'intersection
						b.set_flat(false)
						b.add_color_override("font_color", Color(0,1,0,1))
						addButtontoselectedButtons( b.get_name() )
			
			#for i in range(cartes.size()):
			#	if cartes[i].get_name().find(buttonName) != -1 :
			#		cartes[i].set_flat(true)
			#		selectedButtons.remove(selectedButtons.find(cartes[i].get_name()))
			

func _answerButtonAll_pressed(button):
	if allPressed == false :
		allPressed = true
		button.set_flat(false)
		for i in range(cartes.size()):
			cartes[i].set_flat(false)
			cartes[i].add_color_override("font_color", Color(0,1,0,1))
			addButtontoselectedButtons(cartes[i].get_name())
	else :
		allPressed = false
		button.set_flat(true)
		button.add_color_override("font_color", Color(0,1,0,1))
		for i in range(cartes.size()):
			cartes[i].set_flat(true)
			cartes[i].add_color_override("font_color", Color(1,1,1,1))
			selectedButtons.remove(selectedButtons.find(cartes[i].get_name()))
		
		### On remet les cartes dont les colonnes / lignes sont sélectionnées
		for buttonColumn in selectedButtonsColumn:
			for b in get_tree().get_nodes_in_group(buttonColumn):
				b.set_flat(false)
				b.add_color_override("font_color", Color(0,1,0,1))
				addButtontoselectedButtons(b.get_name())
		for buttonRow in selectedButtonsRow:
			for b in get_tree().get_nodes_in_group(buttonRow):
				b.set_flat(false)
				b.add_color_override("font_color", Color(0,1,0,1))
				addButtontoselectedButtons(b.get_name())

func _on_Check_pressed():
	if selectedButtons.size() > 0:
		questionAsked += 1

		var boolean=false
		var size=selectedButtons.size()
		for i in range(selectedButtons.size()):
			if selectedButtons[i]==cartes[carteADeviner].get_name():
				boolean=true

		if boolean == true :
			get_node("riddleOverlay").set_text("")
			get_node("riddleOverlay").set_text( global.get_game_text("cardRiddleYes"))
			for i in range(cartes.size()):
				if !cartes[i].is_disabled():
					if !(cartes[i].is_in_group("color") or cartes[i].is_in_group("value")):
						if !(cartes[i].get_name() in selectedButtons):
							cartes[i].set_disabled(true)
							cartes[i].set_default_cursor_shape(0)
							disabledButtonsCounter += 1

		else :
			get_node("riddleOverlay").set_text("")
			get_node("riddleOverlay").set_text( global.get_game_text("cardRiddleNo"))
			for i in range(cartes.size()):
				if !cartes[i].is_disabled():
					if !(cartes[i].is_in_group("color") or cartes[i].is_in_group("value")):
						if cartes[i].get_name() in selectedButtons:
							cartes[i].set_disabled(true)
							cartes[i].set_default_cursor_shape(0)
							disabledButtonsCounter += 1

		#### Désactivation des boutons lignes/colonnes si toute la ligne/colonne est désactivée
		for c in get_tree().get_nodes_in_group("color"):
			if !c.is_disabled():
				var disable = true
				for b in get_tree().get_nodes_in_group( c.get_name() ):
					if !b.is_disabled():
						disable = false
				if disable:
					c.set_disabled(true)
					c.set_default_cursor_shape(0)
		for v in get_tree().get_nodes_in_group("value"):
			if !v.is_disabled():
				var disable = true
				for b in get_tree().get_nodes_in_group( v.get_name() ):
					if !b.is_disabled():
						disable = false
				if disable:
					v.set_disabled(true)
					v.set_default_cursor_shape(0)
		
		#### Suppression de la sélection
		selectedButtons=[]
		selectedButtonsColumn=[]
		selectedButtonsRow=[]
		for i in range(allButtons.size()):
			allButtons[i].set_flat(true)
			allButtons[i].add_color_override("font_color", Color(1,1,1,1))
		if disabledButtonsCounter == 31:
			_riddle_solved()
		elif questionAsked == 5: ### Il faut recommencer
			player.play_sound("wrong")
			get_node("riddleOverlay").set_text( global.get_game_text("cardRiddleFail") )
			reset_card()


func _riddle_solved():
	global.set_state("source_2_casino_cardRiddleSolved", true)
	get_node("riddleOverlay").set_text(global.get_game_text("cardRiddleSolved"))
	global.give_item("source_2_casino_cardToken")
	get_node("riddleOverlay").riddle_solved(2)

func cheat():
	_riddle_solved()

func reset_card():
	disabledButtonsCounter = 0
	selectedButtons=[]
	selectedButtonsColumn=[]
	selectedButtonsRow=[]
	for i in range(allButtons.size()):
		allButtons[i].set_flat(true)
		allButtons[i].add_color_override("font_color", Color(1,1,1,1))
		if allButtons[i].is_disabled():
			allButtons[i].set_disabled(false)
	
	randomize()
	var nbCartes = cartes.size()
	carteADeviner = randi()%nbCartes
	print(cartes[carteADeviner].get_name())