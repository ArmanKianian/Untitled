extends Node2D


const SLOT = preload("uid://cu816sfuctxvy")


# =============================================================================
# Settings
# =============================================================================

@export var slots_count: int = 10
@export var first_slot_position: Vector2 = Vector2(-550, 440)
@export var slot_spacing: float = 120.0


# =============================================================================
# Ready
# =============================================================================

func _ready() -> void:
	spawn_slots()


# =============================================================================
# Slot Creation
# =============================================================================

func spawn_slots():

	for i in range(slots_count):
		add_inventory_slot(i)


func add_inventory_slot(index: int):

	var slot = SLOT.instantiate()

	slot.position = first_slot_position + Vector2(
		index * slot_spacing,
		0
	)

	add_child(slot)
