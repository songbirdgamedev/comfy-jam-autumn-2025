extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const START_SCREEN = preload("uid://chn6qjqgx1aqc")


func _ready():
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(START_SCREEN)
