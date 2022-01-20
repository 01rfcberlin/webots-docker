Docker usage
============

Running container
```
$ docker run --rm -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix -ti rfcberlin/webots
```

Running container with nvidia acceleration
```
$ docker run --rm -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix --privileged -ti rfcberlin/webots
```

Building images:
```
$ docker . build -t rfcberlin/webots
```


