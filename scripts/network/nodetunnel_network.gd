class_name NodeTunnelNetwork extends Node

const SERVER_IP := "127.0.0.1"
const SERVER_PORT := 8080

func create_server_peer():
	print("[ENetNetwork] Creating NodeTunnelPeer Server.")
	var nodetunnel_network_peer := NodeTunnelPeer.new()
	multiplayer.multiplayer_peer = nodetunnel_network_peer
	nodetunnel_network_peer.connect_to_relay("relay.nodetunnel.io", SERVER_PORT)
	await nodetunnel_network_peer.relay_connected
	print("[ENetNetwork] NodeTunnelPeer created!")
	

func create_client_peer():
	print("[ENetNetwork] Creating NodeTunnelPeer Client.")
	var enet_network_peer := NodeTunnelPeer.new()
	enet_network_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer
