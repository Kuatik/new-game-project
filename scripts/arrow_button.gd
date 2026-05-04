extends Button

@export_enum("fwd", "bwd") var dir
@onready var tut_pages = $TutorialPages


func _ready():
	pressed.connect(move_up)
	mouse_entered.connect(hover)
	mouse_exited.connect(unhover)

	
func move_up():
	position.x += 5
	position.y += 5
	await get_tree().create_timer(0.1).timeout
	move_down()

func move_down():
	position.y -= 5
	position.x -= 5
	

var shift = 10
var rot_shift = 10
func hover():
	var t_shift = shift
	if dir == 0:
		t_shift *= -1
	position.x -= t_shift

func unhover():
	var t_shift = shift
	if dir == 0:
		t_shift *= -1
	position.x += t_shift
