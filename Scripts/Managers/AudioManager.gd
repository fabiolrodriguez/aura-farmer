extends Node

enum Sfx { HOVER, CLICK, BUY, PRESTIGE, UPGRADE, NEW_STAGE, POPUP }

var _players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _music_enabled: bool = true
var _sfx_names: Dictionary = {
	Sfx.HOVER: "hover",
	Sfx.CLICK: "click",
	Sfx.BUY: "buy",
	Sfx.PRESTIGE: "prestige",
	Sfx.UPGRADE: "upgrade",
	Sfx.NEW_STAGE: "new_stage",
	Sfx.POPUP: "popup"
}

func _ready() -> void:
	SettingsManager.setting_changed.connect(_on_setting_changed)
	for i in range(8):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.stream = _build_background_loop()
	_apply_volume()
	play_music()

func play_sfx(sfx: Sfx) -> void:
	var player: AudioStreamPlayer = _get_available_player()
	if player == null:
		return
	player.stream = _build_tone_stream(str(_sfx_names.get(sfx, "click")))
	player.play()

func play_music() -> void:
	if _music_player == null or not _music_enabled:
		return
	if not _music_player.playing:
		_music_player.play()

func stop_music() -> void:
	if _music_player != null:
		_music_player.stop()

func set_music_enabled(enabled: bool) -> void:
	_music_enabled = enabled
	SettingsManager.set_setting("music_enabled", enabled)
	if enabled:
		play_music()
	else:
		stop_music()

func is_music_enabled() -> bool:
	return _music_enabled

func toggle_music() -> bool:
	set_music_enabled(not _music_enabled)
	return _music_enabled

func _get_available_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0] if not _players.is_empty() else null

func _build_tone_stream(kind: String) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	var mix_rate: int = 22050
	var duration: float = 0.09
	var frequency: float = 440.0
	match kind:
		"hover":
			frequency = 620.0
			duration = 0.035
		"click":
			frequency = 820.0
			duration = 0.055
		"buy":
			frequency = 980.0
			duration = 0.1
		"prestige":
			frequency = 220.0
			duration = 0.26
		"new_stage":
			frequency = 1280.0
			duration = 0.18
		"popup":
			frequency = 520.0
			duration = 0.12
	var sample_count: int = int(mix_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / float(mix_rate)
		var fade: float = 1.0 - (float(i) / float(sample_count))
		var wave: float = _sample_sfx(kind, t, frequency, fade)
		data.encode_s16(i * 2, int(clamp(wave, -1.0, 1.0) * 32767.0))
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream

func _sample_sfx(kind: String, t: float, frequency: float, fade: float) -> float:
	match kind:
		"buy":
			var coin_1: float = sin(TAU * 1320.0 * t) * exp(-t * 22.0)
			var coin_2: float = sin(TAU * 1760.0 * max(t - 0.035, 0.0)) * exp(-max(t - 0.035, 0.0) * 26.0)
			var register: float = sin(TAU * 660.0 * max(t - 0.07, 0.0)) * exp(-max(t - 0.07, 0.0) * 18.0)
			return (coin_1 + coin_2 * 0.8 + register * 0.45) * 0.26
		"new_stage":
			var sweep: float = sin(TAU * (220.0 + 1800.0 * t) * t)
			var sub: float = sin(TAU * 90.0 * t)
			return (sweep * 0.34 + sub * 0.16) * fade
		"prestige":
			var rise: float = sin(TAU * (140.0 + 620.0 * t) * t)
			var shimmer: float = sin(TAU * 1240.0 * t) * sin(TAU * 8.0 * t)
			return (rise * 0.32 + shimmer * 0.12) * fade
		_:
			return sin(TAU * frequency * t) * 0.28 * fade

func _build_background_loop() -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	var mix_rate: int = 22050
	var duration: float = 8.0
	var sample_count: int = int(mix_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / float(mix_rate)
		var beat: float = fmod(t, 2.0)
		var bar_pos: float = fmod(t, 8.0)
		var kick: float = _drum_pulse(beat, 0.0, 58.0, 28.0) + _drum_pulse(beat, 1.0, 62.0, 24.0)
		var snare: float = _noise_hit(beat, 0.5, 34.0) + _noise_hit(beat, 1.5, 34.0)
		var hat: float = _hat_pattern(t)
		var bass_note: float = 55.0 if bar_pos < 4.0 else 65.41
		var bass: float = sin(TAU * bass_note * t) * 0.18 * (0.65 + 0.35 * sin(TAU * 0.5 * t))
		var stab: float = _chord_stab(beat, 0.25, t, [220.0, 277.18, 329.63]) + _chord_stab(beat, 1.25, t, [196.0, 246.94, 293.66])
		var wave: float = kick * 0.46 + snare * 0.16 + hat * 0.06 + bass + stab * 0.12
		data.encode_s16(i * 2, int(clamp(wave, -1.0, 1.0) * 32767.0))
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = data
	return stream

func _drum_pulse(beat: float, at: float, frequency: float, decay: float) -> float:
	var local_t: float = beat - at
	if local_t < 0.0 or local_t > 0.22:
		return 0.0
	return sin(TAU * (frequency - local_t * 45.0) * local_t) * exp(-local_t * decay)

func _noise_hit(beat: float, at: float, decay: float) -> float:
	var local_t: float = beat - at
	if local_t < 0.0 or local_t > 0.16:
		return 0.0
	var pseudo_noise: float = sin(local_t * 9131.0) * sin(local_t * 3701.0)
	return pseudo_noise * exp(-local_t * decay)

func _hat_pattern(t: float) -> float:
	var step: float = fmod(t, 0.25)
	if step > 0.055:
		return 0.0
	var pseudo_noise: float = sin(t * 16127.0) * sin(t * 7219.0)
	return pseudo_noise * exp(-step * 55.0)

func _chord_stab(beat: float, at: float, t: float, notes: Array) -> float:
	var local_t: float = beat - at
	if local_t < 0.0 or local_t > 0.18:
		return 0.0
	var wave: float = 0.0
	for note in notes:
		wave += sin(TAU * float(note) * t)
	return wave / float(notes.size()) * exp(-local_t * 18.0)

func _on_setting_changed(_key: String, _value) -> void:
	_apply_volume()

func _apply_volume() -> void:
	var volume: float = float(SettingsManager.get_setting("sfx_volume", 0.85))
	for player in _players:
		player.volume_db = linear_to_db(max(volume, 0.001))
	if _music_player != null:
		var music_volume: float = float(SettingsManager.get_setting("music_volume", 0.5))
		_music_enabled = bool(SettingsManager.get_setting("music_enabled", true))
		_music_player.volume_db = linear_to_db(max(music_volume, 0.001))
		if _music_enabled:
			play_music()
		else:
			stop_music()
