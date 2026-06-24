extends Node2D

const SLOT = preload("uid://cu816sfuctxvy")

@onready var enemy_square: Node2D = $enemy_square
@onready var player_square: Node2D = $player_square

@export var line_count = 5
@export var first_slot_position = Vector2(-600, 295.0)
@export var slot_x_distance = 250
@export var slot_y_distance = 110


var slot_position
func _ready() -> void:
	# player square slots
	var line = line_count
	while line > 0:
		slot_position = first_slot_position + Vector2(0, (line - line_count) * slot_y_distance)
		for i in range(line_count - line,line):
			player_square.add_child(add_slot(i))
		line -= 1
	
	# enemy square slots
	line = 0
	first_slot_position = Vector2(-600, -393.0)
	while line < line_count:
		slot_position = first_slot_position + Vector2(0, line * slot_y_distance)
		for i in range(line, line_count - line):
			enemy_square.add_child(add_slot(i))
		line += 1
	
func add_slot(slot_count):
	var slot = SLOT.instantiate()
	slot.position = slot_position + Vector2((slot_count * slot_x_distance), 0)
	return slot
