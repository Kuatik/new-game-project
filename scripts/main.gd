extends Node2D

@onready var spawner: Marker2D = $Spawner
@onready var receiver: Area2D = $Receiver
@onready var ui_sequence: HBoxContainer = $UI/SequenceContainer
@onready var life_label: Label = $UI/LifeLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var gain_label: Label = $UI/GainLabel
@onready var spawn_timer: Timer = $SpawnTimer
@onready var reset_button: Button = $UI/ResetButton
@onready var conveyor: Area2D = $conveyor

@onready var damage_overlay: ColorRect = $UI/DamageOverlay
@onready var floating_message: Label = $UI/FloatingMessage
@onready var idle_progress: ProgressBar = $UI/IdleProgress



const SHAPE_SCENE = preload("res://scenes/shape.tscn")
const TICK_SCENE = preload("res://scenes/tick.tscn")


var all_combinations: Array[String] = [] # Все возможные комбинации спавна
var normal_shapes: Array[String] = [] # Все возможные комбинации порядка фигур
var required_sequence: Array[String] = [] # Требуемый порядок фигур
var needed_counts: Dictionary = {}
var current_index: int = 0
@export var lives: int = 3

# Score
@export var max_score_gain = 100
@export var score_reductor = 20
var score = 0
var current_score_gain = max_score_gain

# Game State
var game_lost = false

var colors = ["Red", "Yellow", "Blue", "Green", "Purple", "Cyan"]
var shapes = ["Circle", "Square", "Triangle", "Cat", "Star", "Luna", "Karakuli", "Heart"]

#@export_enum(1,5,1) 
#@export var rand_fire_chance: Array[int] = [0,0,0]
@export_range(0.1,100.0,1.0) var rand_fire_chance: float
# Цвета для модуляции
var color_map = {
	"Red": Color(1,0,0), "Yellow": Color(1,1,0), "Blue": Color(0,0,1),
	"Green": Color(0,1,0), "Purple": Color(0.5,0,1), "Cyan": Color(0,1,1)
}

# Ресурс с анимациями для предпросмотра (загружаем один раз)
# Вы можете создать отдельный SpriteFrames ресурс через редактор и указать его здесь
@export var preview_sprite_frames: SpriteFrames   # перетащите в инспектор готовый ресурс

@export var complaint_messages = [
	"I hate this job!",
	"Oh no, wrong shape!",
	"Quality control failed!",
	"My boss is gonna kill me...",
	"Stupid conveyor belt!",
	"Where's the union rep?",
	"I should have stayed in bed."
]

func _ready():
	Global.disable(reset_button)
	score_label.text = str(score)
	for color in colors:
		for shape in shapes:
			all_combinations.append(color + "_" + shape)
	#normal_shapes = shapes.duplicate() as Array[String]
	#normal_shapes.erase("Cat")
	#normal_shapes.erase("Karakuli")
	normal_shapes = []
	for shape in shapes:
		if shape != "Cat" and shape != "Karakuli":
			normal_shapes.append(shape)
	generate_sequence(5)
	for combo in required_sequence:
		needed_counts[combo] = 1
	
	update_ui_sequence()
	update_lives_display()
	receiver.body_entered.connect(_on_receiver_body_entered)
	spawn_timer.start()
	get_tree().paused = false
	reset_button.pressed.connect(_reset_game)
	reset_button.process_mode = Node.PROCESS_MODE_ALWAYS
	#reset_button.visible = false

func _process(delta: float) -> void:
	if receiver and receiver.idle_timer.time_left > 0:
		idle_progress.value = (receiver.idle_timer.time_left / receiver.idle_timer.wait_time) * 100
		gain_label.text = "+ %s" % str(current_score_gain)
	else:
		idle_progress.value = 0


func generate_sequence(length: int):
	#var shuffled = all_combinations.duplicate()
	#shuffled.shuffle()
	#required_sequence = shuffled.slice(0, length)

	var possible: Array[String] = []
	for color in colors:
		for shape in normal_shapes:
			possible.append(color+"_"+shape)
	possible.shuffle()
	required_sequence = possible.slice(0, length)

