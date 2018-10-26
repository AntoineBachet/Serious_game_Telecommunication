##### res://scripts/game/tobecontinued.gd
#####
##### Script de la scène qui s'affiche quand on arrive à la fin d'une branche non complète

extends Control

func _ready():
	get_node("tobecontinued").set_text(global.get_gui_text("tobecontinued"))

	if !(global.get_state("ligne_1_finished") and global.get_state("source_3_finished") and global.get_state("canal_1_finished")):
		get_node("riddleOverlay").set_text(global.get_gui_text("tobecontinuedText"))
	else:
		get_node("riddleOverlay").set_text(global.get_gui_text("tobecontinuedText2"))
	get_node("riddleOverlay").set_encyclopedia_enabled(false)
	get_node("riddleOverlay").set_inventory_enabled(false)
	
	get_node("reportButton").set_text(global.get_gui_text("reportButton"))

func _on_reportButton_pressed():
	OS.shell_open(global.get_gui_text("reportURL"))