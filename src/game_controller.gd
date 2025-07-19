extends Node

class_name GameController

@onready var debug_menu: Control = %DebugMenu
@onready var play_light: Light3D = %PlayLight
@export var is_debug_menu_avaiable = false
@export var light_fade_duration: float = 2
@export var initial_light_energy = 0.5
@export var button_cooldown_duration: float = 0.5

var lights_state: Array[bool] = [false, false, false, false]
var can_toggle_lights: bool = true
@onready var poweroff_animator: AnimationPlayer = $PoweroffAnimator

signal light_toggled(light_number: int, is_on: bool)

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var power_controller: PowerController = $"../PowerController"

@onready var wall_light: WallLight = %WallLight
@onready var wall_light_2: WallLight = %WallLight2
@onready var wall_light_3: WallLight = %WallLight3
@onready var wall_light_4: WallLight = %WallLight4

@onready var indicator_square_b_1: Node3D = $"../Environment/Numbers/Number/indicator-square-b2"
@onready var indicator_square_b_2: Node3D = $"../Environment/Numbers/Number2/indicator-square-b3"
@onready var indicator_square_b_3: Node3D = $"../Environment/Numbers/Number3/indicator-square-b6"
@onready var indicator_square_b_4: Node3D = $"../Environment/Numbers/Number4/indicator-square-b7"

@onready var explosion_effect: AudioStreamPlayer3D = $ExplosionEffect
@onready var hit_metal_effect: AudioStreamPlayer3D = $HitMetalEffect

@export var initial_timeout = 15

func _ready():
	SignalBus.hit_battery.connect(_on_hit_battery)

	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	cooldown_timer.wait_time = button_cooldown_duration
	cooldown_timer.one_shot = true

	play_light.light_energy = initial_light_energy
	await get_tree().create_timer(initial_timeout).timeout
	start_light_fade()

func _input(event):
	if event.is_action_pressed("open_menu"):
		open_menu()

	if event.is_action_pressed("light1"):
		toggle_light(1)
	elif event.is_action_pressed("light2"):
		toggle_light(2)
	elif event.is_action_pressed("light3"):
		toggle_light(3)
	elif event.is_action_pressed("light4"):
		toggle_light(4)

func open_menu():
	if !is_debug_menu_avaiable:
		return

	if debug_menu.is_visible():
		debug_menu.hide()
	else:
		debug_menu.show()

func quit_game():
	get_tree().quit()

func _on_quit_pressed() -> void:
	quit_game()

func start_light_fade():
	explosion_effect.playing = true
	poweroff_animator.play("power_off")
	power_controller.start_energy_timer()

func _on_button_1_pressed():
	toggle_light(1)

func _on_button_2_pressed():
	toggle_light(2)

func _on_button_3_pressed():
	toggle_light(3)

func _on_button_4_pressed():
	toggle_light(4)

func toggle_light(light_number: int):
	if not can_toggle_lights:
		return

	var light_index = light_number - 1
	lights_state[light_index] = !lights_state[light_index]

	var wall_lights = [wall_light, wall_light_2, wall_light_3, wall_light_4]
	wall_lights[light_index].toggle_light()

	light_toggled.emit(light_number, lights_state[light_index])

	#print("Luz ", light_number, " está agora: ", "LIGADA" if lights_state[light_index] else "DESLIGADA")
	if !lights_state[light_index]:
		start_button_cooldown()

	toggle_floor_light(light_index)

func toggle_floor_light(light_index: int):
	var indicators = [indicator_square_b_1, indicator_square_b_2, indicator_square_b_4, indicator_square_b_3]

	if light_index >= 0 and light_index < indicators.size():
		var indicator = indicators[light_index]
		if indicator and indicator.has_method("toggle_glow"):
			indicator.toggle_glow()

func start_button_cooldown():
	can_toggle_lights = false
	cooldown_timer.start()

func _on_cooldown_timer_timeout():
	can_toggle_lights = true

func _on_power_controller_energy_depleted() -> void:
	SceneLoader.scene_transition(SceneLoader.SCENES.GAME_OVER)

func get_sectors_with_lights_on() -> Array[int]:
	var sectors_with_lights: Array[int] = []

	for i in range(lights_state.size()):
		if lights_state[i]:
			sectors_with_lights.append(i)

	return sectors_with_lights

func _on_hit_battery(is_enemy: bool):
	if is_enemy:
		hit_metal_effect.playing = true
