extends RefCounted

class_name SpriteLib2D


static var _cache: Dictionary = {}

static func tex(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	var t: Texture2D = null
	if ResourceLoader.exists(path):
		t = load(path)
	if t == null:
		t = _placeholder(path)
	_cache[path] = t
	return t

static func sheet(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return tex(path)
	return null

static func _placeholder(path: String) -> Texture2D:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var hue := float(abs(hash(path)) % 360) / 360.0
	img.fill(Color.from_hsv(hue, 0.5, 0.7))
	return ImageTexture.create_from_image(img)
