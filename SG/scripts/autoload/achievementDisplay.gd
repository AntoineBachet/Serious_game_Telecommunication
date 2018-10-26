##### res://scripts/gui/achievementDisplay.gd
#####
##### Ce script permet l'affichage des achievements au moment où ils sont débloqués dans le jeu

extends CanvasLayer

var _achievementIcon
var _achievementTitle
var _achievementDescription
var _achievementDisplayTimer

var _achievementConditions = {}

var _playing = false
var _i = 0

var _queue = []

######## Initialisation ########
func _ready():
	#### Récupération des nodes d'intérêt
	_achievementIcon = get_node("achievementContainer/achievementContainer/achievementIcon")
	_achievementTitle = get_node("achievementContainer/achievementContainer/achievementTextContainer/achievementTitle")
	_achievementDescription = get_node("achievementContainer/achievementContainer/achievementTextContainer/achievementDescription")
	_achievementDisplayTimer = get_node("achievementDisplayTimer")

	#### Récupération des conditions de réalisation des achievements ####
	var achievements = global.achievements
	for achievement in achievements:
		_achievementConditions[achievement] = {}
		_achievementConditions[achievement].conditions = achievements[achievement].conditions
		if achievements[achievement].has("type"):
			_achievementConditions[achievement].conditionType = achievements[achievement].type
####################

######## Demande d'affichage d'achievement tant qu'il y en a à afficher ########
func _process(delta):
	for achievement in _queue:
		_display_achievement(achievement)
####################

######## Recherche des achievements réalisés et pas encore affichés ########
func check_achievements():
	for achievement in _achievementConditions:
		if !global.is_displayed_achievement(achievement):
			if !_achievementConditions[achievement].has("conditionType") or _achievementConditions[achievement].conditionType == "and":
				var u = 0
				for condition in _achievementConditions[achievement].conditions:
					if global.get_state(condition):
						u+=1
				if u == _achievementConditions[achievement].conditions.size(): # and
					_add_to_queue(achievement)
			elif _achievementConditions[achievement].conditionType == "or":
				var u = 0
				for condition in _achievementConditions[achievement].conditions:
					if global.get_state(condition):
						u+=1
				if u > 0: # or
					_add_to_queue(achievement)
			# Non testé
			elif _achievementConditions[achievement].conditionType == "andor":
				var u = 0
				for conditions in _achievementConditions[achievement].conditions:
					var v = 0
					for condition in _achievementConditions[achievement].conditions[conditions]:
						if global.get_state(condition):
							v+=1
					if v > 0: # or
						u+=1
				if u == _achievementConditions[achievement].conditions.size(): # and
					_add_to_queue(achievement)
			elif _achievementConditions[achievement].conditionType == "orandor":
				var u = 0
				for conditionsList in _achievementConditions[achievement].conditions:
					var v = 0
					for conditions in _achievementConditions[achievement].conditions[conditionsList]:
						var w = 0
						for condition in _achievementConditions[achievement].conditions[conditionsList][condition]:
							if global.get_state(condition):
								w += 1
						if w > 0: # or
							v += 1
					if v == _achievementConditions[achievement].conditions[conditionsList].size(): # and
						u += 1
				if u > 0: # or
					_add_to_queue(achievement)

	set_process(true)
####################

######## Mise en attente d'un achievement pour affichage ########
func _add_to_queue(achievement):
	if not achievement in _queue:
		_queue.append(achievement)
####################

######## Affichage d'un achievement ########
func _display_achievement(achievement):
	if !_playing:
		_queue.remove(_queue.find(achievement))
		_playing = true
		player.play_sound("achievement")

		#### Remplissage de la pop-up d'achievement ####
		var icon = load(str("res://assets/achievements/",achievement,".png"))
		_achievementIcon.set_texture(icon)
		_achievementTitle.set_bbcode(str("[i]", global.get_gui_text("achievementUnlocked"), "[/i]\n","[b]",global.get_achievement(achievement).title,"[/b]"))
		_achievementDescription.set_bbcode(global.get_achievement(achievement).description)

		#### Réglage du timer et lancement de l'animation ####
		_achievementDisplayTimer.set_wait_time(5)
		get_node("AnimationPlayer").play("achievement_pop_up")
		global.set_state(str("achievement_",achievement,"_displayed"), true)
		_achievementDisplayTimer.start()
		_achievementDisplayTimer.set_one_shot(true)

func _on_achievementDisplayTimer_timeout():
	get_node("AnimationPlayer").play("achievement_pop_out")

func _on_AnimationPlayer_finished():
	_i += 1
	if _i == 2: # deux animations doivent être jouées pour que l'achievement ait fini d'être affiché
		_playing = false
		_i = 0
		if _queue == []:
			set_process(false)
####################