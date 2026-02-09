extends RewindableState

@export var character: Player
@export var input: PlayerInput
@export var acceleration = 0.6


func tick(delta, tick, is_fresh):
	var input_move := input.movement

	var wishdir := character.get_wishdir(input_move)
	var wishspeed := character.get_wishspeed(input_move, character.max_speed)

	if character.is_on_floor():
		character.ground_move(wishdir, wishspeed, delta)
	else:
		character.air_move(wishdir, wishspeed, delta)

	# Jump handling (simple version here)
	# For “CS timing”, use jump_pressed (no auto-bhop by default).


	character.net_move_and_slide()

	# transitions
	if input.run:
		state_machine.transition(&"Run")
	if input.jump_pressed:
		state_machine.transition(&"Jump")
	elif input.crouch:
		state_machine.transition(&"Crouch")
	elif input_move == Vector3.ZERO:
		state_machine.transition(&"Idle")
