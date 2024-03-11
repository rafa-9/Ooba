#!/bin/bash
cd /runpod-volume/text-generation-webui

# Edit these arguments if you want to customise text-generation-webui launch.
# Don't remove "$@" from the start unless you want to prevent automatic model loading from template arguments
ARGS=("$@" --listen --api --extensions openai --trust-remote-code --loader ExLlamav2_HF --model cloudyu/Mixtral_34Bx2_MoE_60B)

echo "Launching text-generation-webui with args: ${ARGS[@]}"

pip3 install -r requirements.txt

python3 server.py "${ARGS[@]}"
