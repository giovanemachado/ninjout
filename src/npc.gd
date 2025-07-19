extends CharacterBody3D

class_name NPC

@export var npcs_controller: NPCsController

@export var speed: float = 3.0
@export var rotation_speed: float = 10.0

var has_reached_target = false
var has_returned = false
var current_row = 0
var current_index = 0
var current_sector = 0

var target_position: Vector3
var is_moving = false

func _ready():
	await get_tree().create_timer(0.3).timeout
	get_next_position()

func _physics_process(delta):
	if is_moving and not has_returned:
		move_towards_target(delta)

func get_next_position():
	if has_returned:
		is_moving = false
		return

	var next_data = npcs_controller.get_next_position(
		self,
		current_sector,
		current_row,
		current_index,
		has_reached_target
	)

	if next_data and next_data.has("position"):
		current_row = next_data.row
		current_index = next_data.index
		target_position = next_data.position

		is_moving = true
		print("NPC indo para row: ", current_row, ", index: ", current_index)

func move_towards_target(delta):
	if not is_moving:
		return

	var direction = (target_position - global_position).normalized()
	velocity = direction * speed

	if direction.length() > 0.1:
		var look_direction = Vector3(direction.x, 0, direction.z)
		if look_direction.length() > 0.1:
			var target_rotation = atan2(look_direction.x, look_direction.z)
			var current_rotation = rotation.y

			var new_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
			rotation.y = new_rotation

	if global_position.distance_to(target_position) < 0.5:
		is_moving = false
		velocity = Vector3.ZERO

		get_next_position()

	move_and_slide()
