extends TileMap

signal level_up
signal collision

@export_range(0.0, 100.0, 1.0) var upside_down_transition: float:
	set(percent):
		upside_down_transition = percent
		_upside_down_transition(percent)

@export var transition_after_x_food: int = 3

enum {
	GROUND,
	SNAKE,
	COLLECTIBLE,
	OBSTACLE,
	BORDER
}

var playerStats: Statistics = preload("res://player/player_statistics.tres")
var collected_foods: int:
	get:
		return collected_foods
	set(value):
		collected_foods = value
		if collected_foods >= transition_after_x_food:
			collected_foods = 0
			match _state:
				NORMAL:
					anim.play("to_upside_down")
				UPSIDE_DOWN:
					anim.play("to_normal")

var _head_tiles = {
	Vector2i.UP: Vector2i(1,0),
	Vector2i.DOWN: Vector2i(0,0),
	Vector2i.LEFT: Vector2i(3,0),
	Vector2i.RIGHT: Vector2i(2,0),
	
}

enum {NORMAL, UPSIDE_DOWN, TRANSITION}
var _state: int = NORMAL
var _body_tile = Vector2i(0,1)
var _food_tile = Vector2i(1,0)
var _obstacle_tile = Vector2i(0,0)
var _snake: Array = []
var _head_direction = Vector2i.RIGHT
var _start_cell_coords = Vector2i.ZERO
var _snake_can_move: bool = false

const _upsidedown_ground_tile = Vector2i(2, 4)
const _upsidedown_border_l = Vector2i(1, 4)
const _upsidedown_border_r = Vector2i(3, 4)
const _upsidedown_border_t = Vector2i(2, 3)
const _upsidedown_border_b = Vector2i(2, 5)
const _upsidedown_border_tl = Vector2i(1, 3)
const _upsidedown_border_tr = Vector2i(3, 3)
const _upsidedown_border_br = Vector2i(3, 5)
const _upsidedown_border_bl = Vector2i(1, 5)

const _ground_tile = Vector2i(2, 7)
const _ground_border_l = Vector2i(1, 7)
const _ground_border_r = Vector2i(3, 7)
const _ground_border_t = Vector2i(2, 6)
const _ground_border_b = Vector2i(2, 8)
const _ground_border_tl = Vector2i(1, 6)
const _ground_border_tr = Vector2i(3, 6)
const _ground_border_br = Vector2i(3, 8)
const _ground_border_bl = Vector2i(1, 8)


var _upsidedown_wait_time: float = 4.0
var _normal_wait_time: float = 3.0

@onready var StartPos = $StartPosiiton
@onready var MoveSnakeTimer = $MoveSnakeTimer
@onready var FoodSpawnTimer = $FoodSpawnTimer
@onready var ObstacleSpawnTimer = $ObstacleSpawnTimer
@onready var anim = $AnimationPlayer
@onready var normalMusic = $NormalMusic
@onready var upsideDownMusic = $UpsideDownMusic
@onready var eatSound = $EatSound

func _ready() -> void:
	playerStats.attribute_changed.connect(_on_attribute_changed)
	init_snake()
	set_new_speed(playerStats.movement_speed)
	normalMusic.play()

func _process(delta):
	if _snake_can_move:
		_move_snake()
		_snake_can_move = false

func set_new_speed(value: float) -> void:
	MoveSnakeTimer.stop()
	MoveSnakeTimer.wait_time = 1.0 / value
	MoveSnakeTimer.start()

func init_snake() -> void:
	_start_cell_coords = local_to_map(StartPos.position)
	_snake.append(_start_cell_coords)
	_snake.append(_start_cell_coords + _head_direction)
	_snake.append(_start_cell_coords + (_head_direction * 2))
	
	for coords in _snake:
		set_cell(SNAKE, coords, 1, _body_tile)
	set_cell(SNAKE, _snake[-1], 1, _head_tiles.get(_head_direction))

