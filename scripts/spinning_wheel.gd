extends Node2D

@onready var spinning: AudioStreamPlayer = $"../Audios/Spinning"

const UNIT_1_SHIELD = preload("uid://c6ke12jjs1pm2")
const UNIT_2_SHIELD = preload("uid://dalq6vjaeqx23")
const UNIT_3_SHIELD = preload("uid://bxj6iuq2y2b0r")

# wheel items with chance of getting
var Traits: Array = [
	{"name": "Arcane", "chance": 12.0, "units": [
	{"name": "Mage", "texture": UNIT_1_SHIELD, "level": 1, "damage": 12, "health": 60, "chance": 60.0},
	{"name": "Wizard", "texture": UNIT_2_SHIELD, "level": 1, "damage": 22, "health": 90, "chance": 30.0},
	{"name": "Archmage", "texture": UNIT_3_SHIELD, "level": 1, "damage": 40, "health": 120, "chance": 10.0},
]},
	{"name": "Inventor", "chance": 13.0, "units": [
	{"name": "Mechanic", "texture": UNIT_1_SHIELD, "level": 1, "damage": 10, "health": 70, "chance": 60.0},
	{"name": "Engineer", "texture": UNIT_2_SHIELD, "level": 1, "damage": 20, "health": 105, "chance": 30.0},
	{"name": "Mecha-Master", "texture": UNIT_3_SHIELD, "level": 1, "damage": 36, "health": 145, "chance": 10.0},
]},
	{"name": "Guardian", "chance": 14.0, "units": [
	{"name": "Squire", "texture": UNIT_1_SHIELD, "level": 1, "damage": 8, "health": 100, "chance": 60.0},
	{"name": "Knight", "texture": UNIT_2_SHIELD, "level": 1, "damage": 16, "health": 150, "chance": 30.0},
	{"name": "Paladin", "texture": UNIT_3_SHIELD, "level": 1, "damage": 28, "health": 230, "chance": 10.0},
]},
	{"name": "Forest", "chance": 13.0, "units": [
	{"name": "Dryad", "texture": UNIT_1_SHIELD, "level": 1, "damage": 11, "health": 65, "chance": 60.0},
	{"name": "Ranger", "texture": UNIT_2_SHIELD, "level": 1, "damage": 21, "health": 95, "chance": 30.0},
	{"name": "Treant", "texture": UNIT_3_SHIELD, "level": 1, "damage": 34, "health": 180, "chance": 10.0},
]},
	{"name": "Assasins", "chance": 12.0, "units": [
	{"name": "Rogue", "texture": UNIT_1_SHIELD, "level": 1, "damage": 18, "health": 50, "chance": 60.0},
	{"name": "Shadowblade", "texture": UNIT_2_SHIELD, "level": 1, "damage": 30, "health": 70, "chance": 30.0},
	{"name": "Phantom", "texture": UNIT_3_SHIELD, "level": 1, "damage": 52, "health": 90, "chance": 10.0},
]},
	{"name": "Undead", "chance": 12.0, "units": [
	{"name": "Skeleton", "texture": UNIT_1_SHIELD, "level": 1, "damage": 9, "health": 80, "chance": 60.0},
	{"name": "Ghoul", "texture": UNIT_2_SHIELD, "level": 1, "damage": 18, "health": 130, "chance": 30.0},
	{"name": "Lich", "texture": UNIT_3_SHIELD, "level": 1, "damage": 35, "health": 160, "chance": 10.0},
]},
	{"name": "Shield", "chance": 12.0, "units": [
	{"name": "Defender", "texture": UNIT_1_SHIELD, "level": 1, "damage": 6, "health": 110, "chance": 60.0},
	{"name": "Bulwark", "texture": UNIT_2_SHIELD, "level": 1, "damage": 14, "health": 180, "chance": 30.0},
	{"name": "Fortress", "texture": UNIT_3_SHIELD, "level": 1, "damage": 24, "health": 280, "chance": 10.0},
]},
	{"name": "Inferno", "chance": 12.0, "units": [
	{"name": "Imp", "texture": UNIT_1_SHIELD, "level": 1, "damage": 14, "health": 55, "chance": 60.0},
	{"name": "Demon", "texture": UNIT_2_SHIELD, "level": 1, "damage": 28, "health": 90, "chance": 30.0},
	{"name": "Infernal-Lord", "texture": UNIT_3_SHIELD, "level": 1, "damage": 48, "health": 140, "chance": 10.0},
]},
]

func _ready():
	randomize()



func spin():

	spinning.play()

	var traitt = pick_weighted_random_item(Traits)

	var trait_index = Traits.find(traitt)

	var unit = pick_weighted_random_item(traitt["units"])

	return await rotate_wheel(trait_index, unit)



func pick_weighted_random_item(items: Array):

	var total_weight := 0.0

	for item in items:
		total_weight += item["chance"]


	var roll := randf_range(0, total_weight)


	for item in items:

		roll -= item["chance"]

		if roll <= 0:
			return item


	return items[0]



func rotate_wheel(index: int, chosen):

	var random_rotation = randi_range(3,6)

	var degree = 360.0 / Traits.size()

	var chosen_degree = index * degree + degree / 2


	var tween = create_tween()

	tween.set_ease(Tween.EASE_IN_OUT)


	for i in range(random_rotation):

		tween.tween_property(
			self,
			"rotation_degrees",
			360 * i,
			0.1
		)


	tween.tween_property(
		self,
		"rotation_degrees",
		chosen_degree + 360 * random_rotation,
		0.5
	)


	await tween.finished


	return chosen
