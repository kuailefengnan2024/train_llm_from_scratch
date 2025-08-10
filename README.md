# 从零训练LLM - Docker智能部署

## 🚀 一键启动

```bash
# 自动检测GPU并构建
./build.sh

# 启动训练环境  
docker-compose up -d train

# 进入容器开始训练
docker-compose exec train bash
python train.py
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

## 🛠️ 故障排除

```bash
# 查看GPU状态
nvidia-smi

# 查看容器日志
docker-compose logs train

# 重新构建镜像
docker-compose build --no-cache

# 清理缓存
docker system prune -f
```

## 📈 监控训练

- **TensorBoard**: http://localhost:6006
- **实时日志**: `docker-compose logs -f train`