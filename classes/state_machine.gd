extends Node
class_name StateMachine

signal state_changed(new_state: State)

## The initial state the state_machine starts with.
@export var init_state: State
@export var cur_state: State:
	set(value):
		if cur_state: cur_state.transition_away()
		cur_state = value
		cur_state.transition_to()
## The name of the current state.
@export var cur_state_name: String:
	set(value):
		cur_state_name = value
		cur_state = get_state_with_name(value)
## All states the state machine is a parent of.[br]
## Will only be refreshed in the [method _ready] func.
@export var all_states: Array[State] = []


func _ready() -> void:
	for child: Node in self.get_children():
		if child is State:
			all_states.append(child)


func switch_state(state_name: String) -> bool:
	var new_state: State = get_state_with_name(state_name)
	if new_state:
		cur_state_name = new_state.name
		state_changed.emit(new_state)
		return true
	push_error("State '%s' not found!" % state_name)
	return false


func equals_cur_state(value: String) -> bool:
	return cur_state_name.to_lower() == value.to_lower()


## Returns the [State] with the given [param state_name]. (Case is ignored)[br]
## Returns null if [param state_name] is not valid.
func get_state_with_name(state_name: String = cur_state_name) -> State:
	for state: State in all_states:
		if state.name.to_lower() == state_name.to_lower():
			return state
	return null


func _update_process() -> void:
	if cur_state: cur_state._update_process()

func _update_physics() -> void:
	if cur_state: cur_state._update_physics()
