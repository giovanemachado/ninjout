extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tree = get_tree()

var tween: Tween

const SCENES = {
	MENU = "res://src/main_scenes/menu_scene.tscn",
	MAIN = "res://src/main_scenes/main_scene.tscn",
	GAME_OVER = "res://src/main_scenes/game_over_scene.tscn"
}

func _ready():
	if Globals.debug_mode:
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)

func scene_transition(target: String):
	assert(!SCENES.has(target), "scene doesnt exist")
	
	const transition_animation = 'dissolve'
	animation_player.play(transition_animation)
	await animation_player.animation_finished
	
	tree.change_scene_to_file(target)
	
	animation_player.play_backwards(transition_animation)
	await animation_player.animation_finished
