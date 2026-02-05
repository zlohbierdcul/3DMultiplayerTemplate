extends Node3D

@export var camera: Camera3D

func _ready() -> void:
	if multiplayer.get_unique_id() == owner.name.to_int():
		camera.current = true
	else:
		camera.current = false

func _process(delta: float) -> void:
	pass
