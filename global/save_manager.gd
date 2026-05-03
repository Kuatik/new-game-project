extends Node

const SAVE_PATH = "user://savegame.save"

var game_data = {
	"high_score": 0,
	"level": 0,
}

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(game_data)
		file.store_line(json_string)
		print("Game Saved")
	else:
		print("Failed to save")

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(content)
		if parse_result == OK:
			game_data = json.data
			print("Game loaded")
			apply_loaded_data()
		else:
			print("Parse error")
	else:
		print("Save file not found, using defaults")

func apply_loaded_data():
	# GameManager.set_lives(game_data.lives)
	pass

func set_value(key: String, value):
	game_data[key] = value
	save_game()

func get_value(key: String):
	return game_data.get(key)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
