extends Control

signal event_finished
@export var Enabled: bool = true

@export var press_node: Node2D   # сюда перетащить узел Press из сцены
@export var min_delay: float = 3.0   # минимальная задержка между активациями
@export var max_delay: float = 8.0   # максимальная задержка

@onready var monkey_anim: AnimationPlayer = $MonkeyAnim
var activation_timer: Timer

var click_count: int = 0
var required_clicks: int = 5

@onready var monkey_texture: TextureRect = $MonkeyTexture
const BIBIZYANKA_1 = preload("uid://bh2vommamgkbx")
const BIBIZYANKA_2 = preload("uid://c42laed6fktb8")

@onready var monkey_face: TextureRect = $MonkeyTexture/MonkeyFace
const MONKEY_FACE_1 = preload("uid://b2sr307aytmas")
const MONKEY_FACE_2 = preload("uid://vj35tk7i31d")
const MONKEY_FACE_3 = preload("uid://dvhjxlnvc2l2i")
const MONKEY_FACE_4 = preload("uid://cmcmwbepnw2gi")
const MONKEY_FACE = preload("uid://c7817i72tvef")

@onready var monkey_audio: AudioStreamPlayer2D = $monkey

var is_active: bool = false

func _ready():
	if not Enabled:
		return
	activation_timer = Timer.new()
	activation_timer.one_shot = true
	add_child(activation_timer)
	activation_timer.timeout.connect(_activate_press_randomly)
	press_node.body_destroyed.connect(wow_face)

func wow_face():
	if not is_active:
		return
	monkey_audio.play()
	monkey_face.texture = MONKEY_FACE_3
	await get_tree().create_timer(2).timeout
	monkey_face.texture = MONKEY_FACE_4
	

func start_event():
	if not Enabled:
		stop_event()
		return
	# Показываем обезьянку (если она скрыта)
	is_active = true
	monkey_texture.visible = true
	monkey_anim.play("monkey")
	monkey_audio.play()
	click_count = 0
	required_clicks = randi_range(5, 10)
	# Запускаем первый таймер
	schedule_next_activation()

func stop_event():
	if not Enabled:
		event_finished.emit()
		is_active = false
		return
	monkey_anim.play("RESET")
	if activation_timer:
		activation_timer.stop()
	is_active = false
	monkey_texture.visible = false
	
	event_finished.emit()

func schedule_next_activation():
	monkey_texture.texture = BIBIZYANKA_1
	var delay = randf_range(min_delay, max_delay)
	activation_timer.start(delay)

func _activate_press_randomly():
	if not is_active:
		return
	if press_node and is_instance_valid(press_node) and press_node.has_method("activate_press"):
		press_node.activate_press()
		print("press_node.activate_press()")
		# Проигрываем анимацию обезьянки (например, дёрганье)
		monkey_texture.texture = BIBIZYANKA_2
		#monkey_face.texture = MONKEY_FACE_3
		await get_tree().create_timer(2).timeout
	# Планируем следующее срабатывание (если ивент ещё активен)
	if visible:
		schedule_next_activation()

func _on_monkey_texture_gui_input(event: InputEvent):
	#if not is_active:
		#return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_count += 1
		var face = randi_range(0,1)
		if face == 0:
			monkey_face.texture = MONKEY_FACE_2
		else:
			monkey_face.texture = MONKEY_FACE
			
		# Визуальная обратная связь (например, мигание)
		monkey_texture.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.1).timeout
		monkey_texture.modulate = Color(1, 1, 1)
		monkey_face.texture = MONKEY_FACE_1
		
		if click_count >= required_clicks:
			# Обезьянка убегает
			monkey_anim.play("RESET")
			await monkey_anim.animation_finished
			# Активируем пресс
			#if press_node and press_node.has_method("activate_press"):
				#press_node.activate_press()
			stop_event()
