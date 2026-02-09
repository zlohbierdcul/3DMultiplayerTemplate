extends RewindableState

@export var character: Player
@export var input: PlayerInput
@export var speed = 5.0
@export var jump_strength = 5.0

# Only enter if the character is on the floor
func can_enter(_previous_state):
	var wants_jump = input.jump_pressed or (character.auto_bhop and input.jump_held)
	return wants_jump and character.is_on_floor()

func enter(_previous_state, _tick):
	character.velocity.y = jump_strength


func tick(delta, tick, is_fresh):
	var wishdir = character.get_wishdir(input.movement)
	var wishspeed = character.get_wishspeed(input.movement, character.max_speed)

	# In air: air acceleration rules
	if character.is_on_floor():
		# This can happen on the first jump tick (before move_and_slide makes us airborne),
		# or if we landed during this state.
		character.ground_move(wishdir, wishspeed, delta)
	else:
		character.air_move(wishdir, wishspeed, delta)

	character.net_move_and_slide()

	# Landed? Pick next state based on input
	if character.is_on_floor():
		if input.crouch:
			state_machine.transition(&"Crouch")
		elif input.movement != Vector3.ZERO:
			state_machine.transition(&"Move")
		else:
			state_machine.transition(&"Idle")
