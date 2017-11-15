FROM bwstitt/debian:jessie as base

# FROM plexinc/pms-docker:plexpass
FROM plexinc/pms-docker:latest

COPY --from=base /usr/local/sbin/docker-install /usr/local/sbin/

# Comskip
RUN docker-install \
        automake \
        autoconf \
        build-essential \
        ffmpeg \
        libargtable2-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libsdl1.2-dev \
        libtool-bin \
    ;
# TODO: check sha256sum of archive
RUN set -eux; \
    \
    cd /tmp; \
    curl -L https://github.com/erikkaashoek/Comskip/archive/master.tar.gz | tar xvz -C /tmp/; \
    cd Comskip-master; \
    ./autogen.sh; \
    ./configure; \
    make; \
    mv comskip /usr/local/bin/; \
    rm -rf /tmp/*
    # TODO: remove build-only dependencies

# PlexComskip
# TODO: check sha256sum of archive
RUN set -eux; \
    \
    cd /opt; \
    curl -L https://github.com/ekim1337/PlexComskip/archive/master.tar.gz | tar xvz -C /opt/; \
    mkdir PlexComskip; \
    mv PlexComskip-master/PlexComskip.py PlexComskip-master/comskip.ini PlexComskip &&\
    rm -rf PlexComskip-master; \
    touch /var/log/PlexComskip.log; \
    chown -R plex:plex PlexComskip /var/log/PlexComskip.log

COPY ./PlexComskip.conf /opt/PlexComskip/PlexComskip.conf

# TODO: use https://github.com/just-containers/s6-overlay#fixing-ownership--permissions instead
# CHANGE_CONFIG_DIR_OWNERSHIP disables upstream's chown since we have our own. should probably merge my stuff back upstream
# keep this AFTER 40-plex-first-run otherwise GID and UID won't be correct
ENV CHANGE_CONFIG_DIR_OWNERSHIP=false
COPY ./fixperms.sh /etc/cont-init.d/41-fixperms

COPY ./postProcess.sh /opt/