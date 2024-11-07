extends CharacterBody2D

const SPEED: float = 160.0

@export var patrol_points: NodePath

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var player_detect: Node2D = $PlayerDetect

var _waypoints: Array = []
var _current_wp: int = 0
var _player_ref: Player
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false)
	create_wp()
	_player_ref = get_tree().get_first_node_in_group("player")
	call_deferred("set_physics_process", true)

func create_wp() -> void:
	for c in get_node(patrol_points).get_children():
		_waypoints.append(c.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("set_target"):
		nav_agent.target_position = get_global_mouse_position()
	update_navigation()
	process_patrolling()
	raycast_to_player()
	set_label()
	
func raycast_to_player() -> void:
	player_detect.look_at(_player_ref.global_position)
	
func set_label():
	var s: String = ""
	s += "DONE:%s\n" % nav_agent.is_navigation_finished()
	s += "REACHABLE:%s\n" % nav_agent.is_target_reachable()
	s += "REACHED:%s\n" % nav_agent.is_target_reached()
	s += "TARGET:%s" %nav_agent.target_position
	label.text = s
	
func update_navigation() -> void:
	if nav_agent.is_navigation_finished() == false:
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		#精灵朝向下一个路径目标点
		sprite_2d.look_at(next_path_position)
		#计算速度的朝向和大小
		velocity = global_position.direction_to(next_path_position) * SPEED
		#移动
		move_and_slide()
		
func process_patrolling() -> void:
	if nav_agent.is_navigation_finished() == true:
		navigate_wp()
		
func navigate_wp() -> void:
	if _current_wp >= len(_waypoints):
		_current_wp = 0
	nav_agent.target_position = _waypoints[_current_wp]
	_current_wp += 1
