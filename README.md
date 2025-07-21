# Minimal CUDA + GDS Docker Container

Minimal Docker setup for NVIDIA CUDA with GPU Direct Storage (GDS) and WekaFS support.

## Build

```bash
docker build -t gds-test .
```

## Run

```bash
docker run --rm -it \
  --gpus all --runtime=nvidia \
  --device /dev/infiniband/rdma_cm \
  $(for d in /dev/infiniband/uverbs*; do printf -- '--device=%s ' "$d"; done) \
  -v /mnt/weka:/mnt/weka \
  --env NVIDIA_GDS=enabled \
  -v /etc/cufile.json:/etc/cufile.json:ro \
  --cap-add=IPC_LOCK \
  --network=host \
  gds-test
```

## Verify

First check that GDS works on your host:
```bash
python /usr/local/cuda-12.*/gds/tools/gdscheck.py -p
```

Then verify the same functionality in the container:
```bash
docker run --rm \
  --gpus all --runtime=nvidia \
  --device /dev/infiniband/rdma_cm \
  $(for d in /dev/infiniband/uverbs*; do printf -- '--device=%s ' "$d"; done) \
  -v /mnt/weka:/mnt/weka \
  --env NVIDIA_GDS=enabled \
  -v /etc/cufile.json:/etc/cufile.json:ro \
  --cap-add=IPC_LOCK \
  --network=host \
  gds-test \
  gdscheck -p
```

## Requirements

- NVIDIA GPU with GDS support
- NVIDIA Container Runtime
- InfiniBand/RDMA hardware
- WekaFS mount at `/mnt/weka`
- Host `/etc/cufile.json` configuration

## What's Included

**Minimal packages:**
- `gds-tools` - GDS tools (gdscheck, etc.)
- `libcufile` - Core GDS runtime library  
- `librdmacm1` - RDMA connection manager (for WekaFS)
- `ibverbs-providers` - InfiniBand device drivers (mlx5, etc.)

**Successfully removed:**
- Development headers, utilities, extra RDMA packages

## GDS Docker Run Requirements

- `--device /dev/infiniband/rdma_cm` - RDMA connection manager access
- `--device /dev/infiniband/uverbs*` - InfiniBand user verbs devices for RDMA hardware
- `--env NVIDIA_GDS=enabled` - Critical environment variable to enable GDS functionality
- `-v /mnt/weka:/mnt/weka` - WekaFS mount point for GDS access
- `-v /etc/cufile.json:/etc/cufile.json:ro` - GDS configuration file
- `--cap-add=IPC_LOCK` - Required for pinning memory pages
- `--network=host` - Required for RDMA networking
