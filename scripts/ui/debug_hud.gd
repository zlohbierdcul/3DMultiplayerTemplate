class_name DebugHUD extends PanelContainer

@onready var fps_label: Label = %FPS
@onready var state_label: Label = %State
@onready var speed_label: Label = %Speed
@onready var wish_dir_label: Label = %WishDir

var state: String
var speed: String
var wish_dir: String

func _process(_delta: float) -> void:
	if not visible: return
	
	fps_label.text = str(Engine.get_frames_per_second())
	state_label.text = "Current State: %s" % state
	speed_label.text = "Speed: %s" % speed
	wish_dir_label.text = "Wish Dir: %s" % wish_dir
