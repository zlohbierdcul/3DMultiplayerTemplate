class_name Player extends CharacterBody3D

@export var _player_controller: PlayerController
@export var _player_input: PlayerInput
@export var _camera_input: CameraInput

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var orientation := Transform3D()

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree() -> void:
	_player_input.set_multiplayer_authority(str(name).to_int())
	_camera_input.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	_player_controller._physics_process_controller(delta)
