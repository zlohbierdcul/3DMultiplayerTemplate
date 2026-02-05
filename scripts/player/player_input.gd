class_name PlayerInput extends Node

var input_dir := Vector2.ZERO
var jump_input := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	jump_input = Input.get_action_strength("jump")
