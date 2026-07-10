extends Node2D

const CARD = preload("uid://dlsbf8fn82egx")

# =============================================================================
# Scene References
# =============================================================================

# Camera & Audio
@onready var camera: Camera2D = $Camera2D
@onready var ui_button: AudioStreamPlayer = $Audios/UI_Button

# Managers
@onready var spinning_wheel: Node2D = $Spinning_Wheel
@onready var war_square: Node2D = $war_square
@onready var war_line: Node2D = $War_Line

# =============================================================================
# Card Containers
# =============================================================================

@onready var player_cards: Node2D = $cards/player_cards
@onready var enemy_cards: Node2D = $cards/enemy_cards

# =============================================================================
# Slot Containers
# =============================================================================

@onready var player_inventory: Node2D = $inventory/player_inventory
@onready var enemy_inventory: Node2D = $inventory/enemy_inventory

@onready var player_square: Node2D = $war_square/player_square
@onready var enemy_square: Node2D = $war_square/enemy_square

# =============================================================================
# UI
# =============================================================================

# Buttons
@onready var spin_button: Button = $UI/Spin_Button
@onready var end_turn_button: Button = $UI/End_Turn_button
@onready var reset_button: Button = $UI/Reset_button

# Labels
@onready var spin_cost: Label = $UI/Spin_Button/spin_cost
@onready var turn: Label = $UI/turn
@onready var coin: Label = $UI/coin

# Trait UI
@onready var trait_container: VBoxContainer = $Panels/Traits_panel/VBoxContainer

@onready var Arcane_count: Label = $Panels/Traits_panel/VBoxContainer/Arcane/count
@onready var Inventor_count: Label = $Panels/Traits_panel/VBoxContainer/Inventor/count
@onready var Guardian_count: Label = $Panels/Traits_panel/VBoxContainer/Guardian/count
@onready var Forest_count: Label = $Panels/Traits_panel/VBoxContainer/Forest/count
@onready var Assasins_count: Label = $Panels/Traits_panel/VBoxContainer/Assasins/count
@onready var Undead_count: Label = $Panels/Traits_panel/VBoxContainer/Undead/count
@onready var Shield_count: Label = $Panels/Traits_panel/VBoxContainer/Shield/count
@onready var Inferno_count: Label = $Panels/Traits_panel/VBoxContainer/Inferno/count

# Lights
@onready var player_light: PointLight2D = $Lightings/player
@onready var enemy_light: PointLight2D = $Lightings/enemy
@onready var spin_light: PointLight2D = $Lightings/spin

# =============================================================================
# Game Balance
# =============================================================================

@export var start_coin := 12
@export var turn_coin_gain := 6
@export var turn_spin_cost := 3
@export var spin_cost_gain := 1

# =============================================================================
# Runtime State
# =============================================================================

# Enemy economy
var enemy_coin: int
var enemy_spin_cost: int

# Battlefield progress
var player_line_count := 1
var enemy_line_count := 1

func _ready() -> void:
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 1)
	await tween.finished
	reset()


func change_coin(amount: int):

	var current = int(coin.text)
	var target = current + amount

	var tween = create_tween()

	tween.tween_method(
		func(value):
			coin.text = str(round(value)),
		current,
		target,
		0.4
	)

	# little feedback
	var original_scale = coin.scale

	tween.parallel().tween_property(
		coin,
		"scale",
		Vector2(2, 2),
		0.15
	)

	tween.tween_property(
		coin,
		"scale",
		original_scale,
		0.15
	)

	await tween.finished

func set_buttons_enabled(enabled: bool):
	spin_button.disabled = !enabled
	end_turn_button.disabled = !enabled
	reset_button.disabled = !enabled


func play_button_press(shake_strength: float, shake_time: float):
	ui_button.play()
	set_buttons_enabled(false)
	camera.screen_shake(shake_strength, shake_time)