func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("move_down"):
		get_viewport().set_input_as_handled()
		if _state == UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.DOWN else Vector2i.UP
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.UP else Vector2i.DOWN
	
	if event.is_action_pressed("move_left"):
		get_viewport().set_input_as_handled()
		
		if _state == UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.LEFT else Vector2i.RIGHT		
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.RIGHT else Vector2i.LEFT
	
	if event.is_action_pressed("move_up"):
		get_viewport().set_input_as_handled()
		
		if _state == UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.UP else Vector2i.DOWN
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.DOWN else Vector2i.UP
	
	if event.is_action_pressed("move_right"):
		get_viewport().set_input_as_handled()
		
		if _state == UPSIDE_DOWN:
			_head_direction = _head_direction if _head_direction == Vector2i.RIGHT else Vector2i.LEFT			
		else:
			_head_direction = _head_direction if _head_direction == Vector2i.LEFT else Vector2i.RIGHT

func check_for_collision(head_coords: Vector2i) -> void:
	if head_coords in get_used_cells(BORDER):
		_on_self_collision()
	
	elif head_coords in get_used_cells(SNAKE) or \
		head_coords in get_used_cells(OBSTACLE):
			# calculate with evade chance
			var evaded = false
			
			if randf() < playerStats.evade_chance:
				evaded = true
			
			if not evaded:
				# collision with self or with obstacle
				_on_self_collision()
			else:
				# TODO: cool effect
				pass
	
	elif head_coords in get_used_cells(COLLECTIBLE):
		# collectible
		eatSound.play()
		erase_cell(COLLECTIBLE, head_coords)
		playerStats.length += 1
		collected_foods += 1
		playerStats.score += 1

func pause_snake_movement() -> void:
	FoodSpawnTimer.stop()
	MoveSnakeTimer.stop()

func resume_snake_movement() -> void:
	FoodSpawnTimer.start()
	MoveSnakeTimer.start()

func _switch_state(state: int) -> void:
	_state = state
	match  state:
		UPSIDE_DOWN:
			normalMusic.stop()
			upsideDownMusic.play()
		NORMAL:
			upsideDownMusic.stop()
			normalMusic.play()

func _on_self_collision() -> void:
	collision.emit()

func add_body_part() -> void:
	_snake.insert(0, _snake[0])

func remove_body_part() -> void:
	var erased = _snake.pop_front()
	erase_cell(SNAKE, erased)

func _on_attribute_changed(attribute: String, value: float) -> void:
	match attribute:
		"length":
			var diff = _snake.size() - value
			if sign(diff) == -1:
				add_body_part()
			else:
				for i in range(diff):
					remove_body_part()

func _upside_down_transition(percent: float = 0.0) -> void:
	var completed: float = 0.0
	var completed_cells: int = 0
	var cells = get_used_cells(GROUND)
	cells.sort()
	for cell in cells:
		if completed >= percent:
			set_cell(GROUND, cell,0, _ground_tile)
			continue
		
		set_cell(GROUND, cell, 0, _upsidedown_ground_tile)
		
		completed_cells += 1
		completed = float(completed_cells) / float(cells.size()) * 100

