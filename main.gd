extends Node

var playerStats: Statistics = preload("res://player/player_statistics.tres")

@onready var gameOver = $GUI/game_over
@onready var tileMap = $TileMap
@onready var levelUp: PanelContainer = $GUI/LevelUp

func _ready() -> void:
	Signals.game_over.connect(game_won)
	Signals.new_game.connect(new_game)
	tileMap.level_up.connect(_on_level_up)
	tileMap.collision.connect(new_game)
	Signals.leveled.connect(_on_level_option_selected)

func new_game() -> void:
	get_tree().paused = false
	playerStats.reset()
	get_tree().reload_current_scene()

func game_won() -> void:
	get_tree().paused = true
	gameOver.show()

func close_game() -> void:
	get_tree().quit()

func _on_level_option_selected() -> void:
	levelUp.hide()
	get_tree().paused = false

func _on_level_up() -> void:
	playerStats.level += 1
	get_tree().paused = true
	levelUp.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_game()
