FROM debian:bullseye

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/julia/docker-stack" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG JULIA_VERSION

ENV JULIA_VERSION=${JULIA_VERSION:-1.7.0} \
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
    amd64) tarArch='x86_64'; dirArch='x64'; sha256='7299f3a638aec5e0b9e14eaf0e6221c4fe27189aa0b38ac5a36f03f0dc4c0d40' ;; \
    # arm64v8
    arm64) tarArch='aarch64'; dirArch='aarch64'; sha256='85a93659ef588b7ee9e3eb2ee1e8b1ba8bb200adc4389afed054be44e51e6540' ;; \
    # i386
    i386) tarArch='i686'; dirArch='x86'; sha256='e4498be9c2449791093938e8e4f6a93a708d2a8bf27605c835c7409c0a57695d' ;; \
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
