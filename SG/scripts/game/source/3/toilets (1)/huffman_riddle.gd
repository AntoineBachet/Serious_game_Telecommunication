extends Node2D

var n2
var m

var firstButtonPressed = ""
var firstButtonPosition
var secondButtonPressed = ""
var secondButtonPosition
var mouse_pos

var proba =[0.42,0.2,0.15,0.12,0.06,0.05]

# Pour update du schéma
var drawList =[] #Contient les couples de positions
var nbTrait

# Générer la grille, les images
var n
var nbColonne = 10
var nbLigne = 14
var espaceColonne = 60
var espaceLigne = 60
var grille =[]
var boutons
var tuyaux = [[[13,0],"straight",0.5],[[11,0],"straight",0.5],[[9,0],"straight",0.5],[[8,0],"straight",0.5],[[6,0],"straight",0.5],[[2,0],"straight",0.5],[[12,1], "bent", 0], [[12,1], "bent", 0.5],[[12,2], "bent", 1],[[9,2], "bent", 1.5],[[10,3], "bent", 1],[[5,4], "straight", 1.5],[[2,4], "straight", 0.5],[[7,5], "bent", 1],[[3,6], "bent", 1.5],[[0,8], "bent", 1.5],[[1,9.5], "straight", 0.5]]
# bent : droite
# 0.5 pour tourner de pi/2

