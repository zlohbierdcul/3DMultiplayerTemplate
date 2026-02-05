class_name MainMenu extends Control

const GAME_SCENE = "res://scenes/game/game.tscn"

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("[MainMenu] Calling host game ...")
		NetworkManager.host_game()
		get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))

func host():
	print("[MainMenu] Host Game")
	NetworkManager.host_game()
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
	
func join():
	print("[MainMenu] Join Game %s")
	NetworkManager.join_game()
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
	
func exit():
	get_tree().quit(0)
	
