#!/usr/bin/bash

export WEBOTS_HOME=/code/webots
export QT_QPA_PLATFORM=
export QT_PLUGIN_PATH=/usr/lib/qt/plugins/
export GAME_CONTROLLER_HOME=/code/GameController
export JAVA_HOME=/usr

PREFIX=
if [ $(nvidia-smi -L | wc -l) -gt 0 ]; then
    PREFIX="prime-run "
    echo "Detected nvidia graphics, using 'prime-run' to run webots"
fi
if [ $(ls /robocup | wc -l) -eq 0 ]; then
    cp -r projects/samples/contests/robocup /
fi


if [ "$1" == "--bash" ]; then
    shift;
    bash
elif [ "$1" == "--model_checker" ]; then
    shift;
    $PREFIX /robocup/controllers/model_verifier/model_checker.sh "$1"
else
    $PREFIX ./webots /robocup/worlds/robocup.wbt
fi
