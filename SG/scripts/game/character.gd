##### res://scripts/game/character.gd
#####
##### Ce script gère le personnage principal du jeu, et notament les pop-up d'interaction avec
##### les objets et l'animation du personnage


extends KinematicBody2D

var anim = ""
var orientation
var speed = 400

var canInteractObjects = []

var bubble_pos = "right"
var margin = 0

var moving_left = false
var moving_right = false
var moving_click = false
var margin_click = 70
var gui_height = 0

######################### Initialisation
func _ready():
	if get_parent().has_node("gui"):
		var gui = get_parent().get_node("gui")
		gui_height = get_parent().get_node("gui/guiBackground").get_item_rect().size.y
	
	# Affichage du chapeau si on est censé l'avoir mis
	if Globals.get("gameState").has("hat"):
		var hatTexture = load(str("res://assets/player/hats/", Globals.get("gameState")["hat"], ".png"))
		get_node("AnimatedSprite/hat").set_texture(hatTexture)
		get_node("AnimatedSprite/hat").show()

	# Restauration de l'orientation
	if Globals.get("gameState").has("currentOrientation"):
		orientation = Globals.get("gameState")["currentOrientation"]
		Globals.get("gameState").erase("currentOrientation")
	
	if get_parent().has_method("character_orientation"):
		set_orientation(get_parent().character_orientation())

	# Restauration de la position
	if global.get_target_node() != null:
		if get_parent().has_node(global.get_target_node()):
			var charPos = get_pos()
			var nodePos = get_parent().get_node(global.get_target_node()).get_pos()
			charPos.x = nodePos.x
			set_pos(charPos)
		else:
			print("No node \"", global.get_target_node(), "\" found in scene.")
		global.set_target_node(null)
	elif Globals.get("targetPosition") != null:
		set_pos(Globals.get("targetPosition"))
		Globals.set("targetPosition",null)

	if get_parent().has_node("rightLimit"):
		get_node("Camera2D").set_limit(MARGIN_RIGHT, get_parent().get_node("rightLimit").get_pos().x)
	if get_parent().has_node("leftLimit"):
		get_node("Camera2D").set_limit(MARGIN_LEFT, get_parent().get_node("leftLimit").get_pos().x)

	set_fixed_process(true)
	set_process(true)
	set_process_input(true)

	# Récupération des objets interactifs de la scène
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("canInteractObjects"):
			canInteractObjects.append(child.get_name())

	get_node("canInteract").set_default_cursor_shape(2)

	# Calcul de la marge pour quand on retourne la bulle de dialogue
	var text_pos = get_node("text").get_pos()
	var next_pos = get_node("next").get_pos()
	margin = next_pos.x - text_pos.x

################# Affichage de la pop-up
func _process(delta):
	showcanInteract(canInteractObjects)

############################################################################################
#################################################################### Mise à jour l'animation
func _fixed_process(delta):
	if moving_click:
		move_by_click()
	
	play(delta)
	
	var current_anim = get_node("AnimatedSprite/AnimationPlayer").get_current_animation()
	if anim != current_anim:
		get_node("AnimatedSprite/AnimationPlayer").play(anim)

func play(delta):
	anim = "idle_right"
	if orientation == "left":
		anim = "idle_left"

	if Input.is_action_pressed("ui_right") or moving_right:
		anim = "walking_right"
		move(Vector2(speed*delta,0))
		set_orientation("right")

	if Input.is_action_pressed("ui_left") or moving_left:
		anim = "walking_left"
		move(Vector2(-speed*delta,0))
		set_orientation("left")


func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT:
		if !(get_parent().has_node("cinematic") and get_parent().get_node("cinematic").bubble_shown): # On ne veux pas se déplacer par clic si une cinématique est en cours
			if event.is_pressed():
				var pos_click = event.pos
				if pos_click.y > gui_height:
					moving_click = true
			else:
				moving_right = false
				moving_left = false
				moving_click = false

func stop_move_by_click():
	moving_right = false
	moving_left = false
	moving_click = false

func move_by_click():
	moving_right = false
	moving_left = false
	var pos = get_local_mouse_pos()
	if pos.x > margin_click:
		moving_right = true
	elif pos.x < - margin_click:
		moving_left = true

func set_orientation(o):
	if o == "right":
		orientation = "right"
		get_node("AnimatedSprite").set_flip_h(false)
		get_node("AnimatedSprite/hat").set_flip_h(true)
	elif o == "left":
		orientation = "left"
		get_node("AnimatedSprite").set_flip_h(true)
		get_node("AnimatedSprite/hat").set_flip_h(false)

func get_orientation():
	return orientation


##########################################################################################
################################################################### Gestion de la pop-up
#Affichage du sprite canInteract au dessus du personnage
func canInteractShow():
		get_node("canInteract").show()
func canInteractHide():
		get_node("canInteract").hide()

func showcanInteract(canInteractObjects):
	var show = 0
	#var changeTexture=0

	for object in canInteractObjects:
		#Si on est proche de l'objet
		if get_tree().get_current_scene().has_node(object) and get_tree().get_current_scene().get_node(object).get_node("hitbox").overlaps_body(self):
			#On va afficher quelque chose
			show=1
			#Si en plus on est à proximité d'un object sur lequel on doit utiliser un object de l'inventaire
	if show==1:
		canInteractShow()
	else : #Si rien n'est affiché, on revient par défaut à l'affichage de E
		canInteractHide()

func cannotInteract(nodeName):
	canInteractObjects.remove(canInteractObjects.find(nodeName))
func canInteract(nodeName):
	canInteractObjects.append(nodeName)



###########################################################################################
#################################################################### Blocage du personnage
func freeze_character():
	set_fixed_process(false)
	set_process(false)
	set_process_input(false)
	moving_left = false
	moving_right = false
	if get_node("AnimatedSprite/AnimationPlayer").get_current_animation() == "walking_left":
		get_node("AnimatedSprite/AnimationPlayer").play("idle_left")
	elif get_node("AnimatedSprite/AnimationPlayer").get_current_animation() == "walking_right":
		get_node("AnimatedSprite/AnimationPlayer").play("idle_right")
	canInteractHide()

func unfreeze_character():
	set_fixed_process(true)
	set_process(true)
	set_process_input(true)
	
	_fixed_process(0)


##########################################################################################
################################# Fonctions pour changer le côté de la bulle de dialogue
func bubble_right():
	if bubble_pos == "left":
		bubble_pos = "right"
		get_node("bubble").set_flip_h( true )
		flip_bubble()

func bubble_left():
	if bubble_pos == "right":
		bubble_pos = "left"
		get_node("bubble").set_flip_h( false )
		flip_bubble()

func flip_bubble():
	var pos = get_node("bubble").get_pos()
	pos.x = - pos.x
	get_node("bubble").set_pos(pos)
	
	var text_pos = get_node("text").get_pos()
	var text_size = get_node("text").get_size()
	var next_pos = get_node("next").get_pos()
	
	text_pos.x = -text_pos.x - text_size.x
	get_node("text").set_pos(text_pos)
	next_pos.x = text_pos.x + margin
	get_node("next").set_pos(next_pos)

func _on_canInteract_pressed():
	var ev = InputEvent()
	ev.type = InputEvent.KEY
	ev.scancode = KEY_E
	ev.pressed = true
	get_tree().input_event(ev)