extends Node2D

const CARD = preload("uid://dlsbf8fn82egx")

# Camera for screen shake
@onready var camera: Camera2D = $Camera2D

# Sounds
@onready var ui_button: AudioStreamPlayer = $Audios/UI_Button
@onready var music: AudioStreamPlayer = $Audios/Music
@onready var rain: AudioStreamPlayer = $Audios/Rain


# Slots for removing or adding them for game logic
@onready var player_inventory: Node2D = $inventory/player_inventory
@onready var enemy_inventory: Node2D = $inventory/enemy_inventory
@onready var player_square: Node2D = $war_square/player_square
@onready var enemy_square: Node2D = $war_square/enemy_square

# Cards for removing or adding
@onready var player_cards: Node2D = $cards/player_cards
@onready var enemy_cards: Node2D = $cards/enemy_cards

# Buttons
@onready var spin_button: Button = $UI/Spin_Button
@onready var end_turn_button: Button = $UI/End_Turn_button
@onready var reset_button: Button = $UI/Reset_button

# Spinning wheel for a random unit pick war_square
@onready var spinning_wheel: Node2D = $Spinning_Wheel

# Access to war_square code variables
@onready var war_square: Node2D = $war_square
# War line for moving it up or down
@onready var war_line: Node2D = $War_Line

# UI changable shown labels(numbers)
@onready var spin_cost: Label = $UI/Spin_Button/spin_cost
@onready var turn: Label = $UI/turn
@onready var coin: Label = $UI/coin

# Changable variables for balanacing game in engine
@export var start_coin = 12
@export var turn_coin_gain = 6
@export var turn_spin_cost = 3
@export var spin_cost_gain = 1

# Enemy variables, will be set same as player variables
var enemy_coin
var enemy_spin_cost

# How many line is lost by each player(player or enemy)
var enemy_line_count = 1
var player_line_count = 1

# UI trait counts
@onready var trait_container: VBoxContainer = $Panels/Traits_panel/VBoxContainer
@onready var Arcane_count: Label = $Panels/Traits_panel/VBoxContainer/Arcane/count
@onready var Inventor_count: Label = $Panels/Traits_panel/VBoxContainer/Inventor/count
@onready var Guardian_count: Label = $Panels/Traits_panel/VBoxContainer/Guardian/count
@onready var Forest_count: Label = $Panels/Traits_panel/VBoxContainer/Forest/count
@onready var Assasins_count: Label = $Panels/Traits_panel/VBoxContainer/Assasins/count
@onready var Undead_count: Label = $Panels/Traits_panel/VBoxContainer/Undead/count
@onready var Shield_count: Label = $Panels/Traits_panel/VBoxContainer/Shield/count
@onready var Inferno_count: Label = $Panels/Traits_panel/VBoxContainer/Inferno/count

# whos turn glow
@onready var enemy_light: PointLight2D = $Lightings/enemy
@onready var player_light: PointLight2D = $Lightings/player
@onready var spin_light: PointLight2D = $Lightings/spin

func _ready() -> void:
	reset()

func _on_end_turn_button_pressed() -> void:
	# End Turn Button Pressed
	ui_button.play()
	spin_button.disabled = true
	end_turn_button.disabled = true
	reset_button.disabled = true
	camera.screen_shake(50, 0.5)
	spin_cost.text = str(turn_spin_cost)
	turn.text = str(int(turn.text) + 1)
	coin.text = str(int(coin.text) + turn_coin_gain)
	
	await check_win()
	check_traits()
	await enemy_move()
	spin_button.disabled = false
	end_turn_button.disabled = false
	reset_button.disabled = false

func _on_spin_button_pressed() -> void:
	# Spin Button Pressed
	ui_button.play()
	spin_button.disabled = true
	end_turn_button.disabled = true
	reset_button.disabled = true
	camera.screen_shake(8, 0.2)
	if int(coin.text) >= int(spin_cost.text):
		if await add_card(player_cards, player_inventory, player_square):
			coin.text = str(int(coin.text) - int(spin_cost.text))
			spin_cost.text = str(int(spin_cost.text) + spin_cost_gain)
	check_traits()
	spin_button.disabled = false
	end_turn_button.disabled = false
	reset_button.disabled = false
	
