extends Node3D

@onready var camera = $Camera3D
var zoom := 10.0
var is_rotating := false
var is_panning := false
var last_mouse_pos := Vector2()

var camera_up_pos : Vector3 = Vector3(8.5,zoom/2,6.5)
var camera_up_rot : Vector3 = Vector3(0,0,0)
var camera_old_pos : Vector3 = Vector3()
var camera_old_rot : Vector3 = Vector3()

var camera_sw : bool = false

func _input(event):
	if get_viewport().gui_get_hovered_control() != null:
			return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = maxf(zoom - 0.25, 0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = minf(zoom + 0.25, 10)
		#zoom = clamp(zoom, 2.0, 30.0)

		if event.button_index == MOUSE_BUTTON_LEFT:
			is_rotating = event.pressed
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = event.pressed

	if event is InputEventMouseMotion:
		var delta = event.relative

		if is_rotating:
			rotate_y(-delta.x * 0.003)

		if is_panning:
			translate(Vector3(-delta.x, 0,-delta.y) * 0.015)

func _process(_delta):
	camera.transform.origin = Vector3(0, zoom,0 )
	pass

func _on_camera_sw_pressed() -> void:
	camera_sw = !camera_sw
	
	if camera_sw:
		camera_old_pos = position
		camera_old_rot = rotation
		
		position = camera_up_pos
		rotation = camera_up_rot
		
		camera.rotation_degrees.x = -90
	else:
		position = camera_old_pos
		rotation = camera_old_rot
		
		camera.rotation_degrees.x = -30
	pass 
