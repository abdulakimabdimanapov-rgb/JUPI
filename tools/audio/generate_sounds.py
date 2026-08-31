

import struct
import math
import random
import os
import sys


class WavWriter:


    def __init__(self, sample_rate: int = 44100):
        self.sample_rate = sample_rate
        self.samples: list[int] = []

    def add_sample(self, value: float):

        clamped = max(-1.0, min(1.0, value))
        self.samples.append(int(clamped * 32767))

    def add_samples(self, values: list[float]):
        for v in values:
            self.add_sample(v)

    def silence(self, duration: float):

        n = int(duration * self.sample_rate)
        self.samples.extend([0] * n)

    def write(self, filepath: str):

        num_samples = len(self.samples)
        data_size = num_samples * 2
        file_size = 36 + data_size

        with open(filepath, 'wb') as f:
            f.write(b'RIFF')
            f.write(struct.pack('<I', file_size))
            f.write(b'WAVE')
            f.write(b'fmt ')
            f.write(struct.pack('<I', 16))
            f.write(struct.pack('<H', 1))
            f.write(struct.pack('<H', 1))
            f.write(struct.pack('<I', self.sample_rate))
            f.write(struct.pack('<I', self.sample_rate * 2))
            f.write(struct.pack('<H', 2))
            f.write(struct.pack('<H', 16))
            f.write(b'data')
            f.write(struct.pack('<I', data_size))
            for s in self.samples:
                f.write(struct.pack('<h', s))



def generate_sine(freq: float, duration: float, sr: int = 44100) -> list[float]:

    n = int(duration * sr)
    return [math.sin(2.0 * math.pi * freq * i / sr) for i in range(n)]

def generate_harmonics(freq: float, duration: float, harmonics: list[float], sr: int = 44100) -> list[float]:

    n = int(duration * sr)
    result = []
    for i in range(n):
        t = i / sr
        v = 0.0
        for h_idx, amp in enumerate(harmonics):
            v += amp * math.sin(2.0 * math.pi * freq * (h_idx + 1) * t)
        result.append(v)
    return result

def generate_noise(duration: float, sr: int = 44100) -> list[float]:

    n = int(duration * sr)
    return [random.uniform(-1.0, 1.0) for _ in range(n)]

def apply_envelope(samples: list[float], attack: float, decay: float, sustain: float, release: float, sr: int = 44100) -> list[float]:

    n = len(samples)
    result = []
    attack_n = int(attack * sr)
    decay_n = int(decay * sr)
    release_n = int(release * sr)
    sustain_n = n - attack_n - decay_n - release_n
    if sustain_n < 0:
        sustain_n = 0

    for i in range(n):
        if i < attack_n:
            env = i / max(attack_n, 1)
        elif i < attack_n + decay_n:
            progress = (i - attack_n) / max(decay_n, 1)
            env = 1.0 - (1.0 - sustain) * progress
        elif i < attack_n + decay_n + sustain_n:
            env = sustain
        else:
            progress = (i - attack_n - decay_n - sustain_n) / max(release_n, 1)
            env = sustain * (1.0 - progress)
        result.append(samples[i] * env)
    return result

def apply_fade(samples: list[float], fade_in: float, fade_out: float, sr: int = 44100) -> list[float]:

    n = len(samples)
    fi_n = int(fade_in * sr)
    fo_n = int(fade_out * sr)
    result = []
    for i in range(n):
        v = samples[i]
        if i < fi_n:
            v *= i / max(fi_n, 1)
        elif i > n - fo_n:
            v *= (n - i) / max(fo_n, 1)
        result.append(v)
    return result

def mix(*tracks: list[float]) -> list[float]:

    max_len = max(len(t) for t in tracks) if tracks else 0
    result = [0.0] * max_len
    for track in tracks:
        for i, v in enumerate(track):
            result[i] += v
    peak = max(abs(v) for v in result) if result else 1.0
    if peak > 1.0:
        result = [v / peak for v in result]
    return result

