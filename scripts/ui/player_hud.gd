class_name PlayerHUD extends Control

@export var character: Player
@export var input: PlayerInput

@onready var health_bar: ProgressBar = $HealthBar
@onready var debug_hud: DebugHUD = $Debug

var debug := false

func _rollback_tick(_delta: float, _tick: int, _is_fresh: bool) -> void:
	if input.toggle_debug:
		debug = !debug
	
	if debug:
		debug_hud.state = character.state_machine.state
		debug_hud.speed = str(character.velocity.length())
		debug_hud.wish_dir = str(character.wish_dir)
	
	debug_hud.visible = debug


func _update_state_label(_old_state: RewindableState, _new_state: RewindableState) -> void:
	debug_hud.state = character.state_machine.state
