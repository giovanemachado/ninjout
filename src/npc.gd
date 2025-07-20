extends CharacterBody3D

class_name NPC

@export var npcs_controller: NPCsController

@export var speed: float = 1.5
@export var running_speed: float = 6.0

@export var rotation_speed: float = 10.0
@onready var spot: Sprite3D = $Spot

var has_reached_target = false
var has_returned = false
var current_row = 0
var current_index = 0
var current_sector = 0

var target_position: Vector3
var is_moving = false
var body: Node3D
enum NPCType {ENEMY, GOOD_BOT}
var type: NPCType
@onready var lantern: SpotLight3D = $Lantern

var is_running_away = false

func _ready():
	await get_tree().create_timer(0.3).timeout
	turn_on_physics()
	get_next_position()

	if type == NPCType.ENEMY:
		lantern.light_energy = 0
	else:
		lantern.light_energy = 10

func _process(_delta: float):
	if is_moving == false && has_returned:
		queue_free()

	if is_running_away:
		speed = running_speed

func _physics_process(delta):
	if is_moving and not has_returned:
		move_towards_target(delta)

func turn_on_physics():
	collision_layer = 1

func get_next_position():
	if has_reached_target && type == NPCType.ENEMY:
		is_running_away = true

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
		#print("NPC indo para row: ", current_row, ", index: ", current_index)

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

func caught_on_light():
	var tween = create_tween()
	tween.tween_property(spot, "modulate:a", 1.0, 0.2)
