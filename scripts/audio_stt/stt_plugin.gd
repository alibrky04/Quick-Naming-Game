extends Node2D

var STT

signal text_signal(word)

func _ready() -> void:
	OS.request_permission("RECORD_AUDIO")
	if Engine.has_singleton("SpeechToText"):
		STT = Engine.get_singleton("SpeechToText")
		STT.setLanguage("tr-TR")
		STT.connect("error", _on_error)
		STT.connect("listening_completed", _on_listening_completed)
	
	STT.listen()

func _on_listening_completed(args):
	if args and args.strip_edges() != "":
		var recognized_text = str(args).to_lower()
		print("Received speech:", recognized_text)
		text_signal.emit(recognized_text)
	
	STT.listen()

func _on_error(errorcode):
	# print("STT Error:", errorcode)
	
	STT.listen()	

func stop_stt():
	STT.stop()
