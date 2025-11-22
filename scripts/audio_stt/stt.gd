extends Node

const vosk_model = "res://python_src/dist/vosk_model.exe"
const wav2vec2_model = "res://python_src/dist/wav2vec2_model.exe"

var host = "127.0.0.1"
var port = 5000
var server = TCPServer.new()
var client: StreamPeerTCP = null

var thread: Thread
var python_path = vosk_model
var is_running = false
var last_processed_text: String = ""

signal connected_signal
signal text_signal(message)

func _ready():
	server.listen(port, host)
	print("Server started, waiting for connection...")
	
	select_stt_model()
	
	python_path = ProjectSettings.globalize_path(python_path)
	
	thread = Thread.new()
	is_running = true
	thread.start(_run_stt_model)

func _run_stt_model():
	var result = []
	var exit_code = OS.execute(python_path, [], result, false)
	if exit_code != 0:
		print("Error running Python script:", result)
	is_running = false

func _process(_delta):
	if client == null and server.is_connection_available():
		client = server.take_connection()
		print("Client connected!")
		connected_signal.emit()

	if client and client.get_available_bytes() > 0:
		var message = client.get_utf8_string(client.get_available_bytes())
		
		var lines = message.split("\n", false)
		
		for line in lines:
			var parsed_message = JSON.parse_string(line)
			
			if parsed_message and parsed_message.has("text"):
				var raw_text = parsed_message["text"]
				
				var current_text = raw_text.strip_edges().to_lower()
				
				var text_to_emit = ""
				
				if current_text.length() < last_processed_text.length() or not current_text.begins_with(last_processed_text):
					text_to_emit = current_text
					last_processed_text = current_text
				
				else:
					text_to_emit = current_text.substr(last_processed_text.length())
					text_to_emit = text_to_emit.strip_edges()
					last_processed_text = current_text
				
				if text_to_emit.length() > 0:
					text_to_emit = GameManager.remove_combining_marks(text_to_emit)
					print("New word detected:", text_to_emit)
					text_signal.emit(text_to_emit)

func _exit_tree():
	if client:
		client.set_no_delay(true)
		client.put_string("shutdown")
		print("Shutdown signal sent to Python.")

		client.disconnect_from_host()
		client = null
		print("Client disconnected!")

	if thread and is_running:
		is_running = false
		thread.wait_to_finish()

func select_stt_model():
	if not GameManager.do_shuffle:
		if SetManager.selected_set["type"] == "letter_naming":
			python_path = wav2vec2_model
