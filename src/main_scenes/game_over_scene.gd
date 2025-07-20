extends Node
@onready var game_title: Label = $CanvasLayer/Control/VBoxContainer/GameTitle
@onready var delay: Timer = $Delay

var can_input: bool = false

func _ready():
	if game_title:
		game_title.text = "game over with: " + str(Globals.get_score()) + "kw/h"

	delay.wait_time = 1.0
	delay.one_shot = true
	delay.timeout.connect(_on_delay_timeout)
	delay.start()

func _input(event):
	if not can_input:
		return

	if event.is_action_pressed("light1"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
	elif event.is_action_pressed("light2"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
	elif event.is_action_pressed("light3"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
	elif event.is_action_pressed("light4"):
		SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)

func _on_delay_timeout():
	can_input = true

func _on_play_pressed() -> void:
	if not can_input:
		return
	SceneLoader.scene_transition(SceneLoader.SCENES.MAIN)
