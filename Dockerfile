FROM plexinc/pms-docker:plexpass

COPY ./docker-apt-install.sh /usr/local/sbin/docker-apt-install

# Comskip
RUN docker-apt-install \
    automake \
    autoconf \
    build-essential \
    ffmpeg \
    libargtable2-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libsdl1.2-dev \
    libtool-bin
RUN cd /tmp && \
    curl -L https://github.com/erikkaashoek/Comskip/archive/master.tar.gz | tar xvz -C /tmp/ && \
    cd Comskip-master && \
    ./autogen.sh && \
    ./configure && \
    make && \
    mv comskip /usr/local/bin/ && \
    rm -rf /tmp/*
    # TODO: remove build-only dependencies

# PlexComskip
RUN docker-apt-install \
    python3
RUN cd /opt && \
    curl -L https://github.com/ekim1337/PlexComskip/archive/master.tar.gz | tar xvz -C /opt/ && \
    mkdir PlexComskip && \
    mv PlexComskip-master/PlexComskip.py PlexComskip-master/comskip.ini PlexComskip &&\
    rm -rf PlexComskip-master && \
    touch /var/log/PlexComskip.log && \
    chown plex:plex PlexComskip /var/log/PlexComskip.log

COPY ./PlexComskip.conf /opt/PlexComskip/PlexComskip.conf

# Closed captioning extractor
RUN docker-apt-install \
    libcurl4-gnutls-dev \
    libleptonica-dev \
    tesseract-ocr \
    tesseract-ocr-dev \
    unzip
RUN cd /tmp && \
    curl -o ccextractor.zip -L https://downloads.sourceforge.net/project/ccextractor/ccextractor/0.85/ccextractor-src-nowin.0.85.zip && \
    unzip ccextractor.zip && \
    cd ./ccextractor/linux/ && \
    bash ./build && \
    mv ccextractor /usr/local/bin/ && \
    cd / && \
    rm -rf /tmp/*
    # TODO: remove build-only dependencies

# TODO: s6 already has something like this, too: https://github.com/just-containers/s6-overlay/issues/146
COPY ./fixperms.sh /var/run/s6/etc/cont-init.d/15-fixperms

COPY ./postProcess.sh /opt/