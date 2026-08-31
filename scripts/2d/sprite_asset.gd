extends RefCounted

class_name SpriteAsset


var base_path := ""
var sheet: Texture2D = null
var cols := 8
var rows := 1
var anims: Dictionary = {}
var source := "FALLBACK"

const CELL := 16

static var _stitch_cache: Dictionary = {}

static func create(p_base_path: String, p_anims: Dictionary) -> SpriteAsset:
	var a := SpriteAsset.new()
	a.base_path = p_base_path
	a.anims = p_anims
	a.sheet = _resolve_sheet(p_base_path, p_anims)
	if ResourceLoader.exists(p_base_path + "_sheet.png"):
		a.source = "CANONICAL"
	elif a.sheet != null:
		a.source = "STITCHED"
	if a.sheet != null:
		a.cols = maxi(1, a.sheet.get_width() / CELL)
		a.rows = maxi(1, a.sheet.get_height() / CELL)
	return a


static func _resolve_sheet(base: String, anims: Dictionary) -> Texture2D:
	var direct := base + "_sheet.png"
	if ResourceLoader.exists(direct):
		var tex: Texture2D = load(direct)
		if _sheet_valid(tex, anims):
			return tex
		push_warning("[SpriteAsset] %s has invalid layout — using fallback" % direct)
	return _stitch_per_anim(base, anims)

static func _sheet_valid(tex: Texture2D, anims: Dictionary) -> bool:
	if tex == null:
		return false
	var w := tex.get_width()
	var h := tex.get_height()
	if w < CELL or h < CELL or w % CELL != 0 or h % CELL != 0:
		return false
	var cols := w / CELL
	var need_rows := 1
	for anim_name in anims.keys():
		var a: Dictionary = anims[anim_name]
		if int(a.get("frames", 1)) > cols:
			return false
		need_rows = maxi(need_rows, int(a.get("row", 0)) + 1)
	return h / CELL >= need_rows

static func _anim_sheet_candidates(base: String, anim_name: String) -> Array:
	var low := anim_name.to_lower()
	return [
		"%s_%s_sheet.png" % [base, low],
		"%s/%s_%s_sheet.png" % [base, base.get_file(), low],
	]

static func _stitch_per_anim(base: String, anims: Dictionary) -> Texture2D:
	if _stitch_cache.has(base):
		return _stitch_cache[base]
	var found := {}
	var max_row := 1
	for anim_name in anims.keys():
		for cand in _anim_sheet_candidates(base, anim_name):
			if ResourceLoader.exists(cand):
				var tex: Texture2D = load(cand)
				var img: Image = tex.get_image()
				if img != null and img.is_compressed():
					img.decompress()
				if img != null and img.get_width() >= CELL \
						and img.get_height() == CELL:
					found[anim_name] = img
					max_row = maxi(max_row, int(anims[anim_name].get("row", 0)) + 1)
				break
	if found.is_empty():
		return null
	var atlas := Image.create(8 * CELL, max_row * CELL, false, Image.FORMAT_RGBA8)
	atlas.fill(Color(0, 0, 0, 0))
	for anim_name in found.keys():
		var row := int(anims[anim_name].get("row", 0))
		var src: Image = found[anim_name]
		var frames := mini(int(anims[anim_name].get("frames", 1)),
			int(src.get_width() / CELL))
		for f in range(frames):
			atlas.blit_rect(src, Rect2i(f * CELL, 0, CELL, CELL),
				Vector2i(f * CELL, row * CELL))
	var tex := ImageTexture.create_from_image(atlas)
	_stitch_cache[base] = tex
	return tex

func has_anim(anim_name: String) -> bool:
	return anims.has(anim_name)

func anim_names() -> Array:
	return anims.keys()

func info(anim_name: String) -> Dictionary:
	return anims.get(anim_name, {})

func is_animated() -> bool:
	return sheet != null

func fallback_tex() -> Texture2D:
	return SpriteLib2D.tex(base_path + ".png")
