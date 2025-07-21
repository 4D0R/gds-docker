# CUDA 12.4 + GDS Docker Container

This repository contains a Docker setup for running NVIDIA CUDA 12.4 with GPU Direct Storage (GDS) support.

## What's Included

- **CUDA 12.4.1** runtime and development tools
- **GDS (GPU Direct Storage)** tools and libraries for high-performance I/O
- **Python 3** for scripting and development
- **Ubuntu 20.04** base system

## Requirements

- NVIDIA GPU with GDS support (H100, A100, etc.)
- NVIDIA Container Runtime
- Host system with `/etc/cufile.json` configuration file
- InfiniBand and nvidia-fs devices (for full GDS functionality)

## Building the Container

```bash
docker build -t gds-test .
```

## Running the Container

### Basic Run with GDS Support

```bash
docker run --rm -it \
  --gpus all --runtime=nvidia \
  --device /dev/infiniband/rdma_cm \
  $(for d in /dev/infiniband/uverbs*; do printf -- '--device=%s ' "$d"; done) \
  $(for d in /dev/nvidia-fs*; do printf -- '--device=%s ' "$d"; done) \
  -v /tmp:/tmp \
  -v /run/udev:/run/udev:ro \
  -v /etc/cufile.json:/etc/cufile.json:ro \
  --cap-add=IPC_LOCK \
  gds-test
```

### Running GDS Check

To verify GDS functionality:

```bash
docker run --rm \
  --gpus all --runtime=nvidia \
  --device /dev/infiniband/rdma_cm \
  $(for d in /dev/infiniband/uverbs*; do printf -- '--device=%s ' "$d"; done) \
  -v /tmp:/tmp \
  -v /run/udev:/run/udev:ro \
  --env NVIDIA_GDS=enabled \
  -v /etc/cufile.json:/etc/cufile.json:ro \
  --cap-add=IPC_LOCK \
  gds-test \
  gdscheck -p
```

## Verified Functionality

The container has been tested and verified to work with:

- **8x NVIDIA H100 80GB GPUs** (all supporting GDS)
- **GDS version 1.9.1.3** with cufile library 2.12
- **NVMe storage support** enabled
- **Platform verification** successful on DGXH100 systems

## Key Features

- **Optimized base image**: Uses official NVIDIA CUDA containers
- **Complete GDS stack**: Includes gds-tools, libcufile, and development headers
- **Minimal footprint**: Only essential packages for GDS functionality
- **Flexible configuration**: Runtime cufile.json mounting for different environments

## Device Mappings Explained

- `--device /dev/infiniband/rdma_cm`: RDMA connection manager
- `--device /dev/infiniband/uverbs*`: InfiniBand user verbs devices
- `--device /dev/nvidia-fs*`: NVIDIA filesystem devices for GDS
- `--cap-add=IPC_LOCK`: Required for pinning memory pages
- `-v /etc/cufile.json:/etc/cufile.json:ro`: GDS configuration file

## Customization

You can customize the CUDA version by building with:

```bash
docker build --build-arg CUDA_VERSION=12.4.1 -t gds-test .
```

## Troubleshooting

- Ensure nvidia-container-runtime is properly installed
- Verify `/etc/cufile.json` exists on the host system
- Check that nvidia-fs kernel module is loaded: `lsmod | grep nvidia_fs`
- Confirm GPUs support GDS: `nvidia-smi topo -m`