def low_pass(samples: list[float], cutoff: float, sr: int = 44100) -> list[float]:

    rc = 1.0 / (2.0 * math.pi * cutoff)
    dt = 1.0 / sr
    alpha = dt / (rc + dt)
    result = [0.0] * len(samples)
    result[0] = samples[0]
    for i in range(1, len(samples)):
        result[i] = result[i-1] + alpha * (samples[i] - result[i-1])
    return result

def high_pass(samples: list[float], cutoff: float, sr: int = 44100) -> list[float]:

    rc = 1.0 / (2.0 * math.pi * cutoff)
    dt = 1.0 / sr
    alpha = rc / (rc + dt)
    result = [0.0] * len(samples)
    result[0] = samples[0]
    for i in range(1, len(samples)):
        result[i] = alpha * (result[i-1] + samples[i] - samples[i-1])
    return result



SR = 44100

def gen_step() -> WavWriter:

    w = WavWriter(SR)
    base_freq = random.uniform(90, 140)
    dur = random.uniform(0.04, 0.07)
    samples = generate_harmonics(base_freq, dur, [0.6, 0.25, 0.1], SR)
    samples = apply_envelope(samples, 0.001, 0.02, 0.3, dur * 0.4, SR)
    samples = low_pass(samples, 600, SR)
    click = generate_harmonics(800, 0.008, [0.3, 0.15], SR)
    click = apply_envelope(click, 0.001, 0.003, 0.1, 0.004, SR)
    for i in range(min(len(click), len(samples))):
        samples[i] += click[i]
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.4 for v in samples]
    w.add_samples(samples)
    return w

