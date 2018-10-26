##### res://scripts/menu/characterCustomization.gd
##### 
##### Menu de personnalisation de Victor

extends Control

var language

var hats

var hatSprite

var itemList

var buyPopup

var points = 0
var moneySpent = 0
var money = 0
var unlockedHats

######## Initialisation ########
func _ready():
	language = settings.get_language()

	#### Récupération et préparation des nodes d'intérêt ####
	buyPopup = get_node("buyPopup")
	hatSprite = get_node("VBoxContainer/HBoxContainer/PanelContainer/victor/hat")

	#### Affichage et traduction des textes ####
	get_node("VBoxContainer/menuTitle").set_text(global.get_gui_text("characterCustomizationButton"))
	get_node("VBoxContainer/returnButton").set_text(global.get_gui_text("returnButton"))
	buyPopup.get_cancel().set_text(global.get_gui_text("cancel"))
	buyPopup.get_ok().set_text(global.get_gui_text("buy"))
	buyPopup.set_title(global.get_gui_text("buy"))

	#### Récupération des points ####
	if Globals.get("gameState").has("score_quiz"):
		points = int(Globals.get("gameState")["score_quiz"])
	if Globals.get("gameState").has("moneySpent"):
		moneySpent = int(Globals.get("gameState")["moneySpent"])
	displayMoney()

	#### Récupération de la liste des chapeaux débloqués ####
	if !Globals.get("gameState").has("unlockedHats"):
		global.set_state("unlockedHats", [])
	unlockedHats = global.get_state("unlockedHats")

	#### Génération de la galerie des chapeaux ####
	itemList = get_node("VBoxContainer/HBoxContainer/VBoxContainer/ItemList")
	itemList.set_max_columns(4)

	hats = global.json_into_dictionary("res://data/hats.json")

	var i = 0
	for hat in hats:
		if (Globals.get("gameState").has("unlockedHats") and Globals.get("gameState")["unlockedHats"].has(hat)) or !(hats[hat].has("source") and hats[hat].source == "hidden"):
			var hatImage = load(str("res://assets/player/hats/",hat,".png"))
			if !unlockedHats.has(hat):
				var hatLockedImage = load(str("res://assets/player/hats/",hat,"_locked.png"))
				if !(hatLockedImage == null):
					hatImage = hatLockedImage
			itemList.add_item("", hatImage)
			itemList.set_item_metadata(i, hat)
			i+=1

	#### Affichage du chapeau actuellement porté par Victor le cas échéant ####
	if Globals.get("gameState").has("hat") and Globals.get("gameState")["hat"] != "":
		displayHat(Globals.get("gameState")["hat"])

	set_process_input(true)
####################

######## Affectation d'un chapeau à Victor et affichage sur le mannequin ########
func displayHat(hat):
	var hatImage = load(str("res://assets/player/hats/",hat,".png"))
	Globals.get("gameState")["hat"] = hat
	hatSprite.set_texture(hatImage)
	hatSprite.show()

func hideHat():
	Globals.get("gameState")["hat"] = ""
	hatSprite.hide()
####################

######## Double-clic sur un chapeau ########
func _on_ItemList_item_activated(index):
	var hat = itemList.get_item_metadata(index)
	if unlockedHats.has(hat):
		if Globals.get("gameState").has("hat") and Globals.get("gameState")["hat"] == hat:
			hideHat()
		else:
			displayHat(hat)
	else:
		if hats[hat].has("source") and hats[hat].source == "store":
			var cost = "0"
			if hats[hat].has("cost"):
				cost = hats[hat].cost
			buyPopup.set_text(global.get_gui_text("characterCustomizationBuyText") % [getHatName(hat),cost])
			buyPopup.popup()
			if int(cost) <= money:
				buyPopup.connect("confirmed", self, "buy_hat", [hat])
				buyPopup.get_ok().set_disabled(false)
			else:
				buyPopup.get_ok().set_disabled(true)
####################

######## Renvoie le nom dans la langue sélectionnée ou en français d'un chapeau ########
func getHatName(hatCode):
	var hatName = hats[hatCode].name
	if hatName.has(language):
		return hatName[language]
	else:
		return hatName["fr"]
####################

######## Acheter un chapeau ########
func buy_hat(hat):
	buyPopup.disconnect("confirmed", self, "buy_hat")

	var cost = 0
	if hats[hat].has("cost"):
		cost = int(hats[hat]["cost"])
	moneySpent += cost
	Globals.get("gameState")["moneySpent"] = moneySpent
	displayMoney()

	player.play_sound("coins")

	unlockedHats.append(hat)
	update_itemList_icon(hat)
	displayHatDescription(hat)
####################

######## Affichage de l'argent restant ########
func displayMoney():
	money = points - moneySpent
	var text = str("[right][img]res://assets/player/hats/coin_32.png[/img] ",str(money),"[/right]")
	get_node("VBoxContainer/HBoxContainer/PanelContainer/pointsDisplay").set_bbcode(text)
####################

######## Mise à jour de l'icone ########
func update_itemList_icon(h):
	var i = 0
	for hat in hats: # c'est un peu brutal mais c'est sans doute le plus simple ; sinon on peut stocker quelque part les couples chapeau + id
		print(hat)
		if Globals.get("gameState").has("unlockedHats") and Globals.get("gameState")["unlockedHats"].has(hat):
			print("unlocked")
			if hat == h:
				var hatImage = load(str("res://assets/player/hats/",hat,".png"))
				if !unlockedHats.has(hat):
					var hatLockedImage = load(str("res://assets/player/hats/",hat,"_locked.png"))
					if !(hatLockedImage == null):
						hatImage = hatLockedImage
				itemList.set_item_icon(i, hatImage)
			i+=1
####################

######## Inputs ########
# Retour au menu avec le bouton
func _on_returnButton_pressed():
	player.play_sound("menu")
	global.load_scene()

# Retour au menu avec le raccourci
func _input(event):
	if event.is_action_pressed("menu"):
		_on_returnButton_pressed()
	elif event.is_action_pressed("interactWithItem"):
		pass
		# si on est dans la pop-up, acheter
		# sinon, si quelque chose est sélectionné, _on_ItemList_item_activated(itemList.get_selected())*
####################

######## Affichage de la description du chapeau sélectionné ########
func _on_ItemList_item_selected(index):
	var hat = itemList.get_item_metadata(index)
	displayHatDescription(hat)

func displayHatDescription(hat):
	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Panel/hatDescription").set_use_bbcode(true)
	var text = str("[b]", hats[hat].name[language],"[/b]")
	if !unlockedHats.has(hat):
		text = str(text, " (", global.get_gui_text("characterCustomizationLocked"),")")
	text = str(text,"\n",hats[hat].description[language],"\n\n")
	if hats[hat].has("source"):
		text = str(text,"[i]",global.get_gui_text("characterCustomizationSource"), " ", global.get_gui_text(str("characterCustomization",hats[hat].source.capitalize())))
		if hats[hat].has("cost"):
			text = str(text," (", global.get_gui_text("characterCustomizationCost"), " ", hats[hat].cost, ")[/i]")

	get_node("VBoxContainer/HBoxContainer/VBoxContainer/Panel/hatDescription").set_bbcode(text)
####################