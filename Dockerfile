FROM ubuntu:20.04

### BASICS ###
# Technical Environment Variables
ENV \
    SHELL="/bin/bash" \
    HOME="/root"  \
    # Nobteook server user: https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile#L33
    NB_USER="root" \
    USER_GID=0 \
    DISPLAY=":1" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    WORKSPACE_HOME="/workspace"

WORKDIR $HOME

# Layer cleanup script
COPY scripts/clean-layer.sh  /usr/bin/clean-layer.sh
COPY scripts/fix-permissions.sh  /usr/bin/fix-permissions.sh

# Make clean-layer and fix-permissions executable
RUN \
    chmod a+rwx /usr/bin/clean-layer.sh && \
    chmod a+rwx /usr/bin/fix-permissions.sh

# Generate and Set locals
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#38553499
RUN \
    apt-get update && \
    apt-get install -y locales && \
    # install locales-all?
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # Cleanup
    clean-layer.sh

ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en"

# Install basics
RUN \
    # TODO add repos?
    # add-apt-repository ppa:apt-fast/stable
    # add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main'
    apt-get update --fix-missing && \
    apt-get install -y sudo apt-utils && \
    apt-get upgrade -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    # This is necessary for apt to access HTTPS sources:
    apt-transport-https \
    gnupg-agent \
    gpg-agent \
    gnupg2 \
    ca-certificates \
    build-essential \
    pkg-config \
    software-properties-common \
    lsof \
    net-tools \
    libcurl4 \
    curl \
    wget \
    cron \
    openssl \
    psmisc \
    iproute2 \
    tmux \
    dpkg-sig \
    uuid-dev \
    csh \
    xclip \
    clinfo \
    time \
    libssl-dev \
    libgdbm-dev \
    libncurses5-dev \
    libncursesw5-dev \
    # required by pyenv
    libreadline-dev \
    libedit-dev \
    xz-utils \
    gawk \
    # Simplified Wrapper and Interface Generator (5.8MB) - required by lots of py-libs
    swig \
    # Graphviz (graph visualization software) (4MB)
    graphviz libgraphviz-dev \
    # Terminal multiplexer
    screen \
    # Editor
    nano \
    # Find files
    locate \
    # Dev Tools
    sqlite3 \
    # XML Utils
    xmlstarlet \
    # GNU parallel
    parallel \
    #  R*-tree implementation - Required for earthpy, geoviews (3MB)
    libspatialindex-dev \
    # Search text and binary files
    yara \
    # Minimalistic C client for Redis
    libhiredis-dev \
    # postgresql client
    libpq-dev \
    # mariadb client (7MB)
    # libmariadbclient-dev \
    # image processing library (6MB), required for tesseract
    libleptonica-dev \
    # GEOS library (3MB)
    libgeos-dev \
    # style sheet preprocessor
    less \
    # Print dir tree
    tree \
    # Bash autocompletion functionality
    bash-completion \
    # ping support
    iputils-ping \
    # Map remote ports to localhosM
    socat \
    # Json Processor
    jq \
    rsync \
    # sqlite3 driver - required for pyenv
    libsqlite3-dev \
    # VCS:
    git \
    subversion \
    jed \
    # odbc drivers
    unixodbc unixodbc-dev \
    # Image support
    libtiff-dev \
    libjpeg-dev \
    libpng-dev \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxext-dev \
    libxrender1 \
    libzmq3-dev \
    # protobuffer support
    protobuf-compiler \
    libprotobuf-dev \
    libprotoc-dev \
    autoconf \
    automake \
    libtool \
    cmake  \
    fonts-liberation \
    google-perftools \
    # Compression Libs
    # also install rar/unrar? but both are propriatory or unar (40MB)
    zip \
    gzip \
    unzip \
    bzip2 \
    lzop \
    # deprecates bsdtar (https://ubuntu.pkgs.org/20.04/ubuntu-universe-i386/libarchive-tools_3.4.0-2ubuntu1_i386.deb.html)
    libarchive-tools \
    zlibc \
    # unpack (almost) everything with one command
    unp \
    libbz2-dev \
    liblzma-dev \
    zlib1g-dev \
    # OpenMPI support
    libopenmpi-dev \
    openmpi-bin \
    # libartals
    liblapack-dev \
    libatlas-base-dev \
    libeigen3-dev \
    libblas-dev \
    # HDF5
    libhdf5-dev \
    # TBB   
    libtbb-dev \
    # TODO: installs tenserflow 2.4 - Required for tensorflow graphics (9MB)
    libopenexr-dev \
    # GCC OpenMP
    libgomp1 \
    # ttyd
    libwebsockets-dev \
    libjson-c-dev \
    libssl-dev \
    # data science
    libopenmpi-dev \
    openmpi-bin \
    libomp-dev \
    libopenblas-base \
    # ETC
    vim && \
    # Update git to newest version
    add-apt-repository -y ppa:git-core/ppa  && \
    apt-get update && \
    apt-get install -y --no-install-recommends git && \
    # Fix all execution permissions
    chmod -R a+rwx /usr/local/bin/ && \
    # configure dynamic linker run-time bindings
    ldconfig && \
    # Fix permissions
    fix-permissions.sh $HOME && \
    # Cleanup
    clean-layer.sh

