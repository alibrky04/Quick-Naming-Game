import torch
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
import sounddevice as sd
import numpy as np

processor = Wav2Vec2Processor.from_pretrained("src/wav2vec2-base-turkish")
model = Wav2Vec2ForCTC.from_pretrained("src/wav2vec2-base-turkish")
model.eval()

SAMPLE_RATE = 16000
CHUNK_DURATION = 1.5
CHUNK_SIZE = int(SAMPLE_RATE * CHUNK_DURATION)
ENERGY_THRESHOLD = 0.01

def is_speech(audio_chunk):
    energy = np.sqrt(np.mean(audio_chunk**2))
    return energy > ENERGY_THRESHOLD

def record_chunk():
    audio = sd.rec(CHUNK_SIZE, samplerate=SAMPLE_RATE, channels=1, dtype='float32')
    sd.wait()
    audio = np.squeeze(audio)
    return audio

def transcribe_chunk(audio_chunk):
    inputs = processor(audio_chunk, sampling_rate=SAMPLE_RATE, return_tensors="pt", padding=True)
    with torch.no_grad():
        logits = model(**inputs).logits
    pred_ids = torch.argmax(logits, dim=-1)
    transcription = processor.batch_decode(pred_ids)[0]
    return transcription.lower()

def main():
    print("Start speaking (Ctrl+C to stop)")
    try:
        while True:
            chunk = record_chunk()
            if is_speech(chunk):
                text = transcribe_chunk(chunk)
                if text.strip():
                    print("You said:", text)
            else:
                print("(silence/no speech detected)")
    except KeyboardInterrupt:
        print("\nExiting")

if __name__ == "__main__":
    main()
