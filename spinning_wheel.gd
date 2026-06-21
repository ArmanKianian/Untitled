extends Node2D

# wheel items with chance of getting
var items: Array = [
	{"name": "Item1", "chance": 10.0},
	{"name": "Item2", "chance": 10.0},
	{"name": "Item3", "chance": 10.0},
	{"name": "Item4", "chance": 10.0},
	{"name": "Item5", "chance": 10.0},
	{"name": "Item6", "chance": 10.0},
	{"name": "Item7", "chance": 10.0},
	{"name": "Item8", "chance": 10.0},
	{"name": "Item9", "chance": 10.0},
	{"name": "Item10", "chance": 10.0},
] 

func spin():
	var chosen = pick_weighted_random_item()
	print(chosen)

# Normalize Chance then pick one random based on weight(chance)
func pick_weighted_random_item():
	var chance_sum: float = 0
	for item in items:
		chance_sum += item["chance"]
	
	var random_chance = randf_range(0, chance_sum)
	for item in items:
		random_chance -= item["chance"]
		if random_chance <= 0:
			return item
	return items[0]

func _on_button_pressed() -> void:
	spin()
