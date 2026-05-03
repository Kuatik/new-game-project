extends Control

signal game_completed

const COLORS = {
	"red": Color(1, 0, 0),
	"blue": Color(0, 0, 1),
	"green": Color(0, 1, 0),
	"purple": Color(0.5, 0, 1)
}

var color_list = ["red", "blue", "green", "purple"]
var left_items = []   # массив ссылок на левые ColorRect
var right_items = []  # массив ссылок на правые ColorRect
var current_selected_left = null   # выбранный левый элемент (или его цвет)
var matched_count = 0
var is_active: bool = false
@onready var left_container = $LeftContainer
@onready var right_container = $RightContainer


func _ready():
	# Перемешиваем левые цвета
	pass
	
func start_game():
	if is_active:
		return
	is_active = true
	var shuffled_left = color_list.duplicate()
	shuffled_left.shuffle()
	
	# Создаём левые круги
	for col_name in shuffled_left:
		var rect = create_color_circle(col_name)
		left_container.add_child(rect)
		left_items.append(rect)
		# Подключаем сигнал нажатия
		rect.gui_input.connect(_on_left_click.bind(rect, col_name))
	
	# Создаём правые круги (фиксированный порядок)
	for col_name in color_list:
		var rect = create_color_circle(col_name)
		right_container.add_child(rect)
		right_items.append(rect)
		rect.gui_input.connect(_on_right_click.bind(rect, col_name))

func create_color_circle(color_name: String) -> ColorRect:
	var rect = ColorRect.new()
	rect.color = COLORS[color_name]
	rect.custom_minimum_size = Vector2(64, 64)
	rect.size = Vector2(64, 64)
	# делаем круглым (через StyleBoxFlat)
	var style = StyleBoxFlat.new()
	style.bg_color = COLORS[color_name]
	style.corner_radius_top_left = 32
	style.corner_radius_top_right = 32
	style.corner_radius_bottom_left = 32
	style.corner_radius_bottom_right = 32
	rect.add_theme_stylebox_override("normal", style)
	
	# Добавляем мета-поле для цвета
	rect.set_meta("color", color_name)
	return rect

func _on_left_click(event: InputEvent, rect: ColorRect, color_name: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Снимаем выделение со всех левых
		for item in left_items:
			item.modulate = Color(1,1,1)
		# Выделяем текущий
		rect.modulate = Color(0.8,0.8,0.8)
		current_selected_left = rect

func _on_right_click(event: InputEvent, rect: ColorRect, color_name: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_selected_left == null:
			return
		var left_color = current_selected_left.get_meta("color")
		if left_color == color_name:
			# Правильное соединение – удаляем оба
			remove_pair(current_selected_left, rect)
			current_selected_left = null
			matched_count += 1
			if matched_count >= color_list.size():
				complete_game()

func remove_pair(left_rect: ColorRect, right_rect: ColorRect):
	left_rect.queue_free()
	right_rect.queue_free()
	left_items.erase(left_rect)
	right_items.erase(right_rect)

func complete_game():
	if not is_active:
		return
	is_active = false
	matched_count = 0
	game_completed.emit()
	#queue_free()
