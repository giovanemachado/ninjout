extends Node

class_name NPCsController

@export var sector_0_row_0: Array[Marker3D]
@export var sector_0_row_1: Array[Marker3D]
@export var sector_0_row_2: Array[Marker3D]
@export var sector_0_row_3: Array[Marker3D]

@onready var sectors: Array[Array] = [
	[sector_0_row_0, sector_0_row_1, sector_0_row_2, sector_0_row_3], # Setor 0
	[[], [], [], []], # Setor 1
	[[], [], [], []], # Setor 2
	[[], [], [], []] # Setor 3
]

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
