ARG CUDA_VERSION="12.1.1"
ARG CUDNN_VERSION="8"
ARG UBUNTU_VERSION="22.04"
ARG DOCKER_FROM=nvidia/cuda:$CUDA_VERSION-cudnn$CUDNN_VERSION-devel-ubuntu$UBUNTU_VERSION

# Base NVidia CUDA Ubuntu image
FROM $DOCKER_FROM AS base


SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade apt packages and install required dependencies
RUN apt update && \
  apt upgrade -y && \
  apt install -y \
  python3-dev \
  python3-venv \
  git \
  git-lfs && \
  apt autoremove -y && \
  rm -rf /var/lib/apt/lists/* && \
  apt clean -y

ENV PATH="/usr/local/cuda/bin:${PATH}"

# Install pytorch
ARG PYTORCH="2.2.0"
ARG CUDA="121"
RUN pip3 install --no-cache-dir -U torch==$PYTORCH torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu$CUDA



RUN git clone https://github.com/oobabooga/text-generation-webui && \
  cd text-generation-webui && \
  pip3 install -r requirements.txt && \
  bash -c 'for req in extensions/*/requirements.txt ; do pip3 install -r "$req" ; done' && \
  #pip3 uninstall -y exllama && \
  mkdir -p repositories && \
  cd repositories && \
  git clone https://github.com/turboderp/exllama && \
  pip3 install -r exllama/requirements.txt


# ARG APTPKGS="zsh wget tmux tldr nvtop vim neovim curl rsync net-tools less iputils-ping 7zip zip unzip"

# # Install useful command line utility software
# RUN apt-get update -y && \
#   apt-get install -y --no-install-recommends $APTPKGS && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/*

# # Set up git to support LFS, and to store credentials; useful for Huggingface Hub
# RUN git config --global credential.helper store && \
#   git lfs install

# # Install Oh My Zsh for better command line experience: https://github.com/ohmyzsh/ohmyzsh
# RUN bash -c "ZSH=/root/ohmyzsh $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


RUN pip3 install runpod requests

COPY scripts /root/scripts

COPY --chmod=755 start-with-ui.sh /start.sh

WORKDIR /runpod-volume

CMD [ "/start.sh" ]
