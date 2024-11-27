ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=12
ARG CUDA_IMAGE
ARG CUDA_IMAGE_SUBTAG
ARG BLAS=libopenblas-dev
ARG CUDA_VERSION=12.6.2
ARG JULIA_VERSION=1.10.7
ARG PYTHON_VERSION=3.12.7

FROM glcr.b-data.ch/julia/jsi/${JULIA_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} as jsi
FROM glcr.b-data.ch/python/psi${PYTHON_VERSION:+/}${PYTHON_VERSION:-:none}${PYTHON_VERSION:+/$BASE_IMAGE}${PYTHON_VERSION:+:$BASE_IMAGE_TAG} as psi

FROM ${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG}

ARG DEBIAN_FRONTEND=noninteractive

ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG CUDA_IMAGE
ARG CUDA_IMAGE_SUBTAG
ARG BLAS
ARG CUDA_VERSION
ARG JULIA_VERSION
ARG PYTHON_VERSION
ARG BUILD_START

ARG CUDA_IMAGE_LICENSE=${CUDA_IMAGE:+"NVIDIA Deep Learning Container License"}
ARG IMAGE_LICENSE=${CUDA_IMAGE_LICENSE:-"MIT"}
ARG IMAGE_SOURCE=https://gitlab.b-data.ch/julia/docker-stack
ARG IMAGE_VENDOR="b-data GmbH"
ARG IMAGE_AUTHORS="Olivier Benz <olivier.benz@b-data.ch>"

LABEL org.opencontainers.image.licenses="$IMAGE_LICENSE" \
      org.opencontainers.image.source="$IMAGE_SOURCE" \
      org.opencontainers.image.vendor="$IMAGE_VENDOR" \
      org.opencontainers.image.authors="$IMAGE_AUTHORS"

ENV BASE_IMAGE=${BASE_IMAGE}:${BASE_IMAGE_TAG} \
    CUDA_IMAGE=${CUDA_IMAGE}${CUDA_IMAGE:+:}${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG} \
    PARENT_IMAGE=${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG} \
    JULIA_VERSION=${JULIA_VERSION} \
    PYTHON_VERSION=${PYTHON_VERSION} \
    BUILD_DATE=${BUILD_START}

ENV JULIA_PATH=/usr/local/julia \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

## Install Julia
COPY --from=jsi /usr/local/julia ${JULIA_PATH}
## Install Python
COPY --from=psi /usr/local /usr/local

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    liblapack-dev \
    ${BLAS} \
    locales \
    netbase \
    tzdata \
    unzip \
    zip \
  ## Update locale
  && sed -i "s/# $LANG/$LANG/g" /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=$LANG \
  ## Switch BLAS/LAPACK (manual mode)
  && if [ ${BLAS} = "libopenblas-dev" ]; then \
    update-alternatives --set libblas.so.3-$(uname -m)-linux-gnu \
      /usr/lib/$(uname -m)-linux-gnu/openblas-pthread/libblas.so.3; \
    update-alternatives --set liblapack.so.3-$(uname -m)-linux-gnu \
      /usr/lib/$(uname -m)-linux-gnu/openblas-pthread/liblapack.so.3; \
  fi \
  ## Change owner and group of Julia installation
  && chown -R root:root ${JULIA_PATH} \
  ## Clean up
  && rm -rf /var/lib/apt/lists/*

ENV PATH=$JULIA_PATH/bin:$PATH

CMD ["julia"]
