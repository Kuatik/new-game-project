extends Area2D


@export var main: Node
@export var wait_time: float
@onready var idle_timer: Timer

func _ready() -> void:
	idle_timer = Timer.new()
	add_child(idle_timer)
	idle_timer.start(wait_time)
	
func _on_body_entered(body: Node2D) -> void:
	idle_timer.start(wait_time)
	
	#if body is DraggableShape:
		#main.try_accept_shape(body)


func _on_idle_timer_timeout() -> void:
	main.punish_idle()
