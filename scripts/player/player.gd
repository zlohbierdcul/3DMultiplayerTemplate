class_name Player extends CharacterBody3D

@export var max_speed: float = 7.0              # tune to your scale
@export var ground_accel: float = 60.0          # higher = snappier starts/counter-strafe
@export var air_accel: float = 15.0             # lower = more floaty
@export var friction: float = 8.0               # higher = faster stops
@export var stop_speed: float = 2.5             # minimum friction “control” speed
@export var air_wishspeed_cap: float = 3.0      # cap wishspeed USED for air accel (not actual velocity)

@export var auto_bhop: bool = false

@export var coyote_time: float = 0.08
@export var jump_buffer: float = 0.10

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

var current_speed := 0.0


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
	check_death(tick)
	rotate_head()
	apply_gravity(delta)
	


func check_death(tick: int):
	if tick == death_tick:
		global_position = respawn_position
		did_respawn = true
	else:
		did_respawn = false


func apply_gravity(delta: float) -> void:
	_force_update_is_on_floor()
	if not is_on_floor():
		velocity.y -= gravity * delta


func rotate_head() -> void:
	# Handle look left and right
	rotate_object_local(Vector3(0, 1, 0), input.look_angle.x)
	# Handle look up and down
	head.rotate_object_local(Vector3(1, 0, 0), input.look_angle.y)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(80))
	head.rotation.z = 0
	head.rotation.y = 0

func get_wishdir(input_move: Vector3) -> Vector3:
	# Yaw-only basis so movement doesn't follow pitch.
	if input_move.length_squared() < 0.0001:
		return Vector3.ZERO

	var yaw := rotation.y
	var yaw_basis := Basis(Vector3.UP, yaw)

	var local := Vector3(input_move.x, 0.0, input_move.z)
	return (yaw_basis * local).normalized()


func get_wishspeed(input_move: Vector3, speed: float) -> float:
	# input_move already clamped to length <= 1
	return speed * input_move.length()


func apply_friction(delta: float) -> void:
	var horiz := Vector3(velocity.x, 0.0, velocity.z)
	var speed := horiz.length()
	if speed < 0.001:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var control = max(speed, stop_speed)
	var drop = control * friction * delta
	var new_speed = max(speed - drop, 0.0)

	var scale = new_speed / speed
	velocity.x *= scale
	velocity.z *= scale


func accelerate(wishdir: Vector3, wishspeed: float, accel: float, delta: float) -> void:
	if wishdir == Vector3.ZERO or wishspeed <= 0.0:
		return

	var current_speed := velocity.dot(wishdir)
	var add_speed := wishspeed - current_speed
	if add_speed <= 0.0:
		return

	# Source-like: accel * dt * wishspeed
	var accel_speed := accel * delta * wishspeed
	if accel_speed > add_speed:
		accel_speed = add_speed

	velocity += wishdir * accel_speed


func ground_move(wishdir: Vector3, wishspeed: float, delta: float) -> void:
	apply_friction(delta)
	accelerate(wishdir, wishspeed, ground_accel, delta)


func air_move(wishdir: Vector3, wishspeed: float, delta: float) -> void:
	# cap only the wishspeed used for accel (not the actual velocity)
	var capped = min(wishspeed, air_wishspeed_cap)
	accelerate(wishdir, capped, air_accel, delta)


func net_move_and_slide() -> void:
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor


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


func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity


func get_player_id() -> int:
	return input.get_multiplayer_authority()
