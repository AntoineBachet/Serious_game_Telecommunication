##### res://scripts/menu/achievements.gd
#####
##### Menu des achievements : affichage de la liste de tous les achievements

extends Control

var achievements
var tabContainer

######## Initialisation ########
func _ready():
	#### Affichage et traduction des textes ####
	get_node("VBoxContainer/returnButton").set_text(global.get_gui_text("returnButton"))
	get_node("VBoxContainer/menuTitle").set_text(global.get_gui_text("achievementsButton"))

	#### Chargement et affichage des achievements ####
	achievements = global.achievements

	tabContainer = get_node("VBoxContainer/TabContainer")
	tabContainer.set_tab_title(0, global.get_gui_text("achievementCategoryMisc"))
	tabContainer.set_tab_title(1, global.get_gui_text("achievementCategoryStory"))
	tabContainer.set_tab_title(2, global.get_gui_text("achievementCategorySecret"))

	

	var tabId
	for achievement in achievements:
		if achievements[achievement].category == "story":
			tabId = 1
		elif achievements[achievement].category == "secret":
			tabId = 2
		elif achievements[achievement].category == "general":
			tabId = 0
		else:
			tabId = -1
			print("[Error : invalid category ",  achievements[achievement].category, " for achievement ", achievement, " in achievements.json]")

		if tabId >=0:
			var requirements = []
			var requirementsFulfilled = true

			if achievements[achievement].has("requirements"):
				requirements = achievements[achievement].requirements
			
			var u = 0
			for requirement in requirements:
				if global.get_state(str("achievement_",requirement,"_displayed")):
					u += 1
			if u != requirements.size():
				requirementsFulfilled = false

			if global.get_state(str("achievement_",achievement,"_displayed")):
				display_achievement(tabId, achievement, true)
			elif requirementsFulfilled:
				display_achievement(tabId, achievement, false)

	# Ajout d'un contrôle vide à chaque onglet pour que le défilement se fasse bien jusqu'au bout
	for tabId in [0,1,2]:
		var achievementControl = Control.new()
		var tabName = tabContainer.get_tab_control(tabId).get_name()
		tabContainer.get_node(tabName).get_node(tabName).add_child(achievementControl)

	set_process_input(true)
####################

######## Affichage d'achievement dans l'onglet tabId ########
func display_achievement(tabId, achievement, unlocked):
	#### Création du contrôle à ajouter au ScrollContainer ####
	var achievementControl = Control.new()
	var achievementContainer = HBoxContainer.new()
	achievementContainer.set_size(Vector2(1900,120)) #c'est pas très responsive du coup
	achievementContainer.set("custom_constants/separation",20)
	achievementContainer.set_anchor_and_margin(MARGIN_LEFT, 0, 10)

	#### Icône de l'achievement ####
	var achievementIcon = TextureFrame.new()
	var icon
	var file = File.new()
	if unlocked and file.file_exists(str("res://assets/achievements/", achievement, ".png")):
		icon = load(str("res://assets/achievements/", achievement, ".png"))
	elif !unlocked:
		if global.get_achievement(achievement).category == "secret":
			icon = load(str("res://assets/achievements/secret.png"))
		elif file.file_exists(str("res://assets/achievements/", achievement, "_locked.png")):
			icon = load(str("res://assets/achievements/", achievement, "_locked.png"))
		else:
			icon = load("res://assets/achievements/no_image.png")
	else:
		icon = load("res://assets/achievements/no_image.png")
	achievementIcon.set_texture(icon)

	#### Titre et description de l'achievement ####
	var achievementTextContainer = VBoxContainer.new()
	achievementTextContainer.set_h_size_flags(3)

	# Titre de l'achievement ##
	var achievementTitle = RichTextLabel.new()
	achievementTitle.set_use_bbcode(true)
	if !unlocked:
		achievementTitle.set_bbcode(str("[color=gray][b]", global.get_achievement(achievement).title, "[/b][/color]"))
		if global.get_achievement(achievement).category == "secret":
			achievementTitle.set_bbcode("[color=gray][b]???[/b][/color]")
	else:
		achievementTitle.set_bbcode(str("[color=white][b]", global.get_achievement(achievement).title, "[/b][/color]"))
	achievementTitle.set_h_size_flags(3)
	achievementTitle.set_custom_minimum_size(Vector2(0,40))

	# Description de l'achievement
	var achievementDescription = RichTextLabel.new()
	achievementDescription.set_use_bbcode(true)
	if !unlocked:
		achievementDescription.set_bbcode(str("[color=grey][i]", global.get_achievement(achievement).description,"[/i][/color]"))
		if global.get_achievement(achievement).category == "secret":
			achievementDescription.set_bbcode("[color=gray]???[/color]")
	else:
		achievementDescription.set_bbcode(str("[color=white][i]", global.get_achievement(achievement).description,"[/i][/color]"))
	achievementDescription.set_h_size_flags(3)
	achievementDescription.set_custom_minimum_size(Vector2(0,40))

	# Ajout des enfants
	achievementContainer.add_child(achievementIcon)
	achievementTextContainer.add_child(achievementTitle)
	achievementTextContainer.add_child(achievementDescription)
	achievementContainer.add_child(achievementTextContainer)

	var tabName = tabContainer.get_tab_control(tabId).get_name()
	achievementControl.add_child(achievementContainer)
	tabContainer.get_node(tabName).get_node(tabName).add_child(achievementControl)
####################

######## Inputs ########
# Retour au menu principal avec le raccourci clavier
func _input(event):
	if event.type == InputEvent.KEY and event.pressed and event.is_action_pressed("menu"):
		_on_returnButton_pressed()

# Retour au menu principal avec le bouton Retour
func _on_returnButton_pressed():
	player.play_sound("menu")
	global.set_scene("res://scenes/menu/menu.tscn")
####################