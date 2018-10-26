##### res://scripts/game/mini_encyclopedia.gd
#####
##### Gestion de la mini-encyclopédie présente dans les énigmes : récupération des entrées,
##### affichage des entrées et des titres, etc.


extends Control

var toc
var tree
var treeRoot

var content

var window

###################################### Initialisation
func _ready():
	window = get_node("ResizableWindowDialog")

	#### Affichage et traduction des textes statiques ####
	window.set_title(global.get_gui_text("buttonToEncyclopedia"))
	window.get_node("contentContainer/backToTocButton").set_text(global.get_gui_text("returnButton"))

	#### Configuration de la zone de texte ####
	content = window.get_node("contentContainer")
	content.set_pos(Vector2(10,0))
	content.set_size(window.get_size()-Vector2(20,10))
	content.get_node("entryContent").set_use_bbcode(true)
	content.hide()

	#### Affichage des entrées d'encyclopédie ####
	toc = window.get_node("tocContainer")
	toc.set_pos(Vector2(10,0))
	toc.set_size(window.get_size()-Vector2(20,10))
	tree = toc.get_node("Tree")
	get_node("encyclopediaFunctions").display_encyclopedia(tree)

#### Mise à jour de l'encyclopédie
func update():
	tree.clear()
	get_node("encyclopediaFunctions").display_encyclopedia(tree)


#### Sélection d'une entrée d'encyclopédie
func _on_Tree_cell_selected():
	var test = "(abc) def"
	if tree.get_selected().get_metadata(0)!=null:
		if global.get_state("unreadEntries").has(tree.get_selected().get_metadata(0)[0]):
			global.get_state("unreadEntries").remove(global.get_state("unreadEntries").find(tree.get_selected().get_metadata(0)[0]))
			tree.get_selected().set_text(0,tree.get_selected().get_text(0).split(str("(", global.get_gui_text("encyclopediaUnread"), ") "))[1])
		content.get_node("entryTitle").set_text(tree.get_selected().get_text(0))
		content.get_node("entryContent").set_bbcode(tree.get_selected().get_metadata(0)[1])
	content.show()
	toc.hide()
	tree.get_selected().deselect(0)


#### Retour à l'affichage des entrées d'encyclopédie
func _on_backToTocButton_pressed():
	toc.show()
	content.hide()

#### Affichage ou masquage de la mini-encycoplédie
func _on_Button_pressed():
	if get_node("ResizableWindowDialog").is_visible():
		get_node("ResizableWindowDialog").hide()
	else:
		get_node("ResizableWindowDialog").show()