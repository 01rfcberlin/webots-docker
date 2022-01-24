#!/usr/bin/bash

export WEBOTS_HOME=/code/webots
export QT_QPA_PLATFORM=
export QT_PLUGIN_PATH=/usr/lib/qt/plugins/
export GAME_CONTROLLER_HOME=/code/GameController
export JAVA_HOME=/usr

PREFIX=
if command -v nvidia-smi >/dev/null && [ "$(nvidia-smi -L)" ]; then
    # are you sure about this? I have a nvidia card and have never heard about prime-run
    PREFIX="prime-run "
    echo "Detected nvidia graphics, using 'prime-run' to run webots"
fi
if ! [ -d /robocup ]; then
    # this copy is relative to whatever path this script is run from. not sure what the absolute path of projects/.. is?
    cp -r projects/samples/contests/robocup /
fi


if [ "$1" == "--bash" ]; then
    # use `docker run --entrypoint bash` when you want to debug something. you don't need this
    shift;
    bash
elif [ "$1" == "--model_checker" ]; then
    shift;
    exec $PREFIX /robocup/controllers/model_verifier/model_checker.sh "$1"
else
    # turn this relative path to an absolute path
    exec $PREFIX ./webots /robocup/worlds/robocup.wbt
fi