func update_ui_sequence():
	for child in ui_sequence.get_children():
		child.queue_free()
	
	for i in range(0, required_sequence.size()):
		var combo = required_sequence[i]
		var parts = combo.split("_")
		var color_name = parts[0]
		var shape_name = parts[1]
		var icon = create_preview_icon(shape_name, color_name)
		ui_sequence.add_child(icon)
		if i < current_index:
			icon.get_node("Tick").visible = true

		
func mark_ui_sequence():
	for i in range(0, current_index):
		var combo = required_sequence[i]
		var parts = combo.split("_")
		var color_name = parts[0]
		var shape_name = parts[1]
		var icon = create_preview_icon(shape_name, color_name)
		icon.get_node("Tick").visible = true

func create_preview_icon(shape: String, color: String) -> Control:
	var tick = TICK_SCENE.instantiate()
	tick.visible = false
	# Контейнер для анимации
	var container = CenterContainer.new()
	container.custom_minimum_size = Vector2(64, 64)
	
	# Создаём AnimatedSprite2D для показа формы
	var anim_sprite = AnimatedSprite2D.new()
	if preview_sprite_frames:
		anim_sprite.sprite_frames = preview_sprite_frames
	else:
		# Если ресурс не задан, создаём временный (но лучше задать в инспекторе)
		anim_sprite.sprite_frames = create_temp_sprite_frames()
	
	# Устанавливаем анимацию по названию формы (с маленькой буквы)
	var anim_name = shape.to_lower()
	if anim_sprite.sprite_frames.has_animation(anim_name):
		anim_sprite.animation = anim_name
	else:
		# Если нет такой анимации, используем первую попавшуюся
		var anim_list = anim_sprite.sprite_frames.get_animation_names()
		if anim_list.size() > 0:
			anim_sprite.animation = anim_list[0]
	
	# Цвет – через modulate (если спрайты белые)
	anim_sprite.modulate = color_map[color]
	anim_sprite.play()
	
	container.add_child(anim_sprite)
	container.add_child(tick)
	return container

func create_temp_sprite_frames() -> SpriteFrames:
	# Экстренный вариант – создаёт пустые анимации. Лучше так не делать, настройте preview_sprite_frames.
	var frames = SpriteFrames.new()
	for shape in shapes:
		var anim_name = shape.to_lower()
		frames.add_animation(anim_name)
		# Добавляем пустой кадр (чтобы не было ошибок)
		frames.set_animation_speed(anim_name, 1)
	return frames

func update_lives_display():
	life_label.text = "❤️ x" + str(lives)

func _on_timer_timeout():
	var combo_to_spawn = choose_combo_to_spawn()
	if combo_to_spawn == null:
		return
	var shape_instance = SHAPE_SCENE.instantiate()
	var parts = combo_to_spawn.split("_")
	var color = parts[0]
	var shape_type = parts[1]
	shape_instance.shape_type = shape_type
	shape_instance.shape_color = color
	shape_instance.shape_id = combo_to_spawn
	if shape_instance.shape_type == "Karakuli":
		shape_instance.call_deferred("_draggable_off")
	# ✨ Если фигура Cat, включаем анимацию огня (fire_anim)
	#if shape_type == "Cat":
		## Предполагаем, что в shape.tscn есть узел FireAnim (AnimatedSprite2D)
		## Сделаем его видимым и запустим анимацию
		#shape_instance.call_deferred("_enable_fire_anim")
	if randf() <= rand_fire_chance/100:
		shape_instance.call_deferred("_enable_fire_anim")
	
	
	shape_instance.connect("shape_destroyed", _on_shape_destroyed)
	add_child(shape_instance)
	shape_instance.global_position = spawner.global_position
	
	if needed_counts.has(combo_to_spawn) and needed_counts[combo_to_spawn] > 0:
		needed_counts[combo_to_spawn] -= 1

func choose_combo_to_spawn() -> String:
	var needed_list = []
	for combo in needed_counts:
		if needed_counts[combo] > 0:
			needed_list.append(combo)
	if needed_list.size() > 0:
		return needed_list[randi() % needed_list.size()]
	return all_combinations[randi() % all_combinations.size()]

func _on_shape_destroyed(shape_id: String):
	for i in range(current_index, required_sequence.size()):
		if required_sequence[i] == shape_id:
			needed_counts[shape_id] = needed_counts.get(shape_id, 0) + 1
			break

