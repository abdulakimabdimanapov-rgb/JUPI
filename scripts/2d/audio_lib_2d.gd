extends RefCounted
class_name AudioLib2D


const DIR := "res://assets/2d/audio"
const POOL_SIZE := 10

const CUES := {
	"dodge":        [350.0, 0.12, "whoosh"],
	"clock_open":   [440.0, 0.30, "chime"],
	"attack_swing": [380.0, 0.15, "whoosh"],
	"hurt":         [180.0, 0.14, "thud"],
	"death":        [100.0, 0.60, "thud"],
	"respawn":      [440.0, 0.35, "whoosh"],
	"time_travel":  [220.0, 0.60, "whoosh"],
	"success":      [500.0, 0.80, "chime"],
	"door":         [200.0, 0.18, "thud"],
	"enemy_alert":  [880.0, 0.15, "buzz"],
	"detect":       [740.0, 0.15, "buzz"],
	"chase":        [980.0, 0.25, "buzz"],
	"lost":         [420.0, 0.20, "sine"],
	"alarm":        [240.0, 0.50, "buzz"],
	"step":         [140.0, 0.06, "thud"],
	"contract":     [300.0, 0.35, "chime"],
	"equip":        [600.0, 0.10, "chime"],
	"purchase":     [450.0, 0.20, "chime"],
	"purchase_fail":[200.0, 0.15, "buzz"],
	"era_arrive":   [330.0, 0.50, "chime"],
	"era_travel":   [180.0, 0.70, "whoosh"],
	"unlock":       [550.0, 0.60, "chime"],
	"boss_intro":      [150.0, 0.80, "thud"],
	"boss_phase":      [320.0, 0.30, "buzz"],
	"boss_defeated":   [600.0, 1.00, "chime"],
	"paradox_trigger": [120.0, 0.70, "whoosh"],
	"timeline_view":   [380.0, 0.40, "sine"],
	# combo system
	"combo_hit_1":     [420.0, 0.08, "thud"],
	"combo_hit_2":     [560.0, 0.10, "thud"],
	"combo_hit_3":     [780.0, 0.15, "buzz"],
	"combo_finisher":  [340.0, 0.30, "whoosh"],
	"dash_attack":     [600.0, 0.12, "whoosh"],
	# status effects
	"status_poison":   [220.0, 0.18, "buzz"],
	"status_burn":     [300.0, 0.20, "buzz"],
	"status_freeze":   [880.0, 0.25, "chime"],
	"status_bleed":    [160.0, 0.14, "thud"],
	"status_slow":     [350.0, 0.15, "sine"],
	"status_tick":     [180.0, 0.06, "sine"],
	"status_expire":   [440.0, 0.12, "sine"],
	"pickup":          [520.0, 0.15, "chime"],
	# menu / UI
	"menu_navigate":   [680.0, 0.06, "sine"],
	"menu_select":     [880.0, 0.15, "chime"],
	"menu_back":       [320.0, 0.12, "whoosh"],
	"menu_open":       [520.0, 0.20, "chime"],
}

static var _pool: Array = []
static var _blip_cache: Dictionary = {}
static var _file_cache: Dictionary = {}
static var _loop_players: Dictionary = {}

static func has_file(cue: String) -> bool:
	for ext in ["ogg", "wav"]:
		if ResourceLoader.exists("%s/%s.%s" % [DIR, cue, ext]):
			return true
	return false

static func loop(cue: String, vol_db := -14.0) -> void:
	if _loop_players.has(cue) and is_instance_valid(_loop_players[cue]):
		return
	if not has_file(cue):
		return
	var p := _player()
	if p == null:
		return
	var path := "%s/%s.ogg" % [DIR, cue] \
			if ResourceLoader.exists("%s/%s.ogg" % [DIR, cue]) \
			else "%s/%s.wav" % [DIR, cue]
	var stream: AudioStream = load(path)
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	p.stream = stream
	p.volume_db = vol_db
	p.pitch_scale = 1.0
	p.play()
	_loop_players[cue] = p

