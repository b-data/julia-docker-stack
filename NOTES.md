# Notes

The programming support for NVIDIA GPUs in Julia is provided by the
[CUDA.jl](https://github.com/JuliaGPU/CUDA.jl) package. It does not require the
entire CUDA toolkit installed, as it will automatically be downloaded when the
package is first used.  
:information_source: This docker stack is derived from a CUDA image since Python
packages may require the CUDA toolkit.

## Tweaks

These images are tweaked as follows:

### Julia startup scripts (base+ images)

The following startup scripts are put in place:

* [$JULIA_PATH/etc/julia/startup.jl](base/conf/julia/etc/julia/startup.jl) to add the
  `LOAD_PATH` of the pre-installed packages
* [$HOME/.julia/config/startup.jl](base/conf/user/var/backups/skel/.julia/config/startup.jl)
  to start [Revise](https://github.com/timholy/Revise.jl) and activate either
  the project environment or package directory.

### Environment variables

**Versions**

* `JULIA_VERSION`
* `PYTHON_VERSION`
* `GIT_VERSION`
* `GIT_LFS_VERSION`
* `PANDOC_VERSION`
* `QUARTO_VERSION` (pubtools image)

**Miscellaneous**

* `BASE_IMAGE`: Its very base, a [Docker Official Image](https://hub.docker.com/search?q=&type=image&image_filter=official).
* `PARENT_IMAGE`: The image it was derived from.
* `BUILD_DATE`: The date it was built (ISO 8601 format).
* `CTAN_REPO`: The CTAN mirror URL. (pubtools image)

### TeX packages (pubtools image)

In addition to the TeX packages used in
[rocker/verse](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_texlive.sh),
[jupyter/scipy-notebook](https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile)
and required for `nbconvert`, the
[packages requested by the community](https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt)
are installed.

## Python

The Python version is selected as follows:

* The latest [Python version numba is compatible with](https://numba.readthedocs.io/en/stable/user/installing.html#compatibility).

This Python version is installed at `/usr/local/bin`.

# Additional notes on CUDA

The CUDA version is selected as follows:

* CUDA: The lastest version that has image flavour `devel` including cuDNN
  available.

## Tweaks

### Environment variables

**Versions**

* `CUDA_VERSION`

**Miscellaneous**

* `CUDA_IMAGE`: The CUDA image it is derived from.
