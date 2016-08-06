FROM nickbreen/cron:v1.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qqy jq python-pip && DEBIAN_FRONTEND=noninteractive apt-get -qqy upgrade && apt-get clean

ENV LE_VER=v0.8.1 LE_DIR=/opt/letsencrypt REPO=certbot/certbot

RUN mkdir -p $LE_DIR && cd $LE_DIR && \
    REL_URL=$(curl -sSfL https://api.github.com/repos/$REPO/tags | jq -r '.[0].tarball_url'); \
    TGZ=$(curl -sSfJLOw '%{filename_effective}' $REL_URL) && \
    tar xzf "$TGZ" --strip-components 1

RUN DEBIAN_FRONTEND=noninteractive $LE_DIR/letsencrypt-auto-source/letsencrypt-auto --os-packages-only

RUN cd $LE_DIR && tools/venv.sh

COPY le.sh /usr/local/bin/le
