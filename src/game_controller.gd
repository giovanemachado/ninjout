extends Node

class_name GameController

@onready var debug_menu: Control = %DebugMenu

func _input(event):
	if event.is_action_pressed("open_menu"):
		open_menu()

func open_menu():
	if debug_menu.is_visible():
		debug_menu.hide()
	else:
		debug_menu.show()
	
func quit_game():
	get_tree().quit()

func _on_quit_pressed() -> void:
	quit_game()
