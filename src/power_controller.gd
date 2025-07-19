extends Node

class_name PowerController
@onready var energy_timer: Timer = $EnergyTimer
@export var max_energy: int = 10

var current_energy: int
var lights_on_count: int = 0

signal energy_depleted
signal energy_updated(new_energy: int)

func _ready():
	current_energy = max_energy

	energy_timer.wait_time = 1.0
	energy_timer.timeout.connect(_on_energy_timer_timeout)
	energy_timer.start()

	energy_updated.emit(current_energy)

func _on_energy_timer_timeout():
	var energy_consumption = 1 + lights_on_count

	update_energy(-energy_consumption)

func update_energy(amount: int):
	if amount == 0:
		return
		
	var old_energy = current_energy
	current_energy += amount
	current_energy = clamp(current_energy, 0, max_energy)

	if old_energy != current_energy:
		energy_updated.emit(current_energy)

	if current_energy <= 0:
		energy_depleted.emit()
		print("Energia esgotada!")

func light_on():
	lights_on_count += 1
	lights_on_count = clamp(lights_on_count, 0, 4)
	print("Luzes acesas: ", lights_on_count)

func light_off():
	lights_on_count -= 1
	lights_on_count = clamp(lights_on_count, 0, 4)
	print("Luzes acesas: ", lights_on_count)
