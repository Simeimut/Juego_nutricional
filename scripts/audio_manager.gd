extends Node

const SAMPLE_RATE := 22050

var _sfx: AudioStreamPlayer
var _music: AudioStreamPlayer
var _click: AudioStreamWAV
var _correct: AudioStreamWAV
var _wrong: AudioStreamWAV
var _success: AudioStreamWAV
var _pop: AudioStreamWAV
var _music_stream: AudioStreamWAV


func _ready() -> void:
	_sfx = AudioStreamPlayer.new()
	_sfx.name = "SFX"
	add_child(_sfx)

	_music = AudioStreamPlayer.new()
	_music.name = "Music"
	_music.volume_db = -20.0
	add_child(_music)

	_click = _tone(720.0, 0.05, 0.18)
	_pop = _sweep(420.0, 820.0, 0.12, 0.22)
	_correct = _melody([659.25, 783.99, 987.77], 0.09, 0.20)
	_wrong = _melody([392.0, 311.13], 0.16, 0.20)
	_success = _melody([523.25, 659.25, 783.99, 1046.50], 0.12, 0.22)
	_music_stream = _build_music()

	GameState.settings_changed.connect(_apply_settings)
	_apply_settings()


func play_click() -> void:
	_play_sfx(_click)


func play_pop() -> void:
	_play_sfx(_pop)


func play_correct() -> void:
	_play_sfx(_correct)


func play_wrong() -> void:
	_play_sfx(_wrong)


func play_success() -> void:
	_play_sfx(_success)


func _play_sfx(stream: AudioStreamWAV) -> void:
	if not GameState.sfx_enabled():
		return
	if stream == null or _sfx == null:
		return
	_sfx.stream = stream
	_sfx.play()


func _apply_settings() -> void:
	if _music == null:
		return
	if GameState.music_enabled():
		if _music.stream != _music_stream:
			_music.stream = _music_stream
		if not _music.playing:
			_music.play()
	else:
		_music.stop()


func _wav_from_bytes(bytes: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream


func _tone(freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var count := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var progress := float(i) / float(maxi(count, 1))
		var env := minf(progress * 20.0, 1.0) * (1.0 - progress)
		var sample := (sin(TAU * freq * t) + 0.25 * sin(TAU * freq * 2.0 * t)) * volume * env
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	return _wav_from_bytes(bytes)


func _sweep(from_freq: float, to_freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var count := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase := 0.0
	for i in count:
		var progress := float(i) / float(maxi(count, 1))
		var freq := lerpf(from_freq, to_freq, progress)
		phase += TAU * freq / float(SAMPLE_RATE)
		var sample := sin(phase) * volume * (1.0 - progress)
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	return _wav_from_bytes(bytes)


func _melody(notes: Array, note_duration: float, volume: float) -> AudioStreamWAV:
	var note_count := int(SAMPLE_RATE * note_duration)
	var total := note_count * notes.size()
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	for n in notes.size():
		var freq: float = notes[n]
		for i in note_count:
			var t := float(i) / float(SAMPLE_RATE)
			var progress := float(i) / float(maxi(note_count, 1))
			var env := minf(progress * 18.0, 1.0) * (1.0 - progress)
			var sample := sin(TAU * freq * t) * volume * env
			bytes.encode_s16((n * note_count + i) * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	return _wav_from_bytes(bytes)


func _build_music() -> AudioStreamWAV:
	var notes := [
		523.25, 659.25, 783.99, 659.25,
		587.33, 698.46, 880.00, 698.46,
		523.25, 659.25, 783.99, 1046.50,
		880.00, 783.99, 659.25, 587.33
	]
	var note_duration := 0.42
	var note_count := int(SAMPLE_RATE * note_duration)
	var total := note_count * notes.size()
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	for n in notes.size():
		var freq: float = notes[n]
		for i in note_count:
			var t := float(i) / float(SAMPLE_RATE)
			var progress := float(i) / float(maxi(note_count, 1))
			var env := minf(progress * 20.0, 1.0) * (1.0 - progress)
			var sample := (sin(TAU * freq * t) * 0.55 + sin(TAU * freq * 0.5 * t) * 0.25) * 0.11 * env
			bytes.encode_s16((n * note_count + i) * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	var stream := _wav_from_bytes(bytes)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total
	return stream
