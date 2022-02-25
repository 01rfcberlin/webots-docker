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
$ docker run --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged \
             -v $(pwd)/config:/config \
             rfcberlin/webots webots-run --game
```

## Checking a robot
The path of the robot model must be relative to the `config` folder.

```
$ docker run --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged \
             -v $(pwd)/config:/config \
             rfcberlin/webots webots-run --model_checker webots-robot-models/RFCRobot2016/RFCRobot2016.proto
```



## Building the docker images (only required if you don't like the version in the online docker repo)
```
$ docker build . --build-arg MAKEFLAGS=" -j16 " -t rfcberlin/webots
```


## Troubleshooting & Tricks
### webots not showing anything
- if webots doesn't start. Try to run `xhost +` on the host system.
- you can also check if `${DISPLAY}` variable is set
- check that `/tmp/.X11-unix/X0` exists (Number depends on `${DISPLAY}`)
### Prime-Run laptops with a dedicated nvidia graphic card
you can use `prime-run` to get nvidia acceleration
 ```
$ docker run --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged \
             -v $(pwd)/config:/config:ro \
             rfcberlin/webots prime-run webots-run --game
```
