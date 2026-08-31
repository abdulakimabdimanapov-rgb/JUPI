extends Node

class_name AnimationController2D


signal anim_finished(anim_name: String)

var sprite: Sprite2D = null
var asset: SpriteAsset = null
var current := ""

var _t := 0.0
var _frame := 0
var _finished_emitted := false

func setup(p_sprite: Sprite2D, p_asset: SpriteAsset) -> void:
	sprite = p_sprite
	asset = p_asset
	_apply_frame(0)

func has_anim(anim_name: String) -> bool:
	return asset != null and asset.has_anim(anim_name)

func play(anim_name: String, restart: bool = false) -> void:
	if asset == null:
		return
	if not asset.has_anim(anim_name):
		push_warning("[AnimationController2D] unknown anim '%s' on %s" % [anim_name, asset.base_path])
		return
	if current == anim_name and not restart:
		return
	current = anim_name
	_t = 0.0
	_frame = 0
	_finished_emitted = false
	_apply_frame(0)

func _process(delta: float) -> void:
	if sprite == null or asset == null or current == "":
		return
	var info := asset.info(current)
	if info.is_empty():
		return
	var fps: float = maxf(float(info.get("fps", 6.0)), 0.1)
	var frames: int = maxi(int(info.get("frames", 1)), 1)
	var looping: bool = bool(info.get("loop", true))
	_t += delta
	if looping:
		_frame = int(_t * fps) % frames
	else:
		_frame = mini(int(_t * fps), frames - 1)
		if _frame >= frames - 1 and not _finished_emitted:
			_finished_emitted = true
			anim_finished.emit(current)
	_apply_frame(_frame)

func _apply_frame(index: int) -> void:
	if sprite == null:
		return
	if asset.is_animated():
		var info := asset.info(current)
		var row := int(info.get("row", 0)) if not info.is_empty() else 0
		sprite.texture = asset.sheet
		sprite.hframes = asset.cols
		sprite.vframes = asset.rows
		sprite.frame = clampi(row * asset.cols + index % asset.cols, 0, asset.cols * asset.rows - 1)
	else:
		sprite.texture = asset.fallback_tex()
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame = 0
