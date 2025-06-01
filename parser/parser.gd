extends RefCounted

class_name DialogueParser

## Dialogue parser for json files generated with Snake River Dialogue Editor.
## Create a new one with .new, providing a dialogue dict (load w/ [JSON]) and a start key.
## In December schema these should all be START.

## The current node's key.
var current_node_key: StringName
## A [DialogueNode] object representing the current node.
var current_node: DialogueNode

## The dictionary of dialogue nodes. You generally shouldn't need to access this directly.
var dialogue: Dictionary

## Emitted when the dialogue reaches an end point (no outputs).
signal end_reached

func _init(_dialogue: Dictionary, start_node_key: StringName):
	assert(_dialogue.has(start_node_key), "Dialogue %s does not contain any node with key %s" % [dialogue, start_node_key])
	dialogue = _dialogue
	current_node_key = start_node_key
	current_node = DialogueNode.new(dialogue[start_node_key])

## Follow output path to next node, by default go to first output. Return new node or current node if failed.
func next(index: int = 0) -> DialogueNode:
	if index <= len(current_node.get_outputs()) - 1:
		goto(current_node.get_outputs()[index])
	else: push_warning("Invalid index %s in node with key %s" % [index, current_node_key])
	return(get_current())

## Set the current node by key.
func goto(node_key: StringName):
	current_node_key = node_key
	current_node = DialogueNode.new(dialogue[node_key])
	if current_node.get_outputs().is_empty(): end_reached.emit()

## Returns the current [DialogueNode] object.
func get_current() -> DialogueNode:
	return current_node

# These methods forward to the current node's method

## Returns the current dialogue node's fields dict
func get_fields() -> Dictionary:
	return current_node.get_fields()

## Returns the current dialogue node's outputs array
func get_outputs() -> Array:
	return current_node.get_outputs()

## Returns the field specified or false if it doesn't exist
func get_field(field: StringName):
	return current_node.get_field(field)

## Returns a node from the dialogue dictionary (equivalent to parser.dict[key]), or
## returns null
func get_node(key: StringName):
	if dialogue.has(key):
		return DialogueNode.new(dialogue[key])
	else: return null
