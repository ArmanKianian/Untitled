extends Node2D

# wheel items with chance of getting
var Traits: Array = [
	{"name": "Arcane", "chance": 12.0, "units": [
	{"name": "Mage", "level": 1, "damage": 12, "health": 60, "chance": 60.0},
	{"name": "Wizard", "level": 1, "damage": 22, "health": 90, "chance": 30.0},
	{"name": "Archmage", "level": 1, "damage": 40, "health": 120, "chance": 10.0},
]},
	{"name": "Inventor", "chance": 13.0, "units": [
	{"name": "Mechanic", "level": 1, "damage": 10, "health": 70, "chance": 60.0},
	{"name": "Engineer", "level": 1, "damage": 20, "health": 105, "chance": 30.0},
	{"name": "Mecha-Master", "level": 1, "damage": 36, "health": 145, "chance": 10.0},
]},
	{"name": "Guardian", "chance": 14.0, "units": [
	{"name": "Squire", "level": 1, "damage": 8, "health": 100, "chance": 60.0},
	{"name": "Knight", "level": 1, "damage": 16, "health": 150, "chance": 30.0},
	{"name": "Paladin", "level": 1, "damage": 28, "health": 230, "chance": 10.0},
]},
	{"name": "Forest", "chance": 13.0, "units": [
	{"name": "Dryad", "level": 1, "damage": 11, "health": 65, "chance": 60.0},
	{"name": "Ranger", "level": 1, "damage": 21, "health": 95, "chance": 30.0},
	{"name": "Treant", "level": 1, "damage": 34, "health": 180, "chance": 10.0},
]},
	{"name": "Assasins", "chance": 12.0, "units": [
	{"name": "Rogue", "level": 1, "damage": 18, "health": 50, "chance": 60.0},
	{"name": "Shadowblade", "level": 1, "damage": 30, "health": 70, "chance": 30.0},
	{"name": "Phantom", "level": 1, "damage": 52, "health": 90, "chance": 10.0},
]},
	{"name": "Undead", "chance": 12.0, "units": [
	{"name": "Skeleton", "level": 1, "damage": 9, "health": 80, "chance": 60.0},
	{"name": "Ghoul", "level": 1, "damage": 18, "health": 130, "chance": 30.0},
	{"name": "Lich", "level": 1, "damage": 35, "health": 160, "chance": 10.0},
]},
	{"name": "Shield", "chance": 12.0, "units": [
	{"name": "Defender", "level": 1, "damage": 6, "health": 110, "chance": 60.0},
	{"name": "Bulwark", "level": 1, "damage": 14, "health": 180, "chance": 30.0},
	{"name": "Fortress", "level": 1, "damage": 24, "health": 280, "chance": 10.0},
]},
	{"name": "Inferno", "chance": 12.0, "units": [
	{"name": "Imp", "level": 1, "damage": 14, "health": 55, "chance": 60.0},
	{"name": "Demon", "level": 1, "damage": 28, "health": 90, "chance": 30.0},
	{"name": "Infernal-Lord", "level": 1, "damage": 48, "health": 140, "chance": 10.0},
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
