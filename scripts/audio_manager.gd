extends Node

@onready var soup: AudioStreamPlayer = $Soup


func play_soup():
	var soup_tween = get_tree().create_tween()
	soup_tween.tween_property(soup, "volume_db", linear_to_db(1), 1)
	soup.play()
