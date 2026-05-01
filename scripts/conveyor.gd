extends Area2D

@export var push_force: float = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody2D and body.get_meta("on_conveyor", false):
			body.apply_central_force(Vector2(push_force, 0))


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and not body is DraggableShape == false:
		body.set_meta("on_conveyor", true)


func _on_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		body.set_meta("on_conveyor", false)
