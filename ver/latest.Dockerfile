ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=11
ARG BLAS=libopenblas-dev
ARG JULIA_VERSION
ARG CUDA_IMAGE
ARG CUDA_VERSION
ARG CUDA_IMAGE_SUBTAG

FROM ${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_VERSION:-$BASE_IMAGE_TAG}${CUDA_IMAGE_SUBTAG:+-}${CUDA_IMAGE_SUBTAG}

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/julia/docker-stack" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG DEBIAN_FRONTEND=noninteractive

ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG BLAS
ARG JULIA_VERSION
ARG CUDA_IMAGE
ARG CUDA_VERSION
ARG CUDA_IMAGE_SUBTAG

ENV BASE_IMAGE=${BASE_IMAGE}:${BASE_IMAGE_TAG} \
    JULIA_VERSION=${JULIA_VERSION} \
    JULIA_PATH=/opt/julia \
    CUDA_IMAGE=${CUDA_IMAGE}${CUDA_VERSION:+:}${CUDA_VERSION}${CUDA_IMAGE_SUBTAG:+-}${CUDA_IMAGE_SUBTAG} \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

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
    amd64) tarArch='x86_64'; dirArch='x64'; sha256='671cf3a450b63a717e1eedd7f69087e3856f015b2e146cb54928f19a3c05e796' ;; \
    # arm64v8
    arm64) tarArch='aarch64'; dirArch='aarch64'; sha256='f91c276428ffb30acc209e0eb3e70b1c91260e887e11d4b66f5545084b530547' ;; \
    # i386
    i386) tarArch='i686'; dirArch='x86'; sha256='3e407aef71bb075bbc7746a5d1f46116925490fb0cd992f453882e793fce6c29' ;; \
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
