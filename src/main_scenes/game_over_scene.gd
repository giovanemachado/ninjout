extends Node
@onready var game_title: Label = $CanvasLayer/Control/VBoxContainer/GameTitle

func _ready():
	if game_title:
		game_title.text = "game over with: " + str(Globals.get_score()) + "kw/h" 
		
func _input(event):
	if event.is_action_pressed("light1"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
	elif event.is_action_pressed("light2"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
	elif event.is_action_pressed("light3"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
	elif event.is_action_pressed("light4"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)

func _on_play_pressed() -> void:
	SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
