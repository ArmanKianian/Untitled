extends Node2D

const CARD = preload("uid://dlsbf8fn82egx")

@onready var camera: Camera2D = $Camera2D

@onready var inventory: Node2D = $inventory
@onready var cards: Node2D = $cards
@onready var spinning_wheel: Node2D = $Spinning_Wheel

@onready var spin_cost: Label = $UI/GridContainer/spin_cost
@onready var turn: Label = $UI/GridContainer/turn
@onready var coin: Label = $UI/GridContainer/coin

@export var start_coin = 12
@export var turn_coin_gain = 6
@export var turn_spin_cost = 3
@export var spin_cost_gain = 1

func _ready() -> void:
	coin.text = str(start_coin)

func _on_end_turn_button_pressed() -> void:
	camera.screen_shake(50, 0.5)
	spin_cost.text = str(turn_spin_cost)
	turn.text = str(int(turn.text) + 1)
	coin.text = str(int(coin.text) + turn_coin_gain)

func _on_spin_button_pressed() -> void:
	camera.screen_shake(8, 0.2)
	if int(coin.text) >= int(spin_cost.text):
		if add_card():
			coin.text = str(int(coin.text) - int(spin_cost.text))
			spin_cost.text = str(int(spin_cost.text) + spin_cost_gain)

func add_card():
	for child in inventory.get_children():
		if child.item == null:
			var chosen = spinning_wheel.spin()
			var card = CARD.instantiate()
			card.type = chosen["name"]
			card.level = chosen["level"]
			cards.add_child(card)
			return true
	print("inventory is full!")
