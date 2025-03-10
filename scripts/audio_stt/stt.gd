extends Node

var host = "127.0.0.1"
var port = 5000
var server = TCPServer.new()
var client: StreamPeerTCP = null

var thread: Thread
var python_executable = "res://python_scripts/stt_model.py"
var python_env = "res://python_scripts/.venv/Scripts/python.exe"
var is_running = false

signal text_signal(message)

func _ready():
	server.listen(port, host)
	print("Server started, waiting for connection...")

	python_executable = ProjectSettings.globalize_path(python_executable)
	python_env = ProjectSettings.globalize_path(python_env)

	thread = Thread.new()
	is_running = true
	thread.start(_run_stt_model)

func _run_stt_model():
	var result = []
	var exit_code = OS.execute(python_env, [python_executable], result)
	if exit_code != 0:
		print("Error running Python script:", result.join("\n"))
	is_running = false

func _process(_delta):
	if client == null and server.is_connection_available():
		client = server.take_connection()
		print("Client connected!")

	if client and client.get_available_bytes() > 0:
		var message = client.get_utf8_string(client.get_available_bytes())
		print("Received speech:", message)
		text_signal.emit(message)

func _exit_tree():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	
	if thread and is_running:
		is_running = false
		thread.wait_to_finish()
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	
	if client:
		client.disconnect_from_host()
		client = null

func _on_timer_timeout():
	if client:
		client.put_string("is_alive")
