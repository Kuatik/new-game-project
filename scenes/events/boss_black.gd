extends Control

signal event_finished

@export var Enabled: bool

@export var spawn_timer: Node
@export var receiver_timer: Node
@export var conveyor: Node
@export var ui: Node

var temp_force: float
var shits_to_clean: int = 0

const CURSOR = preload("uid://cn5lkwqhoykaw")

@onready var shitter: Control = $Shitter
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spawn_points: Control = $Shitter/SpawnPoints

const KAKISH_1 = preload("uid://cb1ner46pwoky")
const KAKISH_2 = preload("uid://jry0yklixqgc")
const KAKISH = preload("uid://cwkll5oacy7to")
const PUDDLE = preload("uid://d2hr7yw0etohv")
const SHIT = preload("uid://d2ffgs3mwhmvf")

const MOP = preload("uid://nnw3owgwx575")
#@onready var SHIT: Node = preload("uid://d2ffgs3mwhmvf")
var shits: Array[Node] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shitter.visible = false
	#original_cursor_arrow = Input.custom
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_event():
	if check_exports():
		temp_force = conveyor.get_push_force()
		print("temp_force: ", temp_force)
	if not Enabled:
		stop_event()
		return
	if not check_exports():
		printerr("missing exports")
		stop_event()
		return
	turn_off_conveyor()
	if animation_player.has_animation("boss"):
		animation_player.play("boss")

func stop_event():
	if not Enabled:
		event_finished.emit()
		return
	Input.set_custom_mouse_cursor(CURSOR, Input.CURSOR_ARROW, Vector2(27,0))
	ui.visible = true
	shitter.visible = false
	turn_on_conveyor()
	for shit in shits:
		if is_instance_valid(shit):
			shit.queue_free()
	shits.clear()
	shits_to_clean = 0
	animation_player.play("RESET")
	event_finished.emit()

func check_exports() -> bool:
	if spawn_timer and receiver_timer and conveyor:
		#temp_force = conveyor.push_force
		return true
	else:
		return false

func turn_off_conveyor():
	if not check_exports():
		return
	spawn_timer.paused = true
	receiver_timer.idle_timer.paused = true
	temp_force = conveyor.get_push_force()
	conveyor.set_push_force(0)

func turn_on_conveyor():
	if not check_exports():
		return
	spawn_timer.paused = false
	receiver_timer.idle_timer.paused = false
	conveyor.set_push_force(temp_force)
	print("conveyor.set_push_force(temp_force) ", temp_force, "_", conveyor.get_push_force())


func _on_button_pressed() -> void:
	shitter.visible = true
	ui.visible = false
	Input.set_custom_mouse_cursor(MOP, Input.CURSOR_ARROW, Vector2(40,68))
	spawn_shit()

func _on_mouse_entered_shit(shit_node: Node):
	if not is_instance_valid(shit_node):
		return
	var hits = shit_node.get_meta("hits", 0) + 1
	shit_node.set_meta("hits", hits)
	if hits >= 3:
		shit_node.queue_free()
		shits.erase(shit_node)
		shits_to_clean -= 1
		
		if shits_to_clean <= 0:
			stop_event()
	print("YOU ARE TOUCHIN THE SHIT")
	

func spawn_shit():
	
	for point in spawn_points.get_children():
		var rand_ = randi_range(0,1)
		print("rand_ ", rand_)
		if rand_ == 1:
			var texture: Texture2D = null
			var rand_tex = randi() % 4
			match rand_tex:
				0: texture = KAKISH
				1: texture = KAKISH_1
				2: texture = KAKISH_2
				3: texture = PUDDLE
			#child.add_child(SHIT)
			var shit = SHIT.instantiate()
			shit.texture = texture
			shit.set_meta("hits", 0)
			shit.mouse_entered.connect(_on_mouse_entered_shit.bind(shit))
			point.add_child(shit)
			shits.append(shit)
			shits_to_clean += 1
	if shits_to_clean == 0:
		stop_event()
