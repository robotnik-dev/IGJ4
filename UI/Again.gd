extends Button


func _on_pressed() -> void:
	Signals.new_game.emit()


func _on_visibility_changed() -> void:
	if visible:
		grab_focus()
