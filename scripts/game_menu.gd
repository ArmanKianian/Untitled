extends Node2D

@onready var ui_button: AudioStreamPlayer = $UI_Button
@onready var ui: Node2D = $UI

func _ready() -> void:
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 1)
	await tween.finished

func _on_start_pressed() -> void:
	ui_button.play()
	var tween = create_tween()
	tween.tween_property(ui, "scale", Vector2(0, 0), 1)
	tween.parallel().tween_property(ui, "position", Vector2(0, 850), 1)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed() -> void:
	ui_button.play()
	var tween = create_tween()
	tween.tween_property(ui, "scale", Vector2(0, 0), 1)
	tween.parallel().tween_property(ui, "position", Vector2(0, 850), 1)
	await tween.finished
	get_tree().quit()
