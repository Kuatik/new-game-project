extends Area2D


@export var main: Node
@onready var idle_timer: Timer = $IdleTimer

func _ready() -> void:
	idle_timer.start()
	
func _on_body_entered(body: Node2D) -> void:
	idle_timer.start()
	
	#if body is DraggableShape:
		#main.try_accept_shape(body)


func _on_idle_timer_timeout() -> void:
	main.punish_idle()
