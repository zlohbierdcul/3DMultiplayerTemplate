class_name PlayerController extends Node

@export var _player_ref: Player
@export var _camera_input: CameraInput
@export var _player_input: PlayerInput
@export var _player_model: MeshInstance3D

const ROTATION_SPEED := 40.0




func _process_jump() -> void:
	if _player_input.jump_input > 0.0 and _player_ref.is_on_floor():
		_player_ref.velocity.y = _player_ref.JUMP_VELOCITY * _player_input.jump_input

func _physics_process_controller(delta: float) -> void:
	_process_jump()
	
	var camera_basis := _camera_input.get_camera_rotation_basis()
	var camera_x := camera_basis.x
	var camera_z := camera_basis.z
	
	camera_x.y = 0.0
	camera_x = camera_x.normalized()
	camera_z.y = 0.0
	camera_z = camera_z.normalized()
	
	var look_dir = -camera_z
	
	# Rotation
	if look_dir.length() > 0.001:
		var q_from = _player_ref.orientation.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(look_dir).basis.get_rotation_quaternion()
		_player_ref.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_SPEED))
	else:
		var q_from = _player_ref.orientation.basis.get_rotation_quaternion()
		var q_to = _camera_input.get_camera_mount_quaternion()
		_player_ref.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_SPEED))
	
	var horizontal_vel = _player_ref.velocity
	horizontal_vel.y = 0
	
	camera_basis = camera_basis.rotated(camera_basis.x, -camera_basis.get_euler().x)
	
	var input_dir := _player_input.input_dir

	var dir := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_pos := dir * _player_ref.SPEED
	horizontal_vel = horizontal_vel.lerp(target_pos, _player_ref.SPEED * delta)
	
	if horizontal_vel:
		_player_ref.velocity.x = horizontal_vel.x
		_player_ref.velocity.z = horizontal_vel.z
	else:
		_player_ref.velocity.x = move_toward(_player_ref.velocity.x, 0, _player_ref.SPEED)
		_player_ref.velocity.z = move_toward(_player_ref.velocity.z, 0, _player_ref.SPEED)
	
	_player_ref.move_and_slide()
	_player_ref.orientation.origin = Vector3()
	_player_ref.orientation = _player_ref.orientation.orthonormalized()
	_player_model.global_transform.basis = _player_ref.orientation.basis
	
