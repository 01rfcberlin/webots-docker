#!/usr/bin/bash

# See the changes in someone/entrypoint.sh

# Also, why are there two entrypoints? That seems odd to me

test -e /config/game.json || cp /etc/robocup/game.json /config
test -e /config/empty-team/team.json || cp -r /etc/robocup/empty-team /config

cp /config/game.json /code/webots/projects/samples/contests/robocup/controllers/referee

for d in $(find /config -maxdepth 1 -type d | tail +2); do
    ln -s "$d" "/code/webots/projects/samples/contests/robocup/protos/"
    ln -s "$d" "/code/webots/projects/samples/contests/robocup/controllers/referee/"
done

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
elif [ "$1" == "--init" ]; then
    shift;
elif [ "$1" == "--model_checker" ]; then
    shift;
    $PREFIX /robocup/controllers/model_verifier/model_checker.sh "$1"
else
    $PREFIX ./webots projects/samples/contests/robocup/worlds/robocup.wbt --stdout --stderr
fi
