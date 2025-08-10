#!/bin/bash
# 一键智能构建脚本 - 自动适配GPU类型

GPU_TYPE=${1:-auto}

# 检测GPU类型
detect_gpu() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)
        case $GPU_NAME in
            *"A100"*|*"H100"*) echo "a100" ;;
            *"RTX 40"*|*"4090"*|*"4080"*) echo "rtx40" ;;
            *) echo "rtx40" ;;  # 默认
        esac
    else
        echo "rtx40"  # 默认
    fi
}

# 禁用BuildKit避免兼容性问题
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

# 自动检测GPU
if [ "$GPU_TYPE" = "auto" ]; then
    GPU_TYPE=$(detect_gpu)
fi

echo "🚀 检测到GPU类型: $GPU_TYPE"

# 根据GPU类型设置环境变量
if [ "$GPU_TYPE" = "a100" ]; then
    echo "📊 使用A100优化配置..."
    export BASE_IMAGE="nvcr.io/nvidia/pytorch:24.01-py3"
    export SHM_SIZE="32gb"
    export OMP_THREADS="16"
else
    echo "🎮 使用RTX 40系列配置..."
    export BASE_IMAGE="nvcr.io/nvidia/pytorch:23.09-py3"
    export SHM_SIZE="16gb" 
    export OMP_THREADS="8"
fi

# 构建
echo "⚡ 开始智能构建..."
docker-compose build --progress=plain

echo "✅ Docker镜像构建完成！"
echo ""
echo "📋 下一步操作:"
echo "  1. 启动容器: docker-compose up -d train"
echo "  2. 进入容器: docker-compose exec train bash"
echo "  3. 开始训练: python train.py"
echo ""
echo "💡 提示: 构建完成不等于开始训练，需要手动执行上述步骤"