extends Control

signal event_finished

@export var Enabled: bool
@export var main: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start_event():
	if !Enabled:
		print("Event is NOT ENABLED")
		stop_event()
		return
	if main:
		main.lives +=1
		main.update_lives_display()
		print("BONUS EVENT")
	else:
		print("Main Node not Found")
	stop_event()
func stop_event():
	#emit_signal("event_finished")
	event_finished.emit()
	print("event_finished.emit()")
