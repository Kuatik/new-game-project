extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lever_progress: TextureProgressBar = $Lever/LeverProgress
@onready var lever_texture: TextureRect = $Lever/LeverTexture
@onready var lever_texture_Active: TextureRect = $Lever/LeverTexture2

@onready var lever_cooldown: Timer = $Lever/LeverCooldown

var event_active: bool = false

@export_range(0,15,1) var hold_time: int = 0
var value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lever_progress.hide()


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
		value = 0
		set_value()
		lever_cooldown.start()


func set_value():
	lever_progress.value = value
	if value > 0:
		lever_progress.show()
	else:
		lever_progress.hide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is DraggableShape:
		body.destroy()


func _on_lever_cooldown_timeout() -> void:
	lever_texture.visible = true
	lever_texture_Active.visible = false
