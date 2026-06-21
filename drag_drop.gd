extends Sprite2D

@export var areas: Array[Area2D]
var drag = false
var mouse_offset
var future_position = global_position
var start_position = global_position
var area_position
var droppable = false

func _ready() -> void:
	for area in areas:
		area.mouse_entered.connect(_on_mouse_entered.bind(area))
		area.mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if drag == true:
		future_position = get_global_mouse_position() - mouse_offset
	global_position.x = move_toward(global_position.x, future_position.x, 30)
	global_position.y = move_toward(global_position.y, future_position.y, 30)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and get_rect().has_point(get_local_mouse_position()):
		mouse_offset = get_local_mouse_position()
		drag = true
	elif event.is_action_released("LMB"):
		drag = false
		if droppable == false:
			future_position = start_position
		else:
			future_position = area_position
			start_position = area_position

func _on_mouse_entered(area):
	area_position = area.position
	droppable = true

func _on_mouse_exited():
	area_position = start_position
	droppable = false
