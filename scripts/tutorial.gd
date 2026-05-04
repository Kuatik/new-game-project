extends Control


@onready var pages = $TutorialPages.get_children()
@onready var fwd = $FwdArrow
@onready var bwd = $BwdArrow
@onready var close = $CloseButton


var pages_size = 0
var current: int = 0


func _ready():
	pages_size = pages.size()
	current = clamp(current, 0, pages.size() - 1)
	fwd.pressed.connect(next_page)
	bwd.pressed.connect(prev_page)
	close.pressed.connect(close_tutorial)
	render_pages()

func _process(_delta):
	if current == pages_size-1:
		Global.disable(fwd)
		Global.enable(bwd)
	elif current == 0:
		Global.disable(bwd)
		Global.enable(fwd)
	else:
		Global.enable(fwd)
		Global.enable(bwd)

func render_pages():
	for page in pages:
		if page != pages[current]:
			page.visible = false
		else:
			page.visible = true


func next_page():
	current += 1
	render_pages()
	
	
func prev_page():
	current -= 1
	render_pages()
	
func close_tutorial():
	current = 0
	render_pages()
	await get_tree().create_timer(0.2).timeout
	Global.disable(self)
	
	
