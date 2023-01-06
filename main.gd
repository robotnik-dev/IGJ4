extends Node

var win_condition: int = 50

@onready var gameOver = $GUI/game_over

func _ready() -> void:
	Signals.game_over.connect(game_won)
	Signals.new_game.connect(new_game)

func new_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func game_won() -> void:
	get_tree().paused = true
	gameOver.show()

func close_game() -> void:
	# quit
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_game()
