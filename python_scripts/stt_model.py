import sys
import os
import json
import pyaudio
from vosk import Model, KaldiRecognizer, SetLogLevel
import signal
import socket
import select
import time

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

last_alive_time = time.time()
timeout_duration = 0.2

try:
    while True:
        message = ""
        ready_to_read, _, _ = select.select([client_socket], [], [], 0.1)
        
        for sock in ready_to_read:
            if sock == client_socket:
                try:
                    message = sock.recv(1024).decode().strip()
                    if "is_alive" in message:
                        last_alive_time = time.time()
                        print("Received 'is_alive' signal from server.")
                        break
                except BlockingIOError:
                    continue
                except Exception as e:
                    print(f"Error receiving message: {e}")

        if time.time() - last_alive_time > timeout_duration:
            print("No 'is_alive' signal received. Stopping...")
            break

        # Stream audio data
        data = stream.read(4000, exception_on_overflow=False)
        if recognizer.AcceptWaveform(data):
            result = json.loads(recognizer.Result())
            text = result["text"]
            if text:
                print("Recognized text:", text)
                client_socket.sendall((text + "\n").encode())
except Exception as e:
    print("An error occurred:", str(e))
finally:
    stream.stop_stream()
    stream.close()
    mic.terminate()
    client_socket.close()