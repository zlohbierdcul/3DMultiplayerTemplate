extends RewindableState

@export var character: Player
@export var input: PlayerInput
@export var camera: PlayerCamera

# Only enter if the character is on the floor
func can_enter(_previous_state):
	var wants_jump = input.jump_pressed or (character.auto_bhop and input.jump_held)
	return wants_jump and character.is_on_floor()

func enter(_previous_state, _tick):
	character.velocity.y = character.jump_velocity

func exit(next_state: RewindableState, tick: int) -> void:
	#camera.apply_shake(1.0, 20.0)
	pass

func tick(delta, tick, is_fresh):
	character.wish_dir = character.global_transform.basis * input.movement
	character.handle_air_physics(delta)

	character.net_move_and_slide()

	if character.is_on_floor():
		if input.crouch:
			state_machine.transition(&"Crouch")
		else:
			state_machine.transition(&"Idle")
