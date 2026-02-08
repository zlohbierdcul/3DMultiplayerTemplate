extends Node

var _loading_scene := preload("res://scenes/ui/loading.tscn")
var _active_loading_scene

var is_hosting_game := false

const SERVER_PORT := 9998

@onready var peer: NodeTunnelPeer = NodeTunnelPeer.new()

func _ready() -> void:
	peer.error.connect(
		func(error_msg):
			push_error("NodeTunnel Error: ", error_msg)
	)
	
	peer.connect_to_relay("eu_central.nodetunnel.io:8080", "yl7ubgct9zax5n4")
	print("Connected to Relay!")
	get_tree().get_multiplayer().multiplayer_peer = peer
	print("Authenticating ...")
	await peer.authenticated
	print("Authenticated")

func host_game() -> void:
	print("[NetworkManager] Hosting Game ...")
	show_loading()
	
	peer.host_room(true, "My Test Room")
	await peer.room_connected
	
	DisplayServer.clipboard_set(peer.room_id)
	print("[NetworkManager] Created Room with ID %s" % str(peer.room_id))
	
	is_hosting_game = true
	get_tree().get_multiplayer().server_relay = true
	
	NetworkTime.start()
	hide_loading()

func join_game(id) -> void:
	print("[NetworkManager] Joining Game ...")
	show_loading()
	
	peer.join_room(id)
	
	await peer.room_connected
	print("[NetworkManager] Joined Room with ID %s" % str(peer.room_id))
	
	hide_loading()

func show_loading() -> void:
	print("[NetworkManager] Showing Loading Screen ...")
	_active_loading_scene = _loading_scene.instantiate()
	add_child(_active_loading_scene)


func hide_loading() -> void:
	print("[NetworkManager] Hiding Loading Screen ...")
	if _active_loading_scene != null:
		_active_loading_scene.queue_free()
