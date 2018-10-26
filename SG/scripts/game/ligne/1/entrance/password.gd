extends Sprite

func _ready():
	connect("visibility_changed", self, "_on_visibility_changed")

func _input(event):
	if event.type == InputEvent.KEY and event.scancode == KEY_RETURN and is_visible():
		get_parent()._on_password_pressed()

func _on_visibility_changed():
	if is_visible():
		get_node("LineEdit").grab_focus()
		set_process_input(true)
	else:
		set_process_input(false)