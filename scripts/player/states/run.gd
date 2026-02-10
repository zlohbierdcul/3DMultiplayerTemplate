extends RewindableState

@export var character: Player
@export var input: PlayerInput

func can_enter(previous_state: RewindableState) -> bool:
	character.force_update_is_on_floor()
	return input.run and character.is_on_floor()

func tick(delta, tick, is_fresh):
	character.wish_dir = character.global_transform.basis * input.movement
	character.handle_ground_physics(delta)
	
	character.net_move_and_slide()
	
	if input.jump_pressed or input.jump_held:
		state_machine.transition(&"Jump")
	if input.crouch:
		state_machine.transition(&"Crouch")
	elif input.movement == Vector3.ZERO:
		state_machine.transition(&"Idle")
