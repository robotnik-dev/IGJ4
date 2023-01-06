extends CanvasLayer

@onready var gameOver: PopupPanel = $game_over

func _ready() -> void:
	Signals.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	gameOver.popup_centered()
