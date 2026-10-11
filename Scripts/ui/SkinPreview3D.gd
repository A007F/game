extends SubViewportContainer
class_name SkinPreview3D

var viewport: SubViewport
var camera: Camera3D
var pivot: Node3D
var active_mesh_node: Node3D = null

var is_dragging: bool = false
var drag_sensitivity: float = 0.01

func _ready() -> void:
	custom_minimum_size = Vector2(200, 200)
	_setup_viewport_scene()

func _setup_viewport_scene() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(200, 200)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = true
	add_child(viewport)

	pivot = Node3D.new()
	pivot.name = "Pivot"
	viewport.add_child(pivot)

	camera = Camera3D.new()
	camera.position = Vector3(0, 0.5, 2.0)
	camera.look_at(Vector3(0, 0.5, 0))
	viewport.add_child(camera)

	var light := DirectionalLight3D.new()
	light.position = Vector3(1, 2, 2)
	light.rotation_degrees = Vector3(-45, 45, 0)
	viewport.add_child(light)

func load_preview_mesh(mesh_node: Node3D) -> void:
	if active_mesh_node != null:
		active_mesh_node.queue_free()

	active_mesh_node = mesh_node
	if active_mesh_node != null:
		pivot.add_child(active_mesh_node)
		active_mesh_node.position = Vector3.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed

	if event is InputEventMouseMotion and is_dragging and pivot != null:
		pivot.rotate_y(event.relative.x * drag_sensitivity)
		pivot.rotate_x(event.relative.y * drag_sensitivity)

func _process(delta: float) -> void:
	# Idle auto-rotation when not dragging
	if not is_dragging and pivot != null:
		pivot.rotate_y(0.5 * delta)
