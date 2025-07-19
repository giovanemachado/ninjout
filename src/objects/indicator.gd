extends Node3D

@export var mesh_node: MeshInstance3D
@export var blink_speed: float = 2.0
@export var emission_intensity: float = 2.0

var material: StandardMaterial3D
var original_emission: Color
var original_emission_energy: float
var is_glowing: bool = false
var blink_tween: Tween

func _ready():
	if mesh_node:
		setup_material()

func setup_material():
	var original_material = mesh_node.get_surface_override_material(0)
	if not original_material:
		original_material = mesh_node.mesh.surface_get_material(0)

	if original_material and original_material is StandardMaterial3D:
		material = original_material.duplicate()
		mesh_node.set_surface_override_material(0, material)

		original_emission = material.emission
		original_emission_energy = material.emission_energy_multiplier

		material.emission_enabled = true

func toggle_glow():
	if is_glowing:
		stop_glow()
	else:
		start_glow()

func start_glow():
	if not material:
		return

	is_glowing = true

	if blink_tween:
		blink_tween.kill()

	material.emission = Color.RED
	material.emission_energy = emission_intensity

	blink_tween = create_tween()
	blink_tween.set_loops()

	blink_tween.tween_property(material, "emission_energy_multiplier", 0.1, 1.0 / blink_speed)
	blink_tween.tween_property(material, "emission_energy_multiplier", emission_intensity, 1.0 / blink_speed)

func stop_glow():
	if not material:
		return

	is_glowing = false

	if blink_tween:
		blink_tween.kill()
		blink_tween = null

	material.emission = original_emission
	material.emission_energy_multiplier = original_emission_energy

func set_mesh(new_mesh: MeshInstance3D):
	mesh_node = new_mesh
	if mesh_node:
		setup_material()
