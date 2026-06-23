extends Node2D

const SLOT = preload("uid://cu816sfuctxvy")

@export var slots_count = 10
@export var slot_position = Vector2(-530, 342.0)
@export var slot_distance = 72

func _ready() -> void:
	for i in range(slots_count):
		add_inventory_slot()
		
func add_inventory_slot():
	var slot_count = get_child_count()
	var slot = SLOT.instantiate()
	slot.position = slot_position + Vector2((slot_count * slot_distance), 0)
	add_child(slot)
