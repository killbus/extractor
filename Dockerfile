FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ARG CHANGE_SOURCE=false

#Install tzdata in non-interactive mode, otherwise it asks for timezones.
RUN set -eux; \
    \
    apt-get update; \
    if [ "$CHANGE_SOURCE" = true ]; then \
        apt install -y --no-install-recommends ca-certificates; \
        sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list; \
        apt-get update; \
    fi;

RUN set -eux; \
    \
    apt-get install -y --no-install-recommends \
        build-essential \
        file \
        tzdata \
        python3 \
        python3-pip \
        swig \
        git \
        android-sdk-libsparse-utils \
        liblz4-tool \
        brotli \
        unrar \
        p7zip-full \
        zip \
        rsync \
# Required for "jar" utility, helps with some broken zip files
        openjdk-11-jdk-headless \
# Required for splituapp and kdzextractor
        python2 \
        python-is-python2 \
# Required for compiling sinextract
        zlib1g-dev \
    ; \
    rm -r /var/lib/apt/lists/*;

COPY . /extractor/

RUN set -eux; \
    \
    chmod +x /extractor/sinextract; \
    cd /extractor/sinextract && make -j4

RUN set -eux; \
    \
    cd /extractor && pip3 install -r requirements.txt

RUN set -eux; \
    \
    apt purge -y --auto-remove \
        build-essential \
    ;

ENTRYPOINT ["/extractor/extractor.py"]
