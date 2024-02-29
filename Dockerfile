ARG CUDA_VERSION="12.1.1"
ARG CUDNN_VERSION="8"
ARG UBUNTU_VERSION="22.04"
ARG DOCKER_FROM=nvidia/cuda:$CUDA_VERSION-cudnn$CUDNN_VERSION-devel-ubuntu$UBUNTU_VERSION

# Base NVidia CUDA Ubuntu image
FROM $DOCKER_FROM AS base

# Install Python plus openssh, which is our minimum set of required packages.
RUN apt-get update -y && \
  apt-get install -y python3 python3-pip python3-venv && \
  apt-get install -y --no-install-recommends openssh-server openssh-client git git-lfs && \
  python3 -m pip install --upgrade pip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/cuda/bin:${PATH}"

# Install pytorch
# ARG PYTORCH="2.1.1"
# ARG CUDA="121"
# RUN pip3 install --no-cache-dir -U torch==$PYTORCH torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu$CUDA



# RUN git clone https://github.com/oobabooga/text-generation-webui && \
#   cd text-generation-webui && \
#   pip3 install -r requirements.txt && \
#   bash -c 'for req in extensions/*/requirements.txt ; do pip3 install -r "$req" ; done' && \
#   #pip3 uninstall -y exllama && \
#   mkdir -p repositories && \
#   cd repositories && \
#   git clone https://github.com/turboderp/exllama && \
#   pip3 install -r exllama/requirements.txt

# Base image
# FROM $DOCKER_FROM as base

# ARG APTPKGS="zsh wget tmux tldr nvtop vim neovim curl rsync net-tools less iputils-ping 7zip zip unzip"

# Install useful command line utility software
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends $APTPKGS && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN pip3 install runpod requests rich

COPY scripts /root/scripts

COPY --chmod=755 start-with-ui.sh /start.sh

WORKDIR /runpod-volume

CMD [ "/start.sh" ]
