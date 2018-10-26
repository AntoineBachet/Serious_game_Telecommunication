#### res://scripts/game/cinematic.gd
####
#### Ce fichier est à utiliser tel quel dans les différentes scènes du jeu
#### Pour insérer une cinématique dans une scène, rajouter "scenes/game/cinematic.tscn" à la scène
#### Penser à ajouter les personnages devant parler au groupe "character" dans la scène principale
#### 
#### Elements utiles de ce script pour son utilisation :
####	La cinématique envoie un signal "finished"
####	func start()
####	func next_event() (à utiliser notament à la fin d'une animation) 
####	func freeze_scene()
####	func unfreeze_scene()
####	func set_events( e ) (e devra être un dictionnaire contenant la cinématique)
################################

extends Node

### Le signal "finished" est émis à la fin de la cinématique
signal finished

var default_process = true
var default_process_input = true

var events # Contient le dictionnaire correspondant à la cinématique
var nb_events = 0
var index_events = 0
var dialogue # Contient les différents dialogues
var nb_dialogue = 0
var index_dialogue = -1

var wait_dialogue = 0.7 # Temps d'attente avant de pouvoir passer à la bulle de dialogue suivante
var can_pass_dialogue = false # Booléen indiquant si on peut passer à la bulle de dialogue suivante

var started = false # Booléen indiquant si la cinématique est en cours
var bubble_shown = false

### Variables pour le redimensionnement du texte
var text_scale = {}
var text_size = {}


func _ready():
	clear_bubbles()
	### On enlève le bouton pour passer la cinématique
	if !settings.is_debug_mode():
		get_node("pass").free()
	### On cache pour le bouton Pass tant qu'on a pas démarré la cinématique
	if has_node("pass"):
		get_node("pass").set_disabled(true)
		get_node("pass").hide()
	### Connection du timer, et démarrage (le Timer est par défaut activé à 1s)
	get_node("Timer").connect("timeout", self, "_on_Timer_timeout")


################## Démarrage de la cinématique
func start():
	#### Initialisation des variables
	started = true
	index_events = 0
	nb_events = events.size()
	nb_dialogue = 0
	index_dialogue = -1

	get_node("Timer").set_active(false)
	
	#### Activation des process et du bouton Pass
	set_process(true)
	set_process_input(true)
	if has_node("pass"):
		get_node("pass").set_disabled(false)
		get_node("pass").show()
	
	if get_parent().has_node("character"):
		get_parent().get_node("character").stop_move_by_click()


func end_cinematic():
	### On désactive tout et on envoie le signal "finished"
	started = false
	get_node("Timer").stop()
	clear_bubbles()
	set_process(false)
	set_process_input(false)
	if has_node("pass"):
		get_node("pass").set_disabled(true)
		get_node("pass").hide()
	emit_signal( "finished" )


func _process(delta):
	if started:
		if index_events >= nb_events:
			end_cinematic()
		else:
			if events[index_events].has("condition"):
				if global.get_state( events[index_events]["condition"] ):
					process_cinematic()
			elif events[index_events].has("conditionFalse"):
				if !global.get_state( events[index_events]["conditionFalse"] ):
					process_cinematic()
			else:
				process_cinematic()


func process_cinematic():
	if events[index_events].has("action"):

	#### change_sprite
		if events[index_events]["action"] == "change_sprite":
			if events[index_events].has("node") and events[index_events].has("path"):
				change_sprite( events[index_events]["node"], events[index_events]["path"] )
			next_event()

	#### Show
		elif events[index_events]["action"] == "show":
			if events[index_events].has("name"):
				show_node( events[index_events]["name"] )
			next_event()

	#### Hide
		elif events[index_events]["action"] == "hide":
			if events[index_events].has("name"):
				hide_node( events[index_events]["name"] )
			next_event()

	#### Shake_camera
		elif events[index_events]["action"] == "shake_camera":
			if events[index_events].has("time"):
				shake_camera(float(events[index_events]["time"]))
			next_event()
	#################################

	#### Wait
		elif events[index_events]["action"] == "wait":
			wait()
	######################################

	#### Sound
		elif events[index_events]["action"] == "sound":
			if events[index_events].has("name"):
				sound(events[index_events]["name"])
			next_event()
	#######################################

	#### Animation
		elif events[index_events]["action"] == "animation":
			if events[index_events].has("name"):
				animation( events[index_events]["name"] )
	#####################################

	#### Animation_not_blocking
		elif events[index_events]["action"] == "animation_not_blocking":
			if events[index_events].has("name"):
				animation_not_blocking( events[index_events]["name"] )
			next_event()

	#### Character_animation
		elif events[index_events]["action"] == "character_animation":
			if events[index_events].has("character") and events[index_events].has("animation"):
				character_animation(events[index_events]["character"], events[index_events]["animation"])
			next_event()
	
	#### VictorAnimatedSprite
		elif events[index_events]["action"] == "victorAnim":
			if events[index_events].has("anim"):
				victorAnimatedSprite( events[index_events]["anim"] )
			next_event()
	######################################
	
		else:
			next_event()

	#### Dialogue
	#### Démarrage du dialogue
	elif events[index_events].has("dialogue") and nb_dialogue == 0:
		start_dialogue()
		if !process_dialogue():
			next_event()
			nb_dialogue = 0
	###########################


