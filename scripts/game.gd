extends Node2D

const CARD = preload("uid://dlsbf8fn82egx")

@onready var camera: Camera2D = $Camera2D

@onready var player_inventory: Node2D = $inventory/player_inventory
@onready var enemy_inventory: Node2D = $inventory/enemy_inventory
@onready var player_cards: Node2D = $cards/player_cards
@onready var enemy_cards: Node2D = $cards/enemy_cards
@onready var player_square: Node2D = $war_square/player_square
@onready var enemy_square: Node2D = $war_square/enemy_square

@onready var spin_button: Button = $UI/Spin_Button
@onready var end_turn_button: Button = $UI/End_Turn_button

@onready var spinning_wheel: Node2D = $Spinning_Wheel

@onready var war_square: Node2D = $war_square

@onready var spin_cost: Label = $UI/Spin_Button/spin_cost
@onready var turn: Label = $UI/turn
@onready var coin: Label = $UI/coin

@export var start_coin = 12
@export var turn_coin_gain = 6
@export var turn_spin_cost = 3
@export var spin_cost_gain = 1

var enemy_coin = 12
var enemy_spin_cost = 3

var enemy_line_count = 1
var player_line_count = 1

func _ready() -> void:
	spin_button.disabled = true
	end_turn_button.disabled = true
	enemy_coin = start_coin
	enemy_spin_cost = turn_spin_cost
	coin.text = str(start_coin)
	await enemy_move()
	spin_button.disabled = false
	end_turn_button.disabled = false

func _on_end_turn_button_pressed() -> void:
	spin_button.disabled = true
	end_turn_button.disabled = true
	camera.screen_shake(50, 0.5)
	spin_cost.text = str(turn_spin_cost)
	turn.text = str(int(turn.text) + 1)
	coin.text = str(int(coin.text) + turn_coin_gain)
	
	await check_win()
	await enemy_move()
	spin_button.disabled = false
	end_turn_button.disabled = false

func _on_spin_button_pressed() -> void:
	spin_button.disabled = true
	end_turn_button.disabled = true
	camera.screen_shake(8, 0.2)
	if int(coin.text) >= int(spin_cost.text):
		if await add_card(player_cards, player_inventory, player_square):
			coin.text = str(int(coin.text) - int(spin_cost.text))
			spin_cost.text = str(int(spin_cost.text) + spin_cost_gain)
	spin_button.disabled = false
	end_turn_button.disabled = false

func add_card(cards, inventory, square):
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
			cards.add_child(card)
			return true
	print("inventory is full!")

func enemy_move():
	while enemy_coin >= enemy_spin_cost:
		if await add_card(enemy_cards, enemy_inventory, enemy_square):
			enemy_coin -= enemy_spin_cost
			enemy_spin_cost += spin_cost_gain
		else:
			break
	enemy_coin += turn_coin_gain
	enemy_spin_cost = turn_spin_cost
	
	var max_stat
	var choice
	var enemy_slots = enemy_square.get_children()
	
	for card in enemy_cards.get_children():
			for card2 in enemy_cards.get_children():
				if card != card2 and card.type == card2.type and card.level == card2.level:
					card.level_up(card2)
					card2.queue_free()
	
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

func check_win():
	var enemy_slots = enemy_square.get_children()
	var player_slots = player_square.get_children()
	var is_there_any = false
	var enemy_point = 0
	var player_point = 0
	for i in range(enemy_slots.size()):
		if enemy_slots[i].item:
			if player_slots.size() > i:
				if player_slots[i].item == null:
					enemy_point+=1
			else:
				enemy_point+=1
	
	for i in range(player_slots.size()):
		if player_slots[i].item:
			if enemy_slots.size() > i:
				if enemy_slots[i].item == null:
					player_point+=1
			else:
				player_point+=1
	
	while true:
		for i in range(enemy_slots.size()):
			is_there_any = false
			if enemy_slots[i].item:
				if player_slots.size() > i:
					if player_slots[i].item:
						is_there_any = true
						player_slots[i].item.health -= enemy_slots[i].item.damage
						enemy_slots[i].item.health -= player_slots[i].item.damage
						if enemy_slots[i].item.health <= 0:
							player_point += 1
							enemy_slots[i].item.queue_free()
							enemy_slots[i].item = null
						if player_slots[i].item.health <= 0:
							enemy_point += 1
							player_slots[i].item.queue_free()
							player_slots[i].item = null
						
		if is_there_any == false:
			var enemy_square_slots = enemy_square.get_children()
			var player_square_slots = player_square.get_children()
			if player_point > enemy_point:
				if player_square.get_child_count() == 10:
					if enemy_square.get_child_count() > 0:
						for i in range(1, enemy_line_count+1):
							enemy_square_slots = enemy_square.get_children()
							if enemy_square_slots[-i]:
								if enemy_square_slots[-i].item:
									enemy_square_slots[-i].item.queue_free()
								enemy_square_slots[-i].queue_free()
						enemy_line_count += 1
				
				elif player_square_slots.size() < 10 and player_square_slots.size() >= 2:
					var first_slot_position = Vector2(war_square.player_first_slot_position.x + (war_square.slot_x_distance/2) * (war_square.line_countt+1 - player_line_count), player_square_slots[-1].position.y) - Vector2(0, war_square.slot_y_distance)
					war_square.line_spawn(war_square.player_square, war_square.PLAYER_STAND, first_slot_position, player_line_count-1)
					
					player_square_slots = player_square.get_children()
					for card in player_cards.get_children():
						for i in range(1, player_line_count):
							card.detect_area(player_square_slots[-i])
					player_line_count -= 1
				
			elif player_point < enemy_point:
				if enemy_square.get_child_count() == 10:
					if player_square.get_child_count() > 0:
						for i in range(1, player_line_count+1):
							player_square_slots = player_square.get_children()
							if player_square_slots[-i]:
								if player_square_slots[-i].item:
									player_square_slots[-i].item.queue_free()
								player_square_slots[-i].queue_free()
						player_line_count += 1
				
				elif enemy_square.get_child_count() < 10 and enemy_square_slots.size() >= 2:
					print("enemy: ", enemy_line_count-1)
					var first_slot_position = Vector2(war_square.enemy_first_slot_position.x + (war_square.slot_x_distance/2) * (war_square.line_countt+1 - enemy_line_count), enemy_square_slots[-1].position.y) + Vector2(0, war_square.slot_y_distance)
					war_square.line_spawn(war_square.enemy_square, war_square.ENEMY_STAND, first_slot_position, enemy_line_count-1)
					
					enemy_square_slots = enemy_square.get_children()
					for card in player_cards.get_children():
						for i in range(1, enemy_line_count):
							card.detect_area(enemy_square_slots[-i])
					enemy_line_count -= 1
				
			break
	
