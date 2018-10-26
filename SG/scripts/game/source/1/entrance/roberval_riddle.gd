extends Node2D

var redled = load("res://assets/game/source/1/redled.png")

var bille = preload("res://scenes/game/source/1/entrance/bille.tscn")

var weightleft = 0
var weightright = 0
var weight_b = 0
var nb_bille = 13
var position = "center"
var nb_bille_zone_answer = -1 # Godot compte aussi le cercle que j'utilise pour définir la zone de réponse 

var basket1_posini
var basket2_posini

var nombre_essai_restant = 3
var bonne_bille = false
var numero_bille_differente

var numero_dispo = []

var solved = false
var back_to_level = false

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"1", "scene":"source_entry"})

	for numero in range(nb_bille):
		numero_dispo.append(numero+1)

	randomize()
	init_pos()

	get_node("riddleOverlay").set_tip(global.get_game_text("robervalRiddleTip2"))

	get_node("weighButton").set_text(global.get_game_text("robervalRiddleWeighButton"))
	get_node("validateButton").set_text(global.get_gui_text("validateButton"))
	get_node("validateButton").hide()
	get_node("notepad/notepadLabel").set_text(global.get_game_text("robervalRiddleNotepadLabel"))
	get_node("riddle").set_text(global.get_game_text("robervalRiddle"))
	
	basket1_posini=get_node("scale/gauche/basket1").get_pos()
	basket2_posini=get_node("scale/droite/basket2").get_pos()

	get_node("scale").hide()
	get_node("weighButton").hide()
	get_node("scale/gauche/basket1/CollisionShape2D").set_trigger(true)
	get_node("scale/droite/basket2/CollisionShape2D").set_trigger(true)

	#### Création de la bille différente
	var b = bille.instance()
	b.add_to_group("bille_differente")
	weight_b = (randi()%2-1) * (randi()%4+1.5)
	numero_bille_differente = randi()%13+1
	b.get_node("Label").set_text(str(numero_bille_differente))
	if numero_bille_differente == 6 or numero_bille_differente == 9:
		b.get_node("underscore").show()
	numero_dispo.remove(numero_dispo.find(numero_bille_differente))
	add_child(b)
	b.set_pos(Vector2(rand_range(0,get_viewport().get_visible_rect().size.x),950))

	#On crée le nombre de billes qu'il faut (les normales)
	var i = 1
	while i < nb_bille:
		create_bille()
		i=i+1

	set_process(true)
####################

#### Position initiale de la balance
func init_pos():
	var centerToLeftAnimation = get_node("scale/AnimationPlayer").get_animation("centertoleft")
	var barre = centerToLeftAnimation.find_track(NodePath("barre:transform/rot"))
	var droite = centerToLeftAnimation.find_track(NodePath("droite:transform/pos"))
	var gauche = centerToLeftAnimation.find_track(NodePath("gauche:transform/pos"))
	var rotBarre = centerToLeftAnimation.track_get_key_value(barre,0)
	var posDroite = centerToLeftAnimation.track_get_key_value(droite,0)
	var posGauche = centerToLeftAnimation.track_get_key_value(gauche,0)
	#get_node("scale/AnimationPlayer/barre").set_rot(rotBarre) Il y a un problème avec rot :(
	get_node("scale/droite").set_pos(posDroite)
	get_node("scale/gauche").set_pos(posGauche)


######## Utilisation d'objets ########
func _process(delta):
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_house_scales":
			get_node("scale").show()
			get_node("riddleOverlay").set_tip(global.get_game_text("robervalRiddleTip"))
			get_node("weighButton").show()
			get_node("scale/gauche/basket1/CollisionShape2D").set_trigger(false)
			get_node("scale/droite/basket2/CollisionShape2D").set_trigger(false)
		global.set_used_item("")
####################

