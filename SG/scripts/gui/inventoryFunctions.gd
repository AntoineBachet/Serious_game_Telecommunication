##### res://scripts/gui/inventoryFunctions.gd
#####
##### Ce script contient les fonctions communes à l'inventaire et au mini-inventaire : 
##### l'ajout d'un objet et son affichage, et l'affichage de l'inventaire.

extends Node

var _itemsList # Dictionnaire des noms et descriptions des objets
var _itemsIcons # Dictionnaire avec icônes chargées à la volée s'il y a lieu

var _language 

######## Initialisation ########
func _ready():
	_language = settings.get_language()
	_itemsIcons = {}

	#### Chargement du dictionnaire avec noms et descriptions des objets ####
	_itemsList = global.json_into_dictionary("res://data/items.json")
####################

######## Ajout d'un objet dans l'ItemList ########
func _add_item(itemList, iconScale, itemCode, itemName, itemIcon, itemDescription, index):
	itemList.add_icon_item(itemIcon)
	itemList.set_icon_scale(iconScale)
	itemList.set_item_metadata(index, {"code": itemCode, "name": itemName, "description": itemDescription})
	itemList.set_max_columns(11)
#########################

######## Affichage de l'icône, du nom et de la description de l'objet item dans le cadre en bas ########
func display_item(iconScale, item, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel):
	Globals.set("selectedItem", item)

	var itemName
	var itemDescription

	if !_itemsList[item].name.has(_language):
		itemName = _itemsList[item].name["fr"]
		print("[Error : Missing text, language unavailable for name of item \"", item, "\" in items.json]")
	else:
		itemName = _itemsList[item].name[_language]
	if !_itemsList[item].description.has(_language):
		itemDescription = _itemsList[item].description["fr"]
		print("[Error : Missing text, language unavailable for description of item \"", item, "\" in items.json]")
	else:
		itemDescription = _itemsList[item].description[_language]

	if itemIconTextureFrame != null:
		itemIconTextureFrame.set_texture(_itemsIcons[item].default)
	itemNameLabel.clear()
	itemNameLabel.add_text(itemName)
	itemDescriptionLabel.clear()
	itemDescriptionLabel.add_text(itemDescription)
####################

######## Affichage dans l'inventaire de tous les objets possédés ########
func display_inventory(itemList, iconScale, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel):
	var m = 0		#numéro dans la node ItemList de l'item ajouté
	for item in _itemsList:
		var itemName
		var itemDescription

		if (str(item,"PickedUp") in Globals.get("gameState") and Globals.get("gameState")[str(item,"PickedUp")]) and !(Globals.get("gameState").has(str(item,"Used")) and Globals.get("gameState")[str(item,"Used")]):

			var itemIcon = load(str("res://assets/items/",item,".jpg"))			#chargement dynamique de l'icône
			_itemsIcons[item]={"default": itemIcon}

			if !_itemsList[item].name.has(_language):
				itemName = _itemsList[item].name["fr"]
				print("[Error : Missing text, language unavailable for name of item \"", item, "\" in items.json]")
			else:
				itemName = _itemsList[item].name[_language]
			if !_itemsList[item].description.has(_language):
				itemDescription = _itemsList[item].description["fr"]
				print("[Error : Missing text, language unavailable for description of item \"", item, "\" in items.json]")
			else:
				itemDescription = _itemsList[item].description[_language]

			_add_item(itemList, iconScale, item, itemName, _itemsIcons[item].default, itemDescription,m)
			m+=1
	itemList.show()

	# Sélection et affichage du premier objet de l'inventaire
	itemList.select(0)
	if itemList.get_item_metadata(0)!=null:			#Pour que ça ne plante pas quand on fait des tests d'énigmes avec un inventaire vide
		display_item(iconScale, itemList.get_item_metadata(0).code, itemIconTextureFrame, itemNameLabel, itemDescriptionLabel)

	# Déplacement avec les flèches (focus désactivé sur useButton et returnButton)
	itemList.grab_focus()
####################