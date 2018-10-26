##### res://scripts/riddleOverlay.gd
#####
##### Script du GUI qui s'affiche dans les énigmes, avec la mini-encyclopédie, le mini-inventaire,
##### le bouton d'indice et le bouton retour

##### Fonctions utiles : 
##### set_tip(text)
#####		argument : un String
#####		ne renvoie rien
##### set_tip_list( list_text )
#####		argument : une liste de String
#####		ne renvoie rien
#####		Remarque : comme set_tip, mais avec plusieurs indices qui bouclent
##### riddleSolved( wait_time=1, scene="" )
#####		Appeler cette fonction quand le joueur gagne les mini-jeux
#####		La fonction va jouer la musique de réussite, désactiver les boutons de riddleOverlay,
#####		et passer à la scène suivante
#####		Arguments (optionnels) :
#####			- wait_time : temps d'attente (en seconde) avant de passer à la prochaine scène
#####			- scene : prochaine scène (par défaut, retour à la scène principale)
#####				attention : ne pas donner d'argument si on veut retourner à la scène principale
#####				car donner un argument fait passer par set_scene et non par load_scene
#####		ne renvoie rien

extends CanvasLayer

var tip = []
var ind_tip = -1
var nb_tip = 0
var hotkeys_activated = true

##################### Initialisation
func _ready():
	get_node("text").set_use_bbcode(true)
	get_node("background").set_opacity(0.3)

	#### Suppression des focus
	get_node("VBoxContainer/returnButton").set_focus_mode(Control.FOCUS_NONE)
	get_node("VBoxContainer/tipButton").set_focus_mode(Control.FOCUS_NONE)
	get_node("inventoryButton").set_focus_mode(Control.FOCUS_NONE)
	get_node("encyclopediaButton").set_focus_mode(Control.FOCUS_NONE)

	#### Codage du placement pour être sûr que ce ne soit pas modifié par accident ####
	var guiBackground = get_node("background")
	guiBackground.set_expand(true)
	guiBackground.set_anchor_and_margin(MARGIN_LEFT,0,0)
	guiBackground.set_anchor_and_margin(MARGIN_TOP,0,0)
	guiBackground.set_anchor_and_margin(MARGIN_RIGHT,1,0)
	guiBackground.set_anchor_and_margin(MARGIN_BOTTOM,0,110)

	var vBoxContainer = get_node("VBoxContainer")
	vBoxContainer.set_anchor_and_margin(MARGIN_TOP,0,(guiBackground.get_size().y - vBoxContainer.get_size().y)/2)
	vBoxContainer.set_anchor_and_margin(MARGIN_LEFT,0,(guiBackground.get_size().y - vBoxContainer.get_size().y)/2)

	var encyclopediaButton = get_node("encyclopediaButton")
	encyclopediaButton.set_anchor_and_margin(MARGIN_RIGHT,1,20)
	encyclopediaButton.set_anchor_and_margin(MARGIN_TOP,0,(guiBackground.get_size().y - encyclopediaButton.get_size().y)/2)
	
	var inventoryButton = get_node("inventoryButton")
	inventoryButton.set_anchor_and_margin(MARGIN_RIGHT,1,encyclopediaButton.get_margin(MARGIN_LEFT))
	inventoryButton.set_anchor_and_margin(MARGIN_TOP,0,(guiBackground.get_size().y - inventoryButton.get_size().y)/2)
	
	var text = get_node("text")
	text.set_anchor_and_margin(MARGIN_LEFT,0,vBoxContainer.get_margin(MARGIN_RIGHT) + 20)
	text.set_anchor_and_margin(MARGIN_TOP,0,20)
	text.set_anchor_and_margin(MARGIN_BOTTOM,0,guiBackground.get_margin(MARGIN_BOTTOM)-20)
	text.set_anchor_and_margin(MARGIN_RIGHT,1,inventoryButton.get_margin(MARGIN_LEFT)+20)

	#### Affichage et traduction des textes ####
	get_node("VBoxContainer/tipButton").set_text(global.get_gui_text("tipButton"))
	get_node("VBoxContainer/returnButton").set_text(global.get_gui_text("returnButton"))
	get_node("encyclopediaButton").set_tooltip(global.get_gui_text("buttonToEncyclopedia"))
	get_node("inventoryButton").set_tooltip(global.get_gui_text("buttonToInventory"))
	get_node("cheatButton").set_text(global.get_gui_text("cheatButton"))

	get_node("VBoxContainer/tipButton").set_disabled(true)

	if !global.get_state("inventoryUnlocked"):
		get_node("inventoryButton").set_disabled(true)
	if !global.get_state("encyclopediaUnlocked"):
		get_node("encyclopediaButton").set_disabled(true)
	if !settings.is_debug_mode():
		get_node("cheatButton").queue_free()
	elif !get_parent().has_method("cheat"):
		if !(get_parent().has_node("piano") and get_parent().get_node("piano").has_method("cheat")):
			get_node("cheatButton").set_disabled(true)

	#### Curseurs ####
	if global.get_state("inventoryUnlocked"):
		get_node("inventoryButton").set_default_cursor_shape(2)
	if global.get_state("encyclopediaUnlocked"):
		get_node("encyclopediaButton").set_default_cursor_shape(2)
	if !get_node("cheatButton").is_disabled():
		get_node("cheatButton").set_default_cursor_shape(2)
	get_node("VBoxContainer/returnButton").set_default_cursor_shape(2)

	set_process_input(true)


