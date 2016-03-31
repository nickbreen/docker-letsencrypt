FROM nickbreen/cron:v1.0.0

MAINTAINER Nick Breen <nick@foobar.net.nz>

# Derived from https://letsencrypt.org/getting-started/

# Note: this only exposes the port to other docker containers. You
# still have to bind to 443@host at runtime, as per the ACME spec.
EXPOSE 443

# TODO: make sure --config-dir and --work-dir cannot be changed
# through the CLI (letsencrypt-docker wrapper that uses standalone
# authenticator and text mode only?)
VOLUME /etc/letsencrypt /var/lib/letsencrypt

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qqy git && apt-get clean

RUN git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

RUN /opt/letsencrypt/letsencrypt-auto --help

RUN TMP=$(mktemp -d); git clone https://github.com/nickbreen/letsencrypt_haproxy $TMP && \
  cp -r $TMP/letsencrypt_haproxy $TMP/letsencrypt_haproxy-0.0.1.dist-info \
    /root/.local/share/letsencrypt/lib/python2.7/site-packages/

COPY cli.ini /etc/opt/letsencrypt/

COPY letsinstall.sh /opt/letsencrypt/letsinstall
COPY cron.sh /opt/letsencrypt/cron

ENV XDG_CONFIG_HOME=/etc/opt
