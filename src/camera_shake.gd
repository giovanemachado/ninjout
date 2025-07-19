extends Node

class_name CameraShake

@onready var camera: Camera3D = %Camera3D
@export var default_intensity: float = 0.5
@export var default_duration: float = 0.3

var original_position: Vector3
var shake_tween: Tween
var is_shaking: bool = false

func _ready():
	if camera:
		original_position = camera.position

func shake(intensity: float = default_intensity, duration: float = default_duration):
	if not camera:
		return

	if shake_tween:
		shake_tween.kill()

	is_shaking = true
	original_position = camera.position

	shake_tween = create_tween()

	var shake_count = int(duration * 60)

	for i in range(shake_count):
		var random_offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)

		shake_tween.tween_property(
			camera,
			"position",
			original_position + random_offset,
			duration / shake_count
		)

	shake_tween.tween_property(camera, "position", original_position, 0.1)
	shake_tween.tween_callback(func(): is_shaking = false)

func shake_impulse(intensity: float = default_intensity):
	shake(intensity, 0.15)

func shake_explosion(intensity: float = 1.0):
	shake(intensity, 0.5)
