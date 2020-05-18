FROM debian:buster

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://gitlab.b-data.ch/julia/docker-stack" \
      maintainer="Olivier Benz <olivier.benz@b-data.ch>"

ARG JULIA_VERSION

ENV JULIA_VERSION=${JULIA_VERSION:-1.4.1} \
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
  && mkdir ${JULIA_PATH} \
  && cd /tmp \
  && curl -sLO https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
  && echo "fd6d8cadaed678174c3caefb92207a3b0e8da9f926af6703fb4d1e4e4f50610a *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - \
  && tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C ${JULIA_PATH} --strip-components=1 \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

ENV PATH=$JULIA_PATH/bin:$PATH

CMD ["julia"]
