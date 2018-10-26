extends Control

var frequencySliderValue
var canalSliderValue
var frequencySlider
var canalSlider

var rightCanal
var rightFrequency

var playerAnswer = ""
var rightAnswer

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"storage"})

	set_process(true)

	#### Affichage et traduction des textes ####
	get_node("riddleOverlay").set_tip( global.get_game_text("carRiddleTip") )
	get_node("scanButton").set_text( global.get_game_text("carRiddleScanButton") )
	get_node("instructions").set_use_bbcode(true)
	get_node("instructions").set_bbcode( global.get_game_text("carRiddleInstructions") )

	#### Connexion des boutons ####
	get_node("glovebox/TextureButton").connect("pressed", self, "glovebox_toggle")
	get_node("glovebox_open/TextureButtonTop").connect("pressed", self, "glovebox_toggle")
	get_node("glovebox_open/TextureButtonBottom").connect("pressed", self, "glovebox_toggle")
	get_node("glovebox_open/hat").connect("pressed", self, "_on_hat_pressed")
	get_node("steeringWheel/horn").connect("pressed", self, "_on_horn_pressed")

	#### Préparation des nodes ####
	get_node("oscilloscope").set_signal("res://assets/game/source/3/storage/carCode.png")
	frequencySlider = get_node("frequencySlider")
	frequencySliderValue = get_node("frequencySlider/frequencySliderValue")
	frequencySliderValue.set_text(str(frequencySlider.get_min()))
	canalSlider = get_node("canalSlider")
	canalSliderValue = get_node("canalSlider/canalSliderValue")
	canalSliderValue.set_text(str(canalSlider.get_min()))
	get_node("steeringWheel/horn").set_default_cursor_shape(2)
	get_node("scanButton").set_default_cursor_shape(2)
	get_node("glovebox/TextureButton").set_default_cursor_shape(2)
	get_node("glovebox_open/TextureButtonTop").set_default_cursor_shape(2)
	get_node("glovebox_open/TextureButtonBottom").set_default_cursor_shape(2)
	get_node("glovebox_open/hat").set_default_cursor_shape(2)

	#### Récupération de l'énigme ####
	var riddle = global.get_riddle("car")
	rightFrequency = riddle["frequency"]
	rightCanal = riddle["canal"]
	get_node("codepad").set_code(riddle["answer"])
	get_node("codepad").set_max_size(riddle["answer"].length())
	get_node("codepad").connect("right_input", self, "right_code")

	# Traduction de l'image 1
	var code1Image
	if riddle["code1"].has(settings.get_language()):
		code1Image = load(riddle["code1"][settings.get_language()])
	else:
		code1Image = load(riddle["code1"]["fr"])
	get_node("VBoxContainer/carRiddle1").set_texture(code1Image)

	update()
####################

func _process(delta):
	if global.get_used_item() != "":
		if global.get_used_item() == "tutorial_1_house_oscilloscope":
			if global.get_state("source_3_storage_carRiddleRadioScanned"):
				get_node("oscilloscope").show()
			else:
				get_node("riddleOverlay").set_text( global.get_game_text("carRiddleOscilloBeforeScan") )
		global.set_used_item("")

######## Radio ########
func _on_frequencySlider_value_changed( value ):
	get_node("frequencySlider/frequencySliderValue").set_text( str(value) )

func _on_canalSlider_value_changed( value ):
	get_node("canalSlider/canalSliderValue").set_text( str(value) )

func _on_scanButton_pressed():
	if frequencySlider.get_value() == float(rightFrequency) and canalSlider.get_value() == float(rightCanal):
		get_node("riddleOverlay").set_text( global.get_game_text("carRiddleRight") )
		player.play_sound("right")
		global.set_state("source_3_storage_carRiddleRadioScanned", true)
		update()
	else:
		get_node("riddleOverlay").set_text( global.get_game_text("carRiddleWrong") )
		player.play_sound("wrong")
####################

func right_code():
	global.set_state("source_3_storage_carRiddleCode", true)
	update()

######## Glovebox ########
func glovebox_toggle():
	if global.get_state("source_3_storage_carRiddleCode"):
		global.set_state("source_3_storage_carRiddleBoxOpen", !global.get_state("source_3_storage_carRiddleBoxOpen"))
		player.play_sound("metal_on_metal")
		update()
	else:
		get_node("riddleOverlay").set_text( global.get_game_text("carRiddleBoxBeforeCode") )

func _on_hat_pressed():
	global.unlock_hat("wizard_hat")
	get_node("glovebox_open/hat").hide()
####################

######## Steering wheel ########
func _on_horn_pressed():
	player.play_sound("horn")
####################

func update():
	if global.get_state("source_3_storage_carRiddleRadioScanned"):
		get_node("scanButton").set_disabled(true)
		get_node("scanButton").set_default_cursor_shape(0)
		get_node("canalSlider").set_ignore_mouse(true)
		get_node("frequencySlider").set_ignore_mouse(true)
	if global.get_state("source_3_storage_carRiddleCode"):
		get_node("riddleOverlay").disable_tip()
		get_node("codepad").disable_pad()
	if global.get_state("source_3_storage_carRiddleBoxOpen"):
		get_node("glovebox").hide()
		get_node("glovebox_open").show()
	else:
		get_node("glovebox").show()
		get_node("glovebox_open").hide()
	if global.has_hat("wizard_hat"):
		get_node("glovebox_open/hat").hide()

func cheat():
	global.set_state("source_3_storage_carRiddleRadioScanned", true)
	global.set_state("source_3_storage_carRiddleCode", true)
	global.set_state("source_3_storage_carRiddleBoxOpen", true)
	update()