func _on_end_turn_button_pressed() -> void:
	play_button_press(50, 0.5)

	spin_cost.text = str(turn_spin_cost)
	
	turn.text = str(int(turn.text) + 1)
	
	await change_coin(turn_coin_gain)

	await check_win()
	check_traits()
	await enemy_move()

	set_buttons_enabled(true)

func _on_spin_button_pressed() -> void:
	play_button_press(8, 0.2)

	if int(coin.text) >= int(spin_cost.text):
		
		if await add_card(0):
			
			await change_coin(-int(spin_cost.text))
			
			spin_cost.text = str(int(spin_cost.text) + spin_cost_gain)

	check_traits()

	set_buttons_enabled(true)
	
func _on_reset_button_pressed() -> void:
	play_button_press(0, 0)

	await reset()

	set_buttons_enabled(true)




func add_card(team):

	spin_light.visible = true


	var inventory
	var cards
	if team == 0:
		inventory = player_inventory
		cards = player_cards
	elif team == 1:
		inventory = enemy_inventory
		cards = enemy_cards


	for child in inventory.get_children():

		if child.item == null:

			var chosen = await spinning_wheel.spin()

			var card = CARD.instantiate()


			# Assign ownership
			if team == 0:
				card.team = card.Team.PLAYER 
			elif team == 1:
				card.team = card.Team.ENEMY


			# Assign stats
			card.type = chosen["name"]
			card.level = chosen["level"]
			card.health = chosen["health"]
			card.damage = chosen["damage"]


			# Assign texture
			if chosen["texture"]:
				card.get_node("Card").texture = chosen["texture"]


			cards.add_child(card)


			spin_light.visible = false

			return true



	print("Inventory is full!")


	spin_light.visible = false

	return false




func enemy_buy_phase():

	while enemy_coin >= enemy_spin_cost:

		if await add_card(1):
			enemy_coin -= enemy_spin_cost
			enemy_spin_cost += spin_cost_gain

		else:
			break

func enemy_end_shop_phase():

	enemy_coin += turn_coin_gain
	enemy_spin_cost = turn_spin_cost

func enemy_merge_cards():

	var merged := true

	while merged:

		merged = false

		for card in enemy_cards.get_children():

			for card2 in enemy_cards.get_children():

				if card == card2:
					continue


				if (
					card.type == card2.type
					and card.level == card2.level
				):

					card.level_up(card2)

					card2.queue_free()

					merged = true

					await get_tree().process_frame

					break


			if merged:
				break

func get_strongest_unplayed_card():

	var strongest = null
	var max_stat := -1


	for card in enemy_cards.get_children():

		if card.is_played:
			continue


		var stat = card.health + card.damage


		if stat > max_stat:

			max_stat = stat
			strongest = card


	return strongest

func enemy_play_cards():

	var enemy_slots = enemy_square.get_children()


	while true:

		var strongest = get_strongest_unplayed_card()


		if strongest == null:
			break


		for i in range(enemy_slots.size() - 1, -1, -1):

			var slot = enemy_slots[i]


			if slot.item == null:

				strongest.is_played = true

				strongest.move_to_slot(slot)

				break

func enemy_move():

	player_light.visible = false
	enemy_light.visible = true


	await enemy_buy_phase()

	enemy_end_shop_phase()

	enemy_merge_cards()

	enemy_play_cards()


	player_light.visible = true
	enemy_light.visible = false




func animate_unit(unit, target_position: Vector2, return_position: Vector2, particles: CPUParticles2D):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(unit, "position", target_position, 0.4)
	particles.emitting = true
	tween.tween_property(unit, "position", return_position, 0.4)
	
	await tween.finished

