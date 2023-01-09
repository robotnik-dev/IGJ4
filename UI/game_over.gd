extends PanelContainer

var playerStats: Statistics = preload("res://player/player_statistics.tres")

@onready var stats = $MarginContainer/VBoxContainer/VBoxContainer/Stats

func game_over() -> void:
	var final_score = floor(playerStats.score * playerStats.point_multiplier)
	final_score += playerStats.length
	final_score += playerStats.level
	
	playerStats.score = final_score
	
	stats.update_stats()
