extends PanelContainer

var playerStats: Statistics = preload("res://player/player_statistics.tres")

func _ready() -> void:
	Signals.game_over.connect(game_over)

func game_over() -> void:
	var score = floor(playerStats.score * playerStats.point_multiplier)

func _on_line_edit_text_submitted(new_text: String) -> void:
	playerStats.player_name = new_text
