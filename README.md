Docker usage
============

Running a game container
```
$ # create and initialize config folder
$ mkdir config
$ docker run --rm -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged \
             -v $(pwd)/config:/config \
             -ti rfcberlin/webots run --init
$
$ # add own models and/or adjust game.json
$ cd config
$ git clone git@github.com:01rfcberlin/webots-robot-models.git # (01 rfc berlin model)
$ vim game.json # adjust team.json
$ cd ..
$
$ # enjoy the game
$ docker run --rm -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged \
             -v $(pwd)/config:/config \
             -ti rfcberlin/webots run
```

Building images:
```
$ docker . build -t rfcberlin/webots
```


