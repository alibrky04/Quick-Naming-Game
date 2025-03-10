extends Node

var recording = false
var audio_recorder: AudioEffectRecord
var save_path = "user://sound_recordings/"

func _ready():
	var bus_idx = AudioServer.get_bus_index("Record")
	audio_recorder = AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectRecord
	
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists(save_path):
		dir.make_dir_recursive(save_path)

func start_recording():
	if audio_recorder and not recording:
		audio_recorder.set_recording_active(true)
		recording = true
		print("Recording started")

func stop_recording():
	if audio_recorder and recording:
		audio_recorder.set_recording_active(false)
		recording = false
		print("Recording stopped")
		
		var audio_data = audio_recorder.get_recording()
		if audio_data is AudioStreamWAV:
			var file_path = get_next_available_filename()
			var save_result = audio_data.save_to_wav(file_path)
			
			if save_result == OK:
				print("Audio saved to:", file_path)
			else:
				print("Failed to save audio")

func get_next_available_filename() -> String:
	var index = 1
	var file_path = save_path + "recorded_audio" + str(index) + ".wav"
	var dir = DirAccess.open(save_path)
	
	if dir:
		while dir.file_exists(file_path):
			index += 1
			file_path = save_path + "recorded_audio" + str(index) + ".wav"

	return file_path
