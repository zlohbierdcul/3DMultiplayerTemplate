extends Node

@export var _player_ref: Player
@export var _camera_input: CameraInput
@export var _player_input: PlayerInput

var orientation := Transform3D()

func _process_jump() -> void:
	if _player_input.jump_input > 0.0 and _player_ref.is_on_floor():
		_player_ref.velocity.y = _player_ref.JUMP_VELOCITY * _player_input.jump_input

func _physics_process_controller() -> void:
	_process_jump()
	
	var camera_basis := _camera_input.get_camera_rotation_basis()
	var camera_x := camera_basis.x
	var camera_z := camera_basis.z
	
	camera_x.y = 0.0
	camera_x = camera_x.normalized()
	camera_z.y = 0.0
	camera_z = camera_z.normalized()
	
	var look_dir = camera_z
