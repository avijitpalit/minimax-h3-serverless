# .
# Start from a CUDA 13.0 runtime image
FROM nvidia/cuda:13.0.0-cudnn-runtime-ubuntu24.04

# Install Python 3.12 (required for NVFP4 support)
RUN apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3-pip git wget curl \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install PyTorch 2.9.1 with CUDA 13.0
RUN pip install --no-cache-dir torch==2.9.1+cu130 torchvision==0.24.1+cu130 torchaudio==2.9.1+cu130 --index-url https://download.pytorch.org/whl/cu130

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip install --no-cache-dir -r requirements.txt

# Clone the official RunPod worker repository
RUN git clone https://github.com/runpod-workers/worker-comfyui.git /worker-comfyui

COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

# Copy the handler and startup script from the cloned worker repo into ComfyUI
RUN cp /worker-comfyui/handler.py /comfyui/handler.py
# RUN cp /worker-comfyui/start.sh /comfyui/start.sh
# RUN chmod +x /comfyui/start.sh

# Install MiniMax H3 Custom Nodes
WORKDIR /comfyui/custom_nodes

# Core H3 nodes
RUN git clone https://github.com/NikoDemon80/ComfyUI-H3-Motion-Context.git
RUN git clone https://github.com/seesee75-commits/ComfyUI-MiniMaxH3-Director.git
RUN git clone https://github.com/xmarre/ComfyUI-Spectrum-MiniMax-H3.git
RUN git clone https://github.com/JerryZRic/comfyui-minimax-h3-latent.git

# Math and utility nodes
RUN git clone https://github.com/evanspearman/ComfyMath.git
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git

# Install dependencies for each node pack
RUN pip install --no-cache-dir -r ComfyUI-H3-Motion-Context/requirements.txt || true
RUN pip install --no-cache-dir -r ComfyUI-MiniMaxH3-Director/requirements.txt || true
RUN pip install --no-cache-dir -r ComfyUI-Spectrum-MiniMax-H3/requirements.txt || true
RUN pip install --no-cache-dir -r comfyui-minimax-h3-latent/requirements.txt || true
RUN pip install --no-cache-dir -r ComfyMath/requirements.txt || true
RUN pip install --no-cache-dir -r ComfyUI-KJNodes/requirements.txt || true

# Set working directory back to ComfyUI
WORKDIR /comfyui

# Start the Serverless worker
CMD ["python", "-u", "/comfyui/handler.py"]
