extends Node

const SPRITE: PackedScene = preload("res://scenes/vegetable_sprite.tscn")
const SPEED: float = 0.25
const SOUP_POSITION: Vector2 = Vector2(90, 220)

signal swap_finished
signal drop_finished


func create_sprite(type: int, start: Vector2, dest: Vector2, dist: int) -> Tween:
	var sprite: Sprite2D = SPRITE.instantiate()
	sprite.set_texture(GameManager.SPRITES[type])
	sprite.set_global_position(start)
	add_child(sprite)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", dest, dist * SPEED)
	tween.tween_callback(sprite.queue_free)

	return tween


func swap(a: Vegetable, b: Vegetable) -> void:
	var vegetables: Array[Vegetable] = [a, b]

	for vegetable in vegetables:
		vegetable.set_disabled(true)

	var tween: Tween = \
		create_sprite(a.type, a.global_position, b.global_position, 1)
	create_sprite(b.type, b.global_position, a.global_position, 1)
	await tween.finished

	var temp: int = a.type
	a.update_type(b.type)
	b.update_type(temp)

	for vegetable in vegetables:
		vegetable.set_disabled(false)

	swap_finished.emit()


func drop(type: int, start: Vector2, dest: Vegetable, dist: int) -> void:
	dest.set_disabled(true)
	throw(dest.type, dest.global_position)

	var tween: Tween = create_sprite(type, start, dest.global_position, dist)
	await tween.finished

	dest.update_type(type)
	dest.set_disabled(false)

	_check_children()


func throw(type: int, start: Vector2) -> void:
	var tween: Tween = create_sprite(type, start, SOUP_POSITION, 2)
	await tween.finished
	_check_children()


func _check_children() -> void:
	if get_children().all(_check_child):
		drop_finished.emit()


func _check_child(sprite: Sprite2D) -> bool:
	return sprite.is_queued_for_deletion()