# Vérifier
var isCorrect
var greenList = []
var isGreen
var greenListSize = 0
var nbTraitsMax = 54
var answerList = [[Vector2(140, 800), Vector2(200, 800)], [Vector2(200, 800), Vector2(200, 860)], [Vector2(200, 860), Vector2(200, 920)], [Vector2(200, 920), Vector2(140, 920)], [Vector2(200, 860), Vector2(260, 860)], [Vector2(260, 680), Vector2(260, 740)], [Vector2(260, 740), Vector2(260, 800)], [Vector2(260, 800), Vector2(260, 860)], [Vector2(140, 680), Vector2(200, 680)], [Vector2(200, 680), Vector2(260, 680)], [Vector2(260, 740), Vector2(320, 740)], [Vector2(140, 620), Vector2(200, 620)], [Vector2(200, 620), Vector2(260, 620)], [Vector2(260, 620), Vector2(320, 620)], [Vector2(320, 620), Vector2(380, 620)], [Vector2(380, 500), Vector2(380, 560)], [Vector2(380, 560), Vector2(380, 620)], [Vector2(140, 500), Vector2(200, 500)], [Vector2(200, 500), Vector2(260, 500)], [Vector2(260, 500), Vector2(320, 500)], [Vector2(320, 500), Vector2(380, 500)], [Vector2(320, 440), Vector2(320, 500)], [Vector2(320, 500), Vector2(320, 560)], [Vector2(320, 560), Vector2(320, 620)], [Vector2(320, 620), Vector2(320, 680)], [Vector2(320, 680), Vector2(320, 740)], [Vector2(380, 560), Vector2(440, 560)], [Vector2(320, 440), Vector2(380, 440)], [Vector2(380, 440), Vector2(440, 440)], [Vector2(440, 440), Vector2(500, 440)], [Vector2(440, 320), Vector2(440, 380)], [Vector2(440, 380), Vector2(440, 440)], [Vector2(440, 440), Vector2(440, 500)], [Vector2(440, 500), Vector2(440, 560)], [Vector2(440, 320), Vector2(500, 320)], [Vector2(500, 320), Vector2(500, 380)], [Vector2(500, 380), Vector2(500, 440)], [Vector2(500, 380), Vector2(560, 380)], [Vector2(140, 260), Vector2(200, 260)], [Vector2(200, 260), Vector2(260, 260)], [Vector2(260, 260), Vector2(320, 260)], [Vector2(320, 260), Vector2(380, 260)], [Vector2(380, 260), Vector2(440, 260)], [Vector2(440, 260), Vector2(500, 260)], [Vector2(500, 260), Vector2(560, 260)], [Vector2(560, 260), Vector2(620, 260)], [Vector2(560, 140), Vector2(560, 200)], [Vector2(560, 200), Vector2(560, 260)], [Vector2(560, 260), Vector2(560, 320)], [Vector2(560, 320), Vector2(560, 380)], [Vector2(560, 140), Vector2(620, 140)], [Vector2(620, 140), Vector2(620, 200)], [Vector2(620, 200), Vector2(620, 260)], [Vector2(620, 200), Vector2(680, 200)]]
#[[Vector2(215, 695), Vector2(295, 695)], [Vector2(295, 695), Vector2(295, 775)], [Vector2(295, 775), Vector2(295, 855)], [Vector2(295, 855), Vector2(215, 855)], [Vector2(295, 775), Vector2(375, 775)], [Vector2(375, 615), Vector2(375, 695)], [Vector2(375, 695), Vector2(375, 775)], [Vector2(215, 615), Vector2(295, 615)], [Vector2(295, 615), Vector2(375, 615)], [Vector2(375, 695), Vector2(455, 695)], [Vector2(455, 535), Vector2(455, 615)], [Vector2(455, 615), Vector2(455, 695)], [Vector2(455, 215), Vector2(455, 295)], [Vector2(455, 295), Vector2(455, 375)], [Vector2(455, 375), Vector2(455, 455)], [Vector2(455, 455), Vector2(455, 535)], [Vector2(455, 215), Vector2(535, 215)], [Vector2(215, 375), Vector2(295, 375)], [Vector2(295, 375), Vector2(375, 375)], [Vector2(375, 375), Vector2(455, 375)], [Vector2(455, 375), Vector2(535, 375)], [Vector2(535, 375), Vector2(535, 455)], [Vector2(535, 455), Vector2(535, 535)], [Vector2(215, 535), Vector2(295, 535)], [Vector2(295, 535), Vector2(375, 535)], [Vector2(375, 535), Vector2(455, 535)], [Vector2(455, 535), Vector2(535, 535)], [Vector2(535, 455), Vector2(615, 455)], [Vector2(615, 215), Vector2(615, 295)], [Vector2(615, 295), Vector2(615, 375)], [Vector2(615, 375), Vector2(615, 455)], [Vector2(615, 215), Vector2(535, 215)], [Vector2(615, 295), Vector2(695, 295)], [Vector2(695, 135), Vector2(695, 215)], [Vector2(695, 215), Vector2(695, 295)], [Vector2(215, 135), Vector2(295, 135)], [Vector2(295, 135), Vector2(375, 135)], [Vector2(375, 135), Vector2(455, 135)], [Vector2(455, 135), Vector2(535, 135)], [Vector2(535, 135), Vector2(615, 135)], [Vector2(615, 135), Vector2(695, 135)], [Vector2(695, 215), Vector2(775, 215)]]
# [[Vector2(230, 710), Vector2(310, 710)], [Vector2(310, 710), Vector2(310, 790)], [Vector2(310, 790), Vector2(310, 870)], [Vector2(310, 870), Vector2(230, 870)], [Vector2(310, 790), Vector2(390, 790)], [Vector2(390, 630), Vector2(390, 710)], [Vector2(390, 710), Vector2(390, 790)], [Vector2(230, 630), Vector2(310, 630)], [Vector2(310, 630), Vector2(390, 630)], [Vector2(390, 710), Vector2(470, 710)], [Vector2(470, 230), Vector2(470, 310)], [Vector2(470, 310), Vector2(470, 390)], [Vector2(470, 390), Vector2(470, 470)], [Vector2(470, 470), Vector2(470, 550)], [Vector2(470, 550), Vector2(470, 630)], [Vector2(470, 630), Vector2(470, 710)], [Vector2(470, 230), Vector2(550, 230)], [Vector2(550, 230), Vector2(630, 230)], [Vector2(630, 230), Vector2(630, 310)], [Vector2(630, 310), Vector2(630, 390)], [Vector2(630, 390), Vector2(630, 470)], [Vector2(630, 470), Vector2(550, 470)], [Vector2(550, 470), Vector2(550, 390)], [Vector2(230, 390), Vector2(310, 390)], [Vector2(310, 390), Vector2(390, 390)], [Vector2(390, 390), Vector2(470, 390)], [Vector2(470, 390), Vector2(550, 390)], [Vector2(230, 550), Vector2(310, 550)], [Vector2(310, 550), Vector2(390, 550)], [Vector2(390, 550), Vector2(470, 550)], [Vector2(470, 550), Vector2(550, 550)], [Vector2(550, 550), Vector2(550, 470)], [Vector2(230, 150), Vector2(310, 150)], [Vector2(310, 150), Vector2(390, 150)], [Vector2(390, 150), Vector2(470, 150)], [Vector2(470, 150), Vector2(550, 150)], [Vector2(550, 150), Vector2(630, 150)], [Vector2(630, 150), Vector2(710, 150)], [Vector2(710, 150), Vector2(710, 230)], [Vector2(710, 230), Vector2(710, 310)], [Vector2(710, 310), Vector2(630, 310)], [Vector2(710, 230), Vector2(790, 230)]]
# Compression et Decompression
var liste
var pointsAEnlever =[]
var listeCompression=[]

