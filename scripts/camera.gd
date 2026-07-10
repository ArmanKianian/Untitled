extends Camera2D


# =============================================================================
# Shake Settings
# =============================================================================

@export var shake_decay: float = 5.0
@export var shake_speed: float = 20.0
@export var noise_frequency: float = 2.0
@export var return_speed: float = 10.5


# =============================================================================
# Runtime
# =============================================================================

var shake_intensity: float = 0.0
var shake_time: float = 0.0
var active_shake_time: float = 0.0

var noise := FastNoiseLite.new()


# =============================================================================
# Process
# =============================================================================

func _ready():
	randomize()


func _process(delta: float):

	if active_shake_time > 0:

		shake_time += delta * shake_speed
		active_shake_time -= delta

		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)

		shake_intensity = max(
			shake_intensity - shake_decay * delta,
			0
		)

	else:

		offset = offset.lerp(
			Vector2.ZERO,
			return_speed * delta
		)


# =============================================================================
# Public API
# =============================================================================

func screen_shake(intensity: float, duration: float):

	noise.seed = randi()
	noise.frequency = noise_frequency

	shake_intensity = intensity
	active_shake_time = duration
	shake_time = 0.0
