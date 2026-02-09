extends RewindableState

@export var character: Player
@export var input: PlayerInput

func tick(delta, tick, is_fresh):
	#character.velocity *= NetworkTime.physics_factor
	if character.is_on_floor():
		character.apply_friction(delta)

	character.net_move_and_slide()
	
	var wants_jump := input.jump_pressed or (character.auto_bhop and input.jump_held)
	if input.movement != Vector3.ZERO:
		if input.run:
			state_machine.transition(&"Run")
		else:
			state_machine.transition(&"Move")
	elif wants_jump and character.is_on_floor():
		state_machine.transition(&"Jump")
	elif input.crouch:
		state_machine.transition(&"Crouch")
