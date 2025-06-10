import sys
import io

# Force UTF-8 encoding for stdout to avoid encoding errors on Windows console
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import torch
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
import pyaudio
import signal
import socket
import json
import os
import select
import numpy as np

# Constants
SAMPLE_RATE = 16000
CHUNK_DURATION = 1.5
CHUNK_SIZE = int(SAMPLE_RATE * CHUNK_DURATION)
ENERGY_THRESHOLD = 0.01

# Socket config
HOST = "127.0.0.1"
PORT = 5000

# Handle PyInstaller paths
if getattr(sys, 'frozen', False):
    # Running in a PyInstaller bundle
    BASE_DIR = sys._MEIPASS
else:
    # Running in normal Python
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_DIR = os.path.join(BASE_DIR, "wav2vec2-base-turkish")

# Load model and processor
processor = Wav2Vec2Processor.from_pretrained(MODEL_DIR)
model = Wav2Vec2ForCTC.from_pretrained(MODEL_DIR)
model.eval()

# Setup socket
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((HOST, PORT))
client_socket.setblocking(False)
print(f"Connected to server at {HOST}:{PORT}")

# Setup PyAudio
p = pyaudio.PyAudio()
stream = p.open(format=pyaudio.paFloat32,
                channels=1,
                rate=SAMPLE_RATE,
                input=True,
                frames_per_buffer=CHUNK_SIZE)

# Graceful exit
def signal_handler(sig, frame):
    print("\nStopping...")
    stream.stop_stream()
    stream.close()
    p.terminate()
    client_socket.close()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

def is_speech(audio_array):
    energy = np.sqrt(np.mean(np.square(audio_array)))
    return energy > ENERGY_THRESHOLD

def transcribe_chunk(audio_chunk):
    inputs = processor(audio_chunk, sampling_rate=SAMPLE_RATE, return_tensors="pt", padding=True)
    with torch.no_grad():
        logits = model(**inputs).logits
    pred_ids = torch.argmax(logits, dim=-1)
    return processor.batch_decode(pred_ids)[0].lower()

last_text = ""

print("Start speaking (Ctrl+C to stop)...")

try:
    while True:
        # Check for shutdown command from server
        ready_to_read, _, _ = select.select([client_socket], [], [], 0.001)
        for sock in ready_to_read:
            if sock == client_socket:
                try:
                    message = sock.recv(1024).decode().strip()
                    if "shutdown" in message:
                        print("Shutdown signal received.")
                        client_socket.sendall(b"ack_shutdown\n")
                        signal_handler(None, None)
                except BlockingIOError:
                    continue
                except Exception as e:
                    print(f"Error receiving message: {e}")

        # Read audio and check for speech
        raw_data = stream.read(CHUNK_SIZE, exception_on_overflow=False)
        audio_data = np.frombuffer(raw_data, dtype=np.float32)

        if is_speech(audio_data):
            text = transcribe_chunk(audio_data.tolist()).strip()
            if text and text != last_text:
                last_text = text
                print("You said:", text)
                client_socket.sendall(json.dumps({"text": text}).encode() + b"\n")
        else:
            print("(silence/no speech detected)")

except Exception as e:
    print("An error occurred:", str(e))

finally:
    signal_handler(None, None)