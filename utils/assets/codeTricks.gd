extends Node

# THIS SCRIPT IS NOT RUNNING AND SHOULD NOT RUN

# Useful to keep stuff in their place
class_name codeTricks

# This will be shared for all instances of this class, as a single value. Pretty good for counting stuff.
static var staticValue

# Get the whole tree, good!
var tree = get_tree()

# drag an drop something from the tree after = and it will get the name correctly
@onready var something = $Something

# right click on node in the tree and there is an option to this become unique
@onready var somethingUniqueInThisTree = %SomethingUniqueInThisTree

# Create enums
enum ExampleEnum {A, B}

# Create dictionaries
const EXAMPLE_CONST_OBJECT = { 
		PROPERTY1 = 'preperty 1', 
		PROPERTY2 = 'property 2',
}

func _init():
	# Groups can be set via code or UI
	add_to_group("guards")
	
	var all_guards_in_group = get_tree().get_nodes_in_group("guards")
	
	# A command to all members in that group
	get_tree().call_group("guards", "enter_alert_mode")
	
	# Check if node is in group
	var is_in_group = get_tree().is_in_group("group")
	
	# Create inline await with timing
	await get_tree().create_timer(10).timeout
	
	# Throw errors (from doc)
	# Imagine we always want speed to be between 0 and 20.
	var speed = -10
	assert(speed < 20) # True, the program will continue.
	assert(speed >= 0) # False, the program will stop.
	assert(speed >= 0 and speed < 20) # You can also combine the two conditional statements in one check.
	assert(speed < 20, "the speed limit is 20") # Show a message.

# Signals
func _ready():
	var timer = get_node("Timer")
	# Connect to signal
	timer.timeout.connect(_on_timer_timeout)

func _exit_tree():
	var timer = get_node("Timer")
	# disconnecting
	timer.timeout.disconnect(_on_timer_timeout)

signal some_signal

func _on_timer_timeout():
	print('do stuff')
	# emit signal
	some_signal.emit()
	# emit signal with params
	some_signal.emit('param1', 'param2')
	
