# FSM
Guide to use this FSM.

- Create a Node inside your object called StateManager.
- Attach a script to StateManager, extending from StateManager class. Called [ObjectName]StateManager.
- Create all states Nodes inside StateManager, each one with his own state name, like Idle, Run, Attack, etc.
- Attach a script for each Node, extending from State class. Called [ObjectName][StateName]State.

On ObjectNameStateManager script you can do:
```
func _ready():
	super._ready()
	
```

On ObjectNameState you can do:
```
func _on_enter():
	print("On Enter this state")
```

Attach a state to the initial state field on StateManager and be happy.
