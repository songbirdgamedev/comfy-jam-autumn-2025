extends Node2D

@onready var play_button: NinePatchRect = $Node2D/PlayButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const GAME = preload("res://scenes/game.tscn")


func _ready() -> void:
	AudioManager.play_soup()


func _on_play_button_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(GAME)
