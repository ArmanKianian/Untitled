extends Sprite2D

@onready var camera: Camera2D = $"../../Camera2D"

@onready var player_square: Node2D = $"../../war_square/player_square"
@onready var inventory: Node2D = $"../../inventory"
@onready var Level: Label = $VBoxContainer/Level
@onready var Type: Label = $VBoxContainer/Type

var level
var type

var is_dragged = false
var mouse_offset

var future_position = global_position
var start_area: Area2D
var current_area: Area2D

var is_on_slot = false

func _ready() -> void:
	Level.text = str(level)
	Type.text = str(type)
	# Connect every slot area signals for knowing when card is inside slot
	for area in inventory.get_children():
		area.mouse_entered.connect(_on_mouse_entered.bind(area))
		area.mouse_exited.connect(_on_mouse_exited)
	
	# Connect every player_square slots
	for area in player_square.get_children():
		area.mouse_entered.connect(_on_mouse_entered.bind(area))
		area.mouse_exited.connect(_on_mouse_exited)
	
	# add card to inventory, when it's init in the scene
	add_card_to_inventory()
	
func _process(_delta: float) -> void:
	# move toward the place card must be
	if is_dragged == true:
		future_position = get_global_mouse_position() - mouse_offset
	global_position.x = move_toward(global_position.x, future_position.x, 30)
	global_position.y = move_toward(global_position.y, future_position.y, 30)

func _input(event: InputEvent) -> void:
	# when card is dragged
	if event.is_action_pressed("LMB") and get_rect().has_point(get_local_mouse_position()):
		mouse_offset = get_local_mouse_position()
		is_dragged = true
		top_level = true
	# when card is released
	elif event.is_action_released("LMB") and is_dragged == true:
		
		is_dragged = false
		top_level = false
		# card is not on a slot
		if is_on_slot == false:
			camera.screen_shake(8, 0.5)
			future_position = start_area.position
		# card is on a slot
		else:
			# slot is free
			camera.screen_shake(8, 0.05)
			if current_area.item == null:
				place_card()
			# there is a card in slot
			else:
				# it's the same slot as dragged card slot
				if current_area.item == self:
					future_position = start_area.position
				# level and type of slot card and dragged card are same
				elif int(current_area.item.Level.text) == int(Level.text) and current_area.item.type == type :
					camera.screen_shake(8, 0.1)
					current_area.item.queue_free()
					place_card()
					Level.text = str(int(Level.text) + 1)
				# level and types are different
				else:
					future_position = start_area.position
				
func _on_mouse_entered(area):
	if is_dragged == true:
		current_area = area
		is_on_slot = true

func _on_mouse_exited():
	current_area = start_area
	is_on_slot = false

# add card to first empty slot
func add_card_to_inventory():
	var children = inventory.get_children()
	for i in range(children.size()):
			if children[i].item == null:
				current_area = children[i]
				start_area = current_area
				place_card()
				break

# place card where it's released
func place_card():
	start_area.item = null
	current_area.item = self
	start_area = current_area
	future_position = current_area.position
