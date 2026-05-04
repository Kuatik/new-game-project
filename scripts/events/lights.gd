extends Control

signal event_finished

#region Child notes
@onready var lights_color: ColorRect = $LightsColor
@onready var lights_color_2: ColorRect = $LightsColor2
@onready var conveyor: Area2D = %conveyor
@onready var lever_progress: TextureProgressBar = $LightLever/LeverProgress
@onready var audio: AudioStreamPlayer2D = $Audio
@onready var turn_on_sound: AudioStreamPlayer2D = $TurnOnSound

#endregion


#region Lever Textures

@onready var na_lever: TextureRect = $LightLever/NA_Lever
@onready var a_lever: TextureRect = $LightLever/A_Lever
#endregion
#region Export Nodes
@export var Enabled: bool = true
@export var spawn_timer: Timer
@export var hold_duration: float = 3.0
#endregion

var current_hold: float = 0.0
var holding: bool = false
var is_active:bool = false
var temp_force: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_lights_on()
	lever_progress.max_value = hold_duration
	lever_progress.value = 0
	a_lever.mouse_filter = Control.MOUSE_FILTER_STOP
	a_lever.gui_input.connect(_on_a_lever_gui_input)
	a_lever.mouse_exited.connect(_on_a_lever_mouse_exited)
	# Checks
	if conveyor:
		print("conveyor found")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_active:
		return
	if holding:
		lever_progress.show()
		current_hold += delta
		lever_progress.value = current_hold
		if current_hold >= hold_duration:
			turn_on_sound.playing = true
			stop_event()
			holding = false
	else:
		if current_hold != 0:
			current_hold = 0
			lever_progress.value = 0
			lever_progress.hide()

#region Light Switchers

func turn_lights_off():
	audio.play()
	lights_color.visible = true
	lights_color_2.visible = true
	a_lever.visible = true
	na_lever.visible = false
	
func turn_lights_on():
	lights_color.visible = false
	lights_color_2.visible = false
	a_lever.visible = false
	na_lever.visible = true
	lever_progress.hide()
#endregion

#region Conveyor switchers
func stop_conveyor():
	temp_force = conveyor.get_push_force()
	conveyor.set_push_force(0.0)
	spawn_timer.paused = true

func start_conveyor():
	conveyor.set_push_force(temp_force)
	spawn_timer.paused = false


#endregion

func start_event():
	if is_active:
		return
	if not Enabled:
		print("Event is NOT ENABLED")
		temp_force = conveyor.get_push_force()
		
		stop_event()
		return
	is_active = true
	turn_lights_off()
	stop_conveyor()
	current_hold = 0.0
	lever_progress.value = 0
	holding = false

func stop_event():
	#if not is_active:
		#return
	is_active = false
	turn_lights_on()
	start_conveyor()
	# Отправить сигнал что ивент закончен.
	event_finished.emit()
	print("event_finished.emit()")

func _on_a_lever_gui_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		holding = event.pressed

func _on_a_lever_mouse_exited() -> void:
	holding = false
	# Зажать ЛКМ чтобы включить свет
	# progress bar показывает этот процесс
	#pass # Replace with function body.
