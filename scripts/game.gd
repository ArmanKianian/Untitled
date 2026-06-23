extends Node2D

const CARD = preload("uid://dlsbf8fn82egx")

@onready var camera: Camera2D = $Camera2D

@onready var player_inventory: Node2D = $inventory/player_inventory
@onready var enemy_inventory: Node2D = $inventory/enemy_inventory
@onready var player_cards: Node2D = $cards/player_cards
@onready var enemy_cards: Node2D = $cards/enemy_cards
@onready var spinning_wheel: Node2D = $Spinning_Wheel

@onready var enemy_square: Node2D = $war_square/enemy_square

@onready var spin_cost: Label = $UI/GridContainer/spin_cost
@onready var turn: Label = $UI/GridContainer/turn
@onready var coin: Label = $UI/GridContainer/coin

@export var start_coin = 12
@export var turn_coin_gain = 6
@export var turn_spin_cost = 3
@export var spin_cost_gain = 1

var enemy_coin = 12
var enemy_spin_cost = 3

func _ready() -> void:
	enemy_coin = start_coin
	enemy_spin_cost = turn_spin_cost
	coin.text = str(start_coin)

func _on_end_turn_button_pressed() -> void:
	camera.screen_shake(50, 0.5)
	spin_cost.text = str(turn_spin_cost)
	turn.text = str(int(turn.text) + 1)
	coin.text = str(int(coin.text) + turn_coin_gain)
	
	enemy_move()

func _on_spin_button_pressed() -> void:
	camera.screen_shake(8, 0.2)
	if int(coin.text) >= int(spin_cost.text):
		if add_card(player_cards, player_inventory):
			coin.text = str(int(coin.text) - int(spin_cost.text))
			spin_cost.text = str(int(spin_cost.text) + spin_cost_gain)

func add_card(owner, owner_inventory):
	for child in owner_inventory.get_children():
		if child.item == null:
			var chosen = spinning_wheel.spin()
			var card = CARD.instantiate()
			card.inventory = owner_inventory
			card.type = chosen["name"]
			card.level = chosen["level"]
			card.health = chosen["health"]
			card.damage = chosen["damage"]
			owner.add_child(card)
			return true
	print("inventory is full!")

func enemy_move():
	while enemy_coin >= enemy_spin_cost:
		if add_card(enemy_cards, enemy_inventory):
			enemy_coin -= enemy_spin_cost
			enemy_spin_cost += spin_cost_gain
		else:
			break
	enemy_coin += turn_coin_gain
	enemy_spin_cost = turn_spin_cost
	
	#var enemy_square_slot_count = enemy_square.get_child_count()
	#var enemy_square_slots = enemy_square.get_children()
	#var enemy_card_count = enemy_cards.get_child_count()
	#for i in range(enemy_square_slot_count):
		#if enemy_card_count <= 0:
			#return
		#enemy_card_count = enemy_cards.get_child_count()
		#var a = enemy_square_slots[enemy_square_slot_count-i-1].position
		#var max = -1
		#var chosen
		#for card in enemy_cards.get_children():
			#if card.is_played == false:
				#print(card.health + card.damage)
				#if card.health + card.damage > max:
					#max = card.health + card.damage
					#chosen = card
			#else:
				#enemy_card_count -= 1
		## print(chosen.position)
		#if chosen:
			#chosen.is_played = true
