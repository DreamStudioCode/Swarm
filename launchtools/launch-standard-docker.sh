#!/usr/bin/env bash

# Note: This is an example file, do not edit `launch-standard-docker.sh`. Instead, duplicate the file and edit your duplicate.
# `custom-launch-docker.sh` is reserved in gitignore for if you want to use that.

# Run script automatically in Swarm's dir regardless of how it was triggered
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR/.."

docker build --build-arg UID=$UID -f launchtools/StandardDockerfile.docker -t swarmui .

# Run this script with 'fixch' to run as root in the container and chown to the correct user
SETUSER="--user $UID --cap-drop=ALL"
POSTARG="$0"
if [[ "$1" == "fixch" ]]
then
    SETUSER=""
    POSTARG="fixch $UID"
fi

# add "--network=host" if you want to access other services on the host network (eg a separated comfy instance)
docker run -it \
    --rm \
    $SETUSER \
    --name swarmui \
    --mount source=swarmdata,target=/SwarmUI/Data \
    --mount source=swarmbackend,target=/SwarmUI/dlbackend \
    --mount source=swarmdlnodes,target=/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/DLNodes \
    -v ./Models:/SwarmUI/Models \
    -v ./Output:/SwarmUI/Output \
    -v ./src/BuiltinExtensions/ComfyUIBackend/CustomWorkflows:/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/CustomWorkflows \
    --gpus=all -p 7801:7801 swarmui $POSTARG