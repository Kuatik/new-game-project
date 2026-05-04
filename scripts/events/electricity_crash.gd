extends Control

signal event_finished

@export var Enabled: bool = true

@onready var spawn_timer: Timer = $"../../SpawnTimer"
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d2: GPUParticles2D = $GPUParticles2D2
@onready var bulb_texture: TextureRect = $BulbTexture
@onready var fix_machine: Control = $FixMachine
#@onready var main: Node2D = $"../.."
#@onready var fix_machine: Control = $FixMachine
var is_active: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bulb_texture.visible = false
	gpu_particles_2d.emitting = false
	gpu_particles_2d2.emitting = false
	fix_machine.hide()
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# TEST
	if not is_active:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		#stop_event()
		
		fix_machine.show()
	#pass



func start_event():
	if is_active:
		return
	if not Enabled:
		print("Event is NOT ENABLED")
		stop_event()
		return
	is_active = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d2.emitting = true
	bulb_texture.visible = true
	spawn_timer.paused = true
	fix_machine.game_completed.connect(stop_event)
	fix_machine.start_game()

func stop_event():
	#if not is_active:
		#return
	is_active = false
	gpu_particles_2d.emitting = false
	gpu_particles_2d2.emitting = false
	spawn_timer.paused = false
	bulb_texture.visible = false
	fix_machine.hide()
	#emit_signal("event_finished")
	fix_machine.game_completed.disconnect(stop_event)
	event_finished.emit()
	print("event_finished.emit()")
