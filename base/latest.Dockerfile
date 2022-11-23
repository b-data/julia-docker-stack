ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=11
ARG BUILD_ON_IMAGE=registry.gitlab.b-data.ch/julia/ver
ARG JULIA_VERSION
ARG GIT_VERSION=2.38.1
ARG GIT_LFS_VERSION=3.2.0
ARG PANDOC_VERSION=2.19.2

FROM ${BUILD_ON_IMAGE}:${JULIA_VERSION} as files

RUN mkdir /files

COPY conf/julia /files/${JULIA_PATH}
COPY conf/user /files

RUN chown -R root:root /files/var/backups/skel \
  ## Ensure file modes are correct when using CI
  ## Otherwise set to 777 in the target image
  && find /files -type d -exec chmod 755 {} \; \
  && find /files -type f -exec chmod 644 {} \;

FROM registry.gitlab.b-data.ch/git/gsi/${GIT_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} as gsi
FROM registry.gitlab.b-data.ch/git-lfs/glfsi:${GIT_LFS_VERSION} as glfsi

FROM ${BUILD_ON_IMAGE}:${JULIA_VERSION}

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG GIT_VERSION
ARG GIT_LFS_VERSION
ARG PANDOC_VERSION

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${JULIA_VERSION} \
    GIT_VERSION=${GIT_VERSION} \
    GIT_LFS_VERSION=${GIT_LFS_VERSION} \
    PANDOC_VERSION=${PANDOC_VERSION}

## Install Git
COPY --from=gsi /usr/local /usr/local
## Install Git LFS
COPY --from=glfsi /usr/local /usr/local

RUN dpkgArch="$(dpkg --print-architecture)" \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    bash-completion \
    build-essential \
    curl \
    file \
    fontconfig \
    g++ \
    gcc \
    gfortran \
    gnupg \
    htop \
    info \
    jq \
    libclang-dev \
    man-db \
    nano \
    procps \
    psmisc \
    screen \
    sudo \
    tmux \
    vim \
    wget \
    zsh \
    ## Additional git runtime dependencies
    libcurl3-gnutls \
    liberror-perl \
    ## Additional git runtime recommendations
    less \
    ssh-client \
  ## Additional python-dev dependencies
  && if [ -z "$PYTHON_VERSION" ]; then \
    apt-get -y install --no-install-recommends \
      python3-dev \
      python3-distutils \
      ## venv module for python3
      python3-venv; \
    ## make some useful symlinks that are expected to exist
    ## ("/usr/bin/python" and friends)
    for src in pydoc3 python3 python3-config; do \
      dst="$(echo "$src" | tr -d 3)"; \
      [ -s "/usr/bin/$src" ]; \
      [ ! -e "/usr/bin/$dst" ]; \
      ln -svT "$src" "/usr/bin/$dst"; \
    done; \
  fi \
  ## Install/update pip, setuptools and wheel
  && curl -sLO https://bootstrap.pypa.io/get-pip.py \
  && python get-pip.py \
    pip \
    setuptools \
    wheel \
  && rm get-pip.py \
  ## Set default branch name to main
  && sudo git config --system init.defaultBranch main \
  ## Store passwords for one hour in memory
  && git config --system credential.helper "cache --timeout=3600" \
  ## Merge the default branch from the default remote when "git pull" is run
  && sudo git config --system pull.rebase false \
  ## Install pandoc
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && rm pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    $HOME/.cache

## Install Julia related stuff
RUN export JULIA_DEPOT_PATH=${JULIA_PATH}/local/share/julia \
  ## Install Revise
  && julia -e 'using Pkg; Pkg.add("Revise"); Pkg.precompile()' \
  && julia -e 'using Pkg; Pkg.add(readdir("$(ENV["JULIA_DEPOT_PATH"])/packages"))' \
  && chmod -R ugo+rx ${JULIA_DEPOT_PATH}

## Copy files as late as possible to avoid cache busting
COPY --from=files /files /
COPY --from=files /files/var/backups/skel /root
