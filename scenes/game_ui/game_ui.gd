extends Control

@onready var score_label: Label = $MarginContainer/ScoreLabel
@onready var exit_label: Label = $MarginContainer/ExitLabel
@onready var time_label: Label = $MarginContainer/TimeLabel
@onready var color_rect: ColorRect = $ColorRect
@onready var game_over_label: Label = $ColorRect/GameOverLabel

var _time: float = 0.0
var _game_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_show_exit.connect(on_show_exit)
	SignalManager.on_exit.connect(on_exit)
	SignalManager.on_game_over.connect(on_game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _game_over == false:
		_time += delta
		time_label.text = "%0.1fs" % _time
	elif Input.is_action_just_pressed("press_space"):
		GameManager.load_main_scene()
	
func update_score(act: int, target: int) -> void:
	score_label.text = "%s / %s" % [ act, target ]
	
func on_show_exit() -> void:
	exit_label.show()

func on_exit() -> void:
	_game_over = true
	color_rect.show()
	game_over_label.text = "Well done! you took %.1f seconds" % _time

func on_game_over() -> void:
	if _game_over == false:
		color_rect.show()
		_game_over = true
		game_over_label.text = "You Lose! Press Space to Replay"
