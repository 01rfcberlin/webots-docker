#!/usr/bin/bash

cd /code/GameController/build/jar
export DISPLAY="${GCDISPLAY}"
/usr/bin/java -jar GameControllerSimulator.jar "$@"
