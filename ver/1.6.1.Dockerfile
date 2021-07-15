FROM debian:buster

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://gitlab.b-data.ch/julia/docker-stack" \
      maintainer="Olivier Benz <olivier.benz@b-data.ch>"

ARG JULIA_VERSION

ENV JULIA_VERSION=${JULIA_VERSION:-1.6.1} \
    JULIA_PATH=/opt/julia \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    curl \
    #fonts-texgyre \
    #gsfonts \
    locales \
    unzip \
    zip \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8 \
  && cd /tmp \
  && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    # amd64
    amd64) tarArch='x86_64'; dirArch='x64'; sha256='7c888adec3ea42afbfed2ce756ce1164a570d50fa7506c3f2e1e2cbc49d52506' ;; \
    # arm64v8
    arm64) tarArch='aarch64'; dirArch='aarch64'; sha256='e6c6a0eba5546b6f8b9cdd4d303517f94e0892056c20d89faf86ee1678aab917' ;; \
    # i386
    i386) tarArch='i686'; dirArch='x86'; sha256='b65f3e4288279d214f5a1fb98aafc16fd6dfae7225833b5fb34cfbb5e1651b15' ;; \
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