func _input(event):
	if ((event.type == InputEvent.KEY and (event.scancode == KEY_E or event.scancode == KEY_RETURN or event.scancode == KEY_SPACE)) or (event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT)) and !event.is_pressed() and !event.is_echo():
		if index_events < nb_events and events[index_events].has("dialogue") and can_pass_dialogue:
			#### On passe à la bulle de dialogue suivante
			if nb_dialogue == 0:
				start_dialogue()
			if !process_dialogue():
				next_event()
				nb_dialogue = 0


################################################################ Fonctions de la cinématique (actions et dialogue)
func change_sprite(node, path):
	if get_parent().has_node(node) and get_parent().get_node(node).is_type("Sprite"):
		var texture = load(path)
		get_parent().get_node(node).set_texture(texture)

############################
func show_node(name):
	if get_parent().has_node(name) and get_parent().get_node(name).has_method("show"):
		get_parent().get_node(name).show()
############################

############################
func hide_node(name):
	if get_parent().has_node(name) and get_parent().get_node(name).has_method("hide"):
		get_parent().get_node(name).hide()
############################

############################
func shake_camera(duration):
	if get_parent().has_node("Camera2D"):
		get_parent().get_node("Camera2D").shake(duration,15,10)
	elif get_parent().has_node("character"):
		get_parent().get_node("character/Camera2D").shake(duration,15,10)
############################

############################
func wait():
	if !get_node("Timer").is_active():
		get_node("Timer").set_active(true)
		if events[index_events].has("time"):
			get_node("Timer").set_wait_time( float(events[index_events]["time"]) )
			get_node("Timer").start()
############################

############################
func sound(name):
	#if get_parent().has_node("SamplePlayer2D"):
#		get_parent().get_node("SamplePlayer2D").play(name)
	player.play_sound(name)
############################

############################
func animation(name):
	if get_parent().has_node("cinematicAnimation"):
		if !get_parent().get_node("cinematicAnimation").is_playing():
			get_parent().get_node("cinematicAnimation").connect("finished", self, "_on_cinematicAnimation_finished")
			get_parent().get_node("cinematicAnimation").play(name)
	elif get_parent().has_node("AnimationPlayer"):
		if !get_parent().get_node("AnimationPlayer").is_playing():
			get_parent().get_node("AnimationPlayer").play(name)
############################

func animation_not_blocking(name):
	if get_parent().has_node("cinematicAnimation"):
		if !get_parent().get_node("cinematicAnimation").is_playing():
			get_parent().get_node("cinematicAnimation").play(name)
	elif get_parent().has_node("AnimationPlayer"):
		if !get_parent().get_node("AnimationPlayer").is_playing():
			get_parent().get_node("AnimationPlayer").play(name)

############################
func character_animation(character, animation):
	if get_parent().has_node(character + "/AnimatedSprite/AnimationPlayer") or get_parent().has_node(character + "/Sprite/AnimationPlayer"):
		if get_parent().get_node(character).has_method("set_orientation"):
			if animation == "idle_right":
				get_parent().get_node(character).set_orientation("right")
			elif animation == "idle_left":
				get_parent().get_node(character).set_orientation("left")
		if get_parent().has_node(character + "/AnimatedSprite/AnimationPlayer"):
			get_parent().get_node(character + "/AnimatedSprite/AnimationPlayer").play(animation)
		elif get_parent().has_node(character + "/Sprite/AnimationPlayer"):
			get_parent().get_node(character + "/Sprite/AnimationPlayer").play(animation)

	elif get_parent().has_node(character + "/AnimationPlayer"):
		get_parent().get_node(character + "/AnimationPlayer").play(animation)
	
	elif get_parent().has_node(character) and get_parent().get_node(character).is_type("AnimatedSprite"):
		get_parent().get_node(character).set_animation(animation)
############################

func victorAnimatedSprite(anim):
	if get_parent().has_node("character"):
		get_parent().get_node("character/AnimatedSprite").set_animation(anim)


############################
func start_dialogue():
	dialogue = events[index_events]["dialogue"]
	nb_dialogue = dialogue.size()
	index_dialogue = -1
	can_pass_dialogue = true
############################
##########################################################################################


