extends CharacterBody2D

const SPEED: float = 160.0

enum ENEMY_STATE { PATROLLING, CHASING, SEARCHING }

@export var patrol_points: NodePath

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var player_detect: Node2D = $PlayerDetect
@onready var ray_cast_2d: RayCast2D = $PlayerDetect/RayCast2D

var _waypoints: Array = []
var _current_wp: int = 0
var _player_ref: Player
var _state: ENEMY_STATE = ENEMY_STATE.PATROLLING
 
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
	#if Input.is_action_just_pressed("set_target"):
		#nav_agent.target_position = get_global_mouse_position()
	raycast_to_player()
	update_state()
	update_movement()
	update_navigation()
	set_label() 

#raycast
func can_see_player() -> bool:
	return player_in_fov() and player_detected()

func get_fov_angle() -> float:
	var direction = global_position.direction_to(_player_ref.global_position)
	var dot_p = direction.dot(velocity.normalized())
	if dot_p >= -1.0 and dot_p <= 1.0:
		return rad_to_deg(acos(dot_p))
	return 0.0
	
func player_in_fov() -> bool:
	return get_fov_angle() < 60.0
	
func raycast_to_player() -> void:
	player_detect.look_at(_player_ref.global_position)
	
func player_detected() -> bool:
	var c = ray_cast_2d.get_collider()
	if c != null:
		return c.is_in_group("player")
	return false
	
#navigation
func update_navigation() -> void:
	if nav_agent.is_navigation_finished() == false:
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		#精灵朝向下一个路径目标点
		sprite_2d.look_at(next_path_position)
		#计算速度的朝向和大小
		velocity = global_position.direction_to(next_path_position) * SPEED
		#移动
		move_and_slide()
	
#state
func update_state() -> void:
	var new_state = _state
	var can_see = can_see_player()
	if can_see == true:
		new_state = ENEMY_STATE.CHASING
	else:
		new_state = ENEMY_STATE.PATROLLING
	
	set_state(new_state)
	
func set_state(new_state: ENEMY_STATE) -> void:
	if new_state == _state:
		return
	_state = new_state

#movement
func update_movement() -> void:
	match _state:
		ENEMY_STATE.PATROLLING:
			process_patrolling()
		ENEMY_STATE.CHASING:
			process_chasing()
			
func process_patrolling() -> void:
	if nav_agent.is_navigation_finished() == true:
		navigate_wp()
		
func navigate_wp() -> void:
	if _current_wp >= len(_waypoints):
		_current_wp = 0
	nav_agent.target_position = _waypoints[_current_wp]
	_current_wp += 1
	
func process_chasing() -> void:
	set_nav_to_player()
	
func set_nav_to_player() -> void:
	nav_agent.target_position = _player_ref.global_position

#debug
func set_label():
	var s: String = ""
	s += "Done:%s\n" % nav_agent.is_navigation_finished()
	s += "Reached:%s\n" % nav_agent.is_target_reached()
	s += "Target:%s\n" % nav_agent.target_position
	s += "PlayerDetected:%s\n" % player_detected()
	s += "FOV:%.2f %s\n" % [get_fov_angle(), ENEMY_STATE.keys()[_state]]
	label.text = s
