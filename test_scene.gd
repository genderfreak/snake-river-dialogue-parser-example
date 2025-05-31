extends HBoxContainer

var dialogue_parser: DialogueParser
var lua: LuaState


@export var text_edit: RichTextLabel
@export var button_box: Container
@export var next_button: BaseButton

@export_file var dialogue_file

var on_branch = false
var end_reached = false

func _ready():
	var dialogue: FileAccess = FileAccess.open(dialogue_file, FileAccess.READ)
	var json := JSON.new()
	var err = json.parse(dialogue.get_as_text())
	if err == OK: dialogue_parser = DialogueParser.new(json.data, "START")
	else: push_error("JSON parse error! %s" % json.get_error_message())
	next_button.pressed.connect(next)
	dialogue_parser.end_reached.connect(func(): end_reached = true)
	lua = LuaState.new()

func next():
	if on_branch or end_reached: return
	# same as if dialogue_parser.current_node.get_field
	if dialogue_parser.get_field("branch"):
		for child in button_box.get_children():
			child.queue_free()
		var index: int = 0 # goes up to track choice index
		var count: int = 0 # goes up if choice has content
		for key in dialogue_parser.get_outputs():
			var node = dialogue_parser.get_node(key)
			var show_choice = true
			if node.get_field("condition"):
				show_choice = false
				show_choice = lua.do_string(node.get_field("condition"))
			if show_choice and node.get_field("content"):
				var new_button = Button.new()
				new_button.text = node.get_field("content")
				new_button.pressed.connect(choose_choice.bind(index))
				button_box.add_child(new_button)
				count += 1
			index += 1
		return
	if dialogue_parser.get_field("lua"):
		var result = lua.do_string(dialogue_parser.get_field("lua"))
		if result is LuaError:
			printerr("Error in lua script: %s" % result)
		else:
			print(result)
			if result is int: # if result is returned and is an int, choose that output path
				dialogue_parser.next(result)
	dialogue_parser.next()
	print(dialogue_parser.current_node_key)
	# if no content, skip through (for lua, comments, branches etc)
	if not push_content():
		next()
		return
	# if next node has no content (branch), skip through to branch
	if dialogue_parser.get_node(dialogue_parser.get_outputs()[0]).get_fields().has("branch"):
		next()
		return

func choose_choice(index: int):
	for child in button_box.get_children():
		child.queue_free()
	dialogue_parser.next(index)
	push_content()
	next()

func push_content():
	if dialogue_parser.get_field("content"):
		text_edit.text = text_edit.text + dialogue_parser.get_field("content") + "\n"
		return true
	else: return false
