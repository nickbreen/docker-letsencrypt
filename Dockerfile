FROM nickbreen/cron:v1.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

# Derived from https://letsencrypt.org/getting-started/
# Then re-derived from https://letsencrypt.readthedocs.org/en/latest/contributing.html

ENV LE_VER=0.4.2

RUN curl -LsSf https://github.com/letsencrypt/letsencrypt/archive/v$LE_VER.tar.gz | tar zx -C /opt

RUN /opt/letsencrypt-$LE_VER/letsencrypt-auto-source/letsencrypt-auto --os-packages-only

RUN cd /opt/letsencrypt-$LE_VER && tools/venv.sh

ENV COMB_VER=0.1.0

RUN curl -LsSf https://github.com/nickbreen/letsencrypt-combined-installer/archive/v$COMB_VER.tar.gz | tar zx -C /opt

RUN . /opt/letsencrypt-$LE_VER/venv/bin/activate && cd /opt/letsencrypt-combined-installer-$COMB_VER && python setup.py install

ENV XDG_CONFIG_HOME=/etc/opt

COPY cli.ini $XDG_CONFIG_HOME/letsencrypt/

COPY le.sh /usr/local/bin/le

RUN le --help combined:combined
