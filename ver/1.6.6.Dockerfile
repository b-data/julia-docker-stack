FROM debian:bullseye

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/julia/docker-stack" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG JULIA_VERSION

ENV JULIA_VERSION=${JULIA_VERSION:-1.6.6} \
    JULIA_PATH=/opt/julia \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    curl \
    locales \
    unzip \
    zip \
  && sed -i "s/# $LANG/$LANG/g" /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=$LANG \
  && cd /tmp \
  && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    # amd64
    amd64) tarArch='x86_64'; dirArch='x64'; sha256='a75244724f3b2de0e7249c861fbf64078257c16fb4203be78f1cf4dd5973ba95' ;; \
    # arm64v8
    arm64) tarArch='aarch64'; dirArch='aarch64'; sha256='69fd58b1e8f6f8a72053dcbeab2d2882258fe372a91c7287d38b9c217885821a' ;; \
    # i386
    i386) tarArch='i686'; dirArch='x86'; sha256='f5f8e6cbaf0acd473a5e13c23c80f0672207eb86408178fec221f4f7fb88f6d1' ;; \
    *) echo >&2 "error: current architecture ($dpkgArch) does not have a corresponding Julia binary release"; exit 1 ;; \
	esac \
  && folder="$(echo "$JULIA_VERSION" | cut -d. -f1-2)" \
  && curl -fL -o julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/${dirArch}/${folder}/julia-${JULIA_VERSION}-linux-${tarArch}.tar.gz" \
  && echo "${sha256} *julia.tar.gz" | sha256sum -c - \
  && mkdir ${JULIA_PATH} \
  && tar -xzf julia.tar.gz -C ${JULIA_PATH} --strip-components=1 \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

ENV PATH=$JULIA_PATH/bin:$PATH

CMD ["julia"]
