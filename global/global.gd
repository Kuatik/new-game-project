extends Node

var arrow = load("res://assets/GameJam aitu/mouse/Cursor.png")
var move = load("res://assets/GameJam aitu/mouse/Cursor2.png")
var grab = load("res://assets/GameJam aitu/mouse/Cursor1.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW, Vector2(27,0))
	Input.set_custom_mouse_cursor(grab, Input.CURSOR_DRAG, Vector2(23,21))
	Input.set_custom_mouse_cursor(move, Input.CURSOR_MOVE, Vector2(24,15))

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
