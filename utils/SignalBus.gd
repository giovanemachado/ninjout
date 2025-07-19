extends Node

# signal game_over
signal hit_battery(is_enemy: bool)


# To connect:
# SignalBus.game_over.connect(_on_game_over)

# To emit:
# SignalBus.emit_signal("game_over")
