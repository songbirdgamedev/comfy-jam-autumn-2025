extends Node

const SPRITES: Array[CompressedTexture2D] = [
	preload("res://assets/sprites/carrot.png"),
	preload("res://assets/sprites/leek.png"),
	preload("res://assets/sprites/mushroom.png"),
	preload("res://assets/sprites/onion.png"),
	preload("res://assets/sprites/potato.png"),
	preload("res://assets/sprites/pumpkin.png"),
	preload("res://assets/sprites/squash.png")
]

const SPRITES_HIGHLIGHT: Array[CompressedTexture2D] = [
	preload("res://assets/sprites/carrot-highlight.png"),
	preload("res://assets/sprites/leek-highlight.png"),
	preload("res://assets/sprites/mushroom-highlight.png"),
	preload("res://assets/sprites/onion-highlight.png"),
	preload("res://assets/sprites/potato-highlight.png"),
	preload("res://assets/sprites/pumpkin-highlight.png"),
	preload("res://assets/sprites/squash-highlight.png")
]

const SPRITES_SELECT: Array[CompressedTexture2D] = [
	preload("res://assets/sprites/carrot-select.png"),
	preload("res://assets/sprites/leek-select.png"),
	preload("res://assets/sprites/mushroom-select.png"),
	preload("res://assets/sprites/onion-select.png"),
	preload("res://assets/sprites/potato-select.png"),
	preload("res://assets/sprites/pumpkin-select.png"),
	preload("res://assets/sprites/squash-select.png")
]

const SPRITE_DISABLED: CompressedTexture2D = \
	preload("res://assets/sprites/transparent.png")

const NUM_SPRITES: int = len(SPRITES)
const SPRITE_SIZE: int = 32
const GRID_SIZE: int = 8

enum State {
	WAITING,
	READY,
	SELECTED
}

var current_state: State = State.WAITING
var selected: Vegetable = null
var selected_index: int = -1
var selected_type: int = -1
var highlighted: PackedInt32Array = PackedInt32Array()
var offsets: PackedInt32Array = PackedInt32Array([
	-1, 1, -GRID_SIZE, GRID_SIZE
])


func get_new_type() -> int:
	return randi() % NUM_SPRITES


func set_waiting() -> void:
	current_state = State.WAITING
	reset_selected()


func set_ready() -> void:
	current_state = State.READY
	reset_selected()


func set_selected(vegetable: Vegetable) -> void:
	current_state = State.SELECTED
	selected = vegetable


func reset_selected() -> void:
	selected = null