#################### Affichage des encyclopédies et inventaires quand on appuie sur les touches correspondantes
func _input(event):
	if hotkeys_activated:
		if event.type == InputEvent.KEY and event.is_action_pressed("encyclopedia") and !get_node("encyclopediaButton").is_disabled():
			_on_encyclopediaButton_pressed()
		if event.type == InputEvent.KEY and event.is_action_pressed("inventory") and !get_node("inventoryButton").is_disabled():
			_on_inventoryButton_pressed()
	if event.type == InputEvent.KEY and event.is_action_pressed("menu"):
		if has_node("mini_encyclopedia/ResizableWindowDialog") and get_node("mini_encyclopedia/ResizableWindowDialog").is_visible():
			if get_node("mini_encyclopedia/ResizableWindowDialog/contentContainer").is_visible():
				get_node("mini_encyclopedia")._on_backToTocButton_pressed()
			else:
				get_node("mini_encyclopedia/ResizableWindowDialog").hide()
		elif has_node("mini_inventory") and get_node("mini_inventory").is_visible():
			get_node("mini_inventory").hide()
		else:
			global.load_scene()


#############################################################################################
#################################################################################### Indices
##### Définition d'un indice
func set_tip(text):
	set_tip_list([text])
#	if text != get_node("text").get_bbcode():
#		set_text("") #### S'il y a déjà un indice affiché, on l'efface
#	tip = [text]
#	nb_tip = 1
#	if text != "":
#		get_node("VBoxContainer/tipButton").set_disabled(false)
#		get_node("VBoxContainer/tipButton").set_default_cursor_shape(2)
#	else:
#		get_node("VBoxContainer/tipButton").set_disabled(true)
#		get_node("VBoxContainer/tipButton").set_default_cursor_shape(0)

##### Définition de plusieurs indices
func set_tip_list( text_list ):
	tip = text_list
	nb_tip = text_list.size()
	if nb_tip > 0 and tip[0] != get_node("text").get_bbcode():
		set_text("")
	if nb_tip > 0 and tip[0] != "":
		get_node("VBoxContainer/tipButton").set_disabled(false)
		get_node("VBoxContainer/tipButton").set_default_cursor_shape(2)
	else:
		get_node("VBoxContainer/tipButton").set_disabled(true)
		get_node("VBoxContainer/tipButton").set_default_cursor_shape(0)

#### Ecriture d'un text
func set_text(text):
	if text != get_node("text").get_bbcode():
		get_node("text").set_bbcode(text)
		get_node("AnimationPlayer").play("displayText")

#### Affichage d'un indice
func _on_tipButton_pressed():
	if !(Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN)):
		ind_tip += 1
		if ind_tip >= nb_tip:
			ind_tip = 0
		set_text(tip[ind_tip])

##############################################################################################
################################################################################## Encyclopédie
func set_encyclopedia_enabled(boolean):
	get_node("encyclopediaButton").set_disabled(!boolean)

