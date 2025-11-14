# Use the much smaller "base" image. RunPod provides drivers on the host.
ARG BASE_IMAGE=nvidia/cuda:12.4.1-base-ubuntu22.04
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install ONLY essential system dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python3.11 python3.11-venv python3.11-dev python3-pip \
        git wget curl procps nano net-tools \
        && \
    ln -sf /usr/bin/python3.11 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Ollama (It's a single binary, very small)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Prepare directories
RUN mkdir -p /workspace

# Copy the single start script to the root
COPY scripts/start.sh /start.sh
RUN chmod +x /start.sh

# Set the entrypoint
CMD ["/start.sh"]
