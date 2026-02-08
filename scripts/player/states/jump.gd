extends RewindableState

@export var character: CharacterBody3D
@export var input: PlayerInput
@export var speed = 5.0
@export var jump_strength = 5.0

# Only enter if the character is on the floor
func can_enter(_previous_state):
	return input.jump and character.is_on_floor()

func enter(_previous_state, _tick):
	character.velocity.y = jump_strength
	
func exit(next_state: RewindableState, tick: int) -> void:
	character.velocity.x = 0.0
	character.velocity.z = 0.0

func tick(delta, tick, is_fresh):
	var input_dir = input.movement
	var direction = (character.transform.basis * Vector3(input_dir.x, 0, input_dir.z)).normalized()
	character.velocity.x = lerp(character.velocity.x, direction.x * speed, delta * 3.0)
	character.velocity.z = lerp(character.velocity.z, direction.z * speed, delta * 3.0)

	# move_and_slide assumes physics delta
	# multiplying velocity by NetworkTime.physics_factor compensates for it
	character.velocity *= NetworkTime.physics_factor
	character.move_and_slide()
	character.velocity /= NetworkTime.physics_factor
	
	if character.is_on_floor():
		state_machine.transition(&"Idle")
