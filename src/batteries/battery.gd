extends Node3D

@onready var omni_light_3d_2: OmniLight3D = $OmniLight3D2
@onready var omni_light_3d_3: OmniLight3D = $OmniLight3D3

@export var blink_interval: float = 1.0
@export var blink_duration: float = 0.15
@export var light_energy_on: float = 5.0
@export var light_energy_off: float = 0.0
@export var initial_delay_range: float = 0.5
@onready var blink_timer: Timer = $BlinkTimer

var blink_state: bool = false

func _ready():
    await get_tree().create_timer(randf() * initial_delay_range).timeout
    setup_blinking_lights()

func setup_blinking_lights():
    blink_timer.wait_time = blink_interval
    blink_timer.timeout.connect(_on_blink_timer_timeout)
    blink_timer.start()

    omni_light_3d_2.light_energy = light_energy_off
    omni_light_3d_3.light_energy = light_energy_off

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
    var tween2 = create_tween()
    tween1.tween_property(omni_light_3d_2, "light_energy", light_energy_on, 0.05)
    tween2.tween_property(omni_light_3d_3, "light_energy", light_energy_on, 0.05)

func turn_lights_off():
    var tween1 = create_tween()
    var tween2 = create_tween()
    tween1.tween_property(omni_light_3d_2, "light_energy", light_energy_off, 0.05)
    tween2.tween_property(omni_light_3d_3, "light_energy", light_energy_off, 0.05)
