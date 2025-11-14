#!/bin/bash

# --- Configuration ---
# The Python virtual environment will be stored in your persistent /workspace
VENV_DIR="/workspace/venv"
# The Ollama models will be stored in your persistent /workspace
export OLLAMA_MODELS=/workspace/ollama_models
# The default model to pull on first start.
# NOTE: 'qwen3-vl:8b' was not found. Using 'llava:latest' as a placeholder.
# You can change this to any model from ollama.com/models (e.g., "qwen2:7b", "mistral:latest")
MODEL_TO_PULL="qwen3-vl:8b"


# --- 1. Setup Python Environment (First Run Only) ---
if [ ! -d "$VENV_DIR" ]; then
    echo "----------------------------------------------------------------"
    echo "First run detected! Installing Python environment to /workspace."
    echo "This will take 5-10 minutes but only happens once."
    echo "----------------------------------------------------------------"

    python -m venv $VENV_DIR
    source $VENV_DIR/bin/activate
    pip install --upgrade pip
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
    pip install open-webui jupyterlab chardet

    echo "----------------------------------------------------------------"
    echo "Python environment installed successfully."
    echo "----------------------------------------------------------------"
else
    echo "----------------------------------------------------------------"
    echo "Persistent Python environment found. Skipping installation."
    echo "----------------------------------------------------------------"
    source $VENV_DIR/bin/activate
fi

# --- 2. Start Ollama Server ---
echo "Starting Ollama server..."
mkdir -p $OLLAMA_MODELS
ollama serve &
sleep 5 # Give the server a moment to start

# --- 3. Pull Default Model (First Run Only) ---
# Check if the model is already downloaded before pulling
if ! ollama list | grep -q "$MODEL_TO_PULL"; then
    echo "----------------------------------------------------------------"
    echo "Default model '$MODEL_TO_PULL' not found. Pulling it now..."
    echo "This might take a while depending on the model size."
    echo "----------------------------------------------------------------"
    ollama pull "$MODEL_TO_PULL"
    echo "----------------------------------------------------------------"
    echo "Model pull complete."
    echo "----------------------------------------------------------------"
else
    echo "----------------------------------------------------------------"
    echo "Default model '$MODEL_TO_PULL' already exists. Skipping download."
    echo "----------------------------------------------------------------"
fi

# --- 4. Start Open WebUI Server ---
echo "Starting Open WebUI server..."
# Use --host 0.0.0.0 to make it accessible through RunPod's proxy
open-webui serve --host 0.0.0.0 --port 8080
