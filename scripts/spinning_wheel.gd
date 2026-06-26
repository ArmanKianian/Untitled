extends Node2D

# wheel items with chance of getting
var Traits: Array = [
	{"name": "Arcane", "chance": 10.0, "units": [
	{"name": "Arcane1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Arcane2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Arcane3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
	{"name": "Inventor", "chance": 10.0, "units": [
	{"name": "Inventor1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Inventor2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Inventor3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
	{"name": "Guardian", "chance": 10.0, "units": [
	{"name": "Guardian1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Guardian2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Guardian3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
	{"name": "Forest", "chance": 10.0, "units": [
	{"name": "Forest1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Forest2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Forest3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
	{"name": "Assasins", "chance": 10.0, "units": [
	{"name": "Assasins1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Assasins2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Assasins3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
	{"name": "Undead", "chance": 10.0, "units": [
	{"name": "Undead1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Undead2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Undead3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
	{"name": "Shield", "chance": 10.0, "units": [
	{"name": "Shield1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Shield2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Shield3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
	{"name": "Inferno", "chance": 10.0, "units": [
	{"name": "Inferno1", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Inferno2", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
	{"name": "Inferno3", "level": 1, "damage": 3, "health": 2, "chance": 10.0},
]},
]

func spin():
	var chosen = pick_weighted_random_item(Traits)
	for i in range(Traits.size()):
		if Traits[i] == chosen:
			chosen = pick_weighted_random_item(chosen["units"])
			return await rotate_wheel(i, chosen)
	chosen = pick_weighted_random_item(chosen["units"])
	return chosen

# Normalize Chance then pick one random based on weight(chance)
func pick_weighted_random_item(items):
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

func rotate_wheel(index, chosen):
	randomize()
	var random_rotation = randi_range(3, 6)
	var degree = 360.0 / 8.0
	var chosen_degree = index * degree + (degree/2)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	for i in range(random_rotation):
		tween.tween_property(self, "rotation_degrees", 360 * i, 0.1)
	tween.tween_property(self, "rotation_degrees", chosen_degree + 360*random_rotation, 0.5)
	await tween.finished
	
	return chosen
