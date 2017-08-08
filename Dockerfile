FROM plexinc/pms-docker:plexpass

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3 git build-essential libargtable2-dev autoconf \
    libtool-bin ffmpeg libsdl1.2-dev libavutil-dev libavformat-dev libavcodec-dev && \

# TODO: curl tar.gz instead of git
# Clone Comskip
    cd /opt && \
    git clone git://github.com/erikkaashoek/Comskip && \
    cd Comskip && \
    ./autogen.sh && \
    ./configure && \
    make && \

# TODO: curl tar.gz instead of git
# TODO: don't chmod 777
# Clone PlexComskip
    cd /opt && \
    git clone https://github.com/ekim1337/PlexComskip.git && \
    chmod -R 777 /opt/ /tmp/ /root/ && \
    touch /var/log/PlexComskip.log && \
    chmod 777 /var/log/PlexComskip.log && \

# Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

ADD ./PlexComskip.conf /opt/PlexComskip/PlexComskip.conf

# TODO: something is wrong. i can't find this file...
# TODO: s6 already has something like this, too: https://github.com/just-containers/s6-overlay/issues/146
ADD ./fixperms.sh /var/run/s6/etc/cont-init.d/15-fixperms
