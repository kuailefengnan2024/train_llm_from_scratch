# 从零训练LLM - Docker智能部署

## 🚀 一键启动

### 前置要求
- 安装Docker和Docker Compose
- 安装NVIDIA Container Toolkit（GPU训练必需）
- 准备数据集文件到 `dataset/` 目录

### 快速开始
```bash
# 1. 克隆项目
git clone <your-repo-url>
cd train_llm_from_scratch

# 2. 准备数据集
mkdir -p dataset
# 将训练数据放入dataset目录

# 3. 自动检测GPU并构建环境
./build.sh

# 4. 启动训练容器（后台运行）
docker-compose up -d train

# 5. 进入容器开始训练
docker-compose exec train bash
python train.py
```

### VSCode开发
```bash
# 安装VSCode插件：Dev Containers
# 启动容器后，VSCode中：
# Ctrl+Shift+P → "Dev Containers: Attach to Running Container"
# 选择 "train_llm" 容器即可在容器内开发
```

## 📋 项目特性

- **智能GPU适配**: 自动识别A100/RTX40系列并优化配置
- **国内镜像加速**: 清华PyPI镜像，告别下载卡顿  
- **构建缓存优化**: BuildKit + 分层缓存，重复构建2分钟完成
- **一键部署**: 单个脚本完成所有配置

## 🎯 训练流程

1. **预训练**: `python train.py` 
2. **SFT微调**: `python sft_train.py`
3. **DPO优化**: `python dpo_train.py`

## 📊 性能预估 (RTX 4090)

- **预训练**: 2-4小时
- **SFT**: 1-2小时  
- **模型参数**: ~26M
- **显存占用**: ~18GB

## 🔧 自定义配置

```bash
# 手动指定GPU类型
./build.sh a100     # A100优化配置
./build.sh rtx40    # RTX40系列配置

# 环境变量自定义
export CUDA_DEVICES="0,1"    # 多卡训练
export SHM_SIZE="32gb"       # 更大共享内存
docker-compose up -d train
```

## 📁 目录结构

```
├── train.py          # 预训练脚本
├── sft_train.py      # SFT微调脚本  
├── dpo_train.py      # DPO训练脚本
├── dataset.py        # 数据加载器
├── tokenizer/        # 分词器文件
├── Dockerfile        # 智能GPU适配镜像
├── docker-compose.yml # 容器编排
├── build.sh          # 一键构建脚本
└── requirements.txt  # Python依赖
```

## 🛠️ Docker常用命令

### 容器管理
```bash
# 查看容器状态
docker-compose ps

# 启动容器
docker-compose up -d train

# 停止容器
docker-compose down

# 进入运行中的容器
docker-compose exec train bash

# 查看容器日志
docker-compose logs -f train
```

### 构建和清理
```bash
# 重新构建镜像
./build.sh
# 或
docker-compose build --no-cache

# 查看镜像大小
docker images

# 清理Docker缓存
docker system prune -f

# 清理所有未使用的资源
docker system prune -a
```

## 🛠️ 故障排除

### GPU相关
```bash
# 主机GPU检查
nvidia-smi

# 容器内GPU检查
docker-compose exec train nvidia-smi

# 测试PyTorch GPU
docker-compose exec train python -c "import torch; print(torch.cuda.is_available())"
```

### 网络问题
```bash
# 如果Docker Hub连接慢，已配置国内镜像加速
# 检查镜像源配置
cat /etc/docker/daemon.json
```

## 📈 监控训练

- **TensorBoard**: http://localhost:6006
- **实时日志**: `docker-compose logs -f train`
- **GPU监控**: `watch -n 1 nvidia-smi`