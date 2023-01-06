extends TileMap

@export_range(0.0, 100.0, 1.0) var upside_down_transition: float:
	set(percent):
		upside_down_transition = percent
		_upside_down_transition(percent)

@export var transition_after_x_food: int = 3
@export var movement_speed: float = 8.0


var playerStats: Statistics = preload("res://player/player_statistics.tres")
var collected_foods: int:
	get:
		return collected_foods
	set(value):
		collected_foods = value
		if collected_foods >= transition_after_x_food:
			collected_foods = 0
			match _state:
				States.NORMAL:
					anim.play("to_upside_down")
				States.UPSIDE_DOWN:
					anim.play("to_normal")
			_toggle_state()

var _head_tiles = {
	Vector2i.UP: Vector2i(1,0),
	Vector2i.DOWN: Vector2i(0,0),
	Vector2i.LEFT: Vector2i(3,0),
	Vector2i.RIGHT: Vector2i(2,0),
	
}
enum States {NORMAL, UPSIDE_DOWN}
var _state: int = States.NORMAL
var _body_tile = Vector2i(0,1)
var _food_tile = Vector2i(1,0)
var _obstacle_tile = Vector2i(9,0)
var _snake: Array = []
var _head_direction = Vector2i.RIGHT
var _start_cell_coords = Vector2i.ZERO

@onready var StartPos = $StartPosiiton
@onready var MoveSnakeTimer = $MoveSnakeTimer
@onready var FoodSpawnTimer = $FoodSpawnTimer
@onready var anim = $AnimationPlayer

func _ready() -> void:
	init__snake()
	init_movement()

func init_movement() -> void:
	MoveSnakeTimer.wait_time = 1.0 / movement_speed
	MoveSnakeTimer.start()

func init__snake() -> void:
	_start_cell_coords = local_to_map(StartPos.position)
	_snake.append(_start_cell_coords)
	_snake.append(_start_cell_coords + _head_direction)
	_snake.append(_start_cell_coords + (_head_direction * 2))
	
	for coords in _snake:
		set_cell(1, coords, 1, _body_tile)

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("move_down"):
		if _state == States.UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.DOWN else Vector2i.UP
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.UP else Vector2i.DOWN
	
	if event.is_action_pressed("move_left"):
		if _state == States.UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.LEFT else Vector2i.RIGHT		
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.RIGHT else Vector2i.LEFT
	
	if event.is_action_pressed("move_up"):
		if _state == States.UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.UP else Vector2i.DOWN
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.DOWN else Vector2i.UP
	
	if event.is_action_pressed("move_right"):
		if _state == States.UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.RIGHT else Vector2i.LEFT			
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.LEFT else Vector2i.RIGHT

func check_for_collision(head_coords: Vector2i) -> void:
	if head_coords in get_used_cells(1) or \
		head_coords in get_used_cells(3):
		# collision with self
		_on_self_collision()
	
	if head_coords in get_used_cells(2):
		# collectible
		erase_cell(2, head_coords)
		collected_foods += 1
		add_body_part()
		playerStats.score += 1

func _toggle_state() -> void:
	match _state:
		States.NORMAL:
			_state = States.UPSIDE_DOWN
		States.UPSIDE_DOWN:
			_state = States.NORMAL

func _on_self_collision() -> void:
	get_tree().reload_current_scene()

func add_body_part() -> void:
	_snake.insert(0, _snake[0])

func _upside_down_transition(percent: float = 0.0) -> void:
	var completed: float = 0.0
	var completed_cells: int = 0
	var cells = get_used_cells(0)
	cells.sort()
	for cell in cells:
		if completed >= percent:
			set_cell(0, cell, 0, Vector2i(14, 4))
			continue
		
		set_cell(0, cell, 0, Vector2i(8, 4))
		
		completed_cells += 1
		completed = float(completed_cells) / float(cells.size()) * 100

func pause_snake_movement() -> void:
	FoodSpawnTimer.stop()
	MoveSnakeTimer.stop()

func resume_snake_movement() -> void:
	FoodSpawnTimer.start()
	MoveSnakeTimer.start()

func move_snake() -> void:
	# pop the tail
	var tail_coords = _snake.pop_front()
	
	# delete cell on this coords
	erase_cell(1, tail_coords)
	
	# set the old head to body cell
	set_cell(1, _snake[-1], 1, _body_tile)
	
	# append new head in head direction
	var new_head_coords = _snake[-1] + _head_direction
	check_for_collision(new_head_coords)
	_snake.append(new_head_coords)
	
	# set the new head cell as head tile
	set_cell(1, _snake[-1], 1, _head_tiles.get(_head_direction))


func _get_free_random_coord() -> Vector2i:
	var rect: Rect2i = get_used_rect()
	var used_snake: Array = get_used_cells(1)
	var used_consumables: Array = get_used_cells(2)
	var used_obstacle: Array = get_used_cells(3)
	var rand_coord = Vector2i(
		randi_range(rect.position.x, rect.end.x),
		randi_range(rect.position.y, rect.end.y)
	)

	while rand_coord in used_snake or \
		rand_coord in used_consumables or \
		rand_coord in used_obstacle:
		rand_coord = Vector2i(
			randi_range(rect.position.x, rect.end.x),
			randi_range(rect.position.y, rect.end.y)
		)
	
	return rand_coord

func spawn_obstacle() -> void:
	var rand_coord = _get_free_random_coord()
	
	set_cell(3, rand_coord, 0, _obstacle_tile)

func spawn_food() -> void:
	var rand_coord = _get_free_random_coord()
	
	set_cell(2, rand_coord, 0, _food_tile)


func _on_food_spawn_timer_timeout() -> void:
	spawn_food()


func _on_move_snake_timer_timeout() -> void:
	move_snake()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"to_upside_down":
			# clear consumables
			clear_layer(2)
		"to_normal":
			# clear obstacles
			clear_layer(3)

	set_process_unhandled_input(true)


func _on_obstacle_spawn_timer_timeout() -> void:
	if _state == States.UPSIDE_DOWN:
		spawn_obstacle()

