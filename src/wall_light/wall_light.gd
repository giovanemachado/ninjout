extends Node3D

class_name WallLight

@onready var spot_light: SpotLight3D = $SpotLight3D
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
var light_energy_on: float = 2.0
@export var light_energy_off: float = 0.0
@export var fade_duration: float = 0.3

var is_light_on: bool = false
var current_tween: Tween

func _ready():
	light_energy_on = spot_light.light_energy
	spot_light.light_energy = light_energy_off
	omni_light_3d.hide()

func toggle_light():
	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	
	var target_energy = light_energy_on if not is_light_on else light_energy_off
	
	if is_light_on:
		omni_light_3d.hide()
	else:
		omni_light_3d.show()

	current_tween.tween_property(spot_light, "light_energy", target_energy, fade_duration)

	is_light_on = !is_light_on
