extends CharacterBody2D
class_name Player

const SPEED: float = 150.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	rotation = velocity.angle()
	
func get_input() -> void:
	var nv = Vector2.ZERO
	nv.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	nv.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = nv.normalized() * SPEED
