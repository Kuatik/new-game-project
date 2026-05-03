extends Node2D

@onready var start_button = $UI/StartButton
@onready var high_score_label = $UI/VBoxContainer/HighScoreLabel
@onready var previous_score_label = $UI/VBoxContainer/PreviousScoreLabel
@onready var spawner = $Spawner
@onready var receiver = $Receiver
@onready var spawn_timer: Timer = $SpawnTimer

var save_data = null
var colors = ["Red", "Yellow", "Blue", "Green", "Purple", "Cyan"]
var shapes = ["Circle", "Square", "Triangle", "Cat", "Star", "Luna", "Karakuli", "Heart"]

const SHAPE_SCENE = preload("res://scenes/shape.tscn")

func _ready():
	save_data = Global.load_json(Global.save_data_path)
	high_score_label.text = "High Score: %s" % str(int(save_data.high_score))
	previous_score_label.text = "Previous Score: %s" % str(int(save_data.scores[-1]))
	receiver.body_entered.connect(_on_receiver_body_entered)
	start_button.pressed.connect(_load_game)
	

func _load_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_spawn_timer_timeout():
	var shape_instance = SHAPE_SCENE.instantiate()
	var color = colors.pick_random()
	var shape_type = shapes.pick_random()
	shape_instance.shape_type = shape_type
	shape_instance.shape_color = color

	if shape_type == "Cat":
		shape_instance.call_deferred("_enable_fire_anim")
	
	add_child(shape_instance)
	shape_instance.global_position = spawner.global_position

func _on_receiver_body_entered(body: Node):
	if body is DraggableShape and not body.has_meta("accepted"):
		body.set_meta("accepted", true)
		body.destroy()
