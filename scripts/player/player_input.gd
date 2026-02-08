class_name PlayerInput extends BaseNetInput

@export var mouse_sensitivity := 1.0
@export var big_arm : Node3D
@export var hud : Control

@onready var camera : Camera3D = $"../Head/Camera3D"

var movement := Vector3.ZERO
var look_angle := Vector2.ZERO
var mouse_rotation := Vector2.ZERO
var jump := false
var run := false
var fire := false
var crouch := false

var override_mouse := false
var is_setup := false

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		override_mouse = false
		
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		mouse_rotation.y += event.relative.x * mouse_sensitivity
		mouse_rotation.x += event.relative.y * mouse_sensitivity
		
	if event.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		override_mouse = true

func _gather():
	if !is_setup:
		setup()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var mx = Input.get_axis("move_left", "move_right")
	var mz = Input.get_axis("move_forward", "move_backwards")
	movement = Vector3(mx, 0, mz)

	jump = Input.is_action_pressed("jump")
	fire = Input.is_action_pressed("attack")
	run = Input.is_action_pressed("sprint")
	crouch = Input.is_action_pressed("crouch")
	
	if override_mouse:
		look_angle = Vector2.ZERO
		mouse_rotation = Vector2.ZERO
	else:
		look_angle = Vector2(-mouse_rotation.y, -mouse_rotation.x)
		mouse_rotation = Vector2.ZERO

func setup():
	mouse_sensitivity = mouse_sensitivity / 1000
	is_setup = true
	camera.current = true
	big_arm.hide()
	hud.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
