extends Node2D

# Camera for screen shake
@onready var camera: Camera2D = $"../../../Camera2D"

# Card sprite
@onready var card: Sprite2D = $Card

# Particles
@onready var card_particles: CPUParticles2D = $Card_Particles
@onready var enemy_particles: CPUParticles2D = $Card_Particles2
@onready var player_particles: CPUParticles2D = $Card_Particles3

# Sounds
@onready var card_place: AudioStreamPlayer = $"../../../Audios/card_place"
@onready var card_pick: AudioStreamPlayer = $"../../../Audios/card_pick"
@onready var card_drag: AudioStreamPlayer = $"../../../Audios/card_drag"

# War Square slots
@onready var square: Node2D
@onready var player_square: Node2D = $"../../../war_square/player_square"
@onready var enemy_square: Node2D = $"../../../war_square/enemy_square"

# Inventory slots
@onready var inventory: Node2D
@onready var player_inventory: Node2D = $"../../../inventory/player_inventory"
@onready var enemy_inventory: Node2D = $"../../../inventory/enemy_inventory"

# UI
@onready var Level: Label = $Card/VBoxContainer/HBoxContainer/Level
@onready var Health: Label = $Card/VBoxContainer/HBoxContainer/Health
@onready var Damage: Label = $Card/VBoxContainer/HBoxContainer/Damage
@onready var Type: Label = $Card/VBoxContainer/Type

# Stats
var health: int
var damage: int
var level: int
var type: String

# drag
var is_dragged = false
var mouse_offset
var future_position = global_position

# slot state
var start_area: Area2D
var current_area: Area2D
var is_on_slot = false

var is_played = false

# --- shake ---
var shake_intensity: float = 0.0
var active_shake_time: float = 0.0

var shake_decay: float = 5.0

var shake_time: float = 0.0
var shake_time_speed: float = 20.0

var noise = FastNoiseLite.new()

func _ready() -> void:
	update_ui()
	card_pick.play()
	# Connect every slot area signals for knowing when card is inside slot
	for area in inventory.get_children():
		detect_area(area)
	
	# Connect every player_square slots
	for area in square.get_children():
		detect_area(area)
	
	# add card to inventory, when it's init in the scene
	add_card_to_inventory()
	
func _process(delta: float) -> void:
	# little rotation when mouse is on card
	hover()
	
	# move toward the place card must be
	move()
	
	# --- shake ---
	update_shake(delta)

func _input(event: InputEvent) -> void:
	if inventory !=  player_inventory:
		return
	# when card is dragged
	if event.is_action_pressed("LMB") and card.get_rect().has_point(get_local_mouse_position()):
		mouse_offset = get_local_mouse_position()
		card_drag.play()
		is_dragged = true
		top_level = true
	# when card is released
	elif event.is_action_released("LMB") and is_dragged == true:
		card_particles.emitting = true
		shake(10, 0.3)
		is_dragged = false
		top_level = false
		card_place.play()
		
		# card is not on a slot
		if is_on_slot == false:
			camera.screen_shake(8, 0.5)
			future_position = start_area.position
			return
		# card is on a slot, so do these:
		
		# slot is free
		camera.screen_shake(8, 0.05)
		if current_area.item == null:
			place_card()
			return
		# there is a card in slot, so do these:
		
		# it's the same slot as dragged card slot
		if current_area.item == self:
			future_position = start_area.position
			return
		
		# level and type of slot card and dragged card are same
		if current_area.item.level == level and current_area.item.type == type :
			camera.screen_shake(8, 0.1)
			level_up(current_area.item)
			current_area.item.queue_free()
			place_card()
			return
			
		# level and types are different
		swap_card()

# when mouse entered on a slot
func _on_mouse_entered(area):
	current_area = area
	is_on_slot = true

# when mouse exited on a slot
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
	
func shake(intensity: int, time: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.0
	
func level_up(merged_card):
	level += 1
	health += merged_card.health
	damage += merged_card.damage
	update_ui()

func detect_area(area):
	area.mouse_entered.connect(_on_mouse_entered.bind(area))
	area.mouse_exited.connect(_on_mouse_exited)

func swap_card():
	current_area.item.start_area = start_area
	current_area.item.future_position = start_area.position
	
	future_position = current_area.item.position
	
	start_area.item = current_area.item
	current_area.item = self
	
	var temp = start_area
	start_area = current_area
	current_area = temp

func update_ui():
	Health.text = str(health)
	Damage.text = str(damage)
	Level.text = str(level)
	Type.text = str(type)

func update_shake(delta):
	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		
		card.offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity,
		)
		
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		card.offset = lerp(card.offset, Vector2.ZERO, 10.5 * delta)

func move():
	if is_dragged == true:
		future_position = get_global_mouse_position() - mouse_offset
	global_position = global_position.move_toward(future_position, 30)
	
func hover():
	if card.get_rect().has_point(get_local_mouse_position()) and is_dragged == false and inventory ==  player_inventory:
		rotation_degrees = -5
	else:
		rotation_degrees = 0
