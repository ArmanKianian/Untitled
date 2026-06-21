extends Sprite2D

@onready var cards_inventory: Node2D = $"../../inventory"
@onready var Level: Label = $VBoxContainer/Level
@onready var Type: Label = $VBoxContainer/Type
var level
var type

var areas: Array[Area2D]
var is_dragged = false
var mouse_offset

var future_position = global_position
var start_area: Area2D
var current_area: Area2D

var is_on_slot = false

func _ready() -> void:
	Level.text = str(level)
	Type.text = str(type)
	for child in cards_inventory.get_children():
		areas.append(child)
	add_card_to_inventory()
	for area in areas:
		area.mouse_entered.connect(_on_mouse_entered.bind(area))
		area.mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	if is_dragged == true:
		future_position = get_global_mouse_position() - mouse_offset
	global_position.x = move_toward(global_position.x, future_position.x, 30)
	global_position.y = move_toward(global_position.y, future_position.y, 30)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and get_rect().has_point(get_local_mouse_position()):
		mouse_offset = get_local_mouse_position()
		is_dragged = true
	elif event.is_action_released("LMB") and is_dragged == true:
		is_dragged = false
		if is_on_slot == false:
			future_position = start_area.position
		else:
			if current_area.item == null:
				start_area.item = null
				current_area.item = self
				start_area = current_area
				future_position = current_area.position
			else:
				if current_area.item == self:
					future_position = start_area.position
				elif int(current_area.item.Level.text) == int(Level.text) and current_area.item.type == type :
					current_area.item.queue_free()
					start_area.item = null
					current_area.item = self
					start_area = current_area
					future_position = current_area.position
					Level.text = str(int(Level.text) + 1)
				else:
					future_position = start_area.position
				
func _on_mouse_entered(area):
	if is_dragged == true:
		current_area = area
		is_on_slot = true

func _on_mouse_exited():
	current_area = start_area
	is_on_slot = false

func add_card_to_inventory():
	var children = cards_inventory.get_children()
	for i in range(children.size()):
			if children[i].item == null:
				children[i].item = self
				current_area = areas[i]
				start_area = current_area
				future_position = current_area.position
				position = current_area.position
				break
