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

signal light_toggled(light_number: int, is_on: bool)

@onready var button: Button = %Button
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var power_controller: PowerController = $"../PowerController"

func _ready():
	start_light_fade()

	button.pressed.connect(_on_button_1_pressed)
	button_2.pressed.connect(_on_button_2_pressed)
	button_3.pressed.connect(_on_button_3_pressed)
	button_4.pressed.connect(_on_button_4_pressed)

	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	cooldown_timer.wait_time = button_cooldown_duration
	cooldown_timer.one_shot = true

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
	play_light.light_energy = initial_light_energy

	var tween = create_tween()
	tween.tween_property(play_light, "light_energy", 0.0, light_fade_duration)
	tween.tween_callback(light_fade_done)

func light_fade_done():
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

	light_toggled.emit(light_number, lights_state[light_index])

	#print("Luz ", light_number, " está agora: ", "LIGADA" if lights_state[light_index] else "DESLIGADA")
	start_button_cooldown()

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