func _on_weighButton_pressed():
	#### Affichage de la couleur des LEDs ####
	nombre_essai_restant = nombre_essai_restant-1
	if nombre_essai_restant == 2:
		get_node("led3").set_texture(redled)
	if nombre_essai_restant == 1:
		get_node("led2").set_texture(redled)
	if nombre_essai_restant == 0:
		get_node("led1").set_texture(redled)
		get_node("weighButton").hide()
		get_node("validateButton").show()
		get_node("marblehere").set_text(global.get_game_text("marbleHere"))

	#### Position des paniers ####
	var basket1_pos = basket1_posini
	var basket2_pos = basket2_posini

	basket1_pos = get_node("scale/gauche/basket1").get_pos()
	basket2_pos = get_node("scale/droite/basket2").get_pos()

	if weightright > weightleft : #Si on doit faire pencher à droite
		if position == "center" :
			get_node("scale/AnimationPlayer").play("centertoright")
			position = "right"
		elif position == "left" :
			get_node("scale/AnimationPlayer").play("lefttocenter")
			yield(get_node("AnimationPlayer"), "finished" )
			get_node("scale/AnimationPlayer").play("centertoright")
			position = "right"
	elif weightleft > weightright: #Si on doit faire pencher vers la gauche 
		if position == "center" :
			get_node("scale/AnimationPlayer").play("centertoleft")
			position = "left"
		elif position == "right" :
			get_node("scale/AnimationPlayer").play("righttocenter")
			yield(get_node("scale/AnimationPlayer"), "finished" )
			get_node("scale/AnimationPlayer").play("centertoleft")
			position = "left"
	else:
		if position == "right" :
			get_node("scale/AnimationPlayer").play("righttocenter")
			position = "center"
		elif position == "left" :
			get_node("scale/AnimationPlayer").play("lefttocenter")
			position = "center"

#### Mesures ####
# factorisation en une seule fonction enter et une seule fonction exit possible
# Basket1
func _on_hitbox1_body_enter( body ):
	if(body.is_in_group("billes")):
		weightleft=weightleft+1
	if(body.is_in_group("bille_differente")):
		weightleft=weightleft+weight_b
func _on_hitbox1_body_exit( body ):
	if(body.is_in_group("billes")):
		weightleft=weightleft-1
	if(body.is_in_group("bille_differente")):
		weightleft=weightleft-weight_b

# Basket2
func _on_hitbox2_body_enter( body ):
	if(body.is_in_group("billes")):
		weightright=weightright+1
	if(body.is_in_group("bille_differente")):
		weightright=weightright+weight_b
func _on_hitbox2_body_exit( body ):
	if(body.is_in_group("billes")):
		weightright=weightright-1
	if(body.is_in_group("bille_differente")):
		weightright=weightright-weight_b
####################

######## Création des billes normales ########
func create_bille():
	var b = bille.instance()
	b.add_to_group("billes")
	add_child(b)
	b.set_pos(Vector2(rand_range(0,get_viewport().get_visible_rect().size.x),950))
	b.get_node("Label").set_text(str(numero_dispo[0]))
	if numero_dispo[0] == 6 or numero_dispo[0] == 9:
		b.get_node("underscore").show()
	numero_dispo.remove(numero_dispo.find(numero_dispo[0]))
####################

######## Bouton Valider ########
func _on_validateButton_pressed():
	if bonne_bille and nb_bille_zone_answer==1:
		get_node("validateButton").hide()
		get_node("riddleOverlay").set_text(global.get_game_text("rightMarble"))
		win()
		
	if !bonne_bille and nb_bille_zone_answer==1:
		player.play_sound("wrong")
		get_node("validateButton").hide()
		get_node("riddleOverlay").set_text(global.get_game_text("wrongmarble"))

	if nb_bille_zone_answer>1:
		get_node("riddleOverlay").set_text(global.get_game_text("more_than_one_marble"))

	if nb_bille_zone_answer==0:
		get_node("riddleOverlay").set_text(global.get_game_text("no_marble"))
####################

######## Gestion de la zone de réponse ########
func _on_answercircle_body_enter( body ):
	if(body.is_in_group("bille_differente")):
		bonne_bille = true
		nb_bille_zone_answer = nb_bille_zone_answer+1
	else :
		bonne_bille = false
		nb_bille_zone_answer = nb_bille_zone_answer+1

func _on_answercircle_body_exit( body ):
	if(body.is_in_group("bille_differente")):
		bonne_bille = false
		nb_bille_zone_answer = nb_bille_zone_answer-1
	else :
		nb_bille_zone_answer = nb_bille_zone_answer-1
####################

func win():
	global.set_state("source_1_source_entry_robervalRiddleSolved", true)
	get_node("riddleOverlay").riddle_solved(2)
	global.use_item("tutorial_1_house_scales")

######## Bouton Tricher ########
func cheat():
	get_node("riddleOverlay").set_text(global.get_game_text("rightMarble"))
	win()
####################