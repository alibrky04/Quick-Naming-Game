import sys
import os
import json
import pyaudio
from vosk import Model, KaldiRecognizer, SetLogLevel
import signal
import time

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
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

try:
    while True:
        # Stream audio data
        reading_time = time.time()
        data = stream.read(4000, exception_on_overflow=False)
        start_time = time.time()  # Start timing transcription
        
        if recognizer.AcceptWaveform(data):
            result = json.loads(recognizer.Result())
            text = result
            end_time = time.time()  # End timing transcription
            duration = end_time - start_time
            reading_duration = end_time - reading_time
            
            if text:
                print(f"Recognized text: {text} (Time taken: {duration:.4f} seconds), Reading duration: {reading_duration:.4f} seconds")
except Exception as e:
    print("An error occurred:", str(e))
finally:
    stream.stop_stream()
    stream.close()
    mic.terminate()
