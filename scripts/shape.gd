extends RigidBody2D
class_name DraggableShape

signal shape_destroyed(shape_id: String)

@export_group("Shape Properties")
@export var shape_id: String = ""
@export_enum("Circle", "Square", "Triangle", "Cat", "Star", "Luna", "Karakuli", "Heart") var shape_type: String = "Circle"
@export_enum("Red", "Yellow", "Blue", "Green", "Purple", "Cyan") var shape_color: String = "Red"
@onready var draggable_area: Area2D = $DraggableArea

@onready var circle_collision: CollisionShape2D = $CircleShape2D
@onready var square_collision: CollisionShape2D = $SquareShape2D
@onready var star_collision: CollisionPolygon2D = $StarShape2D
@onready var triangle_collision: CollisionPolygon2D = $TriangleShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_anim: AnimatedSprite2D = $FireAnim

@export var outline: Panel


var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var last_mouse_pos: Vector2 = Vector2.ZERO
var last_mouse_time: int = 0   # <- добавили

@export var throw_sensitivity: float = 1.2

var color_map = {
	"Red": Color(1, 0, 0),
	"Yellow": Color(1, 1, 0),
	"Blue": Color(0, 0, 1),
	"Green": Color(0, 1, 0),
	"Purple": Color(0.5, 0, 1),
	"Cyan": Color(0, 1, 1)
}

func _ready():
	disable_all_collisions()
	fire_anim.visible = false
	circle_collision.disabled = false
	outline.hide()
	var anim_name = shape_type.to_lower()
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.animation = anim_name
	else:
		animated_sprite.animation = "circle"

	animated_sprite.modulate = color_map[shape_color]

	if shape_id.is_empty():
		shape_id = shape_color.to_lower() + "_" + shape_type.to_lower()

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = true
		drag_offset = to_local(event.global_position)
		last_mouse_pos = event.global_position
		last_mouse_time = Time.get_ticks_msec()   # запоминаем время
		freeze = true
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)

func _input(event: InputEvent):
	if dragging:
		if event is InputEventMouseMotion:
			global_position = get_global_mouse_position() - drag_offset
			last_mouse_pos = event.global_position
			last_mouse_time = Time.get_ticks_msec()   # обновляем время при движении
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# Вычисляем время между последним движением и отпусканием
			var delta_time = (Time.get_ticks_msec() - last_mouse_time) / 1000.0
			if delta_time < 0.001:
				delta_time = 0.001
			var throw_velocity = (event.global_position - last_mouse_pos) / delta_time
			throw_velocity = throw_velocity * throw_sensitivity
			throw_velocity = throw_velocity.limit_length(1800)
			dragging = false
			freeze = false
			apply_central_impulse(throw_velocity)
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _draggable_off():
	draggable_area.input_pickable = false
	

func _enable_fire_anim():
	if has_node("FireAnim"):
		_draggable_off()
		$FireAnim.visible = true
		$FireAnim.play("fire")
		

func destroy():
	emit_signal("shape_destroyed", shape_id)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	remove_meta("accepted")
	queue_free()

func _on_draggable_area_mouse_entered():
	if not dragging:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _on_draggable_area_mouse_exited():
	if not dragging:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
