extends Button

var playerStats: Statistics = preload("res://player/player_statistics.tres")

@onready var option = $VBoxContainer/Option

func _on_pressed():
	match option.text:
		"SHORTEN":
			playerStats.shorten()
		"LUCKY":
			playerStats.lucky()
		"RISKY":
			playerStats.risky()

	Signals.leveled.emit()
