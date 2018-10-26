extends Control

var _size = 5
var _encoded_bit = 3
var _keys=[]

func _ready():
	var row
	var codepad = get_node("codepad")
	
	var i = 5
	for k in range (0,14):
		if i == 0 :
			row = HBoxContainer.new()
			codepad.add_child(row)
			
		i += 1
		var button = Button.new()
		button.set_text("1 ou 0")
		button.set_custom_minimum_size(Vector2(174,198))
		button.connect("pressed", self, "_press_key", [k])
		button.set_toggle_mode(true)
		button.set_default_cursor_shape(2)
#		button.add_to_group("codepad_keys")
		_keys.append(button)
		row.add_child(button)

		if i == 5:
			i = 0
