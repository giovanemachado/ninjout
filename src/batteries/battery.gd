extends Node3D

@onready var omni_light_3d_2: OmniLight3D = $OmniLight3D2

@export var first_blink_interval: float = 0.1
@export var blink_interval: float = 1.25
@export var blink_duration: float = 0.05
@export var light_energy_on: float = 5.0
@export var light_energy_off: float = 0.0
@export var initial_delay_range: float = 0.5

@export var color_change_duration: float = 1.0
@onready var blink_timer: Timer = $BlinkTimer

var blink_state: bool = false
var original_color: Color
var is_color_changed: bool = false
@onready var color_timer: Timer = $ColorTimer


func _ready():
	original_color = omni_light_3d_2.light_color

	color_timer.timeout.connect(_on_color_timer_timeout)
	color_timer.one_shot = true

	await get_tree().create_timer(randf() * initial_delay_range).timeout
	setup_blinking_lights()

func turn_off_light():
	omni_light_3d_2.light_energy = light_energy_off
	blink_timer.stop()

func setup_blinking_lights():
	blink_timer.wait_time = first_blink_interval
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	blink_timer.start()

	omni_light_3d_2.light_energy = light_energy_off

func _on_blink_timer_timeout():
	if not blink_state:
		turn_lights_on()
		blink_timer.wait_time = blink_duration
	else:
		turn_lights_off()
		blink_timer.wait_time = blink_interval

	blink_state = !blink_state

func turn_lights_on():
	var tween1 = create_tween()
	tween1.tween_property(omni_light_3d_2, "light_energy", light_energy_on, 0.05)

func turn_lights_off():
	var tween1 = create_tween()
	tween1.tween_property(omni_light_3d_2, "light_energy", light_energy_off, 0.05)

func flash_red():
	if is_color_changed:
		return

	is_color_changed = true

	omni_light_3d_2.light_color = Color.RED

	color_timer.wait_time = color_change_duration
	color_timer.start()

func flash_green():
	if is_color_changed:
		return

	is_color_changed = true

	omni_light_3d_2.light_color = Color.GREEN

	color_timer.wait_time = color_change_duration
	color_timer.start()

func _on_color_timer_timeout():
	omni_light_3d_2.light_color = original_color
	is_color_changed = false
