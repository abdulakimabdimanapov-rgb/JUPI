extends RefCounted
## Abstract aim source for the first-person controller.
##
## The player polls get_aim() every physics frame and applies the result
## to the body yaw / head pitch. That is why an aim source can be either
## incremental (mouse deltas) or absolute (e.g. a future hand-tracking
## pipeline that maps a hand position to a world aim direction).
##
## Contract for concrete sources:
## - get_aim()      -> (yaw, pitch) radians the camera should face.
##                    Pitch must already be clamped to +-PITCH_LIMIT_DEG.
## - handle_input() -> returns true when the event was consumed.
## - is_active()    -> whether aim input is currently live (e.g. the
##                    mouse is captured). Firing is only allowed while
##                    active.
## - activate()     -> bring the source up (e.g. capture the mouse).
## - set_aim()      -> explicit aim override (tests, calibration, or a
##                    future non-input source).

const PITCH_LIMIT_DEG := 89.0


func get_aim() -> Vector2:
	return Vector2.ZERO


func handle_input(_event: InputEvent) -> bool:
	return false


func is_active() -> bool:
	return false


func activate() -> void:
	pass


func set_aim(_yaw: float, _pitch: float) -> void:
	pass