func _set_borders() -> void:
	match _state:
		UPSIDE_DOWN:
			var cells = get_used_cells(BORDER)
			cells.sort()
			for cell in cells:
				var atlas_coord: Vector2i = get_cell_atlas_coords(BORDER, cell)
				match atlas_coord:
					_ground_border_b:
						set_cell(BORDER, cell, 0, _upsidedown_border_b)
					_ground_border_br:
						set_cell(BORDER, cell, 0, _upsidedown_border_br)
					_ground_border_bl:
						set_cell(BORDER, cell, 0, _upsidedown_border_bl)
					_ground_border_t:
						set_cell(BORDER, cell, 0, _upsidedown_border_t)
					_ground_border_tr:
						set_cell(BORDER, cell, 0, _upsidedown_border_tr)
					_ground_border_tl:
						set_cell(BORDER, cell, 0, _upsidedown_border_tl)
					_ground_border_r:
						set_cell(BORDER, cell, 0, _upsidedown_border_r)
					_ground_border_l:
						set_cell(BORDER, cell, 0, _upsidedown_border_l)
		NORMAL:
			var cells = get_used_cells(BORDER)
			cells.sort()
			for cell in cells:
				var atlas_coord: Vector2i = get_cell_atlas_coords(BORDER, cell)
				match atlas_coord:
					_upsidedown_border_b:
						set_cell(BORDER, cell, 0, _ground_border_b)
					_upsidedown_border_br:
						set_cell(BORDER, cell, 0, _ground_border_br)
					_upsidedown_border_bl:
						set_cell(BORDER, cell, 0, _ground_border_bl)
					_upsidedown_border_t:
						set_cell(BORDER, cell, 0, _ground_border_t)
					_upsidedown_border_tr:
						set_cell(BORDER, cell, 0, _ground_border_tr)
					_upsidedown_border_tl:
						set_cell(BORDER, cell, 0, _ground_border_tl)
					_upsidedown_border_r:
						set_cell(BORDER, cell, 0, _ground_border_r)
					_upsidedown_border_l:
						set_cell(BORDER, cell, 0, _ground_border_l)

func _move_snake() -> void:
	# save local direction in case of raise condition
	var current_direction = _head_direction
	
	# pop the tail
	var tail_coords = _snake.pop_front()
	
	# delete cell on this coords
	erase_cell(SNAKE, tail_coords)
	
	# set the old head to body cell
	set_cell(SNAKE, _snake[-1], 1, _body_tile)
	
	# append new head in head direction
	var new_head_coords = _snake[-1] + current_direction
	check_for_collision(new_head_coords)
	_snake.append(new_head_coords)
	
	# set the new head cell as head tile
	set_cell(SNAKE, _snake[-1], 1, _head_tiles.get(current_direction))
	force_update(SNAKE)

func _get_free_random_coord() -> Vector2i:
	var rect: Rect2i = get_used_rect()
	
	var rand_coord = Vector2i(
		randi_range(rect.position.x, rect.end.x),
		randi_range(rect.position.y, rect.end.y)
	)

	while rand_coord in get_used_cells(SNAKE) or \
		rand_coord in get_used_cells(COLLECTIBLE) or \
		rand_coord in get_used_cells(OBSTACLE) or \
		rand_coord in get_used_cells(BORDER):
		rand_coord = Vector2i(
			randi_range(rect.position.x, rect.end.x),
			randi_range(rect.position.y, rect.end.y)
		)
	
	return rand_coord

func _spawn_obstacle() -> void:
	var rand_coord = _get_free_random_coord()
	
	set_cell(OBSTACLE, rand_coord, 0, _obstacle_tile)

func _spawn_food() -> void:
	var rand_coord = _get_free_random_coord()
	
	set_cell(COLLECTIBLE, rand_coord, 0, _food_tile)


func _on_food_spawn_timer_timeout() -> void:
	_spawn_food()


func _on_move_snake_timer_timeout() -> void:
	_snake_can_move = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"to_upside_down":
			clear_layer(COLLECTIBLE)
			
			_switch_state(UPSIDE_DOWN)
		"to_normal":
			clear_layer(OBSTACLE)
			clear_layer(COLLECTIBLE)
			
			_switch_state(NORMAL)
			
			level_up.emit()

	set_process_unhandled_input(true)


func _on_obstacle_spawn_timer_timeout() -> void:
	if _state == UPSIDE_DOWN:
		_spawn_obstacle()


func _on_animation_player_animation_started(anim_name):
	_switch_state(TRANSITION)


func _on_normal_music_finished() -> void:
	normalMusic.play()


func _on_upside_down_music_finished() -> void:
	upsideDownMusic.play()
