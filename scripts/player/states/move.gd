extends RewindableState

@export var character: Player
@export var input: PlayerInput
@export var acceleration = 0.6


func tick(delta, tick, is_fresh):
	character.wish_dir = character.global_transform.basis * input.movement
	if (character.is_on_floor()):
		character.handle_ground_physics(delta)
	else:
		character.handle_air_physics(delta)
	
	character.net_move_and_slide()

	# transitions
	if input.run:
		state_machine.transition(&"Run")
	if input.jump_pressed:
		state_machine.transition(&"Jump")
	elif input.crouch:
		state_machine.transition(&"Crouch")
	elif input.movement == Vector3.ZERO:
		state_machine.transition(&"Idle")
