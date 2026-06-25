extends Node2D

const PLAYER_STAND = preload("uid://c6f5u2xnhgnxh")
const ENEMY_STAND = preload("uid://ctuyshu8kwaeb")


@onready var enemy_square: Node2D = $enemy_square
@onready var player_square: Node2D = $player_square

@export var line_count = 5
@export var first_slot_position = Vector2(-600, 275.0)
@export var slot_x_distance = 250
@export var slot_y_distance = 130


var slot_position
var slot
func _ready() -> void:
	# player square slots
	var line = line_count
	while line > 0:
		slot_position = first_slot_position + Vector2(0, (line - line_count) * slot_y_distance)
		for i in range(line_count - line,line):
			slot = PLAYER_STAND.instantiate()
			slot.position = slot_position + Vector2((i * slot_x_distance), 0)
			player_square.add_child(slot)
		line -= 1
	
	# enemy square slots
	line = 0
	first_slot_position = Vector2(-600, -395.0)
	while line < line_count:
		slot_position = first_slot_position + Vector2(0, line * slot_y_distance)
		for i in range(line, line_count - line):
			slot = ENEMY_STAND.instantiate()
			slot.position = slot_position + Vector2((i * slot_x_distance), 0)
			enemy_square.add_child(slot)
		line += 1