func check_empty_slots(enemy_slots, player_slots) -> Vector2i:
	var enemy_point := 0
	var player_point := 0
	var longest_animation := 0.0

	for i in range(enemy_slots.size()):
		if enemy_slots[i].item and (i >= player_slots.size() or player_slots[i].item == null):
			enemy_point += 1

			var start = enemy_slots[i].item.position
			var tween = create_tween()
			tween.tween_property(enemy_slots[i].item, "position", start + Vector2(0, 50), 0.5)
			enemy_slots[i].item.enemy_particles.emitting = true
			tween.tween_property(enemy_slots[i].item, "position", start, 1)
			longest_animation = 1.5

	for i in range(player_slots.size()):
		if player_slots[i].item and (i >= enemy_slots.size() or enemy_slots[i].item == null):
			player_point += 1

			var start = player_slots[i].item.position
			var tween = create_tween()
			tween.tween_property(player_slots[i].item, "position", start + Vector2(0, -50), 0.5)
			player_slots[i].item.player_particles.emitting = true
			tween.tween_property(player_slots[i].item, "position", start, 1)
			longest_animation = 1.5
	
	if longest_animation > 0:
		await get_tree().create_timer(longest_animation).timeout
	
	return Vector2i(enemy_point, player_point)

func resolve_combat(enemy_slots, player_slots) -> Vector2i:
	var enemy_point := 0
	var player_point := 0

	for i in range(min(enemy_slots.size(), player_slots.size())):

		if enemy_slots[i].item == null or player_slots[i].item == null:
			continue

		var enemy_position = enemy_slots[i].item.position
		var player_position = player_slots[i].item.position

		while enemy_slots[i].item and player_slots[i].item:

			player_slots[i].item.health -= enemy_slots[i].item.damage
			enemy_slots[i].item.health -= player_slots[i].item.damage

			player_slots[i].item.update_ui()
			enemy_slots[i].item.update_ui()

			if enemy_slots[i].item.health <= 0:
				player_point += 1
				enemy_slots[i].item.queue_free()
				enemy_slots[i].item = null

			if player_slots[i].item and player_slots[i].item.health <= 0:
				enemy_point += 1
				player_slots[i].item.queue_free()
				player_slots[i].item = null

		if player_slots[i].item:
			await animate_unit(
				player_slots[i].item,
				enemy_position,
				player_position,
				player_slots[i].item.player_particles
			)

		if enemy_slots[i].item:
			await animate_unit(
				enemy_slots[i].item,
				player_position,
				enemy_position,
				enemy_slots[i].item.enemy_particles
			)

	return Vector2i(enemy_point, player_point)

func update_battlefield(enemy_point: int, player_point: int):
	var enemy_square_slots = enemy_square.get_children()
	var player_square_slots = player_square.get_children()

	if player_point > enemy_point:

		if player_square.get_child_count() == 10:

			if enemy_square.get_child_count() > 0:

				for i in range(1, enemy_line_count + 1):

					enemy_square_slots = enemy_square.get_children()

					if enemy_square_slots[-i]:

						if enemy_square_slots[-i].item:
							enemy_square_slots[-i].item.queue_free()

						var tween = create_tween()
						tween.tween_property(
							war_line,
							"position",
							Vector2(0, enemy_square_slots[-i].position.y + 20),
							0.3
						)

						enemy_square_slots[-i].queue_free()

				enemy_line_count += 1

		elif player_square_slots.size() < 10 and player_square_slots.size() >= 2:

			var first_slot_position = Vector2(
				war_square.player_first_slot_position.x +
				(war_square.slot_x_distance / 2) *
				(war_square.line_countt + 1 - player_line_count),
				player_square_slots[-1].position.y
			) - Vector2(0, war_square.slot_y_distance)

			war_square.line_spawn(
				war_square.player_square,
				war_square.PLAYER_STAND,
				first_slot_position,
				player_line_count - 1
			)

			player_square_slots = player_square.get_children()

			var tween = create_tween()
			tween.tween_property(
				war_line,
				"position",
				Vector2(0, player_square_slots[-1].position.y - war_square.slot_y_distance),
				0.3
			)

			for card in player_cards.get_children():
				for i in range(1, player_line_count):
					card.detect_area(player_square_slots[-i])

			player_line_count -= 1

	elif player_point < enemy_point:

		if enemy_square.get_child_count() == 10:

			if player_square.get_child_count() > 0:

				for i in range(1, player_line_count + 1):

					player_square_slots = player_square.get_children()

					if player_square_slots[-i]:

						if player_square_slots[-i].item:
							player_square_slots[-i].item.queue_free()

						var tween = create_tween()
						tween.tween_property(
							war_line,
							"position",
							Vector2(0, player_square_slots[-i].position.y),
							0.3
						)

						player_square_slots[-i].queue_free()

				player_line_count += 1

		elif enemy_square.get_child_count() < 10 and enemy_square_slots.size() >= 2:

			var first_slot_position = Vector2(
				war_square.enemy_first_slot_position.x +
				(war_square.slot_x_distance / 2) *
				(war_square.line_countt + 1 - enemy_line_count),
				enemy_square_slots[-1].position.y
			) + Vector2(0, war_square.slot_y_distance)

			war_square.line_spawn(
				war_square.enemy_square,
				war_square.ENEMY_STAND,
				first_slot_position,
				enemy_line_count - 1
			)

			enemy_square_slots = enemy_square.get_children()

			var tween = create_tween()
			tween.tween_property(
				war_line,
				"position",
				Vector2(
					0,
					enemy_square_slots[-1].position.y +
					war_square.slot_y_distance +
					20
				),
				0.3
			)

			for card in player_cards.get_children():
				for i in range(1, enemy_line_count):
					card.detect_area(enemy_square_slots[-i])

			enemy_line_count -= 1

