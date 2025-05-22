extends RefCounted

class_name DialogueParser

var current_node_key: StringName
var current_node: Dictionary

var dialogue: Dictionary

signal end_reached

func _init(_dialogue: Dictionary, start_node_key: StringName):
	assert(_dialogue.has(start_node_key), "Dialogue %s does not contain any node with key %s" % [dialogue, start_node_key])
	dialogue = _dialogue
	current_node_key = start_node_key
	current_node = dialogue[start_node_key]

## Follow output path to next node, by default go to first output. Return new node or current node if failed
func next(index: int = 0) -> Dictionary:
	if index <= len(current_node["outputs"]) - 1:
		goto(current_node["outputs"][index])
	else: push_warning("Invalid index %s in node with key %s" % [index, current_node_key])
	return(get_current())

## Set the current node by key
func goto(node_key: StringName):
	current_node_key = node_key
	current_node = dialogue[node_key]
	if current_node["outputs"].is_empty(): end_reached.emit()

# Everything after this should be available to all nodes in the dictionary.
# Get node should return a node object with the methods below this.
# These methods should still exist within the base class, and forward to the child
# methods

## Returns the current dialogue node's dictionary (including fields, fields_meta, and outputs, among others)
func get_current() -> Dictionary:
	return current_node

# Returns the current dialogue node's fields dict
func get_fields() -> Dictionary:
	return current_node["fields"]

# Returns the current dialogue node's outputs array
func get_outputs() -> Array:
	return current_node["outputs"]

# Returns the field specified or false if it doesn't exist
func get_field(field: StringName):
	if current_node["fields"].has(field):
		return current_node["fields"][field]
	else: 
		return false

## Returns a node from the dialogue dictionary (equivalent to parser.dict[key]), or
## returns an empty dict
func get_node(key: StringName):
	if dialogue.has(key):
		return dialogue[key]
	else: return {}
