# Docker usage


## Starting a game in 3 steps
1. Create a config folder and populate it with basic configuration files:
```
$ mkdir config
$ docker run --rm -v $(pwd)/config:/config rfcberlin/webots webots-run --init

```

2. Adjust the game.json and add your robot models
```
$ cd config
$ git clone git@github.com:01rfcberlin/webots-robot-models.git # (01 rfc berlin model)
$ vim game.json # adjust team.json
```

3. Start a game
```
$ # enjoy the game
$ docker run --rm -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged \
             -v $(pwd)/config:/config:ro \
             rfcberlin/webots webots-run --game
```


## Building the docker images (only required if you don't like the version in the online docker repo)
```
$ docker build . --build-arg MAKEFLAGS=" -j16 " -t rfcberlin/webots
```