func check_win():
	var enemy_slots = enemy_square.get_children()
	var player_slots = player_square.get_children()

	var points = await check_empty_slots(enemy_slots, player_slots)
	points += await resolve_combat(enemy_slots, player_slots)

	update_battlefield(points.x, points.y)




func check_traits():
	var trait_counts = [
		Arcane_count,
		Inventor_count,
		Guardian_count,
		Forest_count,
		Assasins_count,
		Undead_count,
		Shield_count,
		Inferno_count
	]

	for i in range(spinning_wheel.Traits.size()):
		var count := 0

		for unit in spinning_wheel.Traits[i]["units"]:
			for card in player_cards.get_children():
				if card.type == unit["name"]:
					count += 1
					break

		trait_counts[i].text = str(count)
		trait_container.get_child(i).visible = count > 0




func clear_container(container: Node):
	for child in container.get_children():
		child.queue_free()

func reset():
	set_buttons_enabled(false)
	
	# Reset battlefield position
	war_line.position.y = -50

	# Remove all cards
	clear_container(player_cards)
	clear_container(enemy_cards)

	# Remove old slots
	clear_container(player_square)
	clear_container(enemy_square)

	# Spawn fresh battlefield
	war_square.spawn(
		war_square.player_square,
		war_square.PLAYER_STAND,
		war_square.player_first_slot_position,
		-1,
		war_square.line_countt
	)

	war_square.spawn(
		war_square.enemy_square,
		war_square.ENEMY_STAND,
		war_square.enemy_first_slot_position,
		1,
		war_square.line_countt
	)
	
	# Reset traits UI
	for traitt in trait_container.get_children():
		traitt.get_child(1).text = "0"
		traitt.visible = true

	# Reset variables
	player_line_count = 1
	enemy_line_count = 1

	spin_cost.text = str(turn_spin_cost)
	turn.text = "0"
	coin.text = str(start_coin)

	enemy_coin = start_coin
	enemy_spin_cost = turn_spin_cost

	# Enemy starts with fresh cards
	await enemy_move()

	check_traits()
	
	set_buttons_enabled(true)

func _on_quit_button_pressed() -> void:
	ui_button.play()

	set_buttons_enabled(false)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2.ZERO, 1.0)

	await tween.finished

	get_tree().change_scene_to_file("res://scenes/game_menu.tscn")
