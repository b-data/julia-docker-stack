[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a>

# Julia docker stack

Multi-arch (`linux/amd64`, `linux/arm64/v8`) docker images:

*  [`registry.gitlab.b-data.ch/julia/ver`](https://gitlab.b-data.ch/julia/ver/container_registry)
*  [`registry.gitlab.b-data.ch/julia/base`](https://gitlab.b-data.ch/julia/base/container_registry)
*  [`registry.gitlab.b-data.ch/julia/pubtools`](https://gitlab.b-data.ch/julia/pubtools/container_registry)

Images considered stable for Julia versions ≥ 1.7.3.  
:point_right: The current state may eventually be backported to versions ≥
1.5.4.

**Features**

`registry.gitlab.b-data.ch/julia/ver` serves as base image for
`registry.gitlab.b-data.ch/jupyterlab/julia/base`.

The other images are counterparts to the JupyterLab images but **without**

*  code-server
*  IJulia
*  JupyterHub
*  JupyterLab
    *  JupyterLab Extensions
    *  JupyterLab Integrations
*  Jupyter Notebook
    *  Jupyter Notebook Conversion
*  LSP Servers
*  Oh My Zsh
    *  Powerlevel10k Theme
    *  MesloLGS NF Font

and any configuration thereof.

## Table of Contents

*  [Prerequisites](#prerequisites)
*  [Install](#install)
*  [Usage](#usage)
*  [Contributing](#contributing)
*  [License](#license)

## Prerequisites

This projects requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

*  [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
*  [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image (ver)

latest:

```bash
cd ver && docker build \
  --build-arg JULIA_VERSION=1.8.1 \
  -t julia-ver \
  -f latest.Dockerfile .
```

version:

```bash
cd ver && docker build \
  -t julia-ver:<major>.<minor>.<patch> \
  -f <major>.<minor>.<patch>.Dockerfile .
```

For `<major>.<minor>.<patch>` ≥ `1.7.3`.

### Run container

self built:

```bash
docker run -it --rm julia-ver[:<major>.<minor>.<patch>]
```

from the project's GitLab Container Registries:

*  [`julia/ver`](https://gitlab.b-data.ch/julia/ver/container_registry)  
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/julia/ver[:<major>[.<minor>[.<patch>]]]
    ```
*  [`julia/base`](https://gitlab.b-data.ch/julia/base/container_registry)  
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/julia/base[:<major>[.<minor>[.<patch>]]]
    ```
*  [`julia/pubtools`](https://gitlab.b-data.ch/julia/pubtools/container_registry)
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/julia/pubtools[:<major>[.<minor>[.<patch>]]]
    ```

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) © 2020 b-data GmbH
