##############################################################################
# Minimal CUDA + GDS image (works for any CUDA 12.x tag on Ubuntu 20.04/22.04)
##############################################################################
ARG CUDA_VERSION=12.4.1
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu20.04 AS base

# Re-declare the arg so it’s visible in *this* build stage
ARG CUDA_VER

# Compute the “12-4”, “12-8”, … string once and install matching packages
RUN set -e; \
    CUDA_MM="$(echo ${CUDA_VERSION} | awk -F. '{printf "%s-%s",$1,$2}')" && \
    echo "Installing GDS for CUDA ${CUDA_MM}" && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gds-tools-${CUDA_MM} \
        libcufile-${CUDA_MM} \
        librdmacm1 \
        ibverbs-providers \
        && \
    rm -rf /var/lib/apt/lists/*

# Make the utilities easy to reach
ENV PATH=/usr/local/cuda/gds/tools:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/targets/x86_64-linux/lib:${LD_LIBRARY_PATH}

# Stub config (override with –v /etc/cufile.json:/etc/cufile.json:ro at run-time)
RUN echo '{}' > /etc/cufile.json

CMD ["/bin/bash"]
