FROM archlinux

# Set mirrors located in Germany
COPY files/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist

RUN pacman -Sy --noconfirm archlinux-keyring pacman-mirrorlist && pacman-key --init && \
    pacman -Syy --noconfirm archlinux-keyring pacman-mirrorlist && \
    pacman -Syyu --noconfirm && \
    pacman -S --noconfirm git lsb-release cmake zsh swig freeimage boost zziplib zip pbzip2 wget unzip \
                          xorg-server-xvfb which glu nss libxcomposite libxrandr libxcursor ttf-dejavu \
                          libxi libxtst libxkbcommon alsa-lib libpulse libssh libzip glm qt5-base \
                          python python-pip \
                          gcc make libjpeg-turbo protobuf-c \
                          ant nvidia-prime protobuf pandoc texlive-core && \
    rm -R /var/cache/pacman/pkg/* /var/lib/pacman/sync/* && \
    echo "Building webots and the player controller" && \
    export WEBOTS_HOME=/code/webots && \
    git clone -b archlinux https://github.com/SGSSGene/webots.git --depth 1 --recursive /code/webots && \
    cd /code/webots && \
    pip3 install -r projects/samples/contests/robocup/controllers/referee/requirements.txt && \
    pip3 install -r projects/samples/contests/robocup/controllers/model_verifier/requirements.txt && \
    \
    echo "compilation fails, but we want to continue (until this is fixed)" && \
    (make -j16 || true) && \
    (cd projects/samples/contests/robocup/ && make -j16) && \
    \
    echo "removing stuff we don't need, to minimize final image" && \
    rm -rf .git docs projects/vehicles projects/robots/[^r]* projects/objects/buildings projects/objects/street_furniture projects/objects/road && \
    rm $(find . | grep '\.d$') $(find . | grep '\.o$') && \
    \
    \
    echo "Building the GameController" && \
    git clone -b master https://github.com/RoboCup-Humanoid-TC/GameController.git --depth 1 --recursive /code/GameController && \
    cd /code/GameController && \
    ant && \
    \
    echo "set access rights and remove build tools" && \
    chmod o+rwX -R /code && \
    pacman -Rsc --noconfirm gcc make cmake git && \
    \
    echo "webots can't run as root, so we need a dedicated user" && \
    useradd someone -m && \
    mkdir /robocup && chown someone:someone /robocup

COPY files/root/entrypoint.sh /usr/bin/run
COPY files/etc/robocup /etc/robocup
COPY --chown=someone:someone files/someone/ /home/someone

USER someone
WORKDIR /code/webots

