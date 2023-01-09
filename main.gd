extends Node

var playerStats: Statistics = preload("res://player/player_statistics.tres")

@onready var gameOver = $GUI/game_over
@onready var tileMap = $TileMap
@onready var levelUp: PanelContainer = $GUI/LevelUp
@onready var stats = $GUI/Stats

func _ready() -> void:
	Signals.game_over.connect(game_won)
	Signals.new_game.connect(new_game)
	tileMap.level_up.connect(_on_level_up)
	tileMap.collision.connect(game_over)
	Signals.leveled.connect(_on_level_option_selected)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func new_game() -> void:
	get_tree().paused = false
	playerStats.reset()
	get_tree().reload_current_scene()
	up_alpha()

func game_over() -> void:
	get_tree().paused = true
	gameOver.show()
	gameOver.game_over()
	lower_alpha()

func game_won() -> void:
	get_tree().paused = true
	gameOver.show()
	lower_alpha()

func _on_level_option_selected() -> void:
	levelUp.hide()
	get_tree().paused = false
	up_alpha()

func _on_level_up() -> void:
	playerStats.level += 1
	get_tree().paused = true
	levelUp.show()
	lower_alpha()

func pause_game() -> void:
	get_tree().paused = true
	stats.show()
	lower_alpha()

func unpause_game() -> void:
	if gameOver.visible or levelUp.visible:
		return
	stats.hide()
	get_tree().paused = false
	up_alpha()

func lower_alpha() -> void:
	tileMap.modulate = Color(1, 1, 1, 0.19607843458652)

func up_alpha() -> void:
	tileMap.modulate = Color(1, 1, 1, 1)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			unpause_game()
		else:
			pause_game()
