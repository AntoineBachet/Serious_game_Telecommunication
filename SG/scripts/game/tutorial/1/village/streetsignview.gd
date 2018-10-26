extends Control

######## Initialisation ########
func _ready():
	global.set_details({"area":"tutorial", "level":"1", "scene":"village"})

	set_process_input(true)
	set_process(true)
####################

func _process(delta):
	#### Utilisation d'objets ####
	if global.get_used_item() != "":
		global.set_used_item("")