func _on_reset_button_pressed() -> void:
	# Reset Button Pressed
	ui_button.play()
	spin_button.disabled = true
	end_turn_button.disabled = true
	reset_button.disabled = true
	# Reset Button Pressed
	await reset()
	spin_button.disabled = false
	end_turn_button.disabled = false
	reset_button.disabled = false

func add_card(cards, inventory, square):
	spin_light.set_visible(true)
	# Add a card random by spinning wheel
	for child in inventory.get_children():
		if child.item == null:
			var chosen = await spinning_wheel.spin()
			var card = CARD.instantiate()
			card.inventory = inventory
			card.square = square
			card.type = chosen["name"]
			card.level = chosen["level"]
			card.health = chosen["health"]
			card.damage = chosen["damage"]
			if chosen["texture"]:
				card.get_child(1).texture = chosen["texture"]
			cards.add_child(card)
			spin_light.set_visible(false)
			return true
	print("inventory is full!")
	spin_light.set_visible(false)

func enemy_move():
	player_light.set_visible(false)
	enemy_light.set_visible(true)
	# Enemy spend all coins on buying cards
	while enemy_coin >= enemy_spin_cost:
		if await add_card(enemy_cards, enemy_inventory, enemy_square):
			enemy_coin -= enemy_spin_cost
			enemy_spin_cost += spin_cost_gain
		else:
			break
	# Enemy Gains each turn coin, and enemy spin cost resets
	enemy_coin += turn_coin_gain
	enemy_spin_cost = turn_spin_cost
	
	var max_stat
	var choice
	var enemy_slots = enemy_square.get_children()
	
	# if there is same card, enemy will merge them and levelup
	for card in enemy_cards.get_children():
			for card2 in enemy_cards.get_children():
				if card != card2 and card.type == card2.type and card.level == card2.level:
					card.level_up(card2)
					card2.queue_free()
	
	# Enemy will play strongest card on the last empty slot
	for y in range(enemy_cards.get_child_count()):
		max_stat = -1
		choice = null
		for card in enemy_cards.get_children():
			if card.is_played == false:
				if max_stat < card.health + card.damage:
					max_stat = card.health + card.damage
					choice = card
			
		if choice:
			choice.is_played = true
			
			for i in range(enemy_slots.size(), 0, -1):
				if enemy_slots[i-1].item == null:
					choice.start_area.item = null
					choice.start_area = enemy_slots[i-1]
					choice.current_area = enemy_slots[i-1]
					choice.future_position = choice.current_area.position
					choice.current_area.item = choice
					break
	player_light.set_visible(true)
	enemy_light.set_visible(false)

func check_win():
	var enemy_slots = enemy_square.get_children()
	var player_slots = player_square.get_children()
	var enemy_point = 0
	var player_point = 0
	# If enemy has a unit there but player don't, add a point to enemy
	for i in range(enemy_slots.size()):
		if enemy_slots[i].item:
			if player_slots.size() > i:
				if player_slots[i].item == null:
					enemy_point+=1
					var tween = create_tween()
					tween.tween_property(enemy_slots[i].item, "position", enemy_slots[i].item.position + Vector2(0, +50), 0.5)
					enemy_slots[i].item.enemy_particles.set_emitting(true)
					tween.tween_property(enemy_slots[i].item, "position", enemy_slots[i].item.position, 1)
			else:
				enemy_point+=1
				var tween = create_tween()
				tween.tween_property(enemy_slots[i].item, "position", enemy_slots[i].item.position + Vector2(0, +50), 0.5)
				enemy_slots[i].item.enemy_particles.set_emitting(true)
				tween.tween_property(enemy_slots[i].item, "position", enemy_slots[i].item.position, 1)
	
	# If player has a unit there but enemy don't, add a point to player
	for i in range(player_slots.size()):
		if player_slots[i].item:
			if enemy_slots.size() > i:
				if enemy_slots[i].item == null:
					player_point+=1
					var tween = create_tween()
					tween.tween_property(player_slots[i].item, "position", player_slots[i].item.position + Vector2(0, -50), 0.5)
					player_slots[i].item.player_particles.set_emitting(true)
					tween.tween_property(player_slots[i].item, "position", player_slots[i].item.position, 1)
			else:
				player_point+=1
				var tween = create_tween()
				tween.tween_property(player_slots[i].item, "position", player_slots[i].item.position + Vector2(0, -50), 0.5)
				player_slots[i].item.player_particles.set_emitting(true)
				tween.tween_property(player_slots[i].item, "position", player_slots[i].item.position, 1)
	
	# Till all units in same slot are done fighting and got their points
	for i in range(enemy_slots.size()):
		if enemy_slots[i].item:
			if player_slots.size() > i:
				if player_slots[i].item:
					var end = false
					var enemy_position = enemy_slots[i].item.position
					var player_position = player_slots[i].item.position
					# Attack each other till at least one unit is died
					while true:
						player_slots[i].item.health -= enemy_slots[i].item.damage
						enemy_slots[i].item.health -= player_slots[i].item.damage
						player_slots[i].item.update_ui()
						enemy_slots[i].item.update_ui()
						if enemy_slots[i].item.health <= 0:
							player_point += 1
							enemy_slots[i].item.free()
							enemy_slots[i].item = null
							end = true
						if player_slots[i].item.health <= 0:
							enemy_point += 1
							player_slots[i].item.free()
							player_slots[i].item = null
							end = true
						if end:
							break
					if player_slots[i].item != null:
						var tween = create_tween()
						tween.tween_property(player_slots[i].item, "position", enemy_position, 0.4)
						tween.set_ease(Tween.EASE_IN)
						tween.tween_property(player_slots[i].item, "position", player_position, 0.4)
						player_slots[i].item.player_particles.set_emitting(true)
					if enemy_slots[i].item != null:
						var tween = create_tween()
						tween.tween_property(enemy_slots[i].item, "position", player_position, 0.4)
						tween.set_ease(Tween.EASE_IN)
						tween.tween_property(enemy_slots[i].item, "position", enemy_position, 0.4)
						enemy_slots[i].item.enemy_particles.set_emitting(true)
				
	# if there is no fight anymore
	var enemy_square_slots = enemy_square.get_children()
	var player_square_slots = player_square.get_children()
	
	# if player won
	if player_point > enemy_point:
		# if player has all of his war_square, enemy loses one line
		if player_square.get_child_count() == 10:
			if enemy_square.get_child_count() > 0:
				for i in range(1, enemy_line_count+1):
					enemy_square_slots = enemy_square.get_children()
					if enemy_square_slots[-i]:
						if enemy_square_slots[-i].item:
							enemy_square_slots[-i].item.queue_free()
						var tween = create_tween()
						tween.tween_property(war_line, "position", Vector2(0, enemy_square_slots[-i].position.y + 20), 0.3)
						enemy_square_slots[-i].queue_free()
				enemy_line_count += 1
		
		# if player has not all of his war_square, player gain one line
		elif player_square_slots.size() < 10 and player_square_slots.size() >= 2:
			var first_slot_position = Vector2(war_square.player_first_slot_position.x + (war_square.slot_x_distance/2) * (war_square.line_countt+1 - player_line_count), player_square_slots[-1].position.y) - Vector2(0, war_square.slot_y_distance)
			war_square.line_spawn(war_square.player_square, war_square.PLAYER_STAND, first_slot_position, player_line_count-1)
			
			player_square_slots = player_square.get_children()
			var tween = create_tween()
			tween.tween_property(war_line, "position", Vector2(0, player_square_slots[-1].position.y - war_square.slot_y_distance), 0.3)
			for card in player_cards.get_children():
				for i in range(1, player_line_count):
					card.detect_area(player_square_slots[-i])
			player_line_count -= 1
	
	# if enemy won
	elif player_point < enemy_point:
		# if enemy has all of his war_square, player loses one line
		if enemy_square.get_child_count() == 10:
			if player_square.get_child_count() > 0:
				for i in range(1, player_line_count+1):
					player_square_slots = player_square.get_children()
					if player_square_slots[-1]:
						if player_square_slots[-1].item:
							player_square_slots[-1].item.free()
						var tween = create_tween()
						tween.tween_property(war_line, "position", Vector2(0, player_square_slots[-1].position.y), 0.3)
						player_square_slots[-1].free()
				player_line_count += 1
		
		# if enemy has not all of his war_square, enemy gain one line
		elif enemy_square.get_child_count() < 10 and enemy_square_slots.size() >= 2:
			var first_slot_position = Vector2(war_square.enemy_first_slot_position.x + (war_square.slot_x_distance/2) * (war_square.line_countt+1 - enemy_line_count), enemy_square_slots[-1].position.y) + Vector2(0, war_square.slot_y_distance)
			war_square.line_spawn(war_square.enemy_square, war_square.ENEMY_STAND, first_slot_position, enemy_line_count-1)
			
			enemy_square_slots = enemy_square.get_children()
			var tween = create_tween()
			tween.tween_property(war_line, "position", Vector2(0, enemy_square_slots[-1].position.y + war_square.slot_y_distance + 20), 0.3)
			for card in player_cards.get_children():
				for i in range(1, enemy_line_count):
					card.detect_area(enemy_square_slots[-i])
			enemy_line_count -= 1

