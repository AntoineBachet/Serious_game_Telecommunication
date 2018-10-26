##### res://scripts/gui/encyclopediaFunctions.gd
#####
##### Ce script contient display_encyclopedia, fonction commune à l'encyclopédie principale et 
##### à la mini-encyclopédie

extends Node

var _entriesList
var _language

######## Initialisation ########
func _ready():
	_language = settings.get_language()

	#### Chargement du dictionnaire avec titre et contenu des entrées ####
	_entriesList = global.encyclopedia
####################

######## Affichage dans l'encyclopédie de toutes les entrées ########
func display_encyclopedia(tree):
	var treeRoot = tree.create_item()
	tree.set_hide_root(true)

	for n in _entriesList:
		if Globals.get("gameState").has(str(n,"Unlocked")) and Globals.get("gameState")[str(n,"Unlocked")]:
			var chapter = tree.create_item(treeRoot)
			if _entriesList[n].title.has(_language):
				chapter.set_text(0, _entriesList[n].title[_language])
			else:
				chapter.set_text(0, _entriesList[n].title["fr"])
				print(str("[Error : Missing text, title unavailable in language for \"", n, "\" in encyclopedia.json. Displaying French version.]"))
			chapter.set_selectable(0, false)
			if "entries" in _entriesList[n]: #Un niveau de profondeur
				for v in _entriesList[n].entries:
					if Globals.get("gameState").has(str(n,"_",v,"Unlocked")) and Globals.get("gameState")[str(n,"_",v,"Unlocked")]:
						var entry = tree.create_item(chapter)

						var title
						if _entriesList[n].entries[v].title.has(_language):
							title = _entriesList[n].entries[v].title[_language]
						else:
							title = _entriesList[n].entries[v].title["fr"]
							print(str("[Error : Missing text, title unavailable in language for \"", n, "/", v, "\" in encyclopedia.json. Displaying French version.]"))
						if global.has_state("unreadEntries") and global.get_state("unreadEntries").has(str(n,"_",v)):
							title = str("(", global.get_gui_text("encyclopediaUnread"), ") ", title)
						entry.set_text(0, title)

						if _entriesList[n].entries[v].content.has(_language):
							entry.set_metadata(0, [str(n,"_",v),_entriesList[n].entries[v].content[_language]])
						else:
							entry.set_metadata(0, [str(n,"_",v),_entriesList[n].entries[v].content["fr"]])
							print(str("[Error : Missing text, content unavailable in language for \"", n, "/", v, "\" in encyclopedia.json. Displaying French version.]"))
						entry.set_tooltip(0, global.get_gui_text("encyclopediaTooltip"))
			else: #Deux niveaux de profondeur
				for v in _entriesList[n].sections:
					if Globals.get("gameState").has(str(n,"_",v,"Unlocked")) and Globals.get("gameState")[str(n,"_",v,"Unlocked")]:	#Déverrouillage section
						var section = tree.create_item(chapter)
						if _entriesList[n].sections[v].title.has(_language):
							section.set_text(0, _entriesList[n].sections[v].title[_language])
						else:
							section.set_text(0, _entriesList[n].sections[v].title["fr"])
							print(str("[Error : Missing text, title unavailable in language for \"", n, "/", v, "\" in encyclopedia.json. Displaying French version.]"))
						section.set_selectable(0, false)
						for w in _entriesList[n].sections[v].entries:
							if Globals.get("gameState").has(str(n,"_",v,"_",w,"Unlocked")) and Globals.get("gameState")[str(n,"_",v,"_",w,"Unlocked")]:	#Déverrouillage entrée
								var entry = tree.create_item(section)
								var title
								if _entriesList[n].sections[v].entries[w].title.has(_language):
									title = _entriesList[n].sections[v].entries[w].title[_language]
								else:
									title = _entriesList[n].sections[v].entries[w].title["fr"]
									print(str("[Error : Missing text, title unavailable in language for \"", n, "/", v, "/", w, "\" in encyclopedia.json. Displaying French version.]"))
								if global.has_state("unreadEntries") and global.get_state("unreadEntries").has(str(n,"_",v,"_",w)):
									title = str("(", global.get_gui_text("encyclopediaUnread"), ") ", title)
								entry.set_text(0, title)
								
								if _entriesList[n].sections[v].entries[w].content.has(_language):
									entry.set_metadata(0, [str(n,"_",v,"_",w),_entriesList[n].sections[v].entries[w].content[_language]])
								else:
									entry.set_metadata(0, [str(n,"_",v,"_",w),_entriesList[n].sections[v].entries[w].content["fr"]])
									print(str("[Error : Missing text, content unavailable in language for \"", v, w, "\" in encyclopedia.json. Displaying French version.]"))
								entry.set_tooltip(0, global.get_gui_text("encyclopediaTooltip"))
####################