extends RigidBody2D
class_name DraggableShape

signal shape_destroyed(shape_id: String)

@export_group("Shape Properties")
@export var shape_id: String = ""
@export_enum("Circle", "Square", "Triangle", "Cat", "Star", "Luna", "Karakuli", "Heart") var shape_type: String = "Circle"
@export_enum("Red", "Yellow", "Blue", "Green", "Purple", "Cyan") var shape_color: String = "Red"

# Коллизии (добавлены в сцене)
@onready var circle_collision: CollisionShape2D = $CircleShape2D
@onready var square_collision: CollisionShape2D = $SquareShape2D
@onready var star_collision: CollisionPolygon2D = $StarShape2D
@onready var triangle_collision: CollisionPolygon2D = $TriangleShape2D

# Анимация и эффекты
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_anim: AnimatedSprite2D = $FireAnim   # можно использовать для горения неправильных фигур

# Перетаскивание
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var last_mouse_pos: Vector2 = Vector2.ZERO

var target_position: Vector2 = Vector2.ZERO
@export var drag_speed: float = 2.0
# Цвета (используем modulate, если анимации белые)
var color_map = {
	"Red": Color(1, 0, 0),
	"Yellow": Color(1, 1, 0),
	"Blue": Color(0, 0, 1),
	"Green": Color(0, 1, 0),
	"Purple": Color(0.5, 0, 1),
	"Cyan": Color(0, 1, 1)
}

func _ready():
	# Отключаем все коллизии по умолчанию
	disable_all_collisions()
	fire_anim.visible = false
	
	circle_collision.disabled = false
	
	# Включаем нужную коллизию в зависимости от типа фигуры
	#match shape_type:
		#"Circle":
			#circle_collision.disabled = false
		#"Square":
			#square_collision.disabled = false
		#"Triangle":
			#triangle_collision.disabled = false
		#"Star":
			#star_collision.disabled = false
		#_:
			## Для Cat, Luna, Karakuli, Heart используем круглую коллизию
			#circle_collision.disabled = false
	
	# Настраиваем анимацию
	var anim_name = shape_type.to_lower()
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.animation = anim_name
	else:
		# Запасной вариант: анимация "circle" по умолчанию
		animated_sprite.animation = "circle"
	
	# Применяем цвет (если спрайты в анимациях белые)
	animated_sprite.modulate = color_map[shape_color]
	
	# Уникальный ID фигуры
	if shape_id.is_empty():
		shape_id = shape_color.to_lower() + "_" + shape_type.to_lower()
	
	# Сигнал выхода за экран (нужен узел VisibleOnScreenNotifier2D в сцене)
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.connect("screen_exited", _on_screen_exited)

func disable_all_collisions():
	circle_collision.disabled = true
	square_collision.disabled = true
	star_collision.disabled = true
	triangle_collision.disabled = true

func _on_screen_exited():
	emit_signal("shape_destroyed", shape_id)
	queue_free()

func _on_draggable_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			#Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			drag_offset = to_local(event.global_position)
			target_position = global_position
			last_mouse_pos = event.global_position
			freeze = true
		else:
			if dragging:
				var throw_velocity = (event.global_position - last_mouse_pos) / get_process_delta_time()
				throw_velocity = throw_velocity.limit_length(800)
				dragging = false
				freeze = false
				apply_central_impulse(throw_velocity)
	if event is InputEventMouseMotion and dragging:
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		
		target_position = get_global_mouse_position() - drag_offset
		last_mouse_pos = event.global_position
		
		
		#var new_pos = get_global_mouse_position() - drag_offset
		#global_position = new_pos
	#else:
		#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
# add larp move
# lever light shut off

#func _physics_process(delta: float) -> void:
	#if dragging:
		#Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		#

func _process(delta):
	if dragging:
		#Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		
		# Дополнительное обновление позиции (хотя в _input_event уже перемещаем)
		#var new_pos = get_global_mouse_position() - drag_offset
		global_position = global_position.lerp(target_position, drag_speed)
	#else:
		#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	

func _enable_fire_anim():
	if has_node("FireAnim"):
		$FireAnim.visible = true
		$FireAnim.play("fire")   # предполагаем, что есть анимация "fire"

func destroy():
	#dragging = false
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	emit_signal("shape_destroyed", shape_id)
	remove_meta("accepted")
	queue_free()


func _on_draggable_area_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)


func _on_draggable_area_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
