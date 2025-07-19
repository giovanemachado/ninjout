extends Node

class_name GameController

@onready var debug_menu: Control = %DebugMenu
@onready var play_light: Light3D = %PlayLight
@export var is_debug_menu_avaiable = false
@export var light_fade_duration: float = 2
@export var initial_light_energy = 0.5
@export var button_cooldown_duration: float = 0.5
@onready var progress_bar: ProgressBar = %ProgressBar

var lights_state: Array[bool] = [false, false, false, false]
var can_toggle_lights: bool = true
@onready var poweroff_animator: AnimationPlayer = $PoweroffAnimator

signal light_toggled(light_number: int, is_on: bool)

@onready var button: Button = %Button
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4
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


func _ready():
	button.pressed.connect(_on_button_1_pressed)
	button_2.pressed.connect(_on_button_2_pressed)
	button_3.pressed.connect(_on_button_3_pressed)
	button_4.pressed.connect(_on_button_4_pressed)

	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	cooldown_timer.wait_time = button_cooldown_duration
	cooldown_timer.one_shot = true
	
	play_light.light_energy = initial_light_energy
	await get_tree().create_timer(15).timeout
	start_light_fade()

func _input(event):
	if event.is_action_pressed("open_menu"):
		open_menu()

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


func _on_power_controller_energy_updated(new_energy: int) -> void:
	progress_bar.max_value = power_controller.max_energy
	progress_bar.value = new_energy

	var energy_percentage = float(new_energy) / float(power_controller.max_energy)
	if energy_percentage <= 0.2:
		progress_bar.modulate = Color.RED
	elif energy_percentage <= 0.5:
		progress_bar.modulate = Color.YELLOW
	else:
		progress_bar.modulate = Color.GREEN


func _on_power_controller_energy_depleted() -> void:
	SceneLoader.scene_transition(SceneLoader.SCENES.GAME_OVER)

func get_sectors_with_lights_on() -> Array[int]:
	var sectors_with_lights: Array[int] = []

	for i in range(lights_state.size()):
		if lights_state[i]:
			sectors_with_lights.append(i)

	return sectors_with_lights
