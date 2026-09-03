extends Node
## Temporary bootstrap scene root (removed after verification).
## Adds the foundation test driver as a root child so real scene changes
## never free the driver.

func _ready() -> void:
	call_deferred("_add_driver")

func _add_driver() -> void:
	var driver := preload("res://dev_driver.gd").new()
	get_tree().root.add_child(driver)
