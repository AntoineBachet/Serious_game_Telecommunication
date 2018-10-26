extends CanvasLayer

var scene

func _ready():
	pass

func fadeTo(scene):
	self.scene = scene
	get_node("AnimationPlayer").play("fade")

func change_scene(): # Appelée au milieu de l'animation
	if scene != "":
		global.changeScene(scene)