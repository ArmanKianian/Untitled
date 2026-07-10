extends Node2D


# =============================================================================
# Constants
# =============================================================================

const MOVE_SPEED := 30.0


enum Team {
	PLAYER,
	ENEMY
}



# =============================================================================
# References
# =============================================================================

@onready var camera: Camera2D = $"../../../Camera2D"

@onready var card: Sprite2D = $Card


# Particles
@onready var card_particles: CPUParticles2D = $Card_Particles
@onready var enemy_particles: CPUParticles2D = $Card_Particles2
@onready var player_particles: CPUParticles2D = $Card_Particles3


# Audio
@onready var card_place: AudioStreamPlayer = $"../../../Audios/card_place"
@onready var card_pick: AudioStreamPlayer = $"../../../Audios/card_pick"
@onready var card_drag: AudioStreamPlayer = $"../../../Audios/card_drag"


# UI
@onready var level_label: Label = $Card/VBoxContainer/HBoxContainer/Level
@onready var health_label: Label = $Card/VBoxContainer/HBoxContainer/Health
@onready var damage_label: Label = $Card/VBoxContainer/HBoxContainer/Damage
@onready var type_label: Label = $Card/VBoxContainer/Type



# =============================================================================
# Ownership
# =============================================================================

var team: Team = Team.PLAYER



func get_inventory() -> Node2D:

	if team == Team.PLAYER:
		return $"../../../inventory/player_inventory"

	return $"../../../inventory/enemy_inventory"



func get_square() -> Node2D:

	if team == Team.PLAYER:
		return $"../../../war_square/player_square"

	return $"../../../war_square/enemy_square"



func is_player() -> bool:

	return team == Team.PLAYER



# =============================================================================
# Card Stats
# =============================================================================

var health: int = 0
var damage: int = 0
var level: int = 1
var type: String = ""



# =============================================================================
# Drag
# =============================================================================

var is_dragged := false

var mouse_offset := Vector2.ZERO

var future_position := Vector2.ZERO



# =============================================================================
# Slots
# =============================================================================

var start_area: Area2D
var current_area: Area2D

var is_on_slot := false

var is_played := false



# =============================================================================
# Shake
# =============================================================================

var shake_intensity := 0.0
var active_shake_time := 0.0
var shake_time := 0.0


const SHAKE_DECAY := 5.0
const SHAKE_SPEED := 20.0


var noise := FastNoiseLite.new()



# =============================================================================
# Ready
# =============================================================================

func _ready():

	update_ui()

	card_pick.play()

	if is_player():

		card_pick.play()


		for area in get_inventory().get_children():
			detect_area(area)


		for area in get_square().get_children():
			detect_area(area)



	add_card_to_inventory()



func _process(delta):

	hover()

	move()

	update_shake(delta)



# =============================================================================
# Input
# =============================================================================

func _input(event):

	# Enemy cards cannot be dragged
	if not is_player():
		return


	if event.is_action_pressed("LMB") \
	and card.get_rect().has_point(get_local_mouse_position()):

		mouse_offset = get_local_mouse_position()

		card_drag.play()

		is_dragged = true

		top_level = true



	elif event.is_action_released("LMB") and is_dragged:

		end_drag()



# =============================================================================
# Drag Logic
# =============================================================================

func end_drag():

	card_particles.emitting = true

	shake(10,0.3)


	is_dragged = false

	top_level = false


	card_place.play()



	if not is_on_slot:

		camera.screen_shake(8,0.5)

		future_position = start_area.position

		return



	if current_area.item == null:

		camera.screen_shake(8,0.05)

		place_card()

		return



	if current_area.item == self:

		future_position = start_area.position

		return



	if current_area.item.level == level \
	and current_area.item.type == type:


		camera.screen_shake(8,0.1)

		level_up(current_area.item)

		current_area.item.queue_free()

		place_card()

		return



	swap_card()



# =============================================================================
# Slot System
# =============================================================================

func detect_area(area: Area2D):

	area.mouse_entered.connect(_on_mouse_entered.bind(area))

	area.mouse_exited.connect(_on_mouse_exited)



func _on_mouse_entered(area):

	current_area = area

	is_on_slot = true



func _on_mouse_exited():

	current_area = start_area

	is_on_slot = false



func add_card_to_inventory():

	for slot in get_inventory().get_children():

		if slot.item == null:

			current_area = slot

			start_area = slot

			place_card()

			return



	push_warning("No empty inventory slot")



func place_card():

	if start_area:

		start_area.item = null



	if current_area == null:
		return


	current_area.item = self

	start_area = current_area


	future_position = current_area.position



func swap_card():

	var other_card = current_area.item


	other_card.start_area = start_area

	other_card.future_position = start_area.position


	future_position = other_card.position



	start_area.item = other_card

	current_area.item = self



	var temp = start_area

	start_area = current_area

	current_area = temp

func move_to_slot(slot: Area2D):

	if start_area:
		start_area.item = null

	current_area = slot
	start_area = slot

	slot.item = self

	future_position = slot.position

	card_place.play()

# =============================================================================
# Card Logic
# =============================================================================

func level_up(other_card):

	level += 1

	health += other_card.health

	damage += other_card.damage


	update_ui()



func update_ui():

	health_label.text = str(health)

	damage_label.text = str(damage)

	level_label.text = str(level)

	type_label.text = type



# =============================================================================
# Movement
# =============================================================================

func move():

	if is_dragged:

		future_position = get_global_mouse_position() - mouse_offset



	global_position = global_position.move_toward(
		future_position,
		MOVE_SPEED
	)



func hover():

	if is_player() \
	and card.get_rect().has_point(get_local_mouse_position()) \
	and not is_dragged:


		rotation_degrees = -5


	else:

		rotation_degrees = 0



# =============================================================================
# Shake
# =============================================================================

func shake(intensity: float, time: float):

	noise.seed = randi()

	noise.frequency = 2.0


	shake_intensity = intensity

	active_shake_time = time

	shake_time = 0



func update_shake(delta):

	if active_shake_time > 0:


		shake_time += delta * SHAKE_SPEED

		active_shake_time -= delta



		card.offset = Vector2(
			noise.get_noise_2d(shake_time,0) * shake_intensity,
			noise.get_noise_2d(0,shake_time) * shake_intensity
		)



		shake_intensity = max(
			shake_intensity - SHAKE_DECAY * delta,
			0
		)



	else:


		card.offset = card.offset.lerp(
			Vector2.ZERO,
			10.5 * delta
		)
