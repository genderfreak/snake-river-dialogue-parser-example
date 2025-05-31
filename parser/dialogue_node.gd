extends RefCounted

class_name DialogueNode

var dictionary: Dictionary

## Create a new DialogueNode with data from _dictionary
## Does a sanity check to ensure the data is formatted properly
func _init(_dictionary: Dictionary):
	if _dictionary.is_empty(): push_error("Tried to create DialogueNode with empty dictionary!")
	if not _dictionary.has("fields"): push_error("Tried to create DialogueNode with dictionary with no fields key!")
	if not _dictionary.has("outputs"): push_error("Tried to create DialogueNode with dictionary with no outputs key!")
	dictionary = _dictionary

## Returns the fields dict
func get_fields() -> Dictionary:
	return dictionary["fields"]

## Returns the outputs array
func get_outputs() -> Array:
	return dictionary["outputs"]

## Returns the field specified or false if it doesn't exist
func get_field(field: StringName):
	if dictionary["fields"].has(field):
		return dictionary["fields"][field]
	else: 
		return false
