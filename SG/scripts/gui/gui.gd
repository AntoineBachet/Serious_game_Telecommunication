##### res://scripts/gui/gui.gd
#####
##### Ce script gère le gui, qui contient les différents menus et une zone de texte

extends CanvasLayer

###################### Initialisation
func _ready():
	#### Activation/désactivation des boutons de menu - Affichage/traduction des textes d'infobulles ####
	for guiElement in ["inventory", "encyclopedia", "log", "map", "menu"]:
		if Globals.get("gameState").has(str(guiElement,"Unlocked")):
			enable_gui_element(guiElement, Globals.get("gameState")[str(guiElement,"Unlocked")])
		get_node(str("PanelContainer/HBoxContainer/",guiElement,"Button")).set_tooltip(global.get_gui_text(str("buttonTo",guiElement.capitalize())))
		enable_gui_element("menu", true)
	####################

	#### Codage du placement responsive ####
	var guiBackground = get_node("guiBackground")
	guiBackground.set_expand(true)
	guiBackground.set_anchor_and_margin(MARGIN_LEFT,0,0)
	guiBackground.set_anchor_and_margin(MARGIN_TOP,0,0)
	guiBackground.set_anchor_and_margin(MARGIN_RIGHT,1,0)
	guiBackground.set_anchor_and_margin(MARGIN_BOTTOM,0,110)

	var panelContainer = get_node("PanelContainer")
	panelContainer.set_anchor_and_margin(MARGIN_LEFT,0,0)				# c'est en double, c'est intentionnel
	panelContainer.set_anchor_and_margin(MARGIN_TOP,0,(guiBackground.get_size().y-panelContainer.get_size().y)/2)
	panelContainer.set_anchor_and_margin(MARGIN_LEFT,0,(guiBackground.get_size().y-panelContainer.get_size().y)/2)

	var comments = get_node("comments")
	comments.set_anchor_and_margin(MARGIN_TOP,0,20)
	comments.set_anchor_and_margin(MARGIN_BOTTOM,0,guiBackground.get_margin(MARGIN_BOTTOM)-20)
	comments.set_anchor_and_margin(MARGIN_LEFT,0,panelContainer.get_margin(MARGIN_RIGHT)+40)
	comments.set_anchor_and_margin(MARGIN_RIGHT,1,20)
	####################

	get_node("comments").set_use_bbcode(true)

	set_process_input(true)

#### Désactivation complète du GUI ####
func set_gui_off():
	set_process_input(false)
	for guiElement in ["inventory", "encyclopedia", "log", "map", "menu"]:
		enable_gui_element(guiElement, false)
####################

#### Réactivation du GUI ####
func set_gui_on():
	set_process_input(true)
	for guiElement in ["inventory", "encyclopedia", "log", "map"]:
		if Globals.get("gameState").has(str(guiElement,"Unlocked")):
			enable_gui_element(guiElement, Globals.get("gameState")[str(guiElement,"Unlocked")])
		enable_gui_element("menu", true)
####################

#### Raccourcis clavier ####
func _input(event):	
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("inventory") and !get_node("PanelContainer/HBoxContainer/inventoryButton").is_disabled():
			_on_inventoryButton_pressed()
		if event.is_action_pressed("log") and !get_node("PanelContainer/HBoxContainer/logButton").is_disabled():
			_on_logButton_pressed()
		if event.is_action_pressed("encyclopedia") and !get_node("PanelContainer/HBoxContainer/encyclopediaButton").is_disabled():
			_on_encyclopediaButton_pressed()
		if event.is_action_pressed("map") and !get_node("PanelContainer/HBoxContainer/mapButton").is_disabled():
			_on_mapButton_pressed()
		if event.is_action_pressed("menu") and !get_node("PanelContainer/HBoxContainer/menuButton").is_disabled():
			_on_menuButton_pressed()
####################

#### Appui sur les boutons de menu ####
# La factorisation du screenshot en une seule fonction n'est pas très fructueuse
func _on_menuButton_pressed():
	if global.save_scene():
		player.play_sound("menu")
		_screenshot("res://scenes/menu/menu.tscn")

func _on_mapButton_pressed():
	if global.save_scene():
		player.play_sound("map")
		_screenshot("res://scenes/gui/map.tscn")

func _on_encyclopediaButton_pressed():
	if global.save_scene():
		player.play_sound("encyclopedia")
		_screenshot("res://scenes/gui/encyclopedia.tscn")

func _on_logButton_pressed():
	if global.save_scene():
		player.play_sound("log")
		_screenshot("res://scenes/gui/log.tscn")

func _on_inventoryButton_pressed():	
	if global.save_scene():
		player.play_sound("inventory")
		_screenshot("res://scenes/gui/inventory.tscn")
####################

#### Affichage animé d'un message dans la zone en haut à droite ####
## Taille maximale permise par l'animation actuelle : 256 caractères ##
func set_text(text):
	if text != get_node("comments").get_bbcode():
		get_node("comments").set_bbcode(text)
		get_node("AnimationPlayer").play("displayComments")
####################

#### Activer (true) ou désactiver (false) un des quatre menus + curseurs modifiés ####
func enable_gui_element(guiElement, boolean):
	get_node("PanelContainer/HBoxContainer").get_node(str(guiElement,"Button")).set_disabled(!boolean)
	if boolean:
		get_node("PanelContainer/HBoxContainer").get_node(str(guiElement,"Button")).set_default_cursor_shape(2)
	else:
		get_node("PanelContainer/HBoxContainer").get_node(str(guiElement,"Button")).set_default_cursor_shape(0)
####################

func update():
	for guiElement in ["inventory", "encyclopedia", "log", "map", "menu"]:
		if Globals.get("gameState").has(str(guiElement,"Unlocked")):
			enable_gui_element(guiElement, Globals.get("gameState")[str(guiElement,"Unlocked")])
		get_node(str("PanelContainer/HBoxContainer/",guiElement,"Button")).set_tooltip(global.get_gui_text(str("buttonTo",guiElement.capitalize())))
		enable_gui_element("menu", true)

#### Capture d'écran en écrant dans les menus en cas de sauvegarde manuelle (menu) ou automatique (inventaire, journal, encyclopédie, carte) ####
func _screenshot(path):
	get_parent().get_viewport().queue_screen_capture()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	Globals.set("screenshot",get_parent().get_viewport().get_screen_capture())
	global.set_scene(path)
####################