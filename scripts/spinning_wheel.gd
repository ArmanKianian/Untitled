extends Node2D

# wheel items with chance of getting
var items: Array = [
	{"name": "Item1", "level": 1, "damage": 2, "health": 3, "chance": 10.0},
	{"name": "Item2", "level": 1, "damage": 1, "health": 1, "chance": 10.0},
	{"name": "Item3", "level": 1, "damage": 2, "health": 1, "chance": 10.0},
	{"name": "Item4", "level": 1, "damage": 1, "health": 2, "chance": 10.0},
	{"name": "Item5", "level": 1, "damage": 3, "health": 1, "chance": 10.0},
	{"name": "Item6", "level": 1, "damage": 1, "health": 3, "chance": 10.0},
	{"name": "Item7", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Item8", "level": 1, "damage": 4, "health": 1, "chance": 10.0},
	{"name": "Item9", "level": 1, "damage": 1, "health": 4, "chance": 10.0},
	{"name": "Item10", "level": 1, "damage": 3, "health": 3, "chance": 10.0},
] 

func spin():
	var chosen = pick_weighted_random_item()
	return chosen

# Normalize Chance then pick one random based on weight(chance)
func pick_weighted_random_item():
	randomize()
	var chance_sum: float = 0
	for item in items:
		chance_sum += item["chance"]
	
	var random_chance = randf_range(0, chance_sum)
	for item in items:
		random_chance -= item["chance"]
		if random_chance <= 0:
			return item
	return items[0]
