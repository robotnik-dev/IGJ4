extends MarginContainer

var playerStats: Statistics = preload("res://player/player_statistics.tres")

@onready var level = $VBoxContainer/AttrBox/Value
@onready var score = $VBoxContainer/AttrBox2/Value
@onready var score_multiplier = $VBoxContainer/AttrBox3/Value
@onready var length = $VBoxContainer/AttrBox4/Value
@onready var evade_chance = $VBoxContainer/AttrBox5/Value

func _on_visibility_changed() -> void:
#	await self.ready
	if visible:
		update_stats()

func update_stats() -> void:
	level.text = str(playerStats.level)
	score.text = str(playerStats.score)
	score_multiplier.text = "x " + str(playerStats.point_multiplier)
	length.text = str(playerStats.length)
	evade_chance.text = str(playerStats.evade_chance * 100) + " %"
