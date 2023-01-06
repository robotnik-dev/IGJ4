extends PanelContainer

var playerStats : Statistics = preload("res://player/player_statistics.tres")

@onready var playerName = $MarginContainer/VBoxContainer/Statistics/MarginContainer/VBoxContainer/VBoxContainer/PlayerName
@onready var score = $MarginContainer/VBoxContainer/Statistics/MarginContainer/VBoxContainer/VBoxContainer/Score
@onready var highscore = $MarginContainer/VBoxContainer/Statistics/MarginContainer/VBoxContainer/VBoxContainer/Highscore


func _ready() -> void:
	Signals.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	playerName = "NAME: " + playerStats.name
	score = "SCORE: " + str(playerStats.score)
	highscore = "HIGHSCORE: " + str(playerStats.highscore)