func check_traits():
	# Set all zero and calculate again
	Arcane_count.text = "0"
	Inventor_count.text = "0"
	Guardian_count.text = "0"
	Forest_count.text = "0"
	Assasins_count.text = "0"
	Undead_count.text = "0"
	Shield_count.text = "0"
	Inferno_count.text = "0"
	var Traits = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
	var Trait_counts = [Arcane_count, Inventor_count, Guardian_count, Forest_count, Assasins_count, Undead_count, Shield_count, Inferno_count]
	# Check for all 3 units of each class in player cards
	for card in player_cards.get_children():
		for i in range(Traits.size()):
			if card.type == spinning_wheel.Traits[i]["units"][0]["name"]:
				Traits[i][0] = 1
			if card.type == spinning_wheel.Traits[i]["units"][1]["name"]:
				Traits[i][1] = 1
			if card.type == spinning_wheel.Traits[i]["units"][2]["name"]:
				Traits[i][2] = 1
	# add one trait_count for each unit player has for each class
	for i in range(Trait_counts.size()):
		if Traits[i][0]:
			Trait_counts[i].text = str(int(Trait_counts[i].text) + 1)
		if Traits[i][1]:
			Trait_counts[i].text = str(int(Trait_counts[i].text) + 1)
		if Traits[i][2]:
			Trait_counts[i].text = str(int(Trait_counts[i].text) + 1)
		if Trait_counts[i].text == "0":
			trait_container.get_child(i).set_visible(false)
		else:
			trait_container.get_child(i).set_visible(true)

func reset():
	spin_button.disabled = true
	end_turn_button.disabled = true
	reset_button.disabled = true
	
	war_line.position.y = -50

	# remove cards
	for card in player_cards.get_children():
		card.free()
	for card in enemy_cards.get_children():
		card.queue_free()
	
	# reset slots
	for slot in player_square.get_children():
		slot.queue_free()
	for slot in enemy_square.get_children():
		slot.queue_free()
	war_square.spawn(war_square.player_square, war_square.PLAYER_STAND, war_square.player_first_slot_position, -1, war_square.line_countt)
	war_square.spawn(war_square.enemy_square, war_square.ENEMY_STAND, war_square.enemy_first_slot_position, 1, war_square.line_countt)
	
	check_traits()
	for t in trait_container.get_children():
		t.set_visible(true)
	
	# Variables
	enemy_line_count = 1
	player_line_count = 1
	spin_cost.text = str(turn_spin_cost)
	turn.text = "0"
	coin.text = str(start_coin)
	enemy_coin = start_coin
	enemy_spin_cost = turn_spin_cost
	coin.text = str(start_coin)
	await enemy_move()
	check_traits()
	
	spin_button.disabled = false
	end_turn_button.disabled = false
	reset_button.disabled = false


func _on_music_finished() -> void:
	music.play()


func _on_rain_finished() -> void:
	rain.play()