var buttonSize = 30


func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"toilets"})

	#### Affichage et traduction des textes ####
	get_node("riddleOverlay").set_tip(global.get_game_text("huffmanRiddleTip"))
	get_node("Label").set_text(global.get_game_text("huffmanRiddle"))
	get_node("Effacer").set_text( global.get_game_text("huffmanRiddleEraseAll") )
	get_node("Verif").set_text( global.get_gui_text("validateButton") )

	#### Curseurs ####
	get_node("Effacer").set_default_cursor_shape(2)
	get_node("Verif").set_default_cursor_shape(2)

	get_node("Verif").connect("pressed", self, "_on_Verif_pressed")
	get_node("Effacer").connect("pressed", self, "_on_Effacer_pressed")

	# On génère la grille (composée de boutons) sur laquelle le joueur doit construire son arbre de Huffman
	var boutons = get_node("BoutonsContainer")
	for i in range(0,nbColonne):
		for j in range(0,nbLigne):
			
			grille = grille + [[Vector2(155+i*espaceColonne,155), Vector2(155+i*espaceColonne,155+espaceLigne*(nbLigne-1))]]
			grille = grille + [[Vector2(155,155+j*espaceLigne), Vector2(155+espaceColonne*(nbColonne-1),155+j*espaceLigne)]]
			
			var node = Button.new()

			node.set_size(Vector2(buttonSize, buttonSize))
			node.set_pos(Vector2(155+i*espaceColonne-buttonSize/2,155+j*espaceLigne-buttonSize/2)) 
			node.set_name("button"+str(i)+str(j))
			node.connect("pressed", self, "_nodeButton_pressed", [node])
			node.set_flat(true)
			boutons.add_child(node)
			
	# Création des label pour afficher les proba
	for j in range(0,6): #nb de proba à déterminer
		var label = Label.new()
		label.set_text(str(proba[j]))
		label.set_pos(Vector2(85,210+(j+1)*espaceLigne*2))
		if j==2:
			label.set_pos(Vector2(85,210+(j+1)*espaceLigne*2+espaceLigne))
		if j==1:
			label.set_pos(Vector2(85,210+(j+1)*espaceLigne*2+espaceLigne))
		if j==0:
			label.set_pos(Vector2(85,210+(j+1)*espaceLigne))
		boutons.add_child(label)

	
		
	var canalAngle = preload("res://assets/game/source/3/toilets/canal2.png")
	var canalDroit = preload("res://assets/game/source/3/toilets/canal1.png")
	addImageToNode(tuyaux)
	
	nbTrait=nbTraitsMax
	set_process(true)
	
	get_node("howTo").set_bbcode(global.get_game_text("huffmanHowToFix"))
	
################################################## FONCTIONS DE CONSTRUCTION 
	
