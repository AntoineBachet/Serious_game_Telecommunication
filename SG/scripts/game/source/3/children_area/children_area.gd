extends Node2D

var yPos

func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"children_area"})

	set_process(true)
	set_process_input(true)

	var victorPos = get_node("character").get_pos()
	yPos = victorPos.y


func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")


func _input(event):
	if event.type == InputEvent.KEY:
		if event.is_action_pressed("interactWithItem"):
			if global.character_in_hitbox("juliette"):
				interact_juliette()
			elif global.character_in_hitbox("doorToOutside"):
				interact_doorToOutside()
			elif global.character_in_hitbox("piscine"):
				interact_piscine()
			elif global.character_in_hitbox("doorToShop"):
				interact_doorToShop()

func interact_juliette():
	get_node("gui").set_text( global.get_game_text("interactJuliette") )

func interact_doorToOutside():
	global.set_target_node("doorToChildren")
	global.set_scene("res://scenes/game/source/3/outside.tscn")

func interact_piscine():
	_freeze()
	var piscineBorderPos = get_node("piscine/left").get_global_pos()
	var victorPos = get_node("character").get_pos()
	if victorPos.x < piscineBorderPos.x:
		jump_right1()
		get_node("AnimationPlayer").play("boules")
		get_node("gui").set_text( global.get_game_text("enterPiscine") )
		if !global.has_state("source_3_children_pool"):
			global.set_state("source_3_children_pool", "1")
		else:
			global.set_state("source_3_children_pool", str(int(global.get_state("source_3_children_pool"))+1))
			if int(global.get_state("source_3_children_pool"))>=20 and !global.get_state("source_3_children_poolAchievement"):
				global.set_state("source_3_children_poolAchievement", true)
	else:
		jump_left1()
		get_node("gui").set_text( global.get_game_text("exitPiscine") )
	get_node("character").set_pos(victorPos)

func interact_doorToShop():
	if global.get_state("source_3_shop_doorToChildrenUnlocked"):
		player.play_sound("woodendoor")
		global.set_target_node("doorToChildren")
		global.set_scene("res://scenes/game/source/3/shop.tscn")
	else:
		get_node("gui").set_text( global.get_game_text("interactDoor") )


func _freeze():
	get_node("gui").set_gui_off()
	get_node("character").freeze_character()

func _unfreeze(char, key):
	get_node("gui").set_gui_on()
	get_node("character").unfreeze_character()
	get_node("Tween").disconnect("tween_complete", self, "_unfreeze")


func jump_right1():
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x += 100
	endPos.y -= 75

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.connect("tween_complete", self, "jump_right2")

func jump_right2(char, key):
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x += 100
	endPos.y -= 25

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.disconnect("tween_complete", self, "jump_right2")
	tween.connect("tween_complete", self, "jump_right3")

func jump_right3(char, key):
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x += 100
	endPos.y += 25

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.disconnect("tween_complete", self, "jump_right3")
	tween.connect("tween_complete", self, "jump_right4")

func jump_right4(char, key):
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x += 100
	endPos.y = yPos

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.disconnect("tween_complete", self, "jump_right4")
	tween.connect("tween_complete", self, "_unfreeze")




func jump_left1():
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x -= 100
	endPos.y -= 75

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.connect("tween_complete", self, "jump_left2")

func jump_left2(char, key):
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x -= 100
	endPos.y -= 25

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.disconnect("tween_complete", self, "jump_left2")
	tween.connect("tween_complete", self, "jump_left3")

func jump_left3(char, key):
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x -= 100
	endPos.y += 25

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.disconnect("tween_complete", self, "jump_left3")
	tween.connect("tween_complete", self, "jump_left4")

func jump_left4(char, key):
	var tween = get_node("Tween")
	var animationDuration = 0.1
	var startPos = get_node("character").get_pos()
	var endPos = startPos
	endPos.x -= 100
	endPos.y = yPos

	tween.interpolate_property(get_node("character"), "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.disconnect("tween_complete", self, "jump_left4")
	tween.connect("tween_complete", self, "_unfreeze")