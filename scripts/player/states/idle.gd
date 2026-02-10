extends RewindableState

@export var character: Player
@export var input: PlayerInput

var _jump_tick = -1

func enter(previous_state: RewindableState, tick: int) -> void:
	if previous_state == state_machine._available_states.get(&"Jump"):
		_jump_tick = tick


func tick(delta, tick, is_fresh):
	character.wish_dir = lerp(character.wish_dir, Vector3.ZERO, delta * 30.0)
	
	if tick != _jump_tick:
		if (character.is_on_floor()):
			character.handle_ground_physics(delta)
		else:
			character.handle_air_physics(delta)
		
		character.net_move_and_slide()
	
	var wants_jump := input.jump_pressed or (character.auto_bhop and input.jump_held)
	if wants_jump and character.is_on_floor():
		state_machine.transition(&"Jump")
	elif input.movement != Vector3.ZERO:
		if input.run:
			state_machine.transition(&"Run")
		else:
			state_machine.transition(&"Move")
	elif input.crouch:
		state_machine.transition(&"Crouch")
