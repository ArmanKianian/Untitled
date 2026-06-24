extends Node2D

@onready var card: Sprite2D = $Card

@onready var card_particles: CPUParticles2D = $Card_Particles

@onready var card_place: AudioStreamPlayer = $"../../../Audios/card_place"
@onready var card_pick: AudioStreamPlayer = $"../../../Audios/card_pick"
@onready var card_drag: AudioStreamPlayer = $"../../../Audios/card_drag"

@onready var camera: Camera2D = $"../../../Camera2D"

@onready var player_square: Node2D = $"../../../war_square/player_square"
@onready var square: Node2D
@onready var enemy_square: Node2D = $"../../../war_square/enemy_square"
@onready var player_inventory: Node2D = $"../../../inventory/player_inventory"
@onready var inventory: Node2D
@onready var enemy_inventory: Node2D = $"../../../inventory/enemy_inventory"
@onready var Level: Label = $Card/VBoxContainer/HBoxContainer/Level
@onready var Health: Label = $Card/VBoxContainer/HBoxContainer/Health
@onready var Damage: Label = $Card/VBoxContainer/HBoxContainer/Damage
@onready var Type: Label = $Card/VBoxContainer/Type
var health
var damage
var level
var type

var is_dragged = false
var mouse_offset

var future_position = global_position
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
	card_pick.play()
	# Connect every slot area signals for knowing when card is inside slot
	for area in inventory.get_children():
		area.mouse_entered.connect(_on_mouse_entered.bind(area))
		area.mouse_exited.connect(_on_mouse_exited)
	
	# Connect every player_square slots
	for area in square.get_children():
		area.mouse_entered.connect(_on_mouse_entered.bind(area))
		area.mouse_exited.connect(_on_mouse_exited)
	
	# add card to inventory, when it's init in the scene
	add_card_to_inventory()
	
func _process(delta: float) -> void:
	Health.text = str(health)
	Damage.text = str(damage)
	Level.text = str(level)
	Type.text = str(type)
	if card.get_rect().has_point(get_local_mouse_position()) and is_dragged == false and inventory ==  player_inventory:
		rotation_degrees = -5
	else:
		rotation_degrees = 0
	# move toward the place card must be
	if is_dragged == true:
		future_position = get_global_mouse_position() - mouse_offset
	global_position.x = move_toward(global_position.x, future_position.x, 30)
	global_position.y = move_toward(global_position.y, future_position.y, 30)
	
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
					level_up()
				# level and types are different
				else:
					future_position = start_area.position
				
func _on_mouse_entered(area):
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
	
func shake(intensity: int, time: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.0
	
func level_up():
	level += 1
	health += 1
	damage += 1
