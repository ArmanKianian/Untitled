extends Node2D

@onready var music: AudioStreamPlayer = $Music
@onready var rain: AudioStreamPlayer = $Rain

func _on_music_finished() -> void:
	music.play()


func _on_rain_finished() -> void:
	rain.play()
