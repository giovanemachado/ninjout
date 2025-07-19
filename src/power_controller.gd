extends Node

class_name PowerController
@onready var energy_timer: Timer = $EnergyTimer
@export var max_energy: float = 100
@export var energy_subtract_timing: float = 0.5
@export var light_base_consume: float = 1
@export var light_multiplier: float = 1
@export var hit_reduction_amount: float = -10

var current_energy: float
var lights_on_count: int = 0

signal energy_depleted
signal energy_updated(new_energy: int)

func _ready():
	SignalBus.hit_battery.connect(_on_hit_battery)
	current_energy = max_energy
	energy_updated.emit(current_energy)

func start_energy_timer():
	energy_timer.wait_time = energy_subtract_timing
	energy_timer.timeout.connect(_on_energy_timer_timeout)
	energy_timer.start()

func _on_energy_timer_timeout():
	var energy_consumption = light_base_consume + (lights_on_count * light_multiplier)
	# print(-energy_consumption)
	update_energy(-energy_consumption)

func update_energy(amount: float):
	if amount == 0:
		return

	var old_energy = current_energy
	current_energy += amount
	current_energy = clamp(current_energy, 0, max_energy)

	if old_energy != current_energy:
		energy_updated.emit(current_energy)

	if current_energy <= 0:
		energy_depleted.emit()
		# print("Energia esgotada!")

func light_on():
	lights_on_count += 1
	lights_on_count = clamp(lights_on_count, 0, 4)
	# print("Luzes acesas: ", lights_on_count)

func light_off():
	lights_on_count -= 1
	lights_on_count = clamp(lights_on_count, 0, 4)
	# print("Luzes acesas: ", lights_on_count)


func _on_game_controller_light_toggled(light_number: int, is_on: bool) -> void:
	if is_on:
		light_on()
	else:
		light_off()

func _on_hit_battery():
	update_energy(hit_reduction_amount)
