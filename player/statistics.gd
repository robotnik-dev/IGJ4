class_name  Statistics
extends Resource

signal attribute_changed(attribute, value)
signal new_highscore(player_name, highscore)

var winning_score: int = 50
var highscore: int = 0
var player_name: String = "":
	set(value):
		player_name = value
		if floor(score * point_multiplier) > highscore:
			highscore = floor(score * point_multiplier)
			new_highscore.emit(player_name, highscore)

var score: int = 0:
	set(value):
		score = value
#		if score >= winning_score:
#			Signals.emit_signal("game_over")
#		else:
		Signals.emit_signal("score_changed", score)

var level: int = 0
var movement_speed: float = 10.0:
	set(value):
		movement_speed = value
		movement_speed = clampf(movement_speed, min_speed, max_speed)
		attribute_changed.emit("movement_speed", movement_speed)

var movement_speed_change: float = 0.5
var min_speed: float = 1.0
var max_speed: float = 10.0

var evade_chance: float = 0.0:
	set(value):
		evade_chance = value
		evade_chance = clamp(evade_chance, min_evade, max_evade)
		attribute_changed.emit("evade_chance", evade_chance)

var min_evade: float = 0.0
var max_evade: float = 0.75
var length: int = 2:
	set(value):
		length = value
		length = clampi(length, min_length, length)
		attribute_changed.emit("length", length)

var min_length: int = 2

var point_multiplier: float = 1.0:
	set(value):
		point_multiplier = value
		point_multiplier = clampf(point_multiplier, min_multiplier, max_multiplier)
		attribute_changed.emit("point_multiplier", point_multiplier)

var min_multiplier: float = 1.0
var max_multiplier: float = 4.0

var _shorten_value: int = 3
var _evade_up_value: float = 0.15
var _multiplier_up_value: float = 0.5

func reset() -> void:
	self.score = 0
	self.level = 0
	self.length = 2
	self.point_multiplier = 1.0
	self.evade_chance = 0.0

func shorten() -> void:
	self.length -= _shorten_value

func lucky() -> void:
	self.evade_chance += _evade_up_value

func risky() -> void:
	self.point_multiplier += _multiplier_up_value

func has_max_evade() -> bool:
	return true if evade_chance >= max_evade else false

func has_max_multiplier() -> bool:
	return true if point_multiplier >= max_multiplier else false
