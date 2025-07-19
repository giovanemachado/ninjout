extends Node


func _on_play_pressed() -> void:
	SceneLoader.scene_transition(SceneLoader.SCENES.MENU)
