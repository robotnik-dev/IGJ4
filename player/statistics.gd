class_name  Statistics
extends Resource

var winning_score: int = 50
var highscore: int = 0
var name: String = "player"
var score: int = 0:
	set(value):
		score = value
		if score >= winning_score:
			Signals.emit_signal("game_over")
		else:
			Signals.emit_signal("score_changed", score)
