extends Control

signal event_finished
@export var Enabled: bool

@onready var monkey_anim: AnimationPlayer = $MonkeyAnim


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_event():
	pass
	
func stop_event():
	event_finished.emit()