func _on_encyclopediaButton_pressed():
	if get_node("mini_encyclopedia/ResizableWindowDialog").is_visible():
		get_node("mini_encyclopedia/ResizableWindowDialog").hide()
	else:
		player.play_sound("encyclopedia")
		get_node("mini_encyclopedia/ResizableWindowDialog").show()
		get_node("mini_encyclopedia/ResizableWindowDialog").set_pos(Vector2(Globals.get("display/width"),Globals.get("display/height"))/2 - get_node("mini_encyclopedia/ResizableWindowDialog").get_size()/2)

###############################################################################################
################################################################################### Inventaire
func set_inventory_enabled(boolean):
	get_node("inventoryButton").set_disabled(!boolean)

func _on_inventoryButton_pressed():
	if get_node("mini_inventory").is_visible():
		get_node("mini_inventory").hide()
		Globals.set("selectedItem", "")
	else:
		player.play_sound("inventory")
		get_node("mini_inventory").show()
		get_node("mini_inventory").set_pos(Vector2(Globals.get("display/width"),Globals.get("display/height"))/2 - get_node("mini_inventory").get_size()/2)

###############################################################################################
######################################### Mise à jour des boutons encyclopédie et inventaire
func update():
	get_node("mini_encyclopedia").update()
	if global.get_state("inventoryUnlocked"):
		get_node("inventoryButton").set_disabled(false)
	else:
		get_node("inventoryButton").set_disabled(true)
	if global.get_state("encyclopediaUnlocked"):
		get_node("encyclopediaButton").set_disabled(false)
	else:
		get_node("encyclopediaButton").set_disabled(true)
	get_node("mini_inventory").update()


##############################################################################################
######################################################################################### Retour
func _on_returnButton_pressed():
	if !(Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN)):
		global.load_scene()

func toggle_return():
	get_node("VBoxContainer/returnButton").set_disabled(!get_node("VBoxContainer/returnButton").is_disabled())
	if get_node("VBoxContainer/returnButton").is_disabled():
		get_node("VBoxContainer/returnButton").set_default_cursor_shape(0)
	else:
		get_node("VBoxContainer/returnButton").set_default_cursor_shape(2)

func toggle_tip():
	get_node("VBoxContainer/tipButton").set_disabled(!get_node("VBoxContainer/tipButton").is_disabled())
	if get_node("VBoxContainer/tipButton").is_disabled():
		get_node("VBoxContainer/tipButton").set_default_cursor_shape(0)
	else:
		get_node("VBoxContainer/tipButton").set_default_cursor_shape(2)

func disable_tip():
	get_node("VBoxContainer/tipButton").set_disabled(true)
	get_node("VBoxContainer/tipButton").set_default_cursor_shape(0)

func enable_tip():
	set_tip_list(tip)
#	get_node("VBoxContainer/tipButton").set_enabled(true)
#	get_node("VBoxContainer/tipButton").set_default_cursor_shape(2)

#################################### Retour automatique
func riddle_solved( wait_time=1 , scene="" ):
	### Bruitage de réussite et retour à la scène principale après un temps d'attente
	if scene == "": # Par défaut : retour à la scène principale
		get_node("Timer").connect("timeout", self, "_on_Timer_timeout")
	else:
		get_node("Timer").connect("timeout", self, "_go_to_scene", [scene])
	get_node("Timer").set_wait_time(wait_time)
	get_node("Timer").set_one_shot(true)
	get_node("Timer").start()
	toggle_return()
	disable_tip()
	player.play_sound("right")

func _on_Timer_timeout():
	global.load_scene()

func _go_to_scene(scene):
	global.set_scene(scene)

func _on_cheatButton_pressed():
	if get_parent().has_method("cheat"):
		get_parent().cheat()
	if get_parent().has_node("piano") and get_parent().get_node("piano").has_method("cheat"):
		get_parent().get_node("piano").cheat()

###### Désactive les raccourcis clavier de l'encyclopédie et de l'inventaire
###### (pour quand le joueur doit taper un texte)
func deactivate_hotkeys():
	hotkeys_activated = false

func activate_hotkeys():
	hotkeys_activated = true