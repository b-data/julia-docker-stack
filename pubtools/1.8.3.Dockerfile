ARG BUILD_ON_IMAGE=registry.gitlab.b-data.ch/julia/base
ARG JULIA_VERSION=1.8.3
ARG QUARTO_VERSION=1.2.280
ARG CTAN_REPO=https://www.texlive.info/tlnet-archive/2022/12/23/tlnet

FROM ${BUILD_ON_IMAGE}:${JULIA_VERSION}

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG QUARTO_VERSION
ARG CTAN_REPO

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${JULIA_VERSION} \
    CTAN_REPO=${CTAN_REPO} \
    PATH=/opt/TinyTeX/bin/linux:/opt/quarto/bin:$PATH

RUN dpkgArch="$(dpkg --print-architecture)" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    fonts-roboto \
    ghostscript \
    qpdf \
    texinfo \
  && if [ ${dpkgArch} = "amd64" ]; then \
    ## Install quarto
    curl -sLO https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz; \
    mkdir -p /opt/quarto; \
    tar -xzf quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz -C /opt/quarto --no-same-owner --strip-components=1; \
    rm quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz; \
    ## Apply patch
    echo '\n\
    91521c91521\n\
    <                 const url = isRStudioWorkbench() ? await rswURL(port, kPdfJsInitialPath) : "/" + kPdfJsInitialPath;\n\
    ---\n\
    >                 const url = isRStudioWorkbench() ? await rswURL(port, kPdfJsInitialPath) : isVSCodeServer() ? vsCodeServerProxyUri().replace("{{port}}", `${port}`) + kPdfJsInitialPath : "/" + kPdfJsInitialPath;\n\
    ' | patch /opt/quarto/bin/quarto.js; \
    ## Remove quarto pandoc
    rm /opt/quarto/bin/tools/pandoc; \
    ## Link to system pandoc
    ln -s /usr/bin/pandoc /opt/quarto/bin/tools/pandoc; \
  fi \
  ## Tell APT about the TeX Live installation
  ## by building a dummy package using equivs
  && apt-get install -y --no-install-recommends equivs \
  && cd /tmp \
  && wget https://github.com/scottkosty/install-tl-ubuntu/raw/master/debian-control-texlive-in.txt \
  && equivs-build debian-* \
  && mv texlive-local*.deb texlive-local.deb \
  && dpkg -i texlive-local.deb \
  && apt-get -y purge equivs \
  && apt-get -y autoremove \
  ## Admin-based install of TinyTeX
  && wget -qO- "https://yihui.org/tinytex/install-unx.sh" \
    | sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && ln -rs /opt/TinyTeX/bin/$(uname -m)-linux \
    /opt/TinyTeX/bin/linux \
  && /opt/TinyTeX/bin/linux/tlmgr path add \
  && tlmgr update --self \
  ## TeX packages as requested by the community
  && curl -sSLO https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt \
  && tlmgr install $(cat pkgs-yihui.txt | tr '\n' ' ') \
  && rm -f pkgs-yihui.txt \
  ## TeX packages as in rocker/verse
  && tlmgr install \
    context \
    pdfcrop \
  ## TeX packages as in jupyter/scipy-notebook
  && tlmgr install \
    cm-super \
    dvipng \
  ## TeX packages specific for nbconvert
  && tlmgr install \
    oberdiek \
    titling \
  && tlmgr path add \
  && chown -R root:${NB_GID} /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  ## Clean up
  && rm -rf /var/lib/apt/lists/* \
    $HOME/.config \
    $HOME/.local \
    $HOME/.wget-hsts
