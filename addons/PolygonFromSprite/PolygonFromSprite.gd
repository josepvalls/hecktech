tool
extends EditorPlugin

var stack_button = null
var current_object: Sprite = null

func _enter_tree():
	stack_button = Button.new()
	stack_button.text = "Polygon Frame"
	stack_button.connect("pressed", self, "convert_button_pressed")
	var editor_interface = get_editor_interface()
	var gui = editor_interface.get_base_control()
	stack_button.icon = gui.get_icon("Sprite", "EditorIcons")
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, stack_button)
	stack_button.hide()

func handles(object):
	if object is Sprite:
		current_object = object
		stack_button.show()
		return true
	else:
		current_object = null
		stack_button.hide()	
		return false

func clear():
	stack_button.hide()

func _exit_tree():
	if (stack_button):
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, stack_button)
		stack_button.queue_free()

func convert_button_pressed():
	prints("convert_button_pressed", current_object)
	if not current_object:
		return
	var p = Polygon2DArmatureAnimator.new()
	p.position = current_object.position
	var size = current_object.get_rect().size
	if current_object.centered:
		p.position -= size / 2
	var points = [
		Vector2.ZERO,
		Vector2(size.x/2, 0.0),
		Vector2(size.x, 0.0),
		Vector2(size.x, size.y/2),
		Vector2(size.x, size.y),
		Vector2(size.x/2, size.y),
		Vector2(0, size.y),
		Vector2(0, size.y/2),
	]
	p.polygon = points
	p.uv = points
	p.texture = current_object.texture
	current_object.get_parent().add_child(p)
	p.owner = current_object.owner