#func _on_shape_destroyed(shape_id: String):
	#if current_index < required_sequence.size():
		#var current_required = required_sequence[current_index]
		#if shape_id == current_required:
			#needed_counts[current_required] = needed_counts.get(current_required, 0) + 1

func _on_receiver_body_entered(body: Node):
	if body is DraggableShape and not body.has_meta("accepted"):
		body.set_meta("accepted", true)
		try_accept_shape(body)

func try_accept_shape(shape: DraggableShape):
	if game_lost:
		return
	if not is_instance_valid(shape):
		return
	
	var shape_id = shape.shape_id
	if current_index >= required_sequence.size():
		shape.destroy()
		return
	#var is_karakuli = shape.shape_type == "Karakuli"
	var is_universal = shape.shape_type == "Cat"
	var required_now = required_sequence[current_index]
	print("required_now: ", required_now)
	print("shape_id: ", shape_id)
	print("shape circle collision: ", shape.circle_collision.disabled)
	print("shape square collision: ", shape.square_collision.disabled)
	print("shape star collision: ", shape.star_collision.disabled)
	print("shape triangle collision: ", shape.triangle_collision.disabled)
	if is_universal or shape_id == required_now:
		shape.destroy()
		current_index += 1
		update_ui_sequence()
		if current_index >= required_sequence.size():
			win_game()
	else:
		reduce_score_gain()
		take_damage()
		shape.destroy()


func win_game():
	#get_tree().paused = true
	score += current_score_gain
	score_label.text = str(score)
	current_score_gain = max_score_gain
	print("Current score: ", score)
	receiver.idle_timer.start()
	var label = Label.new()
	label.text = "Excellent!"
	label.position = Vector2(400, 250)
	label.add_theme_font_size_override("font_size", 40)
	add_child(label)
	# Удалить/выключить текст через 2-3 секунды
	await get_tree().create_timer(1.0).timeout
	label.queue_free()
	lives = min(lives + 2, 5)
	update_lives_display()
	
	conveyor.push_force += 50
	if conveyor.push_force > 1500:
		conveyor.push_force = 1500
		
	current_index = 0
	required_sequence.clear()
	needed_counts.clear()
	
	generate_sequence(randi_range(3,6))
	for combo in required_sequence:
		needed_counts[combo] = 1
	update_ui_sequence()

func lose_game():
	#get_tree().paused = true
	Global.enable(reset_button)
	game_lost = true
	save_score(score)
	score = 0
	current_score_gain = max_score_gain
	var label = Label.new()
	label.text = "GAME OVER\nPress to restart"
	label.position = Vector2(300, 200)
	label.add_theme_font_size_override("font_size", 40)
	label.add_theme_color_override("font_color", Color())
	$background/Patrick.visible = true
	add_child(label)
	reset_button.visible = true
	conveyor.push_force *= 100

func save_score(score):
	var new_save_data = Global.save_data
	print(new_save_data)
	new_save_data.scores.append(score)
	print(new_save_data)
	new_save_data.high_score = new_save_data.scores.max()
	Global.save_json(new_save_data, Global.save_data_path)
	Global.save_data = new_save_data

func _reset_game():
	Global.disable(reset_button)
	game_lost = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func flash_damage():
	#damage_overlay.modulate.a = 0.7
	damage_overlay.color = Color(1.0, 0.0, 0.0, 0.7)
	var tween = create_tween()
	tween.tween_property(damage_overlay, "color:a", 0.0, 0.3)

func show_complaint():
	var msg = complaint_messages[randi() % complaint_messages.size()]
	floating_message.text = msg
	floating_message.visible = true
	await get_tree().create_timer(5).timeout
	floating_message.visible = false

func take_damage():
	lives -= 1
	update_lives_display()
	flash_damage()
	show_complaint()
	if lives <= 0:
		lose_game()

func punish_idle():
	take_damage()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_R):
		if get_tree().paused:
			get_tree().paused = false
			get_tree().reload_current_scene()


func reduce_score_gain():
	current_score_gain -= score_reductor
	if current_score_gain < 0:
		current_score_gain = 0
	
