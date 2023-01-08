extends PanelContainer

var playerStats: Statistics = preload("res://player/player_statistics.tres")

@onready var button1 = $MarginContainer/VBoxContainer/HBoxContainer/Selection/VBoxContainer/HBoxContainer/LevelUpBtn
@onready var level = $MarginContainer/VBoxContainer/HBoxContainer/Stats/VBoxContainer/AttrBox/Value
@onready var score = $MarginContainer/VBoxContainer/HBoxContainer/Stats/VBoxContainer/AttrBox2/Value
@onready var score_multiplier = $MarginContainer/VBoxContainer/HBoxContainer/Stats/VBoxContainer/AttrBox3/Value
@onready var length = $MarginContainer/VBoxContainer/HBoxContainer/Stats/VBoxContainer/AttrBox4/Value
@onready var evade_chance = $MarginContainer/VBoxContainer/HBoxContainer/Stats/VBoxContainer/AttrBox5/Value


func _on_visibility_changed():
	if visible:
		if button1:
			button1.grab_focus()


func _on_level_up_btn_focus_entered() -> void:
	length.modulate = Color(0.06639998406172, 0.8299999833107, 0.19366653263569)
	var shorten_v = clampi(playerStats.length - playerStats._shorten_value, playerStats.min_length, playerStats.length - playerStats._shorten_value)
	length.text = str(shorten_v)


func _on_level_up_btn_focus_exited() -> void:
	length.modulate = Color(1, 1, 1)
	length.text = str(playerStats.length)


func _on_level_up_btn_2_focus_entered() -> void:
	evade_chance.modulate = Color(0.06639998406172, 0.8299999833107, 0.19366653263569)
	var preview_evade_chance = clampf(playerStats.evade_chance + playerStats._evade_up_value, playerStats.min_evade, playerStats.max_evade)
	evade_chance.text = str(preview_evade_chance * 100) + " %"


func _on_level_up_btn_2_focus_exited() -> void:
	evade_chance.modulate = Color(1, 1, 1)
	evade_chance.text = str(playerStats.evade_chance * 100) + " %"


func _on_level_up_btn_3_focus_entered() -> void:
	score_multiplier.modulate = Color(0.06639998406172, 0.8299999833107, 0.19366653263569)
	var preview_score_multiplier = clampf(playerStats.point_multiplier +  playerStats._multiplier_up_value, playerStats.min_multiplier, playerStats.max_multiplier)
	score_multiplier.text = "x " + str(preview_score_multiplier)


func _on_level_up_btn_3_focus_exited() -> void:
	score_multiplier.modulate = Color(1, 1, 1)
	score_multiplier.text = "x " + str(playerStats.point_multiplier)
