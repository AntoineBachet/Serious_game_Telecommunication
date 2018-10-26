
extends Node

var currentGameObject
var objets 
var cuteRobotpos
var initPos = {}

var blocSize = 105 ### Largeur d'un bloc avec UNE SEULE bordure
var sizeRelative = {}

func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"controlRoom"})

	#### Affichage et traduction des textes ####
	get_node("Label").set_text(global.get_game_text("controlRobotText"))
	get_node("resetButton").set_text(global.get_gui_text("resetButton"))

	objets = ["blocs/Victor","blocs/Poubelle", "blocs/Poubelle2", "blocs/Velo", "blocs/Obstacle1", "blocs/Obstacle2", "blocs/Obstacle3", "blocs/Obstacle4", "blocs/Obstacle5", "blocs/Obstacle6", "blocs/Obstacle7", "blocs/Obstacle8"]
	sizeRelative = {"blocs/Victor":[2,1],"blocs/Poubelle":[1,1], "blocs/Poubelle2":[1,1], "blocs/Velo":[2,1], "blocs/Obstacle1":[1,3], "blocs/Obstacle2":[1,3], "blocs/Obstacle3":[1,2], "blocs/Obstacle4":[1,2], "blocs/Obstacle5":[2,1], "blocs/Obstacle6":[3,1], "blocs/Obstacle7":[3,1], "blocs/Obstacle8":[1,2]}

	currentGameObject = get_node("blocs/Poubelle")
	cuteRobotpos = currentGameObject.get_pos()

	get_node("resetButton").connect("pressed", self, "reset_pos")
	get_node("resetButton").set_default_cursor_shape(2)
	for o in objets:
		moveBloc(get_node(o))
		initPos[o] = get_node(o).get_pos()

	set_process(true)
	
func _process(delta):
	
	get_node("blocs/cuteRobot").set_pos(currentGameObject.get_pos())
	
	## Arrivée de Victor à la porte
	if get_node("door").overlaps_body(get_node("blocs/Victor")):
		if !global.get_state("source_2_controlRoom_controlRobotSolved"):
			_riddle_solved()
		
	else:
		if Input.is_action_pressed("ui_up"):
			currentGameObject.move(Vector2(0,-3))
		elif Input.is_action_pressed("ui_down"):
			currentGameObject.move(Vector2(0,3))
		elif Input.is_action_pressed("ui_left"):
			currentGameObject.move(Vector2(-3,0))
		elif Input.is_action_pressed("ui_right"):
			currentGameObject.move(Vector2(3,0))
		else:
			moveBloc(currentGameObject)

		

func _riddle_solved():
	global.set_state("source_2_finished", true)
	global.set_state("source_2_controlRoom_controlRobotSolved", true)
	get_node("riddleOverlay").riddle_solved(3)

func cheat():
	_riddle_solved()
	
func _on_ButtonVelo_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Velo")
func _on_ButtonPoubelle_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Poubelle")
func _on_ButtonPoubelle2_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Poubelle2")
func _on_ButtonVictor_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Victor")
func _on_Button1_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle1")	
func _on_Button2_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle2")
func _on_Button3_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle3")
func _on_Button4_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle4")
func _on_Button5_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle5")
func _on_Button6_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle6")
func _on_Button7_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle7")
func _on_Button8_pressed():
	moveBloc(currentGameObject)
	get_node("blocs/cuteRobot").show()
	currentGameObject = get_node("blocs/Obstacle8")


func reset_pos():
	for o in objets:
		get_node(o).set_pos( initPos[o] )

func moveBloc(bloc):
	var startPos = bloc.get_pos()
	var endPos = startPos
	
	if sizeRelative[ "blocs/" + bloc.get_name() ][0] % 2 == 0:
		endPos.x = movePair(startPos.x)
	else:
		endPos.x = moveImpair(startPos.x)
	
	if sizeRelative[ "blocs/" + bloc.get_name() ][1] % 2 == 0:
		endPos.y = movePair(startPos.y)
	else:
		endPos.y = moveImpair(startPos.y)
	
	var tween = get_node("Tween")
	var animationDuration = 0.15
	tween.interpolate_property(bloc, "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func movePair(x):
	if x > 0:
		var k = int( (x + (blocSize / 2)) / blocSize )
		if k > 2:
			k = 2
		return k * blocSize
	else:
		var k = int( (x - (blocSize / 2)) / blocSize )
		if k < -2:
			k = -2
		return k * blocSize

func moveImpair(x):
	var k = int(x / blocSize)
	if k > 2:
		k = 2
	elif k < -2:
		k = -2
	if x > 0:
		return k * blocSize + blocSize / 2
	else:
		return k * blocSize - blocSize / 2
