tool
# class_name <your_event_class_name_here>
extends DialogTextEvent

func _init() -> void:
	# Uncomment resource_name line if you want to display a name in the editor
	resource_name = "TextWithAudio"

	# Uncomment event_editor_scene_path line and replace it with your custom DialogEditorEventNode scene
	#event_editor_scene_path = "res://path/to/your/editor/node/scene.tscn"

	# Uncomment skip line if you want your event jump directly to next event 
	# at finish or not (false by default)
	#skip = false


func execute(caller:DialogBaseNode) -> void:

	# There goes your event code.

	# Notify that you end this event
	finish()