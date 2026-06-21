extends Sprite2D

@export var areas: Array[Area2D]
var drag = false
var mouse_offset
var future_position = global_position
@export var current_area: Area2D
var start_area
var droppable = false

func _ready() -> void:
	start_area = current_area
	for area in areas:
		area.mouse_entered.connect(_on_mouse_entered.bind(area))
		area.mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	if drag == true:
		future_position = get_global_mouse_position() - mouse_offset
	global_position.x = move_toward(global_position.x, future_position.x, 30)
	global_position.y = move_toward(global_position.y, future_position.y, 30)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and get_rect().has_point(get_local_mouse_position()):
		mouse_offset = get_local_mouse_position()
		drag = true
	elif event.is_action_released("LMB") and drag == true:
		drag = false
		if droppable == false:
			future_position = start_area.position
		else:
			if current_area.item == null:
				start_area.item = null
				current_area.item = self
				start_area = current_area
				future_position = current_area.position
			else:
				future_position = start_area.position
				
func _on_mouse_entered(area):
	if drag == true:
		current_area = area
		droppable = true

func _on_mouse_exited():
	current_area = start_area
	droppable = false
