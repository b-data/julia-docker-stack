ARG BASE_IMAGE=debian:bullseye
ARG BLAS=libopenblas-dev
ARG JULIA_VERSION=1.8.1

FROM registry.gitlab.b-data.ch/julia/jsi/${JULIA_VERSION}/${BASE_IMAGE} as jsi

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/julia/docker-stack" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG DEBIAN_FRONTEND=noninteractive

ARG BASE_IMAGE
ARG BLAS
ARG JULIA_VERSION

ENV BASE_IMAGE=${BASE_IMAGE} \
    JULIA_VERSION=${JULIA_VERSION} \
    JULIA_PATH=/opt/julia \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

## Install Julia
COPY --from=jsi /usr/local/julia ${JULIA_PATH}

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
  ## Change owner and group of Julia installation
  && chown -R root:root ${JULIA_PATH} \
  ## Clean up
  && rm -rf /var/lib/apt/lists/*

ENV PATH=$JULIA_PATH/bin:$PATH

CMD ["julia"]
