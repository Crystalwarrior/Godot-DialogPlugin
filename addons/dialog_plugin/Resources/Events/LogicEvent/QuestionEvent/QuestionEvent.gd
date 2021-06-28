tool
# class_name <your_event_class_name_here>
extends "res://addons/dialog_plugin/Resources/EventResource.gd"

# - - - - - - - - - -
# Base class for all dialog events
# - - - - - - - - - -
# You can read more about this class in the Documentation
# https://anidemdex.gitbook.io/godot-dialog-plugin/documentation/resource-class/class_dialog-event-resource

var options:Dictionary = {}

var OptionsManager:DialogOptionsManager

var _old_timeline:DialogTimelineResource

func _init() -> void:
	# Uncomment resource_name line if you want to display a name in the editor
	resource_name = "Question"

	# Uncomment event_editor_scene_path line and replace it with your custom DialogEditorEventNode scene
	#event_editor_scene_path = "res://path/to/your/editor/node/scene.tscn"

	# Uncomment skip line if you want your event jump directly to next event 
	# at finish or not (false by default)
	#skip = false


func execute(caller:DialogBaseNode) -> void:
	
	caller.visible = true
	
	OptionsManager = caller.OptionsContainer
	
	if not OptionsManager:
		finish(true)
		return
	
	for option in options.keys():
		OptionsManager.add_option(option)
	
	OptionsManager.connect("option_selected", self, "_on_option_selected")


func _on_option_selected(option) -> void:
	var timeline:DialogTimelineResource = options.get(option, null)
	_old_timeline = _caller.timeline
	
	if timeline and not(timeline.events.empty()):
		timeline.current_event = -1
		timeline.connect("timeline_ended", self, "_on_Timeline_ended", [], CONNECT_ONESHOT)
		_caller.timeline = timeline
	
	finish(true)


func _on_Timeline_ended() -> void:
	_caller.timeline = _old_timeline
	_old_timeline = null
	finish(true)