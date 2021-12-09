tool
extends Event


# Dialog
var display_name:String = "" setget set_display_name
var translation_key:String = "" setget set_translation_key
var text:String = "" setget set_text
export(bool) var continue_previous_text:bool = false setget enable_text_ammend
export(float, 0.01, 1.0, 0.01) var text_speed:float = 0.04 setget set_text_speed


# Audio
var audio_same_as_character:bool = true setget use_character_sounds
var audio_sounds:Array = [] setget set_audio_sounds
var audio_loop:bool = false setget set_audio_loop
var audio_force:bool = false setget force_audio
var audio_bus:String = "Master" setget set_audio_bus

var character:Character = null setget set_character

var sound_generator:AudioStreamPlayer = null

var _dialog_manager:DialogManager = null
var _generator := RandomNumberGenerator.new()
var _already_played:bool = false

func set_display_name(value:String) -> void:
	display_name = value
	emit_changed()
	property_list_changed_notify()


func set_text(value:String) -> void:
	text = value
	emit_changed()
	property_list_changed_notify()


func set_text_speed(value:float) -> void:
	text_speed = value
	emit_changed()


func enable_text_ammend(value:bool) -> void:
	continue_previous_text = value
	emit_changed()
	property_list_changed_notify()


func set_translation_key(value:String) -> void:
	translation_key = value
	emit_changed()
	property_list_changed_notify()


func set_character(value:Character) -> void:
	if value != character:
		character = value
		emit_changed()
	
		if character:
			set_deferred("display_name", character.display_name)
	
	property_list_changed_notify()

func use_character_sounds(value:bool) -> void:
	audio_same_as_character = value
	emit_changed()
	property_list_changed_notify()


func set_audio_sounds(value:Array) -> void:
	audio_sounds = value.duplicate()
	emit_changed()
	property_list_changed_notify()


func set_audio_loop(value:bool) -> void:
	audio_loop = value
	emit_changed()
	property_list_changed_notify()


func force_audio(value:bool) -> void:
	audio_force = value
	emit_changed()
	property_list_changed_notify()


func set_audio_bus(value:String) -> void:
	audio_bus = value
	emit_changed()
	property_list_changed_notify()


##########
## Private
##########

func _show_text() -> void:
	event_node.show()
	_dialog_manager.display_text()


func _prepare_text_to_show() -> void:
	_dialog_manager.show()

	var final_text := ""

	if translation_key != "":
		final_text = tr(translation_key)
	else:
		final_text = text

	if continue_previous_text:
		_dialog_manager.add_text(final_text)
	else:
		_dialog_manager.set_text(final_text)
	
	_dialog_manager.text_speed = text_speed


func _configure_display_name() -> void:
	var name_node:Label = event_node.name_node
	if not is_instance_valid(name_node):
		return
	
	name_node.hide()
	if display_name != "":
		name_node.show()

	if character:
		name_node.add_color_override("font_color", character.color)
	
	name_node.text = display_name


func _configure_sound_generator() -> void:
	if audio_sounds.empty():
		# No sounds to play, no need to do anything
		return
	
	_dialog_manager.connect("character_displayed", self, "_on_character_displayed", [], CONNECT_DEFERRED)

	if not is_instance_valid(sound_generator):
		sound_generator = AudioStreamPlayer.new()
	
	if not sound_generator.is_inside_tree():
		event_node.get_tree().root.call_deferred("add_child",sound_generator)
	
	sound_generator.bus = audio_bus


func _get_stream() -> AudioStream:
	var _sounds:Array
	var _stream:AudioStream
	
	if audio_same_as_character and character:
		_sounds = character.blip_sounds
	else:
		_sounds = audio_sounds
	var _limit = max(_sounds.size()-1, 0)
	_stream = _sounds[_generator.randi_range(0, _limit)] as AudioStream
	
	return _stream


func _blip() -> void:
	if not sound_generator.is_playing() or audio_force:
		sound_generator.stop()
		sound_generator.stream = _get_stream()
		sound_generator.play()


func _on_character_displayed(character:String) -> void:
	if not _already_played:
		_blip()
		_already_played = !audio_loop


func _on_text_displayed() -> void:

	if is_instance_valid(sound_generator):
		sound_generator.queue_free()
	
	if _dialog_manager.is_connected("character_displayed", self, "_on_character_displayed"):
		_dialog_manager.disconnect("character_displayed", self, "_on_character_displayed")
	
	finish()


func _execute() -> void:
	event_node = event_node as DialogNode
	if not is_instance_valid(event_node):
		finish()
		return
	
	_dialog_manager = event_node.dialog_manager as DialogManager
	if not is_instance_valid(_dialog_manager):
		finish()
		return
	
	_dialog_manager.connect("text_displayed", self, "_on_text_displayed", [], CONNECT_ONESHOT)
	
	_generator.randomize()

	_configure_display_name()
	_configure_sound_generator()
	_prepare_text_to_show()
	_show_text()


func _get_property_list() -> Array:
	var p := []
	var default_usage := PROPERTY_USAGE_DEFAULT|PROPERTY_USAGE_SCRIPT_VARIABLE
	
	# Text
	
	p.append({"type":TYPE_STRING, "name":"display_name", "usage":default_usage, "hint":PROPERTY_HINT_PLACEHOLDER_TEXT})
	p.append({"type":TYPE_STRING, "name":"text", "usage":default_usage, "hint":PROPERTY_HINT_MULTILINE_TEXT})
	
	# Audio
	p.append({"type":TYPE_NIL, "name":"Audio", "usage":PROPERTY_USAGE_GROUP, "hint_string":"audio_"})
	
	p.append({"type":TYPE_BOOL, "name":"audio_same_as_character", "usage":default_usage})
	p.append({"type":TYPE_ARRAY, "name":"audio_sounds", "hint":24, "usage":default_usage, "hint_string":"17/17:AudioStream"})
	p.append({"type":TYPE_BOOL, "name":"audio_loop", "usage":default_usage})
	p.append({"type":TYPE_BOOL, "name":"audio_force", "usage":default_usage})
	
	var audio_buses:String = ""
	for bus_idx in AudioServer.bus_count:
		audio_buses += AudioServer.get_bus_name(bus_idx)
	
	p.append({"type":TYPE_STRING, "name":"audio_bus", "usage":default_usage, "hint":PROPERTY_HINT_ENUM, "hint_string":audio_buses})
	
	
	p.append({"type":TYPE_STRING, "name":"translation_key", "usage":default_usage, "hint":PROPERTY_HINT_PLACEHOLDER_TEXT, "hint_string":"Same as text"})
	
	p.append({"type":TYPE_OBJECT, "name":"character", "usage":default_usage, "hint":PROPERTY_HINT_RESOURCE_TYPE, "hint_string":"Resource"})
	return p


func property_can_revert(property:String) -> bool:
	var registered_properties = []
	for p in get_property_list():
		if p["usage"] & 8199 == PROPERTY_USAGE_SCRIPT_VARIABLE:
			registered_properties.append(p["name"])
	return property in registered_properties


func property_get_revert(property:String):
	# get_property_default_value() doesn't return the default value of the script
	# so, return must be done manually
	# TODO: Open an issue about this
	# var default_value = (get_script() as Script).get_property_default_value(property)
	
	match property:
		"audio_same_as_character":
			return true
		"audio_sounds":
			return [].duplicate()
		"audio_loop", "audio_force":
			return false
		"audio_bus":
			return "Master"
		"translation_key", "text", "display_name":
			return ""


func _init() -> void:
	event_color = Color("2892D7")
	event_name = "Text"
	event_icon = load("res://addons/textalog/assets/icons/event_icons/text_bubble.png") as Texture
	event_preview_string = "{display_name}: {text}"

	audio_sounds = []
