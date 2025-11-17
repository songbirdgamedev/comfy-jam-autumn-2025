class_name Grid
extends GridContainer

const VEGETABLE: PackedScene = preload("res://scenes/vegetable.tscn")
const GRID_SIZE: int = GameManager.GRID_SIZE

var grid: Array[PackedInt32Array] = []

var axes: Array[PackedVector2Array] = [
	PackedVector2Array([Vector2i.LEFT, Vector2i.RIGHT]),
	PackedVector2Array([Vector2i.UP, Vector2i.DOWN])
]

signal grid_updated


func _ready() -> void:
	set_columns(GRID_SIZE)
	_add_items()


func _add_items() -> void:
	for i in GRID_SIZE:
		grid.append(PackedInt32Array())
		for j in GRID_SIZE:
			var vegetable: Vegetable = VEGETABLE.instantiate()
			grid[i].append(vegetable.type)
			add_child(vegetable)

	await get_tree().create_timer(0.5).timeout
	grid_updated.emit()


func _update_items() -> void:
	for i in GRID_SIZE:
		for j in GRID_SIZE:
			var index: int = _get_index(i, j)
			var vegetable: Vegetable = get_vegetable(index)
			if vegetable.type != grid[i][j]:
				vegetable.update_type(grid[i][j])

	grid_updated.emit()


func get_vegetable(index: int) -> Vegetable:
	return get_child(index)


func _on_grid_updated() -> void:
	var matches: Array[PackedVector2Array] = check_matches()

	if matches.size() > 0:
		set_matches(matches)
	else:
		GameManager.set_ready()


func check_matches() -> Array[PackedVector2Array]:
	var matches: Array[PackedVector2Array] = []

	for n in GRID_SIZE:
		matches.append_array(_check_row(n))
		matches.append_array(_check_column(n))

	return matches


func _check_row(i: int) -> Array[PackedVector2Array]:
	var matches: Array[PackedVector2Array] = []
	var match_group: PackedVector2Array = PackedVector2Array([Vector2i(i, 0)])

	for j in range(1, GRID_SIZE):
		if grid[i][j - 1] == grid[i][j]:
			match_group.append(Vector2i(i, j))
			continue

		if match_group.size() >= 3:
			matches.append(match_group.duplicate())

		match_group.clear()
		match_group.append(Vector2i(i, j))

	if match_group.size() >= 3:
		matches.append(match_group.duplicate())

	return matches


func _check_column(j: int) -> Array[PackedVector2Array]:
	var matches: Array[PackedVector2Array] = []
	var match_group: PackedVector2Array = PackedVector2Array([Vector2i(0, j)])

	for i in range(1, GRID_SIZE):
		if grid[i - 1][j] == grid[i][j]:
			match_group.append(Vector2i(i, j))
			continue

		if match_group.size() >= 3:
			matches.append(match_group.duplicate())

		match_group.clear()
		match_group.append(Vector2i(i, j))

	if match_group.size() >= 3:
		matches.append(match_group.duplicate())

	return matches


func set_matches(matches: Array[PackedVector2Array]) -> void:
	if matches.is_empty():
		return

	for group: PackedVector2Array in matches:
		for item: Vector2i in group:
			_set_match(item.x, item.y)

	_update_grid()


func _set_match(i: int, j: int) -> void:
	var current: int = grid[i][j]
	grid[i][j] = current - 1 if current < 0 else -1


func _update_grid() -> void:
	for n in GRID_SIZE:
		_update_column(n)

	GameManager.set_waiting()
	await AnimationManager.drop_finished
	_update_items()


func _update_column(j: int) -> void:
	var count: int = 0

	for i in range(GRID_SIZE - 1, -1, -1):
		if grid[i][j] < 0:
			count += 1
		elif count > 0:
			grid[i + count][j] = grid[i][j]
			_drop(grid[i][j], i, j, count)

	for i in count:
		grid[i][j] = GameManager.get_new_type()
		_drop(grid[i][j], i - count, j, count)


func _drop(type: int, i: int, j: int, count: int) -> void:
	var start: Vector2 = _get_global_position(i, j)
	var dest: Vegetable = get_vegetable(_get_index(i + count, j))

	AnimationManager.drop(type, start, dest, count)


func _get_global_position(i: int, j: int) -> Vector2:
	if i >= 0:
		return get_vegetable(_get_index(i, j)).global_position

	var drop_position: Vector2 = _get_global_position(0, j)
	drop_position.y += i * GameManager.SPRITE_SIZE
	return drop_position


func _get_index(i: int, j: int) -> int:
	return i * GRID_SIZE + j


func try_swap(vegetable: Vegetable) -> void:
	reset_grid()
	if (
		vegetable.type == GameManager.selected.type
		or not _try_swap(
			_convert(vegetable.index),
			_convert(GameManager.selected.index)
		)
	):
		AnimationManager.swap(vegetable, GameManager.selected)
		await AnimationManager.swap_finished

		AnimationManager.swap(vegetable, GameManager.selected)
		await AnimationManager.swap_finished

		GameManager.set_ready()
	else:
		AnimationManager.swap(vegetable, GameManager.selected)
		await AnimationManager.swap_finished

		GameManager.set_ready()
		_update_items()


func _try_swap(a: Vector2i, b: Vector2i) -> bool:
	_swap(a, b)
	if _check_local_matches(a) or _check_local_matches(b):
		return true
	else:
		_swap(a, b)
		return false


func _check_local_matches(start: Vector2i) -> bool:
	for axis: PackedVector2Array in axes:
		var count: int = 0
		for direction: Vector2i in axis:
			count += _check_direction(start, direction)
			if count >= 2: return true

	return false


func _check_direction(start: Vector2i, direction: Vector2i) -> int:
	var count: int = 0
	var next: Vector2i = start + direction

	while (
		next.x >= 0 and next.y >= 0
		and next.x < GRID_SIZE
		and next.y < GRID_SIZE
		and _check_match(start, next)
	):
		count += 1
		next += direction

	return count


func _check_match(a: Vector2i, b: Vector2i) -> bool:
	return grid[a.x][a.y] == grid[b.x][b.y]


func reset_grid() -> void:
	for index in GameManager.selected.adjacent:
		get_vegetable(index).set_highlight(false)


func shuffle_grid() -> void:
	if GameManager.current_state != GameManager.State.READY:
		return

	for n in range(GRID_SIZE * GRID_SIZE - 1, 0, -1):
		var k: int = randi_range(0, n)
		_swap(_convert(n), _convert(k))

	_update_items()


func _swap(a: Vector2i, b: Vector2i) -> void:
	var temp: int = grid[a.x][a.y]
	grid[a.x][a.y] = grid[b.x][b.y]
	grid[b.x][b.y] = temp


func _convert(n: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(n / GRID_SIZE, n % GRID_SIZE)