#### Affiche la prochaine bulle de dialogue
#### Renvoie true si le dialogue est terminé
func process_dialogue():
	clear_bubbles()
	if index_dialogue < nb_dialogue - 1:
		index_dialogue += 1
		if get_parent().has_node( dialogue[index_dialogue]["character"] ):
			bubble_shown = true
			
			#### Récupération du texte
			var language = settings.get_language()
			if !dialogue[index_dialogue]["text"].has(language):
				language = "fr"
			var text = dialogue[index_dialogue]["text"][language]
			#### Affichage de la bulle et du texte
			get_parent().get_node( dialogue[index_dialogue]["character"] + "/text" ).set_text(text)
			get_parent().get_node( dialogue[index_dialogue]["character"] + "/bubble" ).show()

		#################### Redimensionnement du texte
			var text =  get_parent().get_node( dialogue[index_dialogue]["character"] + "/text" )
			#### Si on a changé la taille des bulles, on remet la taille de base
			if text_scale.has( dialogue[index_dialogue]["character"] ) and text_size.has( dialogue[index_dialogue]["character"] ):
				text.set_scale( text_scale[ dialogue[index_dialogue]["character"] ] )
				text.set_size( text_size[ dialogue[index_dialogue]["character"] ] )

			var line_height = text.get_line_height()
			var max_line = int( text.get_size().y / (line_height * text.get_scale().y) )
			#### Réduction de la taille si le texte est trop grand
			if text.get_line_count() > max_line:
				var old_scale = text.get_scale()
				var old_size = text.get_size()

				### Récupération de la taille de base
				if !( text_scale.has( dialogue[index_dialogue]["character"] ) and text_size.has( dialogue[index_dialogue]["character"] ) ):
					text_scale[ dialogue[index_dialogue]["character"] ] = old_scale
					text_size[ dialogue[index_dialogue]["character"] ] = old_size

				var new_scale = old_scale
				var new_size = old_size
				while text.get_line_count() > max_line and new_scale.x >= 0.1:
					### Réduction de la taille du texte
					new_scale.x -= 0.05
					new_scale.y -= 0.05
					new_size.x = old_size.x / new_scale.x * old_scale.x
					new_size.y = old_size.y / new_scale.y * old_scale.y
					text.set_scale(new_scale)
					text.set_size(new_size)
					max_line = int( old_size.y / (int(line_height * new_scale.y)) - 0.5 )
		########################################

		##### On interdit le passage à la prochaine bulle pendant un certain temps
		can_pass_dialogue = false
		get_node("Timer").set_active(true)
		get_node("Timer").set_wait_time(wait_dialogue)
		get_node("Timer").start()
		return true
	else:
		nb_dialogue = 0
		return false


#### Disparition des bulles de texte
func clear_bubbles():
	bubble_shown = false
	for c in get_tree().get_nodes_in_group("character"):
		c.get_node("text").set_text("")
		c.get_node("bubble").hide()
		if c.has_node("next"):
			c.get_node("next").hide()
#############################

#################################################################################################
##################################################### Fonctions utiles à l'extérieur de ce script
#################################################################################################
#### func start() (voir plus haut)

#### Désactive / réactive la scène
func freeze_scene():
	default_process = get_parent().is_processing()
	default_process_input = get_parent().is_processing_input()
	get_parent().set_process(false)
	get_parent().set_process_input(false)
	if get_parent().has_node("character"):
		get_parent().get_node("character").freeze_character()
	if get_parent().has_node("gui"):
		get_parent().get_node("gui").set_gui_off()
		get_parent().get_node("gui").set_text("")
		
func unfreeze_scene():
	get_parent().set_process(default_process)
	get_parent().set_process_input(default_process_input)
	if get_parent().has_node("character"):
		get_parent().get_node("character").unfreeze_character()
	if get_parent().has_node("gui"):
		get_parent().get_node("gui").set_gui_on()
###########################

func next_event():
	index_events += 1
	get_node("Timer").set_active(false)

func set_events(e):
	events = e
###############################################################################################
###############################################################################################

############################################################################# Signaux

#### Clic sur le bouton "Pass" -> fin de la cinématique
func _on_pass_pressed():
	end_cinematic()


##### Fin du timer
func _on_Timer_timeout():
	if index_events < nb_events:
		######## Si l'action "wait" est finie :
		if events[index_events].has("action") and events[index_events]["action"] == "wait":
			next_event()
		####### On permet le passage à la bulle de dialogue suivante et on affiche l'icone correspondante
		elif events[index_events].has("dialogue"):
			can_pass_dialogue = true
			if get_parent().has_node( dialogue[index_dialogue]["character"] ) and get_parent().get_node( dialogue[index_dialogue]["character"] ).has_node("next"):
				get_parent().get_node( dialogue[index_dialogue]["character"] + "/next" ).show()
########################################################################

#### Fin d'une animation
func _on_cinematicAnimation_finished():
	get_parent().get_node("cinematicAnimation").disconnect("finished", self, "_on_cinematicAnimation_finished")
	next_event()



func get_events(cinematicName):
	set_events( global.get_cinematic(cinematicName) )