def gen_attack_swing() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.18
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 200 + 400 * progress
        v = 0.3 * math.sin(2 * math.pi * freq * t)
        v += 0.15 * math.sin(2 * math.pi * freq * 1.5 * t)
        noise = random.uniform(-0.2, 0.2) * (1.0 - progress)
        v += noise
        samples.append(v)
    samples = apply_envelope(samples, 0.01, 0.05, 0.4, 0.08, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_hurt() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.18
    samples = generate_harmonics(160, dur, [0.6, 0.3, 0.15], SR)
    noise = generate_noise(dur, SR)
    noise = [v * 0.15 for v in noise]
    noise = apply_envelope(noise, 0.001, 0.05, 0.2, 0.1, SR)
    mixed = mix(samples, noise)
    mixed = apply_envelope(mixed, 0.001, 0.04, 0.3, 0.08, SR)
    mixed = low_pass(mixed, 500, SR)
    peak = max(abs(v) for v in mixed) if mixed else 1.0
    if peak > 0:
        mixed = [v / peak * 0.6 for v in mixed]
    w.add_samples(mixed)
    return w

def gen_death() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.6
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 200 * (1.0 - 0.6 * progress)
        env = pow(1.0 - progress, 1.5)
        v = 0.5 * math.sin(2 * math.pi * freq * t) * env
        v += 0.2 * math.sin(2 * math.pi * freq * 0.5 * t) * env
        samples.append(v)
    noise = generate_noise(dur, SR)
    noise = [v * 0.1 for v in noise]
    noise = apply_envelope(noise, 0.001, 0.1, 0.1, 0.3, SR)
    mixed = mix(samples, noise)
    mixed = low_pass(mixed, 400, SR)
    peak = max(abs(v) for v in mixed) if mixed else 1.0
    if peak > 0:
        mixed = [v / peak * 0.7 for v in mixed]
    w.add_samples(mixed)
    return w

def gen_dodge() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.15
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 300 + 600 * progress
        v = 0.25 * math.sin(2 * math.pi * freq * t)
        v += 0.12 * math.sin(2 * math.pi * freq * 1.5 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.03, 0.3, 0.06, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.45 for v in samples]
    w.add_samples(samples)
    return w

def gen_pickup() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.25
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 600 + 400 * progress
        v = 0.3 * math.sin(2 * math.pi * freq * t)
        v += 0.15 * math.sin(2 * math.pi * freq * 2 * t)
        v += 0.08 * math.sin(2 * math.pi * freq * 3 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.05, 0.4, 0.12, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_success() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.8
    n = int(dur * SR)
    samples = []
    freqs = [523.25, 659.25, 783.99, 1046.5]
    for i in range(n):
        t = i / SR
        progress = i / n
        v = 0.0
        for idx, freq in enumerate(freqs):
            note_start = idx * 0.15
            note_t = t - note_start
            if note_t > 0:
                note_env = pow(max(0, 1.0 - note_t / 0.5), 2.0)
                v += 0.2 * math.sin(2 * math.pi * freq * note_t) * note_env
        samples.append(v)
    samples = apply_fade(samples, 0.01, 0.2, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.55 for v in samples]
    w.add_samples(samples)
    return w

def gen_door() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.25
    samples = generate_harmonics(120, dur, [0.5, 0.2, 0.1], SR)
    noise = generate_noise(0.15, SR)
    noise = [v * 0.2 for v in noise]
    noise = apply_envelope(noise, 0.001, 0.03, 0.2, 0.08, SR)
    mixed = mix(samples, noise)
    mixed = apply_envelope(mixed, 0.001, 0.05, 0.4, 0.12, SR)
    mixed = low_pass(mixed, 400, SR)
    peak = max(abs(v) for v in mixed) if mixed else 1.0
    if peak > 0:
        mixed = [v / peak * 0.5 for v in mixed]
    w.add_samples(mixed)
    return w

def gen_time_travel() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.8
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 150 + 300 * progress
        env = math.sin(math.pi * progress)
        v = 0.25 * math.sin(2 * math.pi * freq * t) * env
        v += 0.12 * math.sin(2 * math.pi * freq * 1.5 * t) * env
        v += 0.08 * math.sin(2 * math.pi * freq * 0.5 * t) * env
        samples.append(v)
    tail = [0.0] * int(0.3 * SR)
    mixed = samples + tail
    mixed = apply_fade(mixed, 0.02, 0.4, SR)
    peak = max(abs(v) for v in mixed) if mixed else 1.0
    if peak > 0:
        mixed = [v / peak * 0.6 for v in mixed]
    w.add_samples(mixed)
    return w

def gen_ui_open() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.15
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 400 + 200 * progress
        v = 0.3 * math.sin(2 * math.pi * freq * t)
        v += 0.1 * math.sin(2 * math.pi * freq * 2 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.03, 0.4, 0.05, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.4 for v in samples]
    w.add_samples(samples)
    return w

def gen_ui_close() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.12
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 500 - 200 * progress
        v = 0.3 * math.sin(2 * math.pi * freq * t)
        v += 0.1 * math.sin(2 * math.pi * freq * 2 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.02, 0.3, 0.04, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.35 for v in samples]
    w.add_samples(samples)
    return w

def gen_ui_select() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.06
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        v = 0.4 * math.sin(2 * math.pi * 1200 * t)
        v += 0.2 * math.sin(2 * math.pi * 2400 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.001, 0.01, 0.2, 0.03, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.35 for v in samples]
    w.add_samples(samples)
    return w

def gen_purchase() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.3
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 500 + 300 * progress
        v = 0.3 * math.sin(2 * math.pi * freq * t)
        v += 0.15 * math.sin(2 * math.pi * freq * 2 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.05, 0.4, 0.1, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_purchase_fail() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.2
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 400 - 150 * progress
        v = 0.3 * math.sin(2 * math.pi * freq * t)
        v += 0.15 * math.sin(2 * math.pi * freq * 2 * t)
        v += 0.08 * math.sin(2 * math.pi * freq * 3 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.03, 0.3, 0.08, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.4 for v in samples]
    w.add_samples(samples)
    return w

def gen_equip() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.12
    samples = generate_harmonics(800, dur, [0.3, 0.2, 0.15, 0.1], SR)
    samples = apply_envelope(samples, 0.001, 0.02, 0.3, 0.06, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.4 for v in samples]
    w.add_samples(samples)
    return w

def gen_enemy_alert() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.18
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        v = 0.3 * math.sin(2 * math.pi * 880 * t)
        v += 0.15 * math.sin(2 * math.pi * 1760 * t)
        v += 0.08 * math.sin(2 * math.pi * 2640 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.001, 0.03, 0.3, 0.08, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.45 for v in samples]
    w.add_samples(samples)
    return w

def gen_detect() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.2
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        v = 0.25 * math.sin(2 * math.pi * 740 * t)
        v += 0.12 * math.sin(2 * math.pi * 1480 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.04, 0.3, 0.08, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.4 for v in samples]
    w.add_samples(samples)
    return w

def gen_chase() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.3
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 800 + 200 * progress
        v = 0.25 * math.sin(2 * math.pi * freq * t)
        v += 0.12 * math.sin(2 * math.pi * freq * 1.5 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.05, 0.4, 0.1, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.45 for v in samples]
    w.add_samples(samples)
    return w

def gen_lost() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.25
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 500 - 200 * progress
        v = 0.2 * math.sin(2 * math.pi * freq * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.05, 0.3, 0.1, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.4 for v in samples]
    w.add_samples(samples)
    return w

def gen_alarm() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.6
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        pulse = abs(math.sin(2 * math.pi * 4 * t))
        v = 0.3 * math.sin(2 * math.pi * 440 * t) * pulse
        v += 0.15 * math.sin(2 * math.pi * 880 * t) * pulse
        samples.append(v)
    samples = apply_fade(samples, 0.01, 0.1, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_contract() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.4
    n = int(dur * SR)
    samples = []
    freqs = [440, 554.37, 659.25]
    for i in range(n):
        t = i / SR
        v = 0.0
        for idx, freq in enumerate(freqs):
            note_start = idx * 0.1
            note_t = t - note_start
            if note_t > 0:
                note_env = pow(max(0, 1.0 - note_t / 0.3), 2.0)
                v += 0.2 * math.sin(2 * math.pi * freq * note_t) * note_env
        samples.append(v)
    samples = apply_fade(samples, 0.01, 0.15, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_respawn() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.4
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 200 + 400 * progress
        env = math.sin(math.pi * progress)
        v = 0.25 * math.sin(2 * math.pi * freq * t) * env
        v += 0.1 * math.sin(2 * math.pi * freq * 2 * t) * env
        samples.append(v)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_boss_intro() -> WavWriter:

    w = WavWriter(SR)
    dur = 1.0
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 80 + 20 * progress
        env = math.sin(math.pi * progress)
        v = 0.4 * math.sin(2 * math.pi * freq * t) * env
        v += 0.2 * math.sin(2 * math.pi * freq * 1.5 * t) * env
        v += 0.1 * math.sin(2 * math.pi * freq * 2 * t) * env
        samples.append(v)
    samples = low_pass(samples, 300, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.6 for v in samples]
    w.add_samples(samples)
    return w

def gen_boss_phase() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.4
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 300 + 200 * progress
        env = pow(1.0 - progress, 1.5)
        v = 0.3 * math.sin(2 * math.pi * freq * t) * env
        v += 0.15 * math.sin(2 * math.pi * freq * 2 * t) * env
        samples.append(v)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_boss_defeated() -> WavWriter:

    w = WavWriter(SR)
    dur = 1.2
    n = int(dur * SR)
    samples = []
    freqs = [523.25, 659.25, 783.99, 1046.5, 1318.5]
    for i in range(n):
        t = i / SR
        v = 0.0
        for idx, freq in enumerate(freqs):
            note_start = idx * 0.15
            note_t = t - note_start
            if note_t > 0:
                note_env = pow(max(0, 1.0 - note_t / 0.8), 1.5)
                v += 0.18 * math.sin(2 * math.pi * freq * note_t) * note_env
        samples.append(v)
    samples = apply_fade(samples, 0.01, 0.4, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.6 for v in samples]
    w.add_samples(samples)
    return w

def gen_paradox_trigger() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.9
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 600 * (1.0 - 0.7 * progress)
        env = math.sin(math.pi * progress) * pow(1.0 - progress, 0.5)
        v = 0.25 * math.sin(2 * math.pi * freq * t) * env
        v += 0.12 * math.sin(2 * math.pi * freq * 0.5 * t) * env
        samples.append(v)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_timeline_view() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.5
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        v = 0.2 * math.sin(2 * math.pi * 440 * t)
        v += 0.1 * math.sin(2 * math.pi * 554 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.01, 0.1, 0.3, 0.2, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.4 for v in samples]
    w.add_samples(samples)
    return w

def gen_era_arrive() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.6
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 400 + 200 * progress
        env = math.sin(math.pi * progress)
        v = 0.2 * math.sin(2 * math.pi * freq * t) * env
        v += 0.1 * math.sin(2 * math.pi * freq * 1.5 * t) * env
        v += 0.05 * math.sin(2 * math.pi * freq * 2 * t) * env
        samples.append(v)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_era_travel() -> WavWriter:

    w = WavWriter(SR)
    dur = 1.0
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 100 + 400 * progress
        env = math.sin(math.pi * progress)
        v = 0.2 * math.sin(2 * math.pi * freq * t) * env
        v += 0.1 * math.sin(2 * math.pi * freq * 0.5 * t) * env
        noise = random.uniform(-0.08, 0.08) * env
        v += noise
        samples.append(v)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w

def gen_unlock() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.7
    n = int(dur * SR)
    samples = []
    freqs = [392, 440, 523.25, 659.25, 783.99]
    for i in range(n):
        t = i / SR
        v = 0.0
        for idx, freq in enumerate(freqs):
            note_start = idx * 0.1
            note_t = t - note_start
            if note_t > 0:
                note_env = pow(max(0, 1.0 - note_t / 0.5), 2.0)
                v += 0.18 * math.sin(2 * math.pi * freq * note_t) * note_env
        samples.append(v)
    samples = apply_fade(samples, 0.01, 0.25, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.55 for v in samples]
    w.add_samples(samples)
    return w

def gen_clock_open() -> WavWriter:

    w = WavWriter(SR)
    dur = 0.4
    n = int(dur * SR)
    samples = []
    for i in range(n):
        t = i / SR
        progress = i / n
        freq = 440 + 100 * progress
        v = 0.3 * math.sin(2 * math.pi * freq * t)
        v += 0.15 * math.sin(2 * math.pi * freq * 2 * t)
        v += 0.08 * math.sin(2 * math.pi * freq * 3 * t)
        v += 0.04 * math.sin(2 * math.pi * freq * 1.505 * t)
        samples.append(v)
    samples = apply_envelope(samples, 0.005, 0.05, 0.4, 0.15, SR)
    peak = max(abs(v) for v in samples) if samples else 1.0
    if peak > 0:
        samples = [v / peak * 0.5 for v in samples]
    w.add_samples(samples)
    return w



def main():
    output_dir = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "2d", "audio")
    os.makedirs(output_dir, exist_ok=True)

    sounds = {
        "step": gen_step,
        "attack_swing": gen_attack_swing,
        "hurt": gen_hurt,
        "death": gen_death,
        "dodge": gen_dodge,
        "pickup": gen_pickup,
        "success": gen_success,
        "door": gen_door,
        "time_travel": gen_time_travel,
        "ui_open": gen_ui_open,
        "ui_close": gen_ui_close,
        "ui_select": gen_ui_select,
        "purchase": gen_purchase,
        "purchase_fail": gen_purchase_fail,
        "equip": gen_equip,
        "enemy_alert": gen_enemy_alert,
        "detect": gen_detect,
        "chase": gen_chase,
        "lost": gen_lost,
        "alarm": gen_alarm,
        "contract": gen_contract,
        "respawn": gen_respawn,
        "boss_intro": gen_boss_intro,
        "boss_phase": gen_boss_phase,
        "boss_defeated": gen_boss_defeated,
        "paradox_trigger": gen_paradox_trigger,
        "timeline_view": gen_timeline_view,
        "era_arrive": gen_era_arrive,
        "era_travel": gen_era_travel,
        "unlock": gen_unlock,
        "clock_open": gen_clock_open,
    }

    generated = 0
    for name, generator in sounds.items():
        filepath = os.path.join(output_dir, f"{name}.wav")
        try:
            wav = generator()
            wav.write(filepath)
            size = os.path.getsize(filepath)
            print(f"  ✅ {name}.wav ({size} bytes)")
            generated += 1
        except Exception as e:
            print(f"  ❌ {name}.wav: {e}")

    print(f"\n{'='*50}")
    print(f"Generated {generated}/{len(sounds)} sound effects")
    print(f"Output: {output_dir}")
    print(f"{'='*50}")

    return generated == len(sounds)


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
