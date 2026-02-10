class_name NetworkGun
extends NetworkWeaponHitscan3D

@export var input: PlayerInput
@export var gun: MeshInstance3D
@export var camera: PlayerCamera

@export_category("Settings")
@export var fire_cooldown: float = 0.25

#@onready var sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var bullethole: BulletHole = $BulletHole
@onready var gun_pos: Node3D = $Gun

var last_fire: int = -1

func _ready():
	NetworkTime.on_tick.connect(_tick)
	var tiny_gun = gun.duplicate()
	tiny_gun.scale = Vector3(0.2, 0.2, 0.2)
	gun_pos.add_child(tiny_gun)

func _can_fire() -> bool:
	return NetworkTime.seconds_between(last_fire, NetworkTime.tick) >= fire_cooldown

func _can_peer_use(peer_id: int) -> bool:
	return peer_id == input.get_multiplayer_authority()

func _on_fire():
	#sound.play()
	pass


func _after_fire():
	last_fire = NetworkTime.tick

func _on_hit(result: Dictionary):
	bullethole.action(result)
	if result.collider.has_method("damage"):
		result.collider.damage()
	
func _tick(_delta: float, _t: int):
	if input.fire:
		fire()
