extends Button

var s_shift = 1.2
var small_shift = 1.1

func _ready():
	scale_down(s_shift)
	pressed.connect(button_press)
	mouse_entered.connect(scale_up.bind(s_shift))
	mouse_exited.connect(scale_down.bind(s_shift))

func button_press():
	scale_down(small_shift)
	await get_tree().create_timer(0.1).timeout
	scale_up(small_shift)

func scale_down(shift):
	scale.x /= shift
	scale.y /= shift
	
func scale_up(shift):
	scale.x *= shift
	scale.y *= shift
