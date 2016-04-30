FROM nickbreen/cron:v1.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

# Derived from https://letsencrypt.org/getting-started/
# Then re-derived from https://letsencrypt.readthedocs.org/en/latest/contributing.html

ENV LE_VER=0.5.0 LE_DIR=/opt/letsencrypt

# Update this to a release if/when letsencrypt issues a release in github
RUN curl -LsSf https://api.github.com/repos/letsencrypt/letsencrypt/tarball/v$LE_VER | (mkdir -p $LE_DIR && tar zx -C $LE_DIR --strip-components 1)

RUN $LE_DIR/letsencrypt-auto-source/letsencrypt-auto --os-packages-only

RUN cd $LE_DIR && tools/venv.sh

COPY le.sh /usr/local/bin/le
