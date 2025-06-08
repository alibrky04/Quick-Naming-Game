extends Node

var host = "127.0.0.1"
var port = 5000
var server = TCPServer.new()
var client: StreamPeerTCP = null

var thread: Thread
var python_path = "res://python_src/dist/letter_model.exe"
var is_running = false

signal connected_signal
signal text_signal(message)

func _ready():
	server.listen(port, host)
	print("Server started, waiting for connection...")
	
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
		var parsed_message = JSON.parse_string(message)
		if parsed_message and parsed_message.has("text"):
			var text = parsed_message["text"]
			text = text.strip_edges().to_lower().replace(" ", "")
			print("Received speech:", text)
			text = GameManager.remove_combining_marks(text)
			text_signal.emit(text)

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
