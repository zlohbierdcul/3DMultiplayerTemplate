class_name PlayerCamera
extends Camera3D

@export var shake_fade := 5.0

var rng = RandomNumberGenerator.new()
var shake_strength := 0.0

func apply_shake(duration: float, strength: float):
	var start_origin := transform.origin
	var start_time := _get_time()
	
	while _get_time() - start_time < duration:
		var offset := Vector3(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength), 0)
		transform.origin = offset
		await get_tree().process_frame
	
	transform.origin = start_origin

func _get_time() -> float:
	return Time.get_ticks_msec() / 1000.0
