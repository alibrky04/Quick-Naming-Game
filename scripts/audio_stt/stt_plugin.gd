extends Node2D

var STT

@onready var text_edit: TextEdit = $TextEdit
@onready var text_edit_2: TextEdit = $TextEdit2

func _ready() -> void:
	OS.request_permission("RECORD_AUDIO")
	if Engine.has_singleton("SpeechToText"):
		STT = Engine.get_singleton("SpeechToText")
		STT.setLanguage("tr-TR")
		STT.connect("error", _on_error)
		STT.connect("listening_completed", _on_listening_completed)

func _on_listening_completed(args):
	text_edit.text = str(args)

func _on_error(errorcode):
	text_edit_2.text = str(errorcode)

func _on_listen_button_down() -> void:
	STT.listen()

func _on_stop_button_down() -> void:
	STT.stop()

func _on_get_output_button_down() -> void:
	var words = STT.getWords()
	text_edit_2.text = str(words)
