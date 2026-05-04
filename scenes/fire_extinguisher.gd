extends Node2D

@onready var idle = $Idle
@onready var active = $Active
@onready var penka = $Active/Penka

var dragging = false
var drag_offset: Vector2 = Vector2.ZERO
var last_mouse_pos: Vector2 = Vector2.ZERO
var last_mouse_time: int = 0 

var orig_position
@export var time = 0.1

func _ready():
	orig_position = global_position
	Global.disable(active)
	penka.emitting = false





func _on_draggable_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Global.enable(active)
		Global.disable(idle)
		dragging = true
		drag_offset = to_local(event.global_position)
		last_mouse_pos = event.global_position
		last_mouse_time = Time.get_ticks_msec() 
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		
		
func _on_draggable_area_mouse_entered():
	if not dragging:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _on_draggable_area_mouse_exited():
	if not dragging:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _input(event: InputEvent):
	if dragging:
		if event is InputEventMouseMotion:
			global_position = get_global_mouse_position() - drag_offset
			last_mouse_pos = event.global_position
			last_mouse_time = Time.get_ticks_msec()  
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
			penka.emitting = false
			Global.enable(idle)
			Global.disable(active)
			global_position = orig_position
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			


func _on_extinguishing_area_body_entered(body):
	if "burning" in body:
		penka.emitting = true
		await get_tree().create_timer(time).timeout
		body.call_deferred("_enable_disable_anim")
	else:
		return
		