### END BASICS ###

### MINICONDA ###
# Install Miniconda: https://repo.continuum.io/miniconda/
ENV \
    CONDA_DIR=/opt/conda \
    CONDA_ROOT=/opt/conda \
    PYTHON_VERSION="3.8" \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.8 \
    MINICONDA_VERSION=4.10.3 \
    MINICONDA_MD5=14da4a9a44b337f7ccb8363537f65b9c \
    CONDA_VERSION=4.10.3

RUN wget --no-verbose https://repo.anaconda.com/miniconda/Miniconda3-py38_${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    echo "${MINICONDA_MD5} *miniconda.sh" | md5sum -c - && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_ROOT && \
    export PATH=$CONDA_ROOT/bin:$PATH && \
    rm ~/miniconda.sh && \
    # Update conda
    $CONDA_ROOT/bin/conda update -y -n base conda && \
    $CONDA_ROOT/bin/conda install -y conda-build && \
    $CONDA_ROOT/bin/conda install -y --update-all python=$PYTHON_VERSION && \
    # Link Conda
    ln -s $CONDA_ROOT/bin/python /usr/local/bin/python && \
    ln -s $CONDA_ROOT/bin/conda /usr/bin/conda && \
    # Update
    $CONDA_ROOT/bin/conda install -y pip && \
    $CONDA_ROOT/bin/pip install --upgrade pip && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Cleanup - Remove all here since conda is not in path as of now
    $CONDA_ROOT/bin/conda clean -y --packages && \
    $CONDA_ROOT/bin/conda clean -y -a -f  && \
    $CONDA_ROOT/bin/conda build purge-all && \
    # Fix permissions
    fix-permissions.sh $CONDA_ROOT && \
    clean-layer.sh
ENV PATH=$CONDA_ROOT/bin:$PATH
### END MINICONDA ###
### DEV TOOLS ###

## Install Jupyter Notebook
RUN \
    $CONDA_ROOT/bin/conda install -c conda-forge \
        jupyterlab notebook voila jupyter_contrib_nbextensions ipywidgets \
        autopep8 yapf && \
    # Activate and configure extensions
    jupyter contrib nbextension install --sys-prefix && \
    # Cleanup
    $CONDA_ROOT/bin/conda clean -y --packages && \
    $CONDA_ROOT/bin/conda clean -y -a -f  && \
    $CONDA_ROOT/bin/conda build purge-all && \
    clean-layer.sh

## For Notebook Branding
COPY branding/logo.png /tmp/logo.png
COPY branding/favicon.ico /tmp/favicon.ico
RUN /bin/bash -c 'cp /tmp/logo.png $(python -c "import sys; print(sys.path[-1])")/notebook/static/base/images/logo.png'
RUN /bin/bash -c 'cp /tmp/favicon.ico $(python -c "import sys; print(sys.path[-1])")/notebook/static/base/images/favicon.ico'
RUN /bin/bash -c 'cp /tmp/favicon.ico $(python -c "import sys; print(sys.path[-1])")/notebook/static/favicon.ico'

## Install Visual Studio Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    clean-layer.sh

## Install ttyd. (Not recommended to edit)
RUN \
    wget https://github.com/tsl0922/ttyd/archive/refs/tags/1.6.2.zip \
    && unzip 1.6.2.zip \
    && cd ttyd-1.6.2 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install

### END DEV TOOLS ###

# Make folders
ENV WORKSPACE_HOME="/workspace"
RUN \
    if [ -e $WORKSPACE_HOME ] ; then \
    chmod a+rwx $WORKSPACE_HOME; \
    else \
    mkdir $WORKSPACE_HOME && chmod a+rwx $WORKSPACE_HOME; \
    fi
ENV HOME=$WORKSPACE_HOME
WORKDIR $WORKSPACE_HOME
### CUDA BASE ###
# https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.3.1/ubuntu2004/base/Dockerfile
ENV NVARCH x86_64
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.3 brand=tesla,driver>=418,driver<419"
ENV NV_CUDA_CUDART_VERSION 11.3.109-1
ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-11-3

ENV NV_ML_REPO_ENABLED 1
ENV NV_ML_REPO_URL https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/${NVARCH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH}/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && \
    if [ ! -z ${NV_ML_REPO_ENABLED} ]; then echo "deb ${NV_ML_REPO_URL} /" > /etc/apt/sources.list.d/nvidia-ml.list; fi && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*
    
ENV CUDA_VERSION 11.3.1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11.3=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && ln -s cuda-11.3 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*
    
# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
### END CUDA BASE ###