func addImageToNode(liste): # Cette fonction sert à ajouter des images de des embranchements
# liste -> [([i,j] (nb du noeud), position, rotate]
	var boutons = get_node("BoutonsContainer")
	n = liste.size()
	var canalAngle = preload("res://assets/game/source/3/toilets/canal2.png")
	var canalDroit = preload("res://assets/game/source/3/toilets/canal1.png")
	
	for i in range (0,n):
		var node = Sprite.new()
		boutons.add_child(node)
		if liste[i][1]=="straight":
			node.set_texture(canalDroit) 
			node.set_pos(Vector2(155+liste[i][0][1]*espaceLigne,155+liste[i][0][0]*espaceColonne))
			node.set_scale(Vector2(0.7,0.7))
		if liste[i][1]=="bent":
			node.set_texture(canalAngle)
			node.set_pos(Vector2(155+liste[i][0][1]*espaceLigne,155+liste[i][0][0]*espaceColonne))
			node.set_scale(Vector2(0.7,0.7))
		node.rotate(3.14*liste[i][2])
		
	

func _process(delta):
	update() #La fonction _draw s'appelle grace à update
	
	
############ INPUT BUTTON
func _nodeButton_pressed(button):
		if button.get_name()==firstButtonPressed : #Annuler la sélection du premier bouton
			firstButtonPressed = ""
		elif firstButtonPressed == "":
			firstButtonPressed = button.get_name()
			firstButtonPosition = button.get_pos()
		elif firstButtonPressed != "" and secondButtonPressed == "":
			secondButtonPressed = button.get_name()
			secondButtonPosition = button.get_pos()
		
		
########## UPDATE DU SCHEMA
func _draw():
	n = drawList.size() 
	n2=grille.size()
	get_node("nbTrait").set_text(global.get_game_text("huffmanFreePipes")+str(nbTrait))

	#On retient ce qu'il faut garder à l'écran
	for i in range (0,n) : #Et on les dessine
		
		isGreen = false
		for j in range(0,greenList.size()):
			if drawList[i]==greenList[j] or drawList[i] == [greenList[j][1],greenList[j][0]]: #Si le point de drawList est dans greenList, on va colorier en vert
				isGreen = true
		if isGreen == true :
			draw_line(drawList[i][0]+Vector2(buttonSize/2,buttonSize/2), drawList[i][1] +Vector2(buttonSize/2, buttonSize/2), Color(0, 255, 0), 10)
		else :	
			draw_line(drawList[i][0]+Vector2(buttonSize/2,buttonSize/2), drawList[i][1] +Vector2(buttonSize/2, buttonSize/2), Color(255, 0, 0), 10)
	
	for i in range (0,n2) : #Dessin de la grille
		draw_line(grille[i][0], grille[i][1] , Color(0, 0, 0), 1)
		
	if (firstButtonPressed != "" and secondButtonPressed == ""): #Si un seul bouton est cliqué, le trait rouge suit la souris
		mouse_pos = get_local_mouse_pos ( ) 
		draw_line(firstButtonPosition+Vector2(buttonSize/2,buttonSize/2), mouse_pos , Color(255, 0, 0), 10)
		
		
		
	elif (firstButtonPressed != "" and secondButtonPressed != ""):
		if firstButtonPosition[0]==secondButtonPosition[0] or firstButtonPosition[1]==secondButtonPosition[1] :
			liste = decompression([firstButtonPosition, secondButtonPosition]) # 1--3 devient 1--2--3
			
			n = drawList.size()
			m = liste.size()
			
			if drawList.size()!=0:
				if true:
					pointsAEnlever =[]
					for i in range (0,m): #Pour tous les points de 1--2--3--4
						var alreadyInDrawList = false
						for j in range (0,n): #On compare à drawList et on cherche les points à enlever
							
							if drawList[j] == liste[i] or drawList[j] == [liste[i][1],liste[i][0]] : 
								pointsAEnlever.append(j) #On retient les index à enlever (on enlève pas directement le point pour pas avoir des soucis de variations de n
								alreadyInDrawList=true
								break #On arrête la boucle for pour j
						if alreadyInDrawList == false: # Si le point n'est pas dans drawList, on l'ajoute à la fin
								drawList.append(liste[i])
								nbTrait=nbTrait-1
							
					for i in range (0,pointsAEnlever.size()):
						drawList.remove(pointsAEnlever[pointsAEnlever.size()-i-1]) #On enlève d'abord les index les plus gros pour ne pas modifier les autres index)
						nbTrait=nbTrait+1
				else :
					pass
			else:
				drawList=liste
				nbTrait=nbTraitsMax-liste.size()
		
		if nbTrait<=0:
			get_node("riddleOverlay").set_text(global.get_game_text("huffmanNoPipes"))
			while nbTrait<0:
				drawList.remove(drawList.size()-1)
				nbTrait=nbTrait+1

		firstButtonPressed = ""
		secondButtonPressed = ""
		

	
