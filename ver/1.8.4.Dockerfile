ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=11
ARG CUDA_IMAGE
ARG CUDA_VERSION
ARG CUDA_IMAGE_SUBTAG
ARG BLAS=libopenblas-dev
ARG JULIA_VERSION=1.8.4
ARG PYTHON_VERSION=3.10.9

FROM registry.gitlab.b-data.ch/python/psi${PYTHON_VERSION:+/}${PYTHON_VERSION:-:none}${PYTHON_VERSION:+/$BASE_IMAGE}${PYTHON_VERSION:+:$BASE_IMAGE_TAG} as psi

FROM ${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG}

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/julia/docker-stack" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG DEBIAN_FRONTEND=noninteractive

ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG BLAS
ARG JULIA_VERSION
ARG PYTHON_VERSION
ARG CUDA_IMAGE
ARG CUDA_VERSION
ARG CUDA_IMAGE_SUBTAG

ENV BASE_IMAGE=${BASE_IMAGE}:${BASE_IMAGE_TAG} \
    JULIA_VERSION=${JULIA_VERSION} \
    JULIA_PATH=/opt/julia \
    PYTHON_VERSION=${PYTHON_VERSION} \
    CUDA_IMAGE=${CUDA_IMAGE}${CUDA_IMAGE:+:}${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG} \
    PARENT_IMAGE=${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG} \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

## Install Python
COPY --from=psi /usr/local /usr/local

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
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
  ## Install Julia
  && cd /tmp \
  && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    # amd64
    amd64) tarArch='x86_64'; dirArch='x64'; sha256='f0427a4d7910c47dc7c31f65ba7ecaafedbbc0eceb39c320a37fa33598004fd5' ;; \
    # arm64v8
    arm64) tarArch='aarch64'; dirArch='aarch64'; sha256='dc4798c1ce8768fa35972e8b149ca3a85fc69e1074b609a72b2cfed5c4aa7050' ;; \
    # i386
    i386) tarArch='i686'; dirArch='x86'; sha256='ea53fb0894ea92fd6749f58f7039c0d854f81dcc42899362bde191c9df3ee0c0' ;; \
    *) echo >&2 "error: current architecture ($dpkgArch) does not have a corresponding Julia binary release"; exit 1 ;; \
	esac \
  && folder="$(echo "$JULIA_VERSION" | cut -d. -f1-2)" \
  && curl -fL -o julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/${dirArch}/${folder}/julia-${JULIA_VERSION}-linux-${tarArch}.tar.gz" \
  && echo "${sha256} *julia.tar.gz" | sha256sum -c - \
  && mkdir ${JULIA_PATH} \
  && tar -xzf julia.tar.gz -C ${JULIA_PATH} --no-same-owner --strip-components=1 \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

ENV PATH=$JULIA_PATH/bin:$PATH

CMD ["julia"]
