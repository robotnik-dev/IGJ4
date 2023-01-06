extends MarginContainer

@onready var pointLabel = $VBoxContainer/HBoxContainer/Points

func _ready() -> void:
	Signals.score_changed.connect(_on_score_changed)

func _on_score_changed(score) -> void:
	pointLabel.text = "Points: " + str(score)
