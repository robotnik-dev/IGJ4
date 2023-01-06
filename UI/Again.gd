extends Button


func _on_pressed() -> void:
	Signals.new_game.emit()
