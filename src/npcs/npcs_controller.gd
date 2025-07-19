extends Node

class_name NPCsController

@export var spawn_interval: float = 1.0
var spawn_npcs: Array[Dictionary] = [
	{
		weight = 4,
		scene = preload("res://src/npcs/npc.tscn"),
		body = preload("res://src/npcs/body_0.tscn"),
		type = NPC.NPCType.ENEMY
	},
	{
		weight = 6,
		scene = preload("res://src/npcs/npc.tscn"),
		body = preload("res://src/npcs/body_1.tscn"),
		type = NPC.NPCType.GOOD_BOT
	}
]

@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawned_container: Node3D = $Spawned

@export_group("Setor 0")
@export var sector_0_row_0: Array[Marker3D]
@export var sector_0_row_1: Array[Marker3D]
@export var sector_0_row_2: Array[Marker3D]
@export var sector_0_row_3: Array[Marker3D]

@export_group("Setor 1")
@export var sector_1_row_0: Array[Marker3D]
@export var sector_1_row_1: Array[Marker3D]
@export var sector_1_row_2: Array[Marker3D]
@export var sector_1_row_3: Array[Marker3D]

@export_group("Setor 2")
@export var sector_2_row_0: Array[Marker3D]
@export var sector_2_row_1: Array[Marker3D]
@export var sector_2_row_2: Array[Marker3D]
@export var sector_2_row_3: Array[Marker3D]

@export_group("Setor 3")
@export var sector_3_row_0: Array[Marker3D]
@export var sector_3_row_1: Array[Marker3D]
@export var sector_3_row_2: Array[Marker3D]
@export var sector_3_row_3: Array[Marker3D]

@onready var sectors: Array[Array] = [
	[sector_0_row_0, sector_0_row_1, sector_0_row_2, sector_0_row_3],
	[sector_1_row_0, sector_1_row_1, sector_1_row_2, sector_1_row_3],
	[sector_2_row_0, sector_2_row_1, sector_2_row_2, sector_2_row_3],
	[sector_3_row_0, sector_3_row_1, sector_3_row_2, sector_3_row_3]
]

@onready var game_controller: GameController = %GameController


func _ready():
	setup_spawn_system()

func get_next_position(npc: NPC, sector: int, current_row: int, current_index: int, has_reached_target: bool):
	var invalid_sector = sector < 0 or sector >= sectors.size()
	assert(!invalid_sector, "Setor inválido:  " + str(sector));

	if not has_reached_target:
		if current_row == 3:
			var target_index = get_target_index(sector)
			if current_index != target_index:
				var target_marker = sectors[sector][3][target_index]
				return format_data(current_row, target_index, target_marker)
			else:
				var marker = get_data_from_position(sector, 3, current_index)
				npc.has_reached_target = true
				return marker
		else:
			return get_data_from_position(sector, current_row + 1, -1)

	if has_reached_target:
		if current_row == 0:
			var entry_index = 0
			if current_index != entry_index:
				var entry_marker = sectors[sector][0][entry_index]
				return format_data(current_row, entry_index, entry_marker)
			else:
				npc.has_returned = true
				return
		else:
			var marker = get_data_from_position(sector, current_row - 1, -1)
			return marker

func get_data_from_position(sector: int, row: int, exclude_index: int = -1) -> Dictionary:
	var invalidSector = sector >= sectors.size() or row >= sectors[sector].size()
	assert(!invalidSector, "Setor ou fileira inválidos: " + str(sector) + ", fileira " + str(row));

	var row_positions = sectors[sector][row]
	assert(!row_positions.is_empty(), "Fileira vazia no setor " + str(sector) + ", fileira " + str(row));

	var valid_indices = []
	for i in range(row_positions.size()):
		if i != exclude_index:
			valid_indices.append(i)

	var random_choice = valid_indices.pick_random()
	var selected_index = valid_indices[random_choice]
	var marker: Marker3D = row_positions[selected_index]
	return format_data(row, selected_index, marker)

func get_target_index(sector: int) -> int:
	if sector >= sectors.size():
		return 0

	var target_row = sectors[sector][3]
	return target_row.size() - 1

func format_data(row: int, index: int, marker: Marker3D):
	return {"row": row, "index": index, "position": marker.global_position}

func setup_spawn_system():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	#spawn_npc()

	# print("Sistema de spawn iniciado - Intervalo: ", spawn_interval, "s")

func _on_spawn_timer_timeout():
	spawn_npc()

func spawn_npc():
	var selected_npc_data = get_random_weighted_npc()
	var spawn = get_random_spawn_position()

	if spawn == null:
		return

	var npc_scene = selected_npc_data.scene as PackedScene
	var body_scene = selected_npc_data.body as PackedScene

	var npc_instance = npc_scene.instantiate()
	spawned_container.add_child(npc_instance)
	var body_instance = body_scene.instantiate()
	npc_instance.add_child(body_instance)

	npc_instance.type = selected_npc_data.type
	npc_instance.body = body_instance
	npc_instance.npcs_controller = self
	npc_instance.current_sector = spawn.sector
	npc_instance.global_position = spawn.position

	#print("NPC spawnado em: ", spawn.position, " Secotr: ", spawn.sector)

func get_random_weighted_npc() -> Dictionary:
	var total_weight = 0.0
	for npc_data in spawn_npcs:
		if npc_data.has("weight"):
			total_weight += npc_data.weight

	var random_value = randf() * total_weight
	var current_weight = 0.0

	for npc_data in spawn_npcs:
		current_weight += npc_data.weight
		if random_value < current_weight:
			return npc_data

	return spawn_npcs[0] if not spawn_npcs.is_empty() else {}

func get_random_spawn_position():
	var sectors_with_lights = game_controller.get_sectors_with_lights_on()
	var available_sectors: Array[int] = []

	for i in range(sectors.size()):
		if not sectors_with_lights.has(i):
			available_sectors.append(i)

	if available_sectors.is_empty():
		return null


	var random_sector_index = available_sectors.pick_random()
	var random_sector = sectors[random_sector_index]

	var first_row = random_sector[0]
	var random_marker = first_row.pick_random()

	return {position = random_marker.global_position, sector = random_sector_index}


func _on_game_controller_light_toggled(light_number: int, is_on: bool) -> void:
	if is_on:
		make_enemies_flee_from_sector(light_number)

func make_enemies_flee_from_sector(sector: int):
	for child in spawned_container.get_children():
		if child is NPC:
			var npc = child as NPC
			if npc.type == NPC.NPCType.ENEMY and npc.current_sector == (sector - 1):
				npc.has_reached_target = true
				npc.is_running_away = true
