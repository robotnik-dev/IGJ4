extends Button

var playerStats: Statistics = preload("res://player/player_statistics.tres")

func _on_pressed():
	match text:
		"SHORTEN":
			playerStats.shorten()
		"LUCKY":
			playerStats.lucky()
		"GREEDY":
			playerStats.risky()

	Signals.leveled.emit()

