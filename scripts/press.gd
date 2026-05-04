extends Node2D

signal body_destroyed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lever_progress: TextureProgressBar = $Lever/LeverProgress
@onready var lever_texture: TextureRect = $Lever/LeverTexture
@onready var lever_texture_Active: TextureRect = $Lever/LeverTexture2
@onready var audio: AudioStreamPlayer2D = $Audio

@onready var lever_cooldown: Timer = $Lever/LeverCooldown
@onready var destroy_sound: AudioStreamPlayer2D = $Area2D/DestroySound

var event_active: bool = false

@export_range(0,15,1) var hold_time: int = 0
var value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lever_progress.hide()
	lever_cooldown.timeout.connect(_revert_lever)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not lever_cooldown.is_stopped() or event_active:
		#lever_progress.tint_progress = Color(1,0,0)
		return
	if Input.is_action_just_pressed("lever_press"):
		value = 0
	elif Input.is_action_pressed("lever_press"):
		value += 1
		#value += 1 / (100*delta)
	elif Input.is_action_just_released("lever_press"):
		value = 0
	set_value()
	
	if lever_progress.value == 100:
		lever_texture.visible = false
		lever_texture_Active.visible = true
		animation_player.play("press")
		#audio.play()
		value = 0
		set_value()
		lever_cooldown.start()


func set_value():
	lever_progress.value = value
	if value > 0:
		lever_progress.show()
	else:
		lever_progress.hide()


func _revert_lever():
	lever_texture.visible = true
	lever_texture_Active.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is DraggableShape:
		body.destroy()
		body_destroyed.emit()
		destroy_sound.playing = true


func _on_lever_cooldown_timeout() -> void:
	lever_texture.visible = true
	lever_texture_Active.visible = false

# FOR MONKEY

# Добавьте эту функцию в конец press.gd
func activate_press():
	print("activate_press() ПРИШЛО")
	if lever_cooldown.is_stopped() and event_active:
		value = 100
		set_value()
		lever_texture.visible = false
		lever_texture_Active.visible = true
		animation_player.play("press")
		# audio.play()
		value = 0
		set_value()
		lever_cooldown.start()
