ARG CUDA_VERSION="12.1.1"
ARG CUDNN_VERSION="8"
ARG UBUNTU_VERSION="22.04"
ARG DOCKER_FROM=thebloke/cuda$CUDA_VERSION-ubuntu$UBUNTU_VERSION-textgen:latest 


# Base image
FROM $DOCKER_FROM as base

# ARG APTPKGS="zsh wget tmux tldr nvtop vim neovim curl rsync net-tools less iputils-ping 7zip zip unzip"

# Install useful command line utility software
# RUN apt-get update -y && \
#   apt-get install -y --no-install-recommends $APTPKGS && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/*

RUN pip3 install runpod requests

COPY scripts/rp_handler.py /root/scripts

COPY --chmod=755 start-with-ui.sh /start.sh

WORKDIR /workspace

CMD [ "/start.sh" ]
