extends DialogBaseNode

# TODO: Mejora este mensaje de error
func _ready() -> void:
	_set_nodes_default_values()
	push_error("If you can see this, you didn't replaced this script. Consider replacing it to make it work")
