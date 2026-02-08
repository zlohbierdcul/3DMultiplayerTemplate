class_name Player extends CharacterBody3D

@export_category("Settings")
@export var jump_strength := 4.5
@export var speed := 5.0
@export var speed_muliplier := 2.3

@export var state_machine: RewindableStateMachine

@onready var input: PlayerInput = $Input
@onready var tick_interpolator: TickInterpolator = $TickInterpolator
@onready var head: Node3D = $Head
@onready var hud: Control = $HUD
@onready var state_label: Label = $HUD/StateLabel
@onready var health_bar: ProgressBar = $HUD/HealthBar

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _logger := NetfoxLogger.new("fps", "Player")

var health := 100.0
var did_respawn := false
var death_tick := -1
var respawn_position := Vector3.ZERO

func _ready():
	#display_name.text = name
	#hud.hide()
	
	state_machine.state = &"Idle"
	state_machine.on_state_changed.connect(func(_old_state, _new_state):
		state_label.text = state_machine.state
	)
	health_bar.value = health
	NetworkTime.on_tick.connect(_tick)
	NetworkTime.after_tick_loop.connect(_after_tick_loop)

func _tick(dt: float, tick: int):
	if health <= 0:
		#$DieSFX.play()
		die()

func _after_tick_loop():
	if did_respawn:
		tick_interpolator.teleport()

func _rollback_tick(delta: float, tick: int, is_fresh: bool) -> void:
	# Handle respawn
	if tick == death_tick:
		global_position = respawn_position
		did_respawn = true
	else:
		did_respawn = false

	# Gravity
	_force_update_is_on_floor()
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle look left and right
	rotate_object_local(Vector3(0, 1, 0), input.look_angle.x)

	# Handle look up and down
	head.rotate_object_local(Vector3(1, 0, 0), input.look_angle.y)

	head.rotation.x = clamp(head.rotation.x, -1.57, 1.57)
	head.rotation.z = 0
	head.rotation.y = 0


func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity

func damage():
	#$HitSFX.play()
	if is_multiplayer_authority():
		health -= 34
		health_bar.value = health
		_logger.warning("%s HP now at %s", [name, health])

func die():
	if not is_multiplayer_authority():
		return

	_logger.warning("%s died", [name])
	respawn_position = get_parent().get_next_spawn_point(get_player_id())
	death_tick = NetworkTime.tick

	health = 100

func get_player_id() -> int:
	return input.get_multiplayer_authority()
