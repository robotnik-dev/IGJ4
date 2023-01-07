extends PanelContainer

@onready var button1 = $MarginContainer/VBoxContainer/HBoxContainer/LevelUpBtn
@onready var button2 = $MarginContainer/VBoxContainer/HBoxContainer/LevelUpBtn2
@onready var button3 = $MarginContainer/VBoxContainer/HBoxContainer/LevelUpBtn3

func _on_visibility_changed():
	if visible:
		if button1:
			if not button1.disabled:
				button1.grab_focus()
		elif button2:
			if not button2.disabled:
				button2.grab_focus()
		else:
			if not button3.disabled:
				button3.grab_focus()
