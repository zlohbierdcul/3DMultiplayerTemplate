class_name ENetNetwork extends Node

const SERVER_IP := "127.0.0.1"
const SERVER_PORT := 8080

func create_server_peer():
	print("[ENetNetwork] Creating ENetServerPeer")
	var enet_network_peer := ENetMultiplayerPeer.new()
	enet_network_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer

func create_client_peer():
	print("[ENetNetwork] Creating ENetClientPeer")
	var enet_network_peer := ENetMultiplayerPeer.new()
	enet_network_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer
