class_name DebugHUD extends PanelContainer

@onready var fps_label: Label = %FPS
@onready var tps_label: Label = %TPS
@onready var state_label: Label = %State
@onready var speed_label: Label = %Speed
@onready var jump_height_label: Label = %JumpHeight

var state: String
var speed: float
var jump_height: float

func _process(_delta: float) -> void:
	if not visible: return
	
	fps_label.text = "FPS: %s" % str(Engine.get_frames_per_second())
	tps_label.text = "TPS: %s" % str(NetworkTime.tickrate)
	state_label.text = "Current State: %s" % state
	speed_label.text = "Speed: %s" % snapped(float(speed), 0.01)
	jump_height_label.text = "Jump Height: %s" % snapped(jump_height, 0.01)