static func stop_loop(cue: String) -> void:
	if _loop_players.has(cue):
		var p: AudioStreamPlayer = _loop_players[cue]
		if is_instance_valid(p):
			p.stop()
		_loop_players.erase(cue)

static func stop_all() -> void:
	for cue in _loop_players.keys():
		var p: AudioStreamPlayer = _loop_players[cue]
		if is_instance_valid(p):
			p.stop()
			p.queue_free()
	_loop_players.clear()
	for p in _pool:
		if is_instance_valid(p):
			p.stop()
			p.queue_free()
	_pool.clear()

static func set_loop_vol(cue: String, vol_db: float) -> void:
	if _loop_players.has(cue) and is_instance_valid(_loop_players[cue]):
		_loop_players[cue].volume_db = vol_db

static func play(cue: String, vol_db := -8.0) -> void:
	var stream := _stream_for(cue)
	if stream == null:
		return
	var p := _player()
	if p == null:
		return
	p.stream = stream
	p.volume_db = vol_db
	p.pitch_scale = randf_range(0.94, 1.06)
	p.play()

static func _stream_for(cue: String) -> AudioStream:
	for ext in ["ogg", "wav"]:
		var path := "%s/%s.%s" % [DIR, cue, ext]
		if ResourceLoader.exists(path):
			if not _file_cache.has(path):
				_file_cache[path] = load(path)
			return _file_cache[path]
	return _blip(cue)

static func _player() -> AudioStreamPlayer:
	var root := (Engine.get_main_loop() as SceneTree).root
	for p in _pool:
		if is_instance_valid(p) and not p.playing:
			return p
	if _pool.size() >= POOL_SIZE:
		return null
	var p := AudioStreamPlayer.new()
	root.add_child(p)
	_pool.append(p)
	return p


static func _blip(cue: String) -> AudioStreamWAV:
	if _blip_cache.has(cue):
		return _blip_cache[cue]
	var spec: Array = CUES.get(cue, [440.0, 0.12, "sine"])
	var freq: float = spec[0]
	var dur: float = spec[1]
	var kind: String = spec[2] if spec.size() > 2 else "sine"
	var rate := 22050
	var n := int(dur * rate)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var t := float(i) / rate
		var progress := float(i) / maxf(float(n), 1.0)
		var env := pow(1.0 - progress, 1.8)
		var v := 0.0
		match kind:
			"sine":
				v = 0.40 * sin(TAU * freq * t)
				v += 0.15 * sin(TAU * freq * 2.0 * t)
				v *= env
			"chime":
				v = 0.30 * sin(TAU * freq * t)
				v += 0.18 * sin(TAU * freq * 2.0 * t)
				v += 0.10 * sin(TAU * freq * 3.0 * t)
				v += 0.06 * sin(TAU * freq * 1.505 * t)
				v *= env
			"thud":
				v = 0.50 * sin(TAU * freq * t)
				v += 0.20 * sin(TAU * freq * 0.5 * t)
				v *= pow(env, 0.8)
			"whoosh":
				var sweep := freq * (1.0 + 0.8 * progress)
				v = 0.25 * sin(TAU * sweep * t)
				v += 0.15 * sin(TAU * sweep * 1.5 * t)
				v += 0.08 * sin(TAU * freq * 0.3 * t)
				v *= pow(env, 0.6)
			"buzz":
				v = 0.35 * sin(TAU * freq * t)
				v += 0.20 * sin(TAU * freq * 2.0 * t)
				v += 0.12 * sin(TAU * freq * 3.0 * t)
				v += 0.08 * sin(TAU * freq * 5.0 * t)
				v *= pow(env, 1.2)
		var sample := int(clampf(v, -1.0, 1.0) * 32767.0 * 0.5)
		data.encode_s16(i * 2, sample)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	_blip_cache[cue] = wav
	return wav
