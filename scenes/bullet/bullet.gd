extends Area2D

const BOOM: PackedScene = preload("res://scenes/boom/boom.tscn")
const SPEED: float = 250.0

@onready var timer: Timer = $Timer

var _dir_of_travel: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(_target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += SPEED * delta * _dir_of_travel

func init(target: Vector2, start_pos: Vector2) -> void:
	_target_position = target
	_dir_of_travel = start_pos.direction_to(target)
	global_position = start_pos

func create_boom() -> void:
	var b = BOOM.instantiate()
	b.global_position = global_position
	get_tree().root.add_child(b)
	queue_free()

func _on_timer_timeout() -> void:
	create_boom()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") == true:
		timer.stop()
		SignalManager.on_game_over.emit()
	else:
		create_boom()