### CUDA RUNTIME ###
ENV NV_CUDA_LIB_VERSION 11.3.1-1
ENV NV_NVTX_VERSION 11.3.109-1
ENV NV_LIBNPP_VERSION 11.3.3.95-1
ENV NV_LIBNPP_PACKAGE libnpp-11-3=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION 11.6.0.109-1

ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-11-3
ENV NV_LIBCUBLAS_VERSION 11.5.1.109-1
ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

ENV NV_LIBNCCL_PACKAGE_NAME libnccl2
ENV NV_LIBNCCL_PACKAGE_VERSION 2.9.9-1
ENV NCCL_VERSION 2.9.9-1
ENV NV_LIBNCCL_PACKAGE ${NV_LIBNCCL_PACKAGE_NAME}=${NV_LIBNCCL_PACKAGE_VERSION}+cuda11.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-3=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-11-3=${NV_NVTX_VERSION} \
    libcusparse-11-3=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    ${NV_LIBNCCL_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME} ${NV_LIBNCCL_PACKAGE_NAME}

### END CUDA RUNTIME ###

### CUDA DEVEL ###
ENV NV_CUDA_LIB_VERSION "11.3.1-1"

ENV NV_CUDA_CUDART_DEV_VERSION 11.3.109-1
ENV NV_NVML_DEV_VERSION 11.3.58-1
ENV NV_LIBCUSPARSE_DEV_VERSION 11.6.0.109-1
ENV NV_LIBNPP_DEV_VERSION 11.3.3.95-1
ENV NV_LIBNPP_DEV_PACKAGE libnpp-dev-11-3=${NV_LIBNPP_DEV_VERSION}

ENV NV_LIBCUBLAS_DEV_VERSION 11.5.1.109-1
ENV NV_LIBCUBLAS_DEV_PACKAGE_NAME libcublas-dev-11-3
ENV NV_LIBCUBLAS_DEV_PACKAGE ${NV_LIBCUBLAS_DEV_PACKAGE_NAME}=${NV_LIBCUBLAS_DEV_VERSION}

ENV NV_LIBNCCL_DEV_PACKAGE_NAME libnccl-dev
ENV NV_LIBNCCL_DEV_PACKAGE_VERSION 2.9.9-1
ENV NCCL_VERSION 2.9.9-1
ENV NV_LIBNCCL_DEV_PACKAGE ${NV_LIBNCCL_DEV_PACKAGE_NAME}=${NV_LIBNCCL_DEV_PACKAGE_VERSION}+cuda11.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    libtinfo5 libncursesw5 \
    cuda-cudart-dev-11-3=${NV_CUDA_CUDART_DEV_VERSION} \
    cuda-command-line-tools-11-3=${NV_CUDA_LIB_VERSION} \
    cuda-minimal-build-11-3=${NV_CUDA_LIB_VERSION} \
    cuda-libraries-dev-11-3=${NV_CUDA_LIB_VERSION} \
    cuda-nvml-dev-11-3=${NV_NVML_DEV_VERSION} \
    ${NV_LIBNPP_DEV_PACKAGE} \
    libcusparse-dev-11-3=${NV_LIBCUSPARSE_DEV_VERSION} \
    ${NV_LIBCUBLAS_DEV_PACKAGE} \
    ${NV_LIBNCCL_DEV_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_DEV_PACKAGE_NAME} ${NV_LIBNCCL_DEV_PACKAGE_NAME}

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

### END CUDA DEVEL ###

### CUDA DEVEL CUDNN8 ###
ENV NV_CUDNN_VERSION 8.2.0.53

ENV NV_CUDNN_PACKAGE "libcudnn8=$NV_CUDNN_VERSION-1+cuda11.3"
ENV NV_CUDNN_PACKAGE_DEV "libcudnn8-dev=$NV_CUDNN_VERSION-1+cuda11.3"
ENV NV_CUDNN_PACKAGE_NAME "libcudnn8"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    ${NV_CUDNN_PACKAGE_DEV} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} && \
    rm -rf /var/lib/apt/lists/*
### Install Oh-My-Zsh ###
RUN \
    apt-get update --fix-missing && \
    apt-get install -y zsh  && \
    yes | sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#### Install Oh-My-Zsh Plugin
RUN \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && echo "source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${HOME}/.zshrc && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && echo "source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${HOME}/.zshrc && \
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search && echo "source ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" >> ${HOME}/.zshrc && \
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions && echo "source ~/.oh-my-zsh/custom/plugins/zsh-completions/zsh-completions.plugin.zsh" >> ${HOME}/.zshrc && \
    source  ${HOME}/.zshrc
#### Init
RUN \
    conda init zsh && \
    chsh -s $(which zsh) $NB_USER
### END OH MY ZSH ###
### Start Ainize Worksapce ###
COPY start.sh /scripts/start.sh
RUN ["chmod", "+x", "/scripts/start.sh"]
CMD "/scripts/start.sh"
