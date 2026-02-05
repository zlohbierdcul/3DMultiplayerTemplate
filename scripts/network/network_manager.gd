extends Node

var _loading_scene := preload("res://scenes/ui/loading.tscn")
var _active_loading_scene

var _enet_network := preload("res://scenes/network/enet_network.tscn")

var is_hosting_game := false

func host_game() -> void:
	print("[NetworkManager] Hosting Game ...")
	show_loading()
	is_hosting_game = true
	var active_network = _enet_network.instantiate() as ENetNetwork
	add_child(active_network)
	
	active_network.create_server_peer()

func join_game() -> void:
	print("[NetworkManager] Joining Game ...")
	show_loading()
	
	var active_network = _enet_network.instantiate() as ENetNetwork
	add_child(active_network)
	
	active_network.create_client_peer()

func show_loading() -> void:
	print("[NetworkManager] Showing Loading Screen ...")
	_active_loading_scene = _loading_scene.instantiate()
	add_child(_active_loading_scene)


func hide_loading() -> void:
	print("[NetworkManager] Showing Loading Screen ...")
	if _active_loading_scene != null:
		_active_loading_scene.queue_free()
