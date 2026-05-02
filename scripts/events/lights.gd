extends Control

@onready var lights_color: ColorRect = $LightsColor
@onready var lights_color_2: ColorRect = $LightsColor2
@onready var conveyor: Area2D = %conveyor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lights_color.visible = false
	lights_color_2.visible = false
	# Checks
	if conveyor:
		print("conveyor found")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func turn_lights_off():
	lights_color.visible = true
	lights_color_2.visible = true
	
