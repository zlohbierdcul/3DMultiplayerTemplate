class_name PlayerInput extends BaseNetInput

@export var character: Player
@export var big_arm : Node3D
@export var hud : Control

@onready var camera : Camera3D = $"../Head/Camera3D"

var look_angle := Vector2.ZERO
var mouse_rotation := Vector2.ZERO

var movement := Vector3.ZERO
var _movement_buffer := Vector3.ZERO
var _movement_samples := 0

var run := false
var _run_buffer := false

var fire := false
var _fire_buffer := false

var crouch := false
var _crouch_buffer := false

var jump_pressed := false
var _jump_pressed_buffer := false

var jump_held := false
var _jump_held_buffer := false

var toggle_debug := false
var _toggle_debug_buffer := false

var override_mouse := false
var is_setup := false

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		override_mouse = false


func _process(_delta: float) -> void:
	# Movement
	var mx = Input.get_axis("move_left", "move_right")
	var mz = Input.get_axis("move_forward", "move_backwards")
	
	var v := Vector2(mx, mz)
	if v.length() > 1.0:
		v = v.normalized()
	
	_movement_buffer += Vector3(v.x, 0.0, v.y)
	_movement_samples += 1
	
	# Jump
	if Input.is_action_pressed("jump"):
		_jump_held_buffer = true
	if Input.is_action_just_pressed("jump"):
		_jump_pressed_buffer = true

	
	# Run
	
	# Fire
	
	# Crouch
	
	# Debug
	if Input.is_action_just_pressed("debug"):
		print("[PlayerInput] Debug pressed!")
		_toggle_debug_buffer = true


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		mouse_rotation.y += event.relative.x * character.mouse_sensitivity
		mouse_rotation.x += event.relative.y * character.mouse_sensitivity
		
	if event.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		override_mouse = true


func _gather():
	if !is_setup:
		setup()
	
	# Movement
	if _movement_samples > 0:
		movement = _movement_buffer / _movement_samples
	else:
		movement = Vector3.ZERO
	_movement_buffer = Vector3.ZERO
	_movement_samples = 0
	
	# Jump
	jump_pressed = _jump_pressed_buffer
	_jump_pressed_buffer = false
	jump_held = _jump_held_buffer
	_jump_held_buffer = false
	
	# Fire
	fire = Input.is_action_pressed("attack")
	
	# Run
	run = Input.is_action_pressed("sprint")
	
	# Crouch
	crouch = Input.is_action_pressed("crouch")

	# Debug
	toggle_debug = _toggle_debug_buffer
	_toggle_debug_buffer = false
	
	if override_mouse:
		look_angle = Vector2.ZERO
		mouse_rotation = Vector2.ZERO
	else:
		look_angle = Vector2(-mouse_rotation.y, -mouse_rotation.x)
		mouse_rotation = Vector2.ZERO


func setup():
	character.mouse_sensitivity = character.mouse_sensitivity / 1000
	is_setup = true
	camera.current = true
	big_arm.hide()
	hud.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
