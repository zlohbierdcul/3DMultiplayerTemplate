class_name MainMenu extends Control

const GAME_SCENE = "res://scenes/game/game.tscn"
@onready var host_online_id: LineEdit = $Menu/VBoxContainer/HostOnlineId

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("[MainMenu] Calling host game ...")
		NetworkManager.host_game()
		get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))

func host():
	print("[MainMenu] Host Game")
	await get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
	await NetworkManager.host_game()
	
func join():
	print("[MainMenu] Join Game %s")
	await NetworkManager.join_game(host_online_id.text)
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
	
func exit():
	get_tree().quit(0)
	
