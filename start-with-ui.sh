#!/bin/bash
echo "Starting OOBA"

SCRIPTDIR=/root/scripts
VOLUME=/workspace

# If a volume is already defined, $VOLUME will already exist
# If a volume is not being used, we'll still use /worksapce to ensure everything is in a known place.
mkdir -p $VOLUME/logs

# Set default model if its not set in the environment variable
if [ -z "${MODEL+x}" ]; then
  MODEL="LoneStriker/Air-Striker-Mixtral-8x7B-Instruct-ZLoss-3.75bpw-h6-exl2"
fi

# Replace slashes with underscores
MODEL="${MODEL//\//_}"
echo "Model: ${MODEL}"

if [[ ! -L /workspace ]]; then
  echo "Symlinking files from Network Volume"
  ln -s /runpod-volume /workspace
fi

# Start build of llama-cpp-python in background
if [[ ! -f /.built.llama-cpp-python ]]; then
	"$SCRIPTDIR"/build-llama-cpp-python.sh >>$VOLUME/logs/build-llama-cpp-python.log 2>&1 &
fi

# if [[ $PUBLIC_KEY ]]; then
# 	mkdir -p ~/.ssh
# 	chmod 700 ~/.ssh
# 	cd ~/.ssh
# 	echo "$PUBLIC_KEY" >>authorized_keys
# 	chmod 700 -R ~/.ssh
# 	service ssh start
# fi

# Move text-generation-webui's folder to $VOLUME so models and all config will persist
# "$SCRIPTDIR"/textgen-on-workspace.sh


if [[ ! -d /workspace/text-generation-webui ]]; then
	# If we don't already have /workspace/text-generation-webui, move it there
	mv /root/text-generation-webui /workspace
fi

# If passed a MODEL variable from Runpod template, start it downloading
# This will block the UI until completed
# MODEL can be a HF repo name, eg 'TheBloke/guanaco-7B-GPTQ'
# or it can be a direct link to a single GGML file, eg 'https://huggingface.co/TheBloke/tulu-7B-GGML/resolve/main/tulu-7b.ggmlv3.q2_K.bin'
# if [[ $MODEL ]]; then
# 	"$SCRIPTDIR"/fetch-model.py "$MODEL" $VOLUME/text-generation-webui/models >>$VOLUME/logs/fetch-model.log 2>&1
# fi

# Update text-generation-webui to the latest commit
cd $VOLUME/text-generation-webui && git pull

# Update exllama to the latest commit
cd $VOLUME/text-generation-webui/repositories/exllama && git pull

# Move the script that launches text-gen to $VOLUME, so users can make persistent changes to CLI arguments
# if [[ ! -f $VOLUME/run-text-generation-webui.sh ]]; then
	# mv "$SCRIPTDIR"/run-text-generation-webui.sh $VOLUME/run-text-generation-webui.sh
# fi


python3 /root/scripts/rp_handler.py >/runpod-volume/logs/rp_handler.log 2>&1 &

ARGS=()
# while true; do
	# If the user wants to stop the UI from auto launching, they can run:
	# touch $VOLUME/do.not.launch.UI
	# if [[ ! -f $VOLUME/do.not.launch.UI ]]; then
		# Launch the UI in a loop forever, allowing UI restart
		# if [[ -f /tmp/text-gen-model ]]; then
		# 	# If this file exists, we successfully downloaded a model file or folder
		# 	# Therefore we auto load this model
		# 	ARGS=(--model "$(</tmp/text-gen-model)")
		# fi
		# if [[ ${UI_ARGS} ]]; then
		# 	# Passed arguments in the template
		# 	ARGS=("${ARGS[@]}" ${UI_ARGS})
		# fi
cd /runpod-volume/text-generation-webui
source /workspace/venv/bin/activate

ARGS=("$@" --listen --api --extensions openai --trust-remote-code --loader ExLlamav2_HF --model cloudyu/Mixtral_34Bx2_MoE_60B)

echo "Launching text-generation-webui with args: ${ARGS[@]}"

# python3 server.py "${ARGS[@]}"
