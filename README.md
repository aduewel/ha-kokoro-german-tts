# Home Assistant Kokoro German TTS Add-on Repository

This repository provides the **Wyoming Kokoro TTS (German Martin)** add-on for Home Assistant OS / Supervised.

## Features
- **High-Quality German Voice:** Powered by [Godelaune/Kokoro-82M-ONNX-German-Martin](https://github.com/Godelaune/Kokoro-82M-ONNX-German-Martin) (voice: Martin).
- **German Text Normalization:** Built-in rule handling for abbreviations (z.B., bzw., Dr., Prof.), currency, units (kWh, °C), and ordinals.
- **Home Assistant Voice Assist:** Native Wyoming protocol support over port `10203` with auto-discovery.
- **FastAPI Endpoint:** Also exposes an OpenAI-compatible `/v1/audio/speech` endpoint on port `8881`.
