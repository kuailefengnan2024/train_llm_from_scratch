# 智能GPU适配Dockerfile - 40系列/A100通用
ARG BASE_IMAGE=nvcr.io/nvidia/pytorch:23.09-py3
FROM $BASE_IMAGE

WORKDIR /workspace/train_llm_from_scratch

# GPU优化环境变量
ENV PYTHONPATH=/workspace/train_llm_from_scratch:$PYTHONPATH \
    CUDA_VISIBLE_DEVICES=0 \
    HF_HOME=/workspace/.cache/huggingface \
    TRANSFORMERS_CACHE=/workspace/.cache/huggingface/transformers \
    PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/ \
    PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn \
    PIP_CACHE_DIR=/pip-cache \
    TORCH_CUDNN_V8_API_ENABLED=1

# 系统包 + 缓存目录
RUN apt-get update && apt-get install -y \
    git wget curl vim htop tmux \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /workspace/.cache/huggingface/transformers /pip-cache

# 优化依赖安装 - 大文件优先，利用Docker缓存
COPY requirements.txt .
# 简化安装，避免缓存挂载问题
RUN pip install --index-url https://pypi.tuna.tsinghua.edu.cn/simple/ --no-cache-dir \
    torch torchvision torchaudio && \
    pip install --index-url https://pypi.tuna.tsinghua.edu.cn/simple/ --no-cache-dir \
    transformers datasets accelerate && \
    pip install --index-url https://pypi.tuna.tsinghua.edu.cn/simple/ --no-cache-dir \
    -r requirements.txt

# 创建非root用户
RUN useradd -m -u 1000 developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 项目文件（放最后避免影响缓存）
COPY . .
RUN mkdir -p saves/model saves/sft results2048 sft && \
    chmod +x *.py && \
    chown -R developer:developer /workspace

USER developer
WORKDIR /workspace/train_llm_from_scratch

EXPOSE 6006
CMD ["/bin/bash"]