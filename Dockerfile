FROM nickbreen/cron:v1.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

# Derived from https://letsencrypt.org/getting-started/
# Then re-derived from https://letsencrypt.readthedocs.org/en/latest/contributing.html

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qqy git && apt-get clean

RUN git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

WORKDIR /opt/letsencrypt

RUN letsencrypt-auto-source/letsencrypt-auto --os-packages-only

RUN tools/venv.sh

RUN git clone https://github.com/nickbreen/letsencrypt-combined-installer /opt/letsencrypt-combined-installer

RUN . venv/bin/activate && cd /opt/letsencrypt-combined-installer && python setup.py install

COPY cli.ini /etc/opt/letsencrypt/

ENV XDG_CONFIG_HOME=/etc/opt

RUN . venv/bin/activate && letsencrypt --help combined:combined
