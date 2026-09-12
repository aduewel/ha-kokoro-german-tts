FROM python:3.12-slim-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget curl espeak-ng libsndfile1 jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip install --no-cache-dir \
    fastapi \
    "uvicorn[standard]" \
    numpy \
    kokoro-onnx==0.5.0 \
    wyoming-openai==0.6.1 \
    pysbd

ENV PYTHONPATH="/app"

COPY german_text_rules.py /app/german_text_rules.py
COPY tts_normalizer.py /app/tts_normalizer.py
COPY main.py /app/main.py
COPY apply_german_separator_patch.py /tmp/apply_german_separator_patch.py
RUN python3 /tmp/apply_german_separator_patch.py && rm /tmp/apply_german_separator_patch.py

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

EXPOSE 10203 8881

WORKDIR /data
ENTRYPOINT ["/bin/bash", "/app/run.sh"]
