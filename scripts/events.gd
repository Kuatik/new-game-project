extends Control

@onready var press: Node2D = $"../Press"


@export var min_delay: float = 50.0
@export var max_delay: float = 50.0
@export var start_automatically: bool = true

@export var event_list: Array[Node] = []
var current_event: Node = null
var delay_timer: Timer
# Свет, конвеер слева ломается, пожар, взрывы при проигрыше, пресс срабатывает случайно, 
# 1 lvl basic
# 2 lvl press for cat
# 3 lvl everything else
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child.has_signal("event_finished") and child.has_method("start_event"):
			event_list.append(child)
			
	delay_timer = Timer.new()
	delay_timer.one_shot = true
	add_child(delay_timer)
	delay_timer.timeout.connect(_start_random_event)
	
	if start_automatically and event_list.size() > 0:
		#_start_random_event()
		delay_timer.start(randf_range(min_delay, max_delay))
	
	#pass # Replace with function body.

func _start_random_event():
	if current_event != null:
		return
	if event_list.is_empty():
		return
	
	var random_index = randi() % event_list.size()
	current_event = event_list[random_index]
	print("current_event=", current_event.name)
	current_event.event_finished.connect(_on_event_finished)
	current_event.start_event()
	if current_event and current_event.name == "Lights":
		press.event_active = true
	#pass

func _on_event_finished():
	if current_event:
		current_event.event_finished.disconnect(_on_event_finished)
		current_event = null
	var wait_time = randf_range(min_delay, max_delay)
	delay_timer.start(wait_time)
	print("New event timer started: ", wait_time)
	press.event_active = false
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func force_stop_current_event():
	if current_event:
		current_event.stop_event()
