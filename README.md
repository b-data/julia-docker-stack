[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a>

| See the [CUDA-based Julia docker stack](CUDA.md) for GPU accelerated docker images. |
|-------------------------------------------------------------------------------------|

# Julia docker stack

Multi-arch (`linux/amd64`, `linux/arm64/v8`) docker images:

* [`glcr.b-data.ch/julia/ver`](https://gitlab.b-data.ch/julia/ver/container_registry)
* [`glcr.b-data.ch/julia/base`](https://gitlab.b-data.ch/julia/base/container_registry)
* [`glcr.b-data.ch/julia/pubtools`](https://gitlab.b-data.ch/julia/pubtools/container_registry)

Images considered stable for Julia versions ≥ 1.7.3.  
:point_right: The current state may eventually be backported to versions ≥
1.5.4.

**Build chain**

ver → base → pubtools

**Features**

`glcr.b-data.ch/julia/ver` serves as parent image for
`glcr.b-data.ch/jupyterlab/julia/base`.

The other images are counterparts to the JupyterLab images but **without**

* code-server
* IJulia
* JupyterHub
* JupyterLab
  * JupyterLab Extensions
  * JupyterLab Integrations
* Jupyter Notebook
  * Jupyter Notebook Conversion
* LSP Servers
* Oh My Zsh
  * Powerlevel10k Theme
  * MesloLGS NF Font

and any configuration thereof.

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install](#install)
* [Usage](#usage)
* [Contributing](#contributing)
* [Support](#support)
* [License](#license)

## Prerequisites

This projects requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

* [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
* [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image (ver)

*latest*:

```bash
docker build \
  --build-arg JULIA_VERSION=1.12.2 \
  --build-arg PYTHON_VERSION=3.13.10 \
  -t julia/ver \
  -f ver/latest.Dockerfile .
```

*version*:

```bash
docker build \
  -t julia/ver:MAJOR.MINOR.PATCH \
  -f ver/MAJOR.MINOR.PATCH.Dockerfile .
```

For `MAJOR.MINOR.PATCH` ≥ `1.7.3`.

### Run container

self built:

```bash
docker run -it --rm julia/ver[:MAJOR.MINOR.PATCH]
```

from the project's GitLab Container Registries:

```bash
docker run -it --rm \
  IMAGE[:MAJOR[.MINOR[.PATCH]]]
```

`IMAGE` being one of

* [`glcr.b-data.ch/julia/ver`](https://gitlab.b-data.ch/julia/ver/container_registry)
* [`glcr.b-data.ch/julia/base`](https://gitlab.b-data.ch/julia/base/container_registry)
* [`glcr.b-data.ch/julia/pubtools`](https://gitlab.b-data.ch/julia/pubtools/container_registry)

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## Support

Community support: Open a new discussion
[here](https://github.com/orgs/b-data/discussions).

Commercial support: Contact b-data by [email](mailto:support@b-data.ch).

## License

Copyright © 2020 b-data GmbH

Distributed under the terms of the [MIT License](LICENSE).
