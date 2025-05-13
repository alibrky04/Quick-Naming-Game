import sys
import os
import json

script_dir = os.path.dirname(__file__)
sys.path.insert(0, os.path.join(script_dir, "python_runtime", "libs"))

import pyaudio
from vosk import Model, KaldiRecognizer, SetLogLevel
import signal
import socket
import select

HOST = "127.0.0.1"  # Localhost
PORT = 5000  # Port to connect to

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((HOST, PORT))
client_socket.setblocking(0)

print(f"Connected to server at {HOST}:{PORT}")

SetLogLevel(-1)
MODEL_PATH = os.path.join(os.path.dirname(__file__), "model")

if not os.path.exists(MODEL_PATH):
    print("Model not found!")
    sys.exit(1)

model = Model(MODEL_PATH)
recognizer = KaldiRecognizer(model, 16000)

mic = pyaudio.PyAudio()
stream = mic.open(format=pyaudio.paInt16, channels=1, rate=16000, input=True, frames_per_buffer=8000)
stream.start_stream()

def signal_handler(sig, frame):
    stream.stop_stream()
    stream.close()
    mic.terminate()
    client_socket.close()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

last_text = ""

try:
    while True:
        message = ""
        ready_to_read, _, _ = select.select([client_socket], [], [], 0.001)
        
        for sock in ready_to_read:
            if sock == client_socket:
                try:
                    message = sock.recv(1024).decode().strip()
                    if "shutdown" in message:
                        print("Shutdown signal received.")
                        client_socket.sendall(b"ack_shutdown\n")
                        sys.exit(0)
                except BlockingIOError:
                    continue
                except Exception as e:
                    print(f"Error receiving message: {e}")

        # Stream audio data
        data = stream.read(4000, exception_on_overflow=False)
        
        if recognizer.AcceptWaveform(data):
            result = json.loads(recognizer.Result())
            text = result["text"]
            if text and text != last_text:
                last_text = text
                client_socket.sendall(json.dumps({"text": text}).encode() + b"\n")

        else:
            result = json.loads(recognizer.PartialResult())
            text = result["partial"]
            if text and text != last_text:
                last_text = text
                client_socket.sendall(json.dumps({"text": text}).encode() + b"\n")
except Exception as e:
    print("An error occurred:", str(e))
finally:
    stream.stop_stream()
    stream.close()
    mic.terminate()
    client_socket.close()