func decompression(couple): # 1--3 devient 1-2-3
	var liste = []
	if couple[0][0]==couple[1][0]:
		#Alignés verticalement
		if abs(couple[1][1]-couple[0][1]) > espaceColonne:
			n = abs(couple[1][1]-couple[0][1])/espaceColonne
			for i in range (0,n):
				if couple[0][1]<couple[1][1]:
					liste.append([Vector2(couple[0][0],(couple[0][1]+i*espaceColonne)),Vector2(couple[0][0],(couple[0][1]+(i+1)*espaceColonne))])
				else:
					liste.append([Vector2(couple[0][0],(couple[1][1]+i*espaceColonne)),Vector2(couple[0][0],(couple[1][1]+(i+1)*espaceColonne))])
		else:
			liste.append(couple)
			
		return liste
			
	elif couple[0][1]==couple[1][1]: #Horizontal
		if abs(couple[0][0]-couple[1][0]) > espaceLigne:
			n = abs(couple[0][0]-couple[1][0])/espaceLigne 
			for i in range (0,n):
				if couple[0][0]<couple[1][0]:
					liste.append([Vector2((couple[0][0]+i*espaceLigne),couple[0][1]),Vector2((couple[0][0]+(i+1)*espaceLigne),couple[0][1])])
				else:
					liste.append([Vector2((couple[1][0]+i*espaceLigne),couple[0][1]),Vector2((couple[1][0]+(i+1)*espaceLigne),couple[0][1])])
			return liste
		else : 
			liste.append(couple)
			return liste




func compression(listeCompression): #1-2-3 devient 1--3
	n = listeCompression.size()
	
	for i in range (0,n):
		for j in range(0,n):
			if i!=j:
				if aligned(listeCompression[i], listeCompression[j]) and commonPoint(listeCompression[i], listeCompression[j]):
					fusionner(listeCompression, listeCompression[i], listeCompression[j])
					if i<j: #On supprime de la liste les points avant fusion (on supprimer d'abord l'index le plus grand)
						listeCompression.remove(i)
						listeCompression.remove(j-1)
					else :
						listeCompression.remove(j)
						listeCompression.remove(i-1)
					return false
	return true


#####VERIFICATION
func _on_Verif_pressed(): 
	m = answerList.size()
	n = drawList.size()
	isCorrect=true
	greenList=[]
	greenListSize=0
	if n==0:
		isCorrect=false
	for j in range(m): #Verif des traits
		var verif = false
		for i in range(n):
			if drawList[i]==answerList[j] or drawList[i] == [answerList[j][1],answerList[j][0]]:
				verif = true
				greenList.append(drawList[i]) #Si le trait est bon, on doit le colorier en vert
				greenListSize=greenListSize+1
		if !verif:
			isCorrect = false
	if isCorrect == true :
		_riddle_solved()
	else :
		player.play_sound("wrong")
		if greenListSize > 0:
			get_node("riddleOverlay").set_tip(global.get_game_text("huffmanRiddleTip2"))
		get_node("riddleOverlay").set_text(global.get_game_text("huffmanRiddleNotSolved"))
	
	
func _on_Effacer_pressed():
	drawList = []
	nbTrait=nbTraitsMax
	


func _riddle_solved():
	get_node("riddleOverlay").set_text(global.get_game_text("huffmanRiddleSolved"))
	get_node("riddleOverlay").riddle_solved(2)
	global.set_state("source_3_toilets_huffmanRiddleSolved", true)
	drawList=answerList

func cheat():
	_riddle_solved()
