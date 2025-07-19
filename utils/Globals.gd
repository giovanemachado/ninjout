extends Node

var debug_mode = false
var score: int = 0

#enum ExampleEnum {A, B}
#
#const EXAMPLE_CONST = 'const value'
#
#const EXAMPLE_CONST_OBJECT = {
#		PROPERTY1 = 'preperty 1',
#		PROPERTY2 = 'property 2',
#}

# To use:
# Globals.EXAMPLE_CONST


func add_score(points: int):
    score += points
    score = max(score, 0)

func reset_score():
    score = 0

func get_score() -> int:
    return score
