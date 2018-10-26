extends Node

func _ready():
	#### Placement ####
	get_node("oscilloscope").set_pos(Vector2(Globals.get("display/width"),Globals.get("display/height"))/2 - get_node("oscilloscope").get_size()/2*get_node("oscilloscope").get_scale().x)

	#### Préparation des nodes ####
	get_node("oscilloscope/playstop").connect("pressed", self, "_playstop")
	get_node("oscilloscope/close").connect("pressed", self, "_close")
	get_node("oscilloscope/screen").set_scale(Vector2(0.42,0.42))
	get_node("oscilloscope/mask").set_scale(Vector2(0.42,0.42))
	get_node("oscilloscope/mask").set_enabled(true)
	get_node("oscilloscope/mask").set_mode(3) # mode Mask
	get_node("oscilloscope/mask").set_item_mask(1024) # bit 10

	#### Affichage et traduction des textes ####
	get_node("oscilloscope/playstop").set_text("Play/Stop")

	#### Curseurs ####
	get_node("oscilloscope/playstop").set_default_cursor_shape(2)
	get_node("oscilloscope/close").set_default_cursor_shape(2)

	hide()

func set_signal(path):
	var texture = load(path)
	get_node("oscilloscope/signal").set_texture(texture)

	var x = get_node("oscilloscope/screen").get_pos().x + get_node("oscilloscope/screen").get_texture().get_size().x * get_node("oscilloscope/screen").get_scale().x - get_node("oscilloscope/signal").get_texture().get_size().x * get_node("oscilloscope/signal").get_scale().x
	var y = get_node("oscilloscope/screen").get_pos().y + get_node("oscilloscope/screen").get_size().y * get_node("oscilloscope/screen").get_scale().y - get_node("oscilloscope/signal").get_texture().get_size().y
	
	get_node("oscilloscope/signal").set_pos(Vector2(x,y))

	var tween = get_node("Tween")
	var animationDuration = get_node("oscilloscope/signal").get_texture().get_size().x/150 # 1s pour 150px

	var start = get_node("oscilloscope/screen").get_pos().x
	var end = x

	tween.interpolate_property(get_node("oscilloscope/signal"), "transform/pos", Vector2(start,50), Vector2(end,50), animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.set_repeat(true)

func _playstop():
	pass
	if get_node("Tween").is_active():
		get_node("Tween").stop_all()
	else:
		get_node("Tween").resume_all()

func _close():
	hide()

func show():
	get_node("oscilloscope").show()
	get_node("Tween").resume_all()

func hide():
	get_node("oscilloscope").hide()
	get_node("Tween").reset_all()
	get_node("Tween").stop_all()

func disable_exit():
	get_node("oscilloscope/close").set_disabled(true)
	get_node("oscilloscope/close").set_default_cursor_shape(0)