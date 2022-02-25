# A minimal, but uptodate arch linux
FROM archlinux AS updated-archlinux
COPY files/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm archlinux-keyring pacman-mirrorlist && pacman-key --init && \
    pacman -Syy --noconfirm archlinux-keyring pacman-mirrorlist && \
    pacman -Syyu --noconfirm && \
    rm -R /var/cache/pacman/pkg/* /var/lib/pacman/sync/*




# A minimal clone of the webots repository (this is mainly to generate smaller image sizes)
FROM alpine/git AS minimal-webots-clone
    RUN git clone -b archlinux https://github.com/SGSSGene/webots.git --depth 1 --recursive /code/webots
    RUN (cd /code/webots && git pull)

# compiling webots
FROM updated-archlinux AS webots-build
ARG MAKEFLAGS

COPY --from=minimal-webots-clone /code /code

RUN pacman -Syu --noconfirm lsb-release cmake zsh swig freeimage boost zziplib zip pbzip2 wget unzip \
                            xorg-server-xvfb which glu nss libxcomposite libxrandr libxcursor ttf-dejavu \
                            libxi libxtst libxkbcommon alsa-lib libpulse libssh libzip glm qt5-base \
                            gcc make libjpeg-turbo protobuf-c protobuf python jdk-openjdk && \
    rm -R /var/cache/pacman/pkg/* /var/lib/pacman/sync/*
RUN echo "Building webots and the player controller" && \
    export WEBOTS_HOME=/code/webots && \
    cd /code/webots && \
    \
    echo "compilation fails, but we want to continue (until this is fixed)" && \
    (make -j 1 || true) && \
    (make || true) && \
    (cd projects/samples/contests/robocup/ && make)
RUN cd /code/webots && \
    find . -name "*.d" -or -name "*.o" -delete && \
    rm -rf .git docs projects/vehicles projects/robots/[^r]* projects/objects/buildings projects/objects/street_furniture projects/objects/road && \
    chmod o+rwX -R /code


# A minimal clone of the GameController repository (this is mainly to do the same as with webots
FROM alpine/git AS minimal-GameController-clone
    RUN git clone -b master https://github.com/RoboCup-Humanoid-TC/GameController.git --depth 1 --recursive /code/GameController

# compiling GameController
FROM updated-archlinux AS GameController-build

COPY --from=minimal-GameController-clone /code /code

RUN pacman -Syu --noconfirm protobuf ant && \
    rm -R /var/cache/pacman/pkg/* /var/lib/pacman/sync/* && \
    echo "Building the GameController" && \
    cd /code/GameController && \
    export JAVA_HOME=/usr && \
    ant && \
    chmod o+rwX -R /code



FROM updated-archlinux

COPY --from=webots-build         --chown=1000:1000 /code/webots /code/webots
COPY --from=GameController-build --chown=1000:1000 /code/GameController /code/GameController

RUN pacman -Syu --noconfirm freeimage boost zziplib  \
                          glu libxcomposite libxrandr libxcursor ttf-dejavu \
                          libxi libxtst libxkbcommon alsa-lib libpulse libssh libzip glm qt5-base \
                          libjpeg-turbo protobuf-c \
                          python python-pip nvidia-prime xorg-server-xvfb \
                          ant pandoc texlive-core && \
    rm -R /var/cache/pacman/pkg/* /var/lib/pacman/sync/* && \
    pip3 install -r /code/webots/projects/samples/contests/robocup/controllers/referee/requirements.txt && \
    pip3 install -r /code/webots/projects/samples/contests/robocup/controllers/model_verifier/requirements.txt && \
    pip3 cache purge && \
    \
    echo "set access rights and  add user" && \
    useradd webots -m && \
    mkdir /robocup && chown webots:webots /robocup


#TODO how should the entry point look like?
COPY files/usr/bin/webots-run /usr/bin/webots-run
COPY files/usr/bin/GameController.sh /usr/bin/GameController.sh
COPY files/etc/robocup /etc/robocup
COPY files/robocup_balls.wbt /code/webots/projects/samples/contests/robocup/worlds/robocup_balls.wbt
COPY files/referee.py /code/webots/projects/samples/contests/robocup/controllers/referee/referee.py
COPY --chown=webots:webots files/webots/ /home/webots



USER webots
WORKDIR /code/webots
CMD webots-run "--help"
