class_name CameraInput extends Node3D

@export var camera: Camera3D
@export var camera_mount: Node3D
@export var camera_rot: Node3D
#@export var camera_spring: SpringArm3D

@export_range(0.0, 999.0, 0.5) var camera_mouse_movement_speed := 0.001
@export_range(0.0, 999.0, 0.5) var camera_vertical_movement := 4.0
@export_range(0.0, 90.0, 0.5) var camera_max_up_angle := 90.0
@export_range(0.0, 90.0, 0.5) var camera_max_down_angle := 60.0

var relative_cam := 0.0

func _ready() -> void:
	if multiplayer.get_unique_id() == owner.name.to_int():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_camera(event.relative * camera_mouse_movement_speed)

func rotate_camera(move: Vector2) -> void:
	camera_mount.rotate_y(-move.x)
	camera_mount.orthonormalize()
	
	camera_rot.rotation.x = clamp(
		camera_rot.rotation.x + (camera_vertical_movement * -move.y), 
		deg_to_rad(-camera_max_down_angle),
		deg_to_rad(camera_max_up_angle)
	)
	relative_cam = camera_rot.rotation.x

func get_camera_rotation_basis() -> Basis:
	return camera_rot.global_transform.basis
	
func get_camera_mount_quaternion() -> Quaternion:
	return camera_mount.global_transform.basis.get_rotation_quaternion()
