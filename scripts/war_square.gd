extends Node2D

const PLAYER_STAND = preload("uid://c6f5u2xnhgnxh")
const ENEMY_STAND = preload("uid://ctuyshu8kwaeb")


@onready var enemy_square: Node2D = $enemy_square
@onready var player_square: Node2D = $player_square

@export var line_countt = 4
@export var player_first_slot_position = Vector2(-500, 273.0)
@export var enemy_first_slot_position = Vector2(-500, -393.0)
@export var slot_x_distance = 334.0
@export var slot_y_distance = 80.0

var slot_position
var slot
func _ready() -> void:
	spawn(player_square, PLAYER_STAND, player_first_slot_position, -1, line_countt)
	spawn(enemy_square, ENEMY_STAND, enemy_first_slot_position, 1, line_countt)

func spawn(square, stand, first_slot_position, direction, line_count):
	for line in range(line_count):
		slot_position = first_slot_position + Vector2(line * slot_x_distance/2, direction * line * slot_y_distance)
		for i in range(line_count - line):
			slot = stand.instantiate()
			slot.position = slot_position + Vector2(i * slot_x_distance,0)
			square.add_child(slot)
			
func line_spawn(square, stand, first_slot_position, line_count):
	slot_position = first_slot_position
	for i in range(line_count):
		slot = stand.instantiate()
		slot.position = slot_position + Vector2(i * slot_x_distance,0)
		square.add_child(slot)
