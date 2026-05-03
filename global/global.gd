extends Node

var arrow = load("res://assets/GameJam aitu/mouse/Cursor.png")
var move = load("res://assets/GameJam aitu/mouse/Cursor2.png")
var grab = load("res://assets/GameJam aitu/mouse/Cursor1.png")
var save_data_path = "res://data/save_data.json"
var save_data = load_json("res://data/save_data.json")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW, Vector2(27,0))
	Input.set_custom_mouse_cursor(grab, Input.CURSOR_DRAG, Vector2(23,21))
	Input.set_custom_mouse_cursor(move, Input.CURSOR_MOVE, Vector2(24,15))
	
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func disable(node: Node):
	node.visible = false
	node.process_mode = Node.PROCESS_MODE_DISABLED
	
func enable(node: Node):
	node.visible = true
	node.process_mode = Node.PROCESS_MODE_INHERIT

func save_json(data: Dictionary, path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("JSON file not found!")
		return
	if not data:
		("The data you tried to save is null!")
		return
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	var json_string = JSON.stringify(data, "\t")
	if file.store_string(json_string):
		push_error("Data stored successfully!")
	else:
		push_error("Failed to store data!")
	file.close()


func load_json(path: String):
	if not FileAccess.file_exists(path):
		push_error("JSON file not found!")
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		var data = json.data
		return data
	else:
		push_error("JSON Parse Error: " + json.get_error_message() + " at line " + json.get_erorr_line())
		return null
