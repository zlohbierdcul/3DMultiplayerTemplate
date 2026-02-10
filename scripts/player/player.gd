class_name Player extends CharacterBody3D


#region Exports
@export_category("Dependencies")
@export var state_machine: RewindableStateMachine
@export var gun: Node3D

@export_category("Movement")
@export var mouse_sensitivity := 1.0
@export var jump_velocity := 5.0
@export var auto_bhop := false

@export_category("Ground Movement")
@export var walk_speed := 8.0
@export var run_speed := 10.0
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0

@export_category("Air Movement")
@export var air_cap := 0.85
@export var air_accel := 800.0
@export var air_speed := 500.0

@export_category("Camera")
@export_range(0.0, 1.0, 0.01) var headbob_amp := 1.0
@export_range(0.0, 1.0, 0.01) var headbob_freq := 1.0
#endregion


#region Imports
@onready var input: PlayerInput = $Input
@onready var tick_interpolator: TickInterpolator = $TickInterpolator
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var hud: Control = $HUD
@onready var floor_ray: RayCast3D = $FloorRay
@onready var collision_shape: CollisionShape3D = $CollisionShape
#endregion


#region Variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _logger := NetfoxLogger.new("fps", "Player")

var health := 100.0
var did_respawn := false
var death_tick := -1
var respawn_position := Vector3.ZERO
var wish_dir := Vector3.ZERO
var headbob_time := 0.0
#endregion


#region Life Cycle
func _ready():
	state_machine.state = &"Idle"
	NetworkTime.on_tick.connect(_tick)
	NetworkTime.after_tick_loop.connect(_after_tick_loop)


func _tick(_dt: float, _tick: int):
	if health <= 0:
		#$DieSFX.play()
		die()


func _after_tick_loop():
	if did_respawn:
		tick_interpolator.teleport()


func _rollback_tick(delta: float, tick: int, _is_fresh: bool) -> void:
	check_death(tick)
	handle_rotation()
#endregion


#region Movement
func handle_rotation() -> void:
	rotate_object_local(Vector3(0, 1, 0), input.look_angle.x)
	head.rotate_object_local(Vector3(1, 0, 0), input.look_angle.y)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(80))
	head.rotation.z = 0
	head.rotation.y = 0


func handle_ground_physics(delta: float) -> void:
	apply_gravity(delta)
	apply_friction(delta)
	
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_dir
		
	if is_multiplayer_authority():
		handle_view_bob(delta)


func handle_air_physics(delta: float) -> void:
	apply_gravity(delta)
	
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var capped_speed = min((air_speed * wish_dir).length(), air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_dir
	
	# Strafing
	if is_on_wall():
		if is_surface_too_steep(get_wall_normal()):
			motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_wall_normal(), 1.0, delta)


func handle_view_bob(delta: float) -> void:
	var f = headbob_freq * 10.0
	var a = headbob_amp / 10.0
	headbob_time += delta * velocity.length()
	var bob = Vector3(
		cos(headbob_time * f * 0.5) * a,
		sin(headbob_time * f) * a,
		0
	)
	camera.transform.origin = bob


func apply_gravity(delta: float) -> void:
	force_update_is_on_floor()
	if not is_on_floor():
		velocity.y -= gravity * delta


func apply_friction(delta: float) -> void:
	var control = max(velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(velocity.length() - drop, 0.0)
	if velocity.length() > 0:
		new_speed /= velocity.length()
	velocity *= new_speed


func clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	var backoff := velocity.dot(normal) * overbounce
	if backoff >= 0: return
	var change := normal * backoff
	velocity -= change
	
	var adjust := velocity.dot(normal)
	if adjust < 0.0:
		velocity -= normal * adjust


func is_surface_too_steep(normal: Vector3) -> bool:
	var max_slope_angle_dot := Vector3.UP.rotated(Vector3(1.0, 0.0, 0.0), floor_max_angle).dot(Vector3.UP)
	return normal.dot(Vector3.UP) < max_slope_angle_dot


func get_move_speed() -> float:
	return run_speed if input.run else walk_speed
#endregion


#region Actions
func check_death(tick: int):
	if tick == death_tick:
		global_position = respawn_position
		did_respawn = true
	else:
		did_respawn = false


func damage():
	#$HitSFX.play()
	if is_multiplayer_authority():
		health -= 34
		_logger.warning("%s HP now at %s", [name, health])


func die():
	if not is_multiplayer_authority():
		return

	_logger.warning("%s died", [name])
	respawn_position = get_parent().get_next_spawn_point(get_player_id())
	death_tick = NetworkTime.tick

	health = 100
#endregion


#region Utils
func force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity


func net_move_and_slide() -> void:
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor


func get_jump_height() -> float:
	if not floor_ray.is_colliding(): return 0.0
	return (position.y - collision_shape.shape.height / 2) - floor_ray.get_collision_point().y


func get_player_id() -> int:
	return input.get_multiplayer_authority()
#